import test from "node:test";
import assert from "node:assert/strict";

import {
  adaptPlanToFeedback,
  areTitlesSimilar,
  buildFallbackQuests,
  buildGenerationPlan,
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
