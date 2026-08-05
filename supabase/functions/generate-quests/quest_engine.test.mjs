import test from "node:test";
import assert from "node:assert/strict";

import {
  adaptPlanToFeedback,
  areTitlesSimilar,
  buildFallbackQuests,
  buildGenerationPlan,
  buildVerificationPolicy,
  chooseQuestActionType,
  chooseRequiredPlaceType,
  chooseVerificationType,
  normalizeQuests,
  summarizeQuestFeedback,
} from "./quest_engine.ts";

const spheres = ["discipline", "knowledge", "energy"];

function rawQuest(overrides = {}) {
  return {
    title: "Запиши следующий шаг",
    description:
      "Открой заметки и за десять минут запиши один конкретный следующий шаг к цели.",
    sphere: "discipline",
    isMainGoalTask: false,
    xpReward: 999,
    estimatedMinutes: 30,
    difficulty: "hard",
    tip: "Минимальная версия — написать только первое действие.",
    successCriterion:
      "В заметках записан один конкретный следующий шаг к выбранной цели.",
    actionType: "reflection",
    verificationType: "timer",
    verificationMinutes: 30,
    ...overrides,
  };
}

test("switches to restart mode when completion is low", () => {
  const plan = buildGenerationPlan(60, 0, [
    { title: "A", status: "skipped" },
    { title: "B", status: "pending" },
    { title: "C", status: "completed" },
    { title: "D", status: "pending" },
  ]);

  assert.equal(plan.mode, "restart");
  assert.equal(plan.timeBudget, 30);
  assert.equal(plan.firstQuestMaxMinutes, 7);
  assert.deepEqual(plan.allowedDifficulties, ["trivial", "easy"]);
});

test("allows a stronger plan only after sustained completion", () => {
  const history = Array.from({ length: 10 }, (_, index) => ({
    title: `Quest ${index}`,
    status: index < 8 ? "completed" : "pending",
  }));
  const plan = buildGenerationPlan(90, 12, history);

  assert.equal(plan.mode, "momentum");
  assert.equal(plan.timeBudget, 90);
  assert.deepEqual(plan.allowedDifficulties, ["medium", "hard"]);
});

test("shrinks the plan when time is the repeated rejection reason", () => {
  const basePlan = buildGenerationPlan(90, 12, Array.from(
    { length: 10 },
    (_, index) => ({
      title: `Quest ${index}`,
      status: index < 8 ? "completed" : "pending",
    }),
  ));
  const feedback = summarizeQuestFeedback([
    "no_time",
    "no_time",
    "too_hard",
    "unknown",
  ]);
  const plan = adaptPlanToFeedback(basePlan, feedback);

  assert.equal(feedback.total, 3);
  assert.equal(feedback.dominantReason, "no_time");
  assert.equal(plan.timeBudget, 20);
  assert.equal(plan.firstQuestMaxMinutes, 5);
  assert.deepEqual(plan.allowedDifficulties, ["trivial", "easy"]);
});

test("keeps the base plan when feedback has no clear pattern", () => {
  const basePlan = buildGenerationPlan(45, 5, []);
  const feedback = summarizeQuestFeedback([
    "no_time",
    "too_hard",
    "not_relevant",
  ]);
  const plan = adaptPlanToFeedback(basePlan, feedback);

  assert.equal(feedback.dominantReason, null);
  assert.deepEqual(plan, basePlan);
});

test("makes relevance feedback an explicit planning constraint", () => {
  const basePlan = buildGenerationPlan(45, 5, []);
  const feedback = summarizeQuestFeedback([
    "not_relevant",
    "not_relevant",
  ]);
  const plan = adaptPlanToFeedback(basePlan, feedback);

  assert.equal(plan.timeBudget, basePlan.timeBudget);
  assert.match(plan.guidance, /главную или выбранную сферную цель/);
});

