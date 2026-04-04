/// Pool of System-voice notification messages.
/// {minutes} is replaced with the user's dailyMinutes setting.
class NotificationMessages {
  NotificationMessages._();

  // ── Morning reminders ──────────────────────────────────────────────
  static const morningMessages = [
    '{minutes} минут. Завтрашний ты скажет спасибо.',
    'Фокус. Три задачи. Больше не нужно.',
    'Тот, кто начинает — уже впереди.',
    '{minutes} минут сегодня — это инвестиция в завтра.',
    'Система готова. Осталось начать.',
    'Маленький шаг. Большая разница.',
    'Три задачи. День начинается сейчас.',
    '{minutes} минут — и ты ближе к цели.',
    'Дисциплина — это выбор. Сделай его сейчас.',
    'Не жди вдохновения. Начни — оно догонит.',
    'Сегодня считается. Каждый день считается.',
    '{minutes} минут фокуса. Остальное подождёт.',
    'Путь не ждёт. Но он всегда открыт.',
    'Одна задача меняет день. Три — меняют неделю.',
    'Система видит паттерн. Продолжай.',
  ];

  // ── Streak at risk (evening) ───────────────────────────────────────
  static const streakMessages = [
    'Стрик сгорает через 3 часа. Одна задача — и он жив.',
    'Серия на грани. {minutes} минут — и она продолжится.',
    '{streak} дней подряд. Не останавливайся сейчас.',
    'Осталось немного времени. Одна задача — стрик цел.',
    'Система помнит каждый день. Этот тоже.',
  ];

  // ── Return after absence ───────────────────────────────────────────
  static const returnMessages = [
    'Система ждала. Продолжим.',
    'Пауза — не конец. Возвращение — это сила.',
    'Путь не исчез. Он ждёт.',
    'Каждый перезапуск — тоже начало.',
  ];

  /// Pick a message based on day-of-year for consistent daily rotation.
  static String morning(int dailyMinutes, {DateTime? date}) {
    final day = (date ?? DateTime.now()).difference(DateTime(2026)).inDays;
    final msg = morningMessages[day.abs() % morningMessages.length];
    return msg.replaceAll('{minutes}', dailyMinutes.toString());
  }

  static String streak(int currentStreak, int dailyMinutes, {DateTime? date}) {
    final day = (date ?? DateTime.now()).difference(DateTime(2026)).inDays;
    final msg = streakMessages[day.abs() % streakMessages.length];
    return msg
        .replaceAll('{streak}', currentStreak.toString())
        .replaceAll('{minutes}', dailyMinutes.toString());
  }

  static String returnAfterAbsence({DateTime? date}) {
    final day = (date ?? DateTime.now()).difference(DateTime(2026)).inDays;
    return returnMessages[day.abs() % returnMessages.length];
  }
}
