export type QuestDifficulty =
  | "trivial"
  | "easy"
  | "medium"
  | "hard"
  | "epic";

export type QuestVerificationType = "self_confirm" | "timer";

export interface QuestOutput {
  title: string;
  description: string;
  sphere: string;
  isMainGoalTask: boolean;
  xpReward: number;
  estimatedMinutes: number;
  difficulty: QuestDifficulty;
  tip: string;
  successCriterion: string;
  verificationType: QuestVerificationType;
}

export interface QuestHistoryItem {
  title: string;
  status: string;
  category?: string | null;
  estimated_minutes?: number | null;
  created_at?: string | null;
}

export type GenerationMode = "restart" | "steady" | "momentum";

export interface GenerationPlan {
  mode: GenerationMode;
  completionRate: number;
  timeBudget: number;
  firstQuestMaxMinutes: number;
  allowedDifficulties: QuestDifficulty[];
  guidance: string;
}

export type QuestFeedbackReason = "too_hard" | "not_relevant" | "no_time";

export interface QuestFeedbackSummary {
  total: number;
  tooHard: number;
  notRelevant: number;
  noTime: number;
  dominantReason: QuestFeedbackReason | null;
}

export interface NormalizeOptions {
  allowedSpheres: string[];
  recentTitles: string[];
  plan: GenerationPlan;
}

export interface NormalizeResult {
  quests: QuestOutput[];
  issues: string[];
  valid: boolean;
}

const XP_BY_DIFFICULTY: Record<QuestDifficulty, number> = {
  trivial: 10,
  easy: 25,
  medium: 50,
  hard: 100,
  epic: 200,
};

const DIFFICULTIES: QuestDifficulty[] = [
  "trivial",
  "easy",
  "medium",
  "hard",
  "epic",
];

const VAGUE_PHRASES = [
  "поработай над",
  "займись",
  "подумай о",
  "развивай",
  "стань лучше",
  "сделай прогресс",
];

const SELF_CONFIRM_HINTS = [
  "напиши",
  "запиши",
  "отправ",
  "позвони",
  "выбери",
  "определи",
  "создай",
  "составь",
  "подготов",
  "реши",
  "оплати",
  "забронируй",
  "сохрани",
];

const TIMER_HINTS = [
  "трениров",
  "размин",
  "читай",
  "прочитай",
  "убор",
  "медит",
  "фокус",
  "работай",
  "учись",
  "гуля",
  "пройди",
  "практик",
];

export function buildGenerationPlan(
  dailyMinutes: number,
  streak: number,
  history: QuestHistoryItem[],
): GenerationPlan {
  const relevant = history.filter((item) =>
    ["completed", "pending", "skipped"].includes(item.status)
  );
  const completed = relevant.filter((item) => item.status === "completed").length;
  const completionRate = relevant.length === 0 ? 0.5 : completed / relevant.length;
  const safeDailyMinutes = clampInteger(dailyMinutes, 15, 180, 30);

  if (streak === 0 || completionRate < 0.35) {
    return {
      mode: "restart",
      completionRate,
      timeBudget: Math.min(safeDailyMinutes, 30),
      firstQuestMaxMinutes: 7,
      allowedDifficulties: ["trivial", "easy"],
      guidance:
        "Человек буксует. Первое действие должно запускаться меньше чем за минуту и завершаться за 5–7 минут. Никакого чувства долга и больших планов.",
    };
  }

  if (completionRate < 0.7 || streak < 7) {
    return {
      mode: "steady",
      completionRate,
      timeBudget: Math.min(safeDailyMinutes, 45),
      firstQuestMaxMinutes: 12,
      allowedDifficulties: ["easy", "medium"],
      guidance:
        "Ритм формируется. Дай один быстрый результат и два посильных действия без перегруза.",
    };
  }

  return {
    mode: "momentum",
    completionRate,
    timeBudget: safeDailyMinutes,
    firstQuestMaxMinutes: Math.min(20, Math.max(10, Math.floor(safeDailyMinutes / 3))),
    allowedDifficulties: ["medium", "hard"],
    guidance:
      "Ритм устойчив. Можно дать ощутимый вызов, но каждое задание всё равно должно иметь конкретный финиш за сегодня.",
  };
}