test("reduces difficulty after repeated too-hard feedback", () => {
  const basePlan = buildGenerationPlan(90, 12, Array.from(
    { length: 10 },
    (_, index) => ({
      title: `Quest ${index}`,
      status: index < 8 ? "completed" : "pending",
    }),
  ));
  const plan = adaptPlanToFeedback(
    basePlan,
    summarizeQuestFeedback(["too_hard", "too_hard"]),
  );

  assert.equal(plan.firstQuestMaxMinutes, 7);
  assert.deepEqual(plan.allowedDifficulties, ["easy", "medium"]);
});

test("overrides an unsafe timer for a visible result", () => {
  assert.equal(
    chooseVerificationType(
      "timer",
      "Отправь важное сообщение",
      "Напиши коллеге один конкретный вопрос и отправь его.",
      "Сообщение отправлено выбранному человеку.",
    ),
    "self_confirm",
  );
});

test("uses a timer for sustained focus activity", () => {
  assert.equal(
    chooseVerificationType(
      "self_confirm",
      "Сделай короткую тренировку",
      "Выполни разминку и один круг упражнений без отвлечений.",
      "Тренировка длилась десять минут.",
    ),
    "timer",
  );
});

test("uses a timer for Russian infinitive reading tasks", () => {
  assert.equal(
    chooseVerificationType(
      "self_confirm",
      "Прочитать главу книги",
      "Открыть книгу и прочитать одну главу без отвлечений.",
      "Прочитана одна глава.",
    ),
    "timer",
  );
});

test("classifies communication without asking for private screenshots", () => {
  const actionType = chooseQuestActionType(
    "focus",
    "Позвони старому другу",
    "Позвони и договорись о встрече на этой неделе.",
    "Дата встречи согласована.",
  );
  const policy = buildVerificationPolicy(actionType, 30, 30);

  assert.equal(actionType, "communication");
  assert.equal(policy.verificationType, "self_confirm");
  assert.equal(policy.suggestedProofType, "text");
  assert.match(policy.proofPrompt, /Без скриншотов/);
});

test("uses a bounded timer only for sustained actions", () => {
  const movement = buildVerificationPolicy("movement", 90, 75);
  const routine = buildVerificationPolicy("routine", 30, 30);

  assert.equal(movement.verificationType, "timer");
  assert.equal(movement.verificationMinutes, 60);
  assert.equal(movement.suggestedProofType, "none");
  assert.equal(routine.verificationType, "self_confirm");
  assert.equal(routine.verificationMinutes, 0);
});

test("uses location verification only for a saved training place", () => {
  const placeType = chooseRequiredPlaceType(
    "movement",
    "Проведи тренировку в спортзале",
    ["training"],
  );
  const policy = buildVerificationPolicy("movement", 45, 45, placeType);

  assert.equal(placeType, "training");
  assert.equal(policy.verificationType, "location_timer");
  assert.equal(policy.requiredPlaceType, "training");
});

test("falls back to a regular timer when no training place is saved", () => {
  const placeType = chooseRequiredPlaceType(
    "movement",
    "Проведи тренировку в спортзале",
    [],
  );
  const policy = buildVerificationPolicy("movement", 45, 45, placeType);

  assert.equal(placeType, "");
  assert.equal(policy.verificationType, "timer");
  assert.equal(policy.requiredPlaceType, "");
});

test("normalization upgrades a gym quest to location verification", () => {
  const plan = buildGenerationPlan(60, 5, []);
  const result = normalizeQuests(
    [
      rawQuest({
        title: "Проведи тренировку в спортзале",
        description: "Выполни разминку и три упражнения в сохранённом зале.",
        successCriterion: "Три упражнения в спортзале полностью выполнены.",
        actionType: "movement",
        verificationMinutes: 30,
      }),
      rawQuest({ title: "Подготовь рабочее место", sphere: "knowledge" }),
      rawQuest({ title: "Запиши итоги дня", sphere: "energy" }),
    ],
    {
      allowedSpheres: spheres,
      recentTitles: [],
      plan,
      availablePlaceTypes: ["training"],
    },
  );

  assert.equal(result.valid, true);
  assert.equal(result.quests[0].verificationType, "location_timer");
  assert.equal(result.quests[0].requiredPlaceType, "training");
});

