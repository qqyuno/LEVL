// LEVL — Edge Function: Generate Daily Quests
// Called once per day. Returns 3 quests tailored to user's spheres + main goal.
// All tiers: Groq (Llama 3.3 70B, free API).
// Caches results in quest_cache table (key = userId_YYYY-MM-DD).

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";

interface QuestOutput {
  title: string;
  description: string;
  sphere: string;
  isMainGoalTask: boolean;
  xpReward: number;
  estimatedMinutes: number;
  difficulty: "trivial" | "easy" | "medium" | "hard" | "epic";
  tip: string;
}

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
    const cacheKey = `${user.id}_${today}`;

    const { data: cached } = await supabase
      .from("quest_cache")
      .select("quests")
      .eq("user_id", user.id)
      .eq("cache_key", cacheKey)
      .single();

    if (cached?.quests) {
      return jsonResponse({ quests: cached.quests, cached: true });
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
        sphereGoals = goals;
      }
    } catch {
      sphereGoals = [];
    }

    // --- Determine today's sphere rotation ---
    const spheres: string[] = profile.spheres ?? [];
    const dayOfYear = getDayOfYear(new Date());
    const todaySpheres = getRotatedSpheres(spheres, dayOfYear);

    // --- Build prompt ---
    const prompt = buildPrompt(profile, sphereGoals, todaySpheres);

    // --- Call Groq (all tiers) ---
    const rawText = await callGroq(prompt);

    if (!rawText) {
      return jsonResponse({ error: "AI generation failed" }, 502);
    }

    // --- Parse JSON from AI response ---
    const quests = parseQuestsFromResponse(rawText);

    if (!quests || quests.length === 0) {
      console.error("Failed to parse quests from:", rawText);
      return jsonResponse({ error: "Failed to parse AI response" }, 500);
    }

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

    return jsonResponse({ quests, cached: false });
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
  todaySpheres: string[]
): string {
  const name = (profile.name as string) || "Путник";
  const lifeContext = profile.life_context ?? "—";
  const mainGoal = profile.main_goal ?? "—";
  const workStyle = profile.work_style ?? "—";
  const dailyMinutes = profile.daily_minutes ?? 30;
  const level = profile.level ?? 1;
  const streak = profile.current_streak ?? 0;
  const painPoints = profile.pain_points ?? "";

  const sphereLines = todaySpheres
    .map((s) => {
      const label = SPHERE_LABELS[s] ?? s;
      const goal = sphereGoals.find((g) => g.sphere === s)?.goal ?? "—";
      return `  ${label}: хочет "${goal}"`;
    })
    .join("\n");

  const streakLine = streak >= 3
    ? `  Стрик ${streak} дней — держит ритм.`
    : streak === 0
    ? `  Стрик прерван. Нужен лёгкий старт.`
    : `  Стрик ${streak} день — только начинает.`;

  const difficultyHint = (level as number) <= 3
    ? "trivial или easy — человек только входит в ритм, не перегружай"
    : (level as number) <= 7
    ? "easy или medium — уже есть привычка, можно чуть поднять планку"
    : "medium или hard — уже стабилен, давай реальный вызов";

  return `Ты — Система в приложении LEVL. Твоя задача: создать 3 задания на день для конкретного живого человека.

Перед тем как писать задания — ВНИКНИ в этого человека:

КТО ОН:
  Имя: ${name}
  Где сейчас: ${lifeContext}
  Куда идёт (через год): ${mainGoal}
  Как работает: ${workStyle}
  Что его тормозит: ${painPoints || "не указано"}
${streakLine}
  Уровень: ${level}
  Времени в день: ${dailyMinutes} мин

ЧТО РАЗВИВАЕТ СЕГОДНЯ:
${sphereLines}

ПРИНЦИПЫ ПЕРСОНАЛИЗАЦИИ:
- Задания должны звучать как будто написаны лично для ${name}, а не для "среднего пользователя"
- Если человек говорит "хочу запустить стартап" — задание не "поработай над проектом", а "опиши одну функцию MVP и оцени её за 15 минут"
- Если тормозит прокрастинация — задание начинается с самого маленького шага, не с большого
- Если стрик только начался — задание лёгкое, чтобы не сломать momentum
- Учитывай что у него ВСЕГО ${dailyMinutes} минут — задания реалистичные, не амбициозные планы на день

ПРАВИЛА:
1. Верни РОВНО 3 задания в JSON-массиве
2. Задание 1 — прямой конкретный шаг к суперцели "${mainGoal}" (isMainGoalTask: true)
3. Задания 2 и 3 — развитие оставшихся сфер, тоже конкретные (isMainGoalTask: false)
4. Сумма estimatedMinutes ≤ ${dailyMinutes}
5. Сложность: ${difficultyHint}
6. xpReward: trivial=10, easy=25, medium=50, hard=100, epic=200
7. sphere — строго одно из: ${todaySpheres.join(", ")}
8. tip — голос Системы: 1 предложение, без восклицаний, холодно и точно
9. description — конкретное действие, не абстракция. Что именно делать, как именно, сколько
10. Язык: русский

ФОРМАТ ОТВЕТА (только JSON, без markdown, без пояснений):
[
  {
    "title": "короткое название действия",
    "description": "конкретно что делать — шаг за шагом если нужно",
    "sphere": "ключ_сферы",
    "isMainGoalTask": true,
    "xpReward": 25,
    "estimatedMinutes": 10,
    "difficulty": "easy",
    "tip": "Одно предложение от Системы."
  }
]`;
}

async function callGroq(prompt: string): Promise<string> {
  const apiKey = Deno.env.get("GROQ_API_KEY");
  if (!apiKey) throw new Error("GROQ_API_KEY not configured");

  const response = await fetch(GROQ_API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: "llama-3.3-70b-versatile",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.7,
      max_tokens: 1024,
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    console.error("Groq API error:", errText);
    return "";
  }

  const data = await response.json();
  return data.choices?.[0]?.message?.content ?? "";
}

function parseQuestsFromResponse(text: string): QuestOutput[] | null {
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
