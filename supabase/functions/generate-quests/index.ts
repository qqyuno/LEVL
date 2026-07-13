// LEVL — Edge Function: Generate Daily Quests
// Called once per day. Returns 3 quests tailored to user's spheres + main goal.
// All tiers: Groq (Llama 3.3 70B, free API).
// Caches results in quest_cache table (key = userId_YYYY-MM-DD).

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  buildFallbackQuests,
  buildGenerationPlan,
  normalizeQuests,
  type GenerationPlan,
  type QuestHistoryItem,
  type QuestOutput,
} from "./quest_engine.ts";

const GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";

serve(async (req: Request) => {
  try {
    // --- Auth ---
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Missing Authorization header" }, 401);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    // --- Check cache ---
    const today = new Date().toISOString().split("T")[0]; // YYYY-MM-DD
    const cacheKey = `${user.id}_${today}_v2`;

    const { data: cached } = await supabase
      .from("quest_cache")
      .select("quests")
      .eq("user_id", user.id)
      .eq("cache_key", cacheKey)
      .single();

    if (cached?.quests) {
      return jsonResponse({
        quests: cached.quests,
        cached: true,
        engineVersion: "2.0",
      });
    }

    // --- Parse client context (Flutter sends this as fallback for new/offline users) ---
    const body = await req.json().catch(() => ({}));
    const clientContext = body.userContext ?? {};

    // --- Load profile from Supabase (source of truth) ---
    const { data: supabaseProfile } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .single();

    // Merge: Supabase wins, Flutter context fills gaps (covers first-launch before sync)
    const profile = supabaseProfile ?? (Object.keys(clientContext).length > 0 ? {
      name: clientContext.name ?? "Путник",
      life_context: clientContext.lifeContext ?? "—",
      main_goal: clientContext.mainGoal ?? "—",
      work_style: clientContext.workStyle ?? "—",
      daily_minutes: clientContext.dailyMinutes ?? 30,
      level: clientContext.level ?? 1,
      current_streak: clientContext.streak ?? 0,
      spheres: clientContext.spheres
        ? clientContext.spheres.split(",").map((s: string) => s.trim()).filter(Boolean)
        : [],
      goals: clientContext.goals ?? [],
      pain_points: clientContext.painPoints ?? "",
    } : null);

    if (!profile) {
      return jsonResponse({ error: "Profile not found" }, 404);
    }

    // --- Parse sphere goals ---
    let sphereGoals: { sphere: string; goal: string }[] = [];
    try {
      const goals = profile.goals;
      if (typeof goals === "string") {
        sphereGoals = JSON.parse(goals);
      } else if (Array.isArray(goals)) {
        sphereGoals = goals.flatMap((goal: unknown) => {
          if (typeof goal === "object" && goal !== null) {
            const item = goal as Record<string, unknown>;
            if (typeof item.sphere === "string" && typeof item.goal === "string") {
              return [{ sphere: item.sphere, goal: item.goal }];
            }
          }
          if (typeof goal === "string") {
            const separator = goal.indexOf(":");
            if (separator > 0) {
              return [{
                sphere: goal.slice(0, separator).trim(),
                goal: goal.slice(separator + 1).trim(),
              }];
            }
          }
          return [];
        });
      }
    } catch {
      sphereGoals = [];
    }

    // --- Determine today's sphere rotation ---
    const spheres: string[] = profile.spheres?.length > 0
      ? profile.spheres
      : ["discipline"];
    const dayOfYear = getDayOfYear(new Date());
    const todaySpheres = getRotatedSpheres(spheres, dayOfYear);

    // --- Load recent behavior before asking AI for more work ---
    const historyStart = new Date(Date.now() - 14 * 24 * 60 * 60 * 1000)
      .toISOString();
    const { data: historyRows } = await supabase
      .from("quests")
      .select("title,status,category,estimated_minutes,created_at")
      .eq("user_id", user.id)
      .gte("created_at", historyStart)
      .order("created_at", { ascending: false })
      .limit(42);
    const history = (historyRows ?? []) as QuestHistoryItem[];
    const plan = buildGenerationPlan(
      Number(profile.daily_minutes ?? 30),
      Number(profile.current_streak ?? 0),
      history,
    );

    // --- Generate, validate and retry once if quality is weak ---
    const prompt = buildPrompt(
      profile,
      sphereGoals,
      todaySpheres,
      plan,
      history,
    );
    let rawText = await callGroq(prompt);
    let normalized = normalizeQuests(parseQuestsFromResponse(rawText), {
      allowedSpheres: todaySpheres,
      recentTitles: history.map((item) => item.title),
      plan,
    });

    if (!normalized.valid) {
      console.warn("Quest validation failed:", normalized.issues);
      const correction = normalized.issues
        .slice(0, 8)
        .map((issue) => `- ${issue}`)
        .join("\n");
      rawText = await callGroq(
        `${prompt}\n\nПРЕДЫДУЩАЯ ПОПЫТКА НЕ ПРОШЛА ПРОВЕРКУ:\n${correction}\nСоздай новый набор, исправив каждую проблему.`,
      );
      normalized = normalizeQuests(parseQuestsFromResponse(rawText), {
        allowedSpheres: todaySpheres,
        recentTitles: history.map((item) => item.title),
        plan,
      });
    }

    const usedFallback = !normalized.valid;
    const quests = usedFallback
      ? buildFallbackQuests(
          String(profile.main_goal ?? "главная цель"),
          todaySpheres,
          plan,
        )
      : normalized.quests;

    // --- Save to quest_cache ---
    await supabase.from("quest_cache").upsert({
      user_id: user.id,
      cache_key: cacheKey,
      quests: quests,
      generated_at: new Date().toISOString(),
    });

    // --- Save individual quests ---
    const questRows = quests.map((q: QuestOutput, i: number) => ({
      id: `${cacheKey}_${i}`,
      user_id: user.id,
      title: q.title,
      description: q.description,
      category: q.sphere,
      xp: q.xpReward,
      difficulty: q.difficulty,
      type: q.isMainGoalTask ? "main" : "daily",
      tip: q.tip,
      status: "pending",
      estimated_minutes: q.estimatedMinutes,
      created_at: new Date().toISOString(),
    }));

    await supabase.from("quests").upsert(questRows);

    return jsonResponse({
      quests,
      cached: false,
      engineVersion: "2.0",
      generationMode: plan.mode,
      fallback: usedFallback,
    });
  } catch (err) {
    console.error("Edge function error:", err);
    return jsonResponse({ error: "Internal server error" }, 500);
  }
});