test("suggests visible proof only for a finished artifact", () => {
  const actionType = chooseQuestActionType(
    "routine",
    "Собери первый прототип",
    "Подготовь один кликабельный экран продукта.",
    "Кликабельный экран открывается без ошибок.",
  );
  const policy = buildVerificationPolicy(actionType, 20, 20);

  assert.equal(actionType, "result");
  assert.equal(policy.verificationType, "self_confirm");
  assert.equal(policy.suggestedProofType, "image");
});

test("normalizes difficulty, XP, main quest and total time", () => {
  const plan = buildGenerationPlan(20, 0, []);
  const result = normalizeQuests(
    [
      rawQuest(),
      rawQuest({
        title: "Подготовь рабочее место",
        sphere: "knowledge",
      }),
      rawQuest({
        title: "Сделай короткую разминку",
        sphere: "energy",
      }),
    ],
    { allowedSpheres: spheres, recentTitles: [], plan },
  );

  assert.equal(result.valid, true);
  assert.equal(result.quests.length, 3);
  assert.deepEqual(result.quests.map((quest) => quest.isMainGoalTask), [true, false, false]);
  assert.ok(result.quests[0].estimatedMinutes <= 7);
  assert.ok(result.quests.reduce((sum, quest) => sum + quest.estimatedMinutes, 0) <= 20);
  assert.ok(result.quests.every((quest) => quest.difficulty === "trivial"));
  assert.ok(result.quests.every((quest) => quest.xpReward === 10));
  assert.equal(result.quests[0].verificationType, "self_confirm");
  assert.equal(result.quests[0].actionType, "reflection");
  assert.equal(result.quests[0].verificationMinutes, 0);
  assert.equal(result.quests[0].suggestedProofType, "text");
  assert.ok(result.quests.every((quest) =>
    quest.verificationType !== "timer" ||
    quest.verificationMinutes <= quest.estimatedMinutes
  ));
  assert.ok(result.quests.every((quest) => quest.successCriterion.length > 20));
});

test("rejects a quest that repeats recent history", () => {
  const plan = buildGenerationPlan(30, 3, []);
  const result = normalizeQuests(
    [
      rawQuest(),
      rawQuest({ title: "Подготовь рабочее место", sphere: "knowledge" }),
      rawQuest({ title: "Сделай короткую разминку", sphere: "energy" }),
    ],
    {
      allowedSpheres: spheres,
      recentTitles: ["Запиши один следующий шаг"],
      plan,
    },
  );

  assert.equal(result.valid, false);
  assert.match(result.issues.join(" "), /Повтор/);
});

test("detects similar titles without requiring exact text", () => {
  assert.equal(
    areTitlesSimilar("Запиши конкретный следующий шаг", "Определи следующий конкретный шаг"),
    true,
  );
  assert.equal(
    areTitlesSimilar("Сделай разминку", "Позвони старому другу"),
    false,
  );
});

test("fallback always returns three small actionable quests", () => {
  const plan = buildGenerationPlan(15, 0, []);
  const quests = buildFallbackQuests("Запустить приложение", spheres, plan);

  assert.equal(quests.length, 3);
  assert.equal(quests[0].isMainGoalTask, true);
  assert.ok(quests[0].estimatedMinutes <= 7);
  assert.ok(quests.reduce((sum, quest) => sum + quest.estimatedMinutes, 0) <= 15);
  assert.ok(quests.every((quest) => quest.description.length > 20));
  assert.ok(quests.every((quest) => quest.successCriterion.length > 20));
});

test("fails safely when no development sphere is available", () => {
  const plan = buildGenerationPlan(30, 0, []);
  const result = normalizeQuests(
    [rawQuest(), rawQuest(), rawQuest()],
    { allowedSpheres: [], recentTitles: [], plan },
  );

  assert.equal(result.valid, false);
  assert.match(result.issues[0], /хотя бы одна сфера/);
});
