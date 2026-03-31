# Phase 8: Polish & Animations - Context

**Gathered:** 2026-03-31
**Status:** Ready for planning

<domain>
## Phase Boundary

App feels alive on iOS + Android: Rive/Lottie animations on key moments, haptic feedback, sound effects, performance jank fixes. Offline conflict resolution and Windows support are explicitly out of scope for this phase.

</domain>

<decisions>
## Implementation Decisions

### Target Platforms
- **D-01:** iOS + Android only. Windows is dev-only environment, not a target platform.
- **D-02:** No platform guards needed for Rive/Lottie — both work natively on mobile.

### Animations (Rive + Lottie)
- **D-03:** Uncomment `rive` and `lottie` in pubspec.yaml — both packages go back in.
- **D-04:** Rive → quest completion effect (interactive state machine: idle → complete → celebrate).
- **D-05:** Lottie → level-up full-screen overlay (JSON asset from LottieFiles, minimalist style matching app palette: #F8F8F6 bg, #B8962E gold accent).
- **D-06:** Animation style must match brand — no cartoonish effects. Minimal, purposeful, Apple-like.

### Sound Effects (just_audio)
- **D-07:** Add `just_audio` to pubspec.yaml.
- **D-08:** 3 sound effects: `quest_complete.mp3`, `level_up.mp3`, `ui_tap.mp3`.
- **D-09:** Assets stored in `assets/sounds/`.
- **D-10:** AudioPlayer initialized once (singleton/provider), not per-widget.

### Haptic Feedback
- **D-11:** Quest complete → already has `HapticFeedback.mediumImpact()` — keep as-is.
- **D-12:** Level-up → add `HapticFeedback.heavyImpact()` (more impactful moment).
- **D-13:** No haptic on tab switch or message send — keep it focused on meaningful moments.

### Offline Sync
- **D-14:** Deferred to v1.1. Phase 8 stays focused on polish only.

### Performance Audit
- **D-15:** Include performance audit (Phase 8.6 from roadmap): check for jank on dashboard scroll, quest completion animation, and character page radar chart render.
- **D-16:** Fix any identified jank. No full rewrite — targeted fixes only.

### Claude's Discretion
- Exact Rive state machine structure
- Lottie file selection from LottieFiles (must be free/open license)
- AudioPlayer lifecycle management (dispose, background behavior)
- Performance fix approach (RepaintBoundary, const widgets, etc.)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing animation/haptic code
- `levl/lib/features/dashboard/presentation/screens/dashboard_page.dart` — lines 444, 576: existing HapticFeedback calls (pattern to follow)
- `levl/pubspec.yaml` — lines 31-32: commented-out rive/lottie (uncomment these)

### Visual system constraints
- `CLAUDE.md` §Визуальный стиль — gold #B8962E ONLY for earned rewards, palette rules
- `.planning/PROJECT.md` §Visual System — Apple minimalism, no decoration

No external specs — requirements fully captured in decisions above.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `HapticFeedback.mediumImpact()` pattern in dashboard_page.dart — copy this for level-up with heavyImpact
- `QuestNotifier.completeQuest()` in quest_provider.dart — trigger point for quest animation + sound
- `UserProfileNotifier` — trigger point for level-up detection (xp crosses threshold)

### Established Patterns
- Riverpod StateNotifier for all state — sound/animation triggers go through providers
- Isar writes first, then UI update — don't block animation on DB write
- Bottom nav uses ShellRoute — tab switch haptic would go in router shell widget

### Integration Points
- Quest complete: `dashboard_page.dart` → completeQuest() callback → add Rive animation overlay + sound
- Level-up: detect in `UserProfileNotifier.addXp()` when `floor(xp/100)+1 > currentLevel` → emit event → trigger Lottie overlay + heavyImpact
- Sound: single `AudioService` provider, called from quest_provider and profile_provider

</code_context>

<specifics>
## Specific Ideas

- Animations must feel like the System responding — not celebration, more like "зафиксировано"
- Level-up Lottie: minimal particles or geometric shapes, gold accent, NOT confetti
- Sound effects: subtle, not gaming. Short, clean tones. Think Notion/Linear, not Duolingo.

</specifics>

<deferred>
## Deferred Ideas

- Offline sync conflict resolution → v1.1 (separate phase, not polish)
- Windows platform polish → not a target platform, skip
- Tab switch haptic → reviewed and rejected (too noisy for minimal feel)
- Send message haptic → reviewed and rejected

</deferred>

---

*Phase: 08-polish-animations*
*Context gathered: 2026-03-31*
