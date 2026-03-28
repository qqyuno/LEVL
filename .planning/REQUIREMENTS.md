# LEVL — Requirements

## Functional Requirements

### F1 — Onboarding
- [ ] 7-screen onboarding flow with progress bar
- [ ] Screen 1: Epic intro animation (8 sec) — "Твоя жизнь — это игра. Давай начнём."
- [ ] Screen 2: Character creation (name input + avatar selection/generation)
- [ ] Screens 3-7: Interactive wheel-of-life survey (Health, Career, Relations, Energy, Finance, Growth)
- [ ] Goals input (3-6 months), energy level, joy/stress, daily time, quest style
- [ ] AI Processing screen with animation — generates: start level, "Chapter Name", 90-day plan, 3 Main Quests
- [ ] Success screen: "Добро пожаловать, [Name]. Твоя легенда начинается здесь."
- [ ] Save profile to Supabase + local Isar cache

### F2 — Dashboard
- [ ] Header: Level, Chapter name, Streak fire icon
- [ ] Hero segment: clickable avatar + XP bar with progress and numbers
- [ ] Quest feed: Daily tasks (3-5), color-coded by category
- [ ] Main Quest as large separate card
- [ ] Minimap: life skill tree preview at bottom
- [ ] FAB: "Поговорить с AI-ментором"
- [ ] Quest completion: animation (Rive/Lottie) + haptic feedback + AI mentor message
- [ ] Daily quest refresh every 24 hours

### F3 — Character Sheet
- [ ] Full RPG character interface
- [ ] 6 stat bars: Дисциплина, Знания, Отношения, Энергия, Воля, Мудрость
- [ ] Equipment/appearance: unlock visual items via real achievements (not purchasable)
- [ ] Current chapter description
- [ ] Achievement icons + XP log + level-up history

### F4 — Quest System
- [ ] Daily Quests: 3-5 tasks, refresh every 24h
- [ ] Main Quest: large goal (30-90 days) with milestones
- [ ] Side Quests: AI-generated based on wheel-of-life gaps
- [ ] Epic Challenges: weekly, large XP/achievement reward
- [ ] Each task has: fantasy name, difficulty (1-5 skulls), reward, importance description
- [ ] Completion can require photo/note confirmation
- [ ] After completion: animation + AI mentor text

### F5 — XP & Progression
- [ ] XP per task: 10-200 based on difficulty
- [ ] Level = floor(XP / 100) + 1
- [ ] Streak tracking (daily check-in)
- [ ] 6 character stats linked to quest categories
- [ ] Hidden achievements for behavior patterns

### F6 — AI Mentor Chat
- [ ] Chat UI with mentor
- [ ] Context: last 7 days of completed tasks sent to Claude
- [ ] Daily analysis: motivating or difficulty-adjusting quest suggestions
- [ ] Triggered on: app open, quest completion, manual FAB tap

### F7 — Auth & Sync
- [ ] Google + Apple Sign-In via Supabase Auth
- [ ] Offline-first: write to Isar → sync to Supabase in background
- [ ] Supabase Edge Function: generate-quests (Claude API call)

## Non-Functional Requirements
- [ ] Offline mode: full functionality without network
- [ ] Haptic feedback on all key actions
- [ ] Sound effects on menu/level-up
- [ ] Response time < 200ms for local operations
- [ ] AI generation < 5 sec (with loading animation)
- [ ] iOS + Android support via Flutter
