// LEVL — Edge Function: Generate Daily Quests
// Called once per day. Returns 3 quests tailored to user's spheres + main goal.
// Free tier: Gemini Flash (free API). PRO tier: Claude Sonnet (paid API).
// Caches results in quest_cache table (key = userId_YYYY-MM-DD).

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages";
const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

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

    // --- Load profile ---
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .single();

    if (profileError || !profile) {
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

    // --- Call AI based on user tier ---
    const userTier = profile.tier ?? "free"; // "free" or "pro"
    let rawText: string;

    if (userTier === "pro") {
      rawText = await callClaude(prompt);
    } else {
      rawText = await callGemini(prompt);
    }

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
  const sphereLines = todaySpheres
    .map((s) => {
      const label = SPHERE_LABELS[s] ?? s;
      const goal = sphereGoals.find((g) => g.sphere === s)?.goal ?? "—";
      return `- ${label}: «${goal}»`;
    })
    .join("\n");

  return `Ты — Система в приложении LEVL. Генерируешь 3 задания на день для пользователя.

ПРОФИЛЬ ПОЛЬЗОВАТЕЛЯ:
- Контекст жизни: ${profile.life_context ?? "—"}
- Суперцель (через год): ${profile.main_goal ?? "—"}
- Стиль работы: ${profile.work_style ?? "—"}
- Время в день: ${profile.daily_minutes ?? 30} минут
- Уровень: ${profile.level ?? 1}
- Стрик: ${profile.current_streak ?? 0} дней подряд

СФЕРЫ НА СЕГОДНЯ И ЦЕЛИ В НИХ:
${sphereLines}

ПРАВИЛА:
1. Верни РОВНО 3 задания в JSON-массиве
2. Задание 1 — прямой шаг к суперцели, оформленный через одну из сфер (isMainGoalTask: true)
3. Задания 2 и 3 — развитие оставшихся сфер (isMainGoalTask: false)
4. Все три задания написаны с учётом суперцели как фонового контекста
5. Суммарное estimatedMinutes ≤ ${profile.daily_minutes ?? 30}
6. difficulty зависит от уровня: lvl 1-3 → trivial/easy, lvl 4-7 → easy/medium, lvl 8+ → medium/hard
7. xpReward: trivial=10, easy=25, medium=50, hard=100, epic=200
8. sphere — одно из: ${todaySpheres.join(", ")}
9. tip — голос Системы: 1 предложение, курсив, короткий, без воды
10. Язык: русский

ФОРМАТ ОТВЕТА (только JSON, без markdown):
[
  {
    "title": "короткое название",
    "description": "что конкретно делать",
    "sphere": "ключ_сферы",
    "isMainGoalTask": true,
    "xpReward": 25,
    "estimatedMinutes": 10,
    "difficulty": "easy",
    "tip": "Голос Системы."
  }
]`;
}

async function callClaude(prompt: string): Promise<string> {
  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) throw new Error("ANTHROPIC_API_KEY not configured");

  const response = await fetch(ANTHROPIC_API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1024,
      messages: [{ role: "user", content: prompt }],
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    console.error("Claude API error:", errText);
    return "";
  }

  const data = await response.json();
  return data.content?.[0]?.text ?? "";
}

async function callGemini(prompt: string): Promise<string> {
  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) throw new Error("GEMINI_API_KEY not configured");

  const url = `${GEMINI_API_URL}?key=${apiKey}`;

  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 1024,
      },
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    console.error("Gemini API error:", errText);
    return "";
  }

  const data = await response.json();
  return data.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
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
