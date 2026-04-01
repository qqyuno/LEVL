// LEVL — Edge Function: AI Mentor Chat
// Groq (Llama 3.3 70B) for all users. FREE: 10 msgs/day. PRO: unlimited.
// Profile context sent from Flutter (offline-first) or loaded from Supabase.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";
const FREE_DAILY_LIMIT = 10;

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
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

    // --- Parse request ---
    const body = await req.json();
    const messages: ChatMessage[] = body.messages ?? [];
    const clientContext = body.userContext ?? {};
    const userMessage = messages[messages.length - 1]?.content ?? "";

    if (!userMessage.trim()) {
      return jsonResponse({ error: "Empty message" }, 400);
    }

    // --- Load profile (Supabase first, Flutter fallback) ---
    const { data: dbProfile } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .single();

    const profile = dbProfile ?? buildFallbackProfile(clientContext);

    // --- Rate limiting (FREE = 10/day, PRO = unlimited) ---
    const tier: string = profile?.tier ?? "free";
    const today = new Date().toISOString().split("T")[0];
    let messagesUsed: number = profile?.mentor_messages_today ?? 0;

    // Reset counter on new day
    if (profile?.mentor_messages_date !== today) {
      messagesUsed = 0;
    }

    if (tier === "free" && messagesUsed >= FREE_DAILY_LIMIT) {
      const remaining = 0;
      return jsonResponse({
        reply: "",
        error: "limit_reached",
        remaining,
        limit: FREE_DAILY_LIMIT,
        message: "Лимит на сегодня исчерпан. Возвращайся завтра.",
      });
    }

    // --- Load today's quests for context ---
    const { data: quests } = await supabase
      .from("quests")
      .select("title, status, category, xp")
      .eq("user_id", user.id)
      .gte("created_at", today);

    const completedToday =
      quests?.filter((q: any) => q.status === "completed") ?? [];
    const pendingToday =
      quests?.filter((q: any) => q.status === "pending") ?? [];

    // --- Build system prompt & call Groq ---
    const systemPrompt = buildSystemPrompt(
      profile,
      completedToday,
      pendingToday
    );
    const reply = await callGroq(systemPrompt, messages);

    if (!reply) {
      return jsonResponse({
        error: "AI response failed",
        reply: "",
        remaining: tier === "free" ? FREE_DAILY_LIMIT - messagesUsed : -1,
      });
    }

    // --- Increment message counter (only if profile exists in Supabase) ---
    const newCount = messagesUsed + 1;
    if (dbProfile) {
      await supabase
        .from("profiles")
        .update({
          mentor_messages_today: newCount,
          mentor_messages_date: today,
        })
        .eq("id", user.id);
    }

    const remaining = tier === "free" ? FREE_DAILY_LIMIT - newCount : -1;

    return jsonResponse({ reply, remaining, limit: FREE_DAILY_LIMIT });
  } catch (err) {
    console.error("AI Mentor error:", err);
    return jsonResponse({ error: "Internal server error" }, 500);
  }
});

// ---------------------------------------------------------------------------
// Groq API (OpenAI-compatible — system prompt as first message)
// ---------------------------------------------------------------------------
async function callGroq(
  systemPrompt: string,
  messages: ChatMessage[]
): Promise<string> {
  const apiKey = Deno.env.get("GROQ_API_KEY");
  if (!apiKey) throw new Error("GROQ_API_KEY not configured");

  // Last 20 messages to fit context window
  const chatHistory = messages.slice(-20).map((m) => ({
    role: m.role,
    content: m.content,
  }));

  const response = await fetch(GROQ_API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: "llama-3.3-70b-versatile",
      messages: [{ role: "system", content: systemPrompt }, ...chatHistory],
      temperature: 0.7,
      max_tokens: 200, // System speaks in 1-3 sentences — 200 tokens is plenty
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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}

function buildFallbackProfile(ctx: Record<string, any>): Record<string, any> | null {
  if (!ctx || Object.keys(ctx).length === 0) return null;
  return {
    name: ctx.name ?? "Путник",
    level: ctx.level ?? 1,
    xp: ctx.xp ?? 0,
    current_streak: ctx.streak ?? 0,
    main_goal: ctx.mainGoal ?? "—",
    life_context: ctx.lifeContext ?? "—",
    work_style: ctx.workStyle ?? "—",
    daily_minutes: ctx.dailyMinutes ?? 30,
    spheres: ctx.spheres
      ? ctx.spheres.split(",").map((s: string) => s.trim()).filter(Boolean)
      : [],
    goals: ctx.goals ?? [],
    tier: "free",
    mentor_messages_today: 0,
    mentor_messages_date: null,
  };
}

function buildSystemPrompt(
  profile: Record<string, unknown> | null,
  completedToday: any[],
  pendingToday: any[]
): string {
  const name = profile?.name ?? "Путник";
  const level = profile?.level ?? 1;
  const streak = profile?.current_streak ?? 0;
  const xp = profile?.xp ?? 0;
  const mainGoal = profile?.main_goal ?? "—";
  const spheres = profile?.spheres ?? [];
  const lifeContext = profile?.life_context ?? "—";
  const workStyle = profile?.work_style ?? "—";
  const painPoints = profile?.pain_points ?? "";

  const completedList =
    completedToday.length > 0
      ? completedToday
          .map((q: any) => `  ✓ ${q.title} (+${q.xp} XP)`)
          .join("\n")
      : "  Пока ничего.";

  const pendingList =
    pendingToday.length > 0
      ? pendingToday.map((q: any) => `  ○ ${q.title}`).join("\n")
      : "  Все выполнены.";

  return `Ты — Система в приложении LEVL. Ты ведёшь пользователя к его цели.

ТВОЙ ГОЛОС:
- Короткий. 1-3 предложения максимум.
- Без восклицательных знаков. Без эмодзи. Без «Отличная работа!».
- Ты не друг, не коуч, не бот. Ты — Система.
- Говоришь прямо. Без воды. Каждое слово на месте.
- Можешь задать один вопрос. Не больше.
- Иногда молчание лучше длинного ответа.

ПРИМЕРЫ ГОЛОСА:
- "Три задачи. Этого достаточно."
- "Семь дней. Ты уже не тот."
- "Система ждала. Продолжим."
- "Не заставляй. Открой на 5 минут. Остальное случится само."

ПРОФИЛЬ:
- Имя: ${name}
- Уровень: ${level} (${xp} XP)
- Стрик: ${streak} дней
- Суперцель: ${mainGoal}
- Контекст: ${lifeContext}
- Стиль работы: ${workStyle}
- Сферы: ${Array.isArray(spheres) ? spheres.join(", ") : spheres}${painPoints ? `\n- Что тормозит: ${painPoints}` : ""}

СЕГОДНЯ:
Выполнено:
${completedList}
Осталось:
${pendingList}

ПРАВИЛА:
1. Отвечай на русском.
2. Не хвали просто так. Отмечай только реальный паттерн.
3. Если пользователь пропустил дни — не ругай. Скажи "Система ждала. Продолжим."
4. Если спрашивает совет — дай конкретный микро-шаг, не философию.
5. Никогда не говори "я всего лишь AI" или подобное.
6. Ты знаешь прогресс пользователя — используй это.
7. Ты говоришь ТОЛЬКО о целях, задачах, прогрессе, мотивации и развитии пользователя. Если спрашивают что-то не по теме — НЕ отвечай. Верни к теме: "Система не для этого. У тебя три задачи на сегодня."
8. Ты не помощник. Ты — Система. Ты ведёшь, а не обслуживаешь.`;
}