export function summarizeQuestFeedback(
  reasons: string[],
): QuestFeedbackSummary {
  const summary: QuestFeedbackSummary = {
    total: 0,
    tooHard: 0,
    notRelevant: 0,
    noTime: 0,
    dominantReason: null,
  };

  for (const reason of reasons) {
    if (reason === "too_hard") summary.tooHard += 1;
    if (reason === "not_relevant") summary.notRelevant += 1;
    if (reason === "no_time") summary.noTime += 1;
  }
  summary.total = summary.tooHard + summary.notRelevant + summary.noTime;

  const ranked: [QuestFeedbackReason, number][] = [
    ["too_hard", summary.tooHard],
    ["not_relevant", summary.notRelevant],
    ["no_time", summary.noTime],
  ].sort((a, b) => b[1] - a[1]);
  if (ranked[0][1] >= 2 && ranked[0][1] > ranked[1][1]) {
    summary.dominantReason = ranked[0][0];
  }

  return summary;
}

export function adaptPlanToFeedback(
  plan: GenerationPlan,
  feedback: QuestFeedbackSummary,
): GenerationPlan {
  if (feedback.dominantReason === "no_time") {
    return {
      ...plan,
      timeBudget: Math.min(plan.timeBudget, 20),
      firstQuestMaxMinutes: Math.min(plan.firstQuestMaxMinutes, 5),
      allowedDifficulties: ["trivial", "easy"],
      guidance:
        `${plan.guidance} Пользователь несколько раз указал, что задания не помещаются во время. Убери лишние шаги и дай действия, которые реально закрыть в коротком окне.`,
    };
  }

  if (feedback.dominantReason === "too_hard") {
    return {
      ...plan,
      firstQuestMaxMinutes: Math.min(plan.firstQuestMaxMinutes, 7),
      allowedDifficulties: plan.mode === "momentum"
        ? ["easy", "medium"]
        : ["trivial", "easy"],
      guidance:
        `${plan.guidance} Пользователь несколько раз отметил задания как слишком сложные. Сохрани пользу, но сократи действие до одного ясного шага без подготовки.`,
    };
  }

  if (feedback.dominantReason === "not_relevant") {
    return {
      ...plan,
      guidance:
        `${plan.guidance} Пользователь несколько раз не увидел связи с целью. Каждое задание должно прямо опираться на его главную или выбранную сферную цель; не добавляй общие привычки ради активности.`,
    };
  }

  return plan;
}

export function normalizeQuests(
  raw: unknown,
  options: NormalizeOptions,
): NormalizeResult {
  const issues: string[] = [];
  if (options.allowedSpheres.length === 0) {
    return {
      quests: [],
      issues: ["Для генерации нужна хотя бы одна сфера."],
      valid: false,
    };
  }
  if (!Array.isArray(raw) || raw.length !== 3) {
    return {
      quests: [],
      issues: ["Нужно вернуть ровно три задания."],
      valid: false,
    };
  }

  const parsed = raw.map((item, index) =>
    normalizeSingleQuest(item, index, options, issues)
  );
  if (parsed.some((quest) => quest === null)) {
    return { quests: [], issues, valid: false };
  }

  const quests = parsed as QuestOutput[];
  const allTitles = [...options.recentTitles];
  for (const quest of quests) {
    if (allTitles.some((title) => areTitlesSimilar(quest.title, title))) {
      issues.push(`Повтор или слишком похожее задание: "${quest.title}".`);
    }
    allTitles.push(quest.title);
  }

  fitTimeBudget(quests, options.plan.timeBudget, options.plan.firstQuestMaxMinutes);

  return {
    quests,
    issues,
    valid: issues.length === 0,
  };
}

