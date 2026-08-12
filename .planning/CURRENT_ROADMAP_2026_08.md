# LEVL Current Roadmap - August 2026

This file is the current execution view. `ROADMAP.md` remains the long-form
product backlog.

## Completed

- [x] Quest Engine 2.5 with deterministic verification selection.
- [x] Timer, self-confirmation, optional evidence, and location presence flows.
- [x] Verified action -> XP -> sphere growth -> Life Map consequence.
- [x] Privacy-safe product analytics for the core funnel.
- [x] Weekly recap and return-after-absence experience.
- [x] Full-body 2.5D character studio foundation.
- [x] First wardrobe catalogue with progress-gated outfits.

## Now: Reward Inventory v1

**Outcome:** clothing becomes a consequence of progress, not a cosmetic menu.

- [ ] Add an explicit owned-item inventory to the profile domain.
- [ ] Grant each item once when its achievement condition is reached.
- [ ] Persist equipped items locally and in Supabase.
- [ ] Show a concise locked reason and unlock progress in the studio.
- [ ] Add one visible celebration when a new item is earned.

**Acceptance criteria:** a new user owns the starter outfit; completing an
eligible milestone grants exactly one item; the item remains equipped after
restart and account sync.

## Next: Release Foundation

- [ ] Replace `com.example.levl` with production iOS and Android identifiers.
- [ ] Configure Apple signing and Android upload/release signing.
- [ ] Recreate and verify the iOS CocoaPods setup on a Mac, then archive in
  Xcode and test through TestFlight.
- [ ] Target Android API 36 for new submissions after August 31, 2026.
- [ ] Complete App Privacy and Google Data Safety declarations from actual
  runtime behavior and third-party SDKs.
- [ ] Verify in-app account deletion and publish a web deletion-request page
  for Google Play.
- [ ] Add crash monitoring and release-channel analytics.
- [ ] Test startup, scrolling, avatar rendering, maps, location sessions, and
  offline recovery on representative iPhones and Android phones.

## Then: Private Social Foundation

- [ ] Nickname and unique friend code.
- [ ] Invite/accept/remove friend flow.
- [ ] Private progress profile with user-controlled visibility.
- [ ] Supportive reactions to milestones and weekly progress.

Exact live locations and open chat are not part of this phase. They require a
separate safety, moderation, blocking, reporting, and privacy design.

## Later

- [ ] Contextual map events, easter eggs, and rare challenges.
- [ ] Character behavior states, aura, artifacts, and additional outfits.
- [ ] Daily contextual notification from the System.
- [ ] Subscription rollout after the entitlement layer and store builds work.
- [ ] Telegram Mini App companion after the native daily loop is stable.

## Product Checkpoint

Before expanding social or the wardrobe catalogue, measure:

- onboarding completion;
- first action started on day 0;
- started actions that become verified;
- day 1 and day 7 retention;
- weekly recap opens;
- verified actions per active week.