// --- Helpers ---

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}

function getDayOfYear(date: Date): number {
  const start = new Date(date.getFullYear(), 0, 0);
  const diff = date.getTime() - start.getTime();
  return Math.floor(diff / (1000 * 60 * 60 * 24));
}

/**
 * Rotation logic:
 * - 2 spheres → both every day
 * - 3 spheres → all 3 every day
 * - 4 spheres → 3 per day, rotating which one sits out
 */
function getRotatedSpheres(spheres: string[], dayOfYear: number): string[] {
  if (spheres.length <= 3) return spheres;
  // 4 spheres: skip one per day in rotation
  const skipIndex = dayOfYear % spheres.length;
  return spheres.filter((_, i) => i !== skipIndex);
}

const SPHERE_LABELS: Record<string, string> = {
  discipline: "Дисциплина",
  knowledge: "Знания",
  relations: "Отношения",
  energy: "Энергия",
  will: "Воля",
  wisdom: "Мудрость",
};

function buildPrompt(
  profile: Record<string, unknown>,
  sphereGoals: { sphere: string; goal: string }[],
  todaySpheres: string[],
  plan: GenerationPlan,
  history: QuestHistoryItem[],
): string {
  const name = (profile.name as string) || "Путник";
  const lifeContext = profile.life_context ?? "—";
  const mainGoal = profile.main_goal ?? "—";
  const workStyle = profile.work_style ?? "—";
  const dailyMinutes = profile.daily_minutes ?? 30;
  const streak = profile.current_streak ?? 0;
  const painPoints = profile.pain_points ?? "";

  const sphereLines = todaySpheres
    .map((s) => {
      const label = SPHERE_LABELS[s] ?? s;
      const goal = sphereGoals.find((g) => g.sphere === s)?.goal ?? "—";
      return `  ${label}: хочет "${goal}"`;
    })
    .join("\n");

  const recentLines = history.length === 0
    ? "  Истории пока нет."
    : history.slice(0, 12).map((item) =>
      `  [${item.status}] ${item.title}`
    ).join("\n");
  const completionPercent = Math.round(plan.completionRate * 100);

  return `Ты — планировщик действий в приложении LEVL. Создай ровно три небольших задания, которые двигают человека к целям и снижают сопротивление началу.

КТО ОН:
  Имя: ${name}
  Где сейчас: ${lifeContext}
  Куда идёт (через год): ${mainGoal}
  Как работает: ${workStyle}
  Что его тормозит: ${painPoints || "не указано"}
  Серия: ${streak} дней
  Заявленное время: ${dailyMinutes} мин
  Выполнение последних заданий: ${completionPercent}%
  Режим нагрузки: ${plan.mode}

РЕШЕНИЕ ПЛАНИРОВЩИКА:
  ${plan.guidance}
  Реальный бюджет на сегодня: ${plan.timeBudget} мин
  Первое задание: не более ${plan.firstQuestMaxMinutes} мин
  Допустимая сложность: ${plan.allowedDifficulties.join(", ")}

ЧТО РАЗВИВАЕТ СЕГОДНЯ:
${sphereLines}

ПОСЛЕДНИЕ ЗАДАНИЯ — НЕ ПОВТОРЯЙ ИХ И НЕ ПЕРЕФРАЗИРУЙ:
${recentLines}

ПРИНЦИПЫ:
- Не мотивируй словами и не стыди. Уменьшай порог входа.
- Каждое задание начинается с наблюдаемого действия: открыть, написать, отправить, выбрать, пройти, выполнить.
- У каждого задания должен быть видимый финиш за сегодня: запись, решение, сообщение, подход, готовый артефакт.
- Не используй формулировки "поработай над", "займись", "подумай о", "стань лучше".
- description объясняет одно действие и критерий готовности. Не создавай многоступенчатый план на будущее.
- tip — минимальная версия на случай сильного сопротивления, которую можно начать меньше чем за минуту.
- Задание должно быть уважительным к человеку, который много прокрастинирует: маленьким, но не бессмысленным.

ПРАВИЛА:
1. Верни РОВНО 3 задания в JSON-массиве
2. Задание 1 — прямой конкретный шаг к суперцели "${mainGoal}" (isMainGoalTask: true)
3. Задания 2 и 3 — развитие оставшихся сфер, тоже конкретные (isMainGoalTask: false)
4. Сумма estimatedMinutes ≤ ${plan.timeBudget}; первое ≤ ${plan.firstQuestMaxMinutes}
5. Сложность — только ${plan.allowedDifficulties.join(" или ")}
6. xpReward: trivial=10, easy=25, medium=50, hard=100, epic=200
7. sphere — строго одно из: ${todaySpheres.join(", ")}
8. tip — минимальный старт, одно предложение без восклицаний
9. description — конкретное действие плюс проверяемый результат
10. Язык: русский

ФОРМАТ ОТВЕТА (только JSON, без markdown, без пояснений):
[
  {
    "title": "короткое название действия",
    "description": "одно действие и конкретный критерий готовности",
    "sphere": "ключ_сферы",
    "isMainGoalTask": true,
    "xpReward": 25,
    "estimatedMinutes": 10,
    "difficulty": "easy",
    "tip": "Минимальная версия действия, если трудно начать."
  }
]`;
}

async function callGroq(prompt: string): Promise<string> {
  const apiKey = Deno.env.get("GROQ_API_KEY");
  if (!apiKey) {
    console.error("GROQ_API_KEY not configured");
    return "";
  }

  try {
    const response = await fetch(GROQ_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: "llama-3.3-70b-versatile",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.55,
        max_tokens: 1200,
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error("Groq API error:", errText);
      return "";
    }

    const data = await response.json();
    return data.choices?.[0]?.message?.content ?? "";
  } catch (error) {
    console.error("Groq request failed:", error);
    return "";
  }
}

function parseQuestsFromResponse(text: string): unknown[] | null {
  try {
    // Try direct parse
    const parsed = JSON.parse(text);
    if (Array.isArray(parsed)) return parsed;
    return null;
  } catch {
    // Try to extract JSON array from text
    const match = text.match(/\[[\s\S]*\]/);
    if (match) {
      try {
        return JSON.parse(match[0]);
      } catch {
        return null;
      }
    }
    return null;
  }
}
