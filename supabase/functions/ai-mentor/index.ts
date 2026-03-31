// LEVL — Edge Function: AI Mentor Chat
// PRO-only feature. Uses Claude Sonnet for conversational mentoring.
// Receives chat history + user progress context, returns System's response.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages";

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
    const clientContext = body.userContext ?? {}; // context sent from Flutter (offline-first fallback)
    const userMessage = messages[messages.length - 1]?.content ?? "";

    if (!userMessage.trim()) {
      return jsonResponse({ error: "Empty message" }, 400);
    }

    // --- Load profile for context (Supabase is source of truth; Flutter context is fallback) ---
    const { data: supabaseProfile } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .single();

    // Merge: Supabase wins on overlap, Flutter fills the gaps
    const profile = supabaseProfile ?? (Object.keys(clientContext).length > 0 ? {
      name: clientContext.name,
      level: clientContext.level,
      xp: clientContext.xp,
      current_streak: clientContext.streak,
      main_goal: clientContext.mainGoal,
      life_context: clientContext.lifeContext,
      work_style: clientContext.workStyle,
      daily_minutes: clientContext.dailyMinutes,
      spheres: clientContext.spheres ? clientContext.spheres.split(",").map((s: string) => s.trim()) : [],
      goals: clientContext.goals ?? [],
    } : null);

    // --- Load today's quests ---
    const today = new Date().toISOString().split("T")[0];
    const { data: quests } = await supabase
      .from("quests")
      .select("title, status, category, xp")
      .eq("user_id", user.id)
      .gte("created_at", today);

    const completedToday = quests?.filter((q: any) => q.status === "completed") ?? [];
    const pendingToday = quests?.filter((q: any) => q.status === "pending") ?? [];

    // --- Build system prompt ---
    const systemPrompt = buildSystemPrompt(profile, completedToday, pendingToday);

    // --- Call Claude API ---
    const anthropicKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!anthropicKey) {
      return jsonResponse({ error: "ANTHROPIC_API_KEY not configured" }, 500);
    }

    // Build messages for Claude (last 20 messages max for context window)
    const chatHistory = messages.slice(-20).map((m) => ({
      role: m.role,
      content: m.content,
    }));

    const claudeResponse = await fetch(ANTHROPIC_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": anthropicKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-sonnet-4-20250514",
        max_tokens: 512,
        system: systemPrompt,
        messages: chatHistory,
      }),
    });

    if (!claudeResponse.ok) {
      const errText = await claudeResponse.text();
      console.error("Claude API error:", errText);
      return jsonResponse({ error: "AI response failed" }, 502);
    }

    const claudeData = await claudeResponse.json();
    const reply = claudeData.content?.[0]?.text ?? "";

    return jsonResponse({ reply });
  } catch (err) {
    console.error("AI Mentor error:", err);
    return jsonResponse({ error: "Internal server error" }, 500);
  }
});

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
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

  const completedList = completedToday.length > 0
    ? completedToday.map((q: any) => `  ✓ ${q.title} (+${q.xp} XP)`).join("\n")
    : "  Пока ничего.";

  const pendingList = pendingToday.length > 0
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
- Сферы: ${Array.isArray(spheres) ? spheres.join(", ") : spheres}

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
6. Ты знаешь прогресс пользователя — используй это.`;
}
