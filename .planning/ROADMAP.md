# LEVL — Roadmap

## Milestone 1.0 — MVP

### Phase 1: Foundation
**Goal:** Flutter project scaffold with full architecture ready.

- 1.1 Initialize Flutter project (`flutter create levl`)
- 1.2 Set up folder structure: `core/`, `features/`, `shared/`
- 1.3 Configure Riverpod + GoRouter
- 1.4 Set up ThemeData: colors (#F8F8F6, #0A0A0A, #E2E2DE, #B8962E), DM Serif Display + DM Sans fonts
- 1.5 Integrate Isar database + define base models (UserProfile, Quest)
- 1.6 Add core dependencies to pubspec.yaml

### Phase 2: Supabase & Auth
**Goal:** Backend connected, auth working on real device.

- 2.1 Supabase client setup (supabase_flutter)
- 2.2 Create DB tables: profiles, quests, quest_cache, daily_checkins + add_xp function
- 2.3 Google Sign-In integration
- 2.4 Apple Sign-In integration
- 2.5 Auth state management via Riverpod (AuthNotifier)
- 2.6 Persist session locally via Isar

### Phase 3: Onboarding Flow
**Goal:** Full 7-screen onboarding with AI character generation.

- 3.1 Onboarding screens scaffold (PageView + progress bar)
- 3.2 Screen 1: Intro animation (Lottie)
- 3.3 Screens 2-6: Survey UI (wheel-of-life sliders, text inputs)
- 3.4 Screen 7: AI Processing screen with loading animation
- 3.5 Supabase Edge Function: generate initial state via Claude API
- 3.6 Success screen + save profile to Isar + Supabase

### Phase 4: Dashboard
**Goal:** Main screen fully functional with quest feed and XP.

- 4.1 Dashboard layout: header, hero segment, quest feed, FAB
- 4.2 XP bar widget + level display
- 4.3 Streak tracker widget
- 4.4 QuestCard widget with category color coding
- 4.5 Main Quest large card
- 4.6 Quest completion: mark done → add XP → Isar update → sync Supabase
- 4.7 Daily quest refresh logic (24h timer)

### Phase 5: Quest Engine + Edge Function
**Goal:** AI-generated daily quests running end-to-end.

- 5.1 Edge Function: generate-quests (port existing index.ts → update for new schema)
- 5.2 Quest generation trigger: onboarding end + daily refresh
- 5.3 Quest cache logic (quest_cache table)
- 5.4 Quest categories → stat mapping (which quests level which stats)
- 5.5 Daily check-in (energy level) → adjust quest difficulty

### Phase 6: Character Sheet
**Goal:** RPG character screen with 6 stats and achievements.

- 6.1 Character Sheet screen layout
- 6.2 6 stat bars (Дисциплина, Знания, Отношения, Энергия, Воля, Мудрость)
- 6.3 Avatar display with equipment slots
- 6.4 Achievement system: unlock conditions + icon display
- 6.5 XP log + level-up history

### Phase 7: AI Mentor Chat
**Goal:** In-app chat with Claude using user progress context.

- 7.1 Chat UI screen
- 7.2 Edge Function: ai-mentor (send context → get response)
- 7.3 Context builder: last 7 days completed quests + current stats
- 7.4 Auto-trigger on app open (daily insight)
- 7.5 Manual trigger via FAB

### Phase 8: Polish & Animations
**Goal:** App feels alive — haptics, sounds, Rive animations.

- 8.1 Rive animation: quest completion effect
- 8.2 Lottie animation: level-up screen
- 8.3 Haptic feedback on all key interactions
- 8.4 Sound effects: menu tap, level-up, quest complete
- 8.5 Offline sync refinement (conflict resolution)
- 8.6 Performance audit + fix jank

## Status
- [ ] Phase 1 — Foundation
- [ ] Phase 2 — Supabase & Auth
- [ ] Phase 3 — Onboarding
- [ ] Phase 4 — Dashboard
- [ ] Phase 5 — Quest Engine
- [ ] Phase 6 — Character Sheet
- [ ] Phase 7 — AI Mentor
- [ ] Phase 8 — Polish