function normalizeSingleQuest(
  raw: unknown,
  index: number,
  options: NormalizeOptions,
  issues: string[],
): QuestOutput | null {
  if (!isRecord(raw)) {
    issues.push(`Задание ${index + 1} не является объектом.`);
    return null;
  }

  const title = cleanText(raw.title, 80);
  const description = cleanText(raw.description, 520);
  const tip = cleanText(raw.tip, 180);
  const successCriterion = cleanText(raw.successCriterion, 220);
  const sphere = cleanText(raw.sphere, 40);

  if (title.length < 4) issues.push(`У задания ${index + 1} нет ясного названия.`);
  if (description.length < 16) {
    issues.push(`У задания "${title || index + 1}" нет конкретного действия.`);
  }
  if (tip.length < 6) issues.push(`У задания "${title || index + 1}" нет микрошага.`);
  if (successCriterion.length < 12) {
    issues.push(`У задания "${title || index + 1}" нет критерия готовности.`);
  }
  if (!options.allowedSpheres.includes(sphere)) {
    issues.push(`Недопустимая сфера "${sphere}".`);
  }
  if (VAGUE_PHRASES.some((phrase) => `${title} ${description}`.toLowerCase().includes(phrase))) {
    issues.push(`Слишком абстрактная формулировка: "${title}".`);
  }

  const requestedDifficulty = DIFFICULTIES.includes(raw.difficulty as QuestDifficulty)
    ? raw.difficulty as QuestDifficulty
    : options.plan.allowedDifficulties[0];
  const difficulty = options.plan.allowedDifficulties.includes(requestedDifficulty)
    ? requestedDifficulty
    : options.plan.allowedDifficulties[0];

  return {
    title,
    description,
    sphere: options.allowedSpheres.includes(sphere)
      ? sphere
      : options.allowedSpheres[index % options.allowedSpheres.length],
    isMainGoalTask: index === 0,
    xpReward: XP_BY_DIFFICULTY[difficulty],
    estimatedMinutes: clampInteger(raw.estimatedMinutes, 5, 90, 10),
    difficulty,
    tip,
    successCriterion,
    verificationType: chooseVerificationType(
      raw.verificationType,
      title,
      description,
      successCriterion,
    ),
  };
}

export function chooseVerificationType(
  requested: unknown,
  title: string,
  description: string,
  successCriterion: string,
): QuestVerificationType {
  const text = `${title} ${description} ${successCriterion}`.toLowerCase();
  if (SELF_CONFIRM_HINTS.some((hint) => text.includes(hint))) {
    return "self_confirm";
  }
  if (TIMER_HINTS.some((hint) => text.includes(hint))) {
    return "timer";
  }
  return requested === "timer" ? "timer" : "self_confirm";
}

function fitTimeBudget(
  quests: QuestOutput[],
  timeBudget: number,
  firstQuestMaxMinutes: number,
): void {
  quests[0].estimatedMinutes = Math.min(
    quests[0].estimatedMinutes,
    firstQuestMaxMinutes,
  );

  const minimumTotal = quests.length * 5;
  const budget = Math.max(minimumTotal, timeBudget);
  const requestedTotal = quests.reduce((sum, quest) => sum + quest.estimatedMinutes, 0);
  if (requestedTotal <= budget) return;

  let remaining = budget;
  quests.forEach((quest, index) => {
    const remainingQuests = quests.length - index - 1;
    const reserved = remainingQuests * 5;
    const proportional = Math.floor((quest.estimatedMinutes / requestedTotal) * budget);
    const minutes = Math.max(5, Math.min(proportional, remaining - reserved));
    quest.estimatedMinutes = minutes;
    remaining -= minutes;
  });
}

