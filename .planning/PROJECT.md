# LEVL — Project Context

## Vision
Personal life progression system. User sees it as self-improvement RPG — not a task tracker.
Daily actions earn XP, streaks build into chapters, habits become character progression.

## Target Emotion
"I'm becoming stronger every day." — dopamine from progress, not gamification gimmicks.

## Brand Voice
- Say: Система, Путь, Зафиксировано, Уровень, Отражение, Задача
- Don't say: геймификация, квест, герой, игра, мотивация, прокачка
- AI voice: short, italic, from the System's perspective

## Tech Stack
- **Frontend:** Flutter (Dart)
- **State:** Riverpod
- **Local DB:** Isar (offline-first)
- **Animations:** Rive + Lottie
- **Backend:** Supabase (Auth + PostgreSQL + Edge Functions + Realtime)
- **AI:** Anthropic Claude API (claude-sonnet-4-20250514) via Supabase Edge Functions
- **Navigation:** GoRouter

## Visual System
- Background: #F8F8F6 (white), Text: #0A0A0A, Lines: #E2E2DE
- Gold #B8962E — ONLY for earned rewards, never decorative
- Fonts: DM Serif Display (headers, levels, logo), DM Sans (all UI)
- Principle: Apple minimalism — space over decoration

## Key Screens
1. **Onboarding** — 7 screens, AI generates initial character state
2. **Dashboard** — Daily tasks + XP bar + streak + avatar
3. **Character Sheet** — 6 stats + equipment + achievements
4. **AI Mentor** — Chat with progress context

## Constraints
- Offline-first: every action writes locally first, syncs in background
- Gold color only for earned items (never purchasable)
- No RPG language in UI (no "quest", "hero", "level up" as verbs)
- ANTHROPIC_API_KEY only in Supabase Secrets, never in Flutter

## Success Metric
User opens app daily not because of notifications but because they want to see their progression.