export function areTitlesSimilar(left: string, right: string): boolean {
  const leftTokens = tokenize(left);
  const rightTokens = tokenize(right);
  if (leftTokens.size === 0 || rightTokens.size === 0) return false;

  let intersection = 0;
  for (const token of leftTokens) {
    if (rightTokens.has(token)) intersection += 1;
  }
  const union = new Set([...leftTokens, ...rightTokens]).size;
  const overlap = intersection / Math.min(leftTokens.size, rightTokens.size);
  return intersection / union >= 0.6 || overlap >= 0.66;
}

function tokenize(value: string): Set<string> {
  const stopWords = new Set(["для", "над", "свой", "свою", "один", "одну", "сегодня"]);
  const tokens = value
    .toLowerCase()
    .replace(/ё/g, "е")
    .replace(/[^a-zа-я0-9 ]/g, " ")
    .split(/\s+/)
    .filter((token) => token.length >= 4 && !stopWords.has(token));
  return new Set(tokens);
}

export function buildFallbackQuests(
  mainGoal: string,
  spheres: string[],
  plan: GenerationPlan,
): QuestOutput[] {
  const safeGoal = cleanText(mainGoal, 120) || "главная цель";
  const safeSpheres = spheres.length > 0 ? spheres : ["discipline"];
  const firstDifficulty: QuestDifficulty = plan.mode === "momentum"
    ? "easy"
    : plan.allowedDifficulties[0];

  const templates: QuestOutput[] = [
    {
      title: "Определи следующий шаг",
      description:
        `Открой цель «${safeGoal}» и запиши одно физически выполнимое действие, которое можно начать сегодня. Затем сделай его первые две минуты.`,
      sphere: safeSpheres[0],
      isMainGoalTask: true,
      xpReward: XP_BY_DIFFICULTY[firstDifficulty],
      estimatedMinutes: Math.min(7, plan.firstQuestMaxMinutes),
      difficulty: firstDifficulty,
      tip: "Минимальная версия — открыть заметки и написать один глагол действия.",
      successCriterion:
        "В заметках записано одно конкретное действие и начаты его первые две минуты.",
      verificationType: "self_confirm",
    },
    {
      title: "Убери одно препятствие",
      description:
        "Назови одну вещь, из-за которой ты откладываешь важное действие, и убери её на ближайшие десять минут.",
      sphere: safeSpheres[1 % safeSpheres.length],
      isMainGoalTask: false,
      xpReward: XP_BY_DIFFICULTY[firstDifficulty],
      estimatedMinutes: 5,
      difficulty: firstDifficulty,
      tip: "Начни с закрытой вкладки, выключенного уведомления или подготовленного рабочего места.",
      successCriterion:
        "Одно выбранное препятствие убрано минимум на десять минут.",
      verificationType: "self_confirm",
    },
    {
      title: "Зафиксируй маленькую победу",
      description:
        "Сделай одно короткое полезное действие в выбранной сфере и запиши конкретный результат одним предложением.",
      sphere: safeSpheres[2 % safeSpheres.length],
      isMainGoalTask: false,
      xpReward: XP_BY_DIFFICULTY[firstDifficulty],
      estimatedMinutes: 5,
      difficulty: firstDifficulty,
      tip: "Результат должен быть видимым: запись, отправленное сообщение или завершённый подход.",
      successCriterion:
        "Полезное действие завершено, а его результат записан одним предложением.",
      verificationType: "self_confirm",
    },
  ];

  fitTimeBudget(templates, plan.timeBudget, plan.firstQuestMaxMinutes);
  return templates;
}

function cleanText(value: unknown, maxLength: number): string {
  if (typeof value !== "string") return "";
  return value.replace(/\s+/g, " ").trim().slice(0, maxLength);
}

function clampInteger(
  value: unknown,
  minimum: number,
  maximum: number,
  fallback: number,
): number {
  const number = typeof value === "number" ? Math.round(value) : Number(value);
  if (!Number.isFinite(number)) return fallback;
  return Math.max(minimum, Math.min(maximum, number));
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
