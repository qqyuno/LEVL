# LEVL Platform and Monetization Plan

## Product Rule

The free version must contain the complete transformation loop:

1. Receive a useful action.
2. Complete it with appropriate verification.
3. Earn XP, map progress, and character rewards.
4. See weekly change and return without punishment.

PRO sells deeper adaptation and guidance. It must not sell a stronger
character, basic verification, or the ability to make progress.

## Free and PRO v1

| Capability | Free | PRO |
| --- | --- | --- |
| Daily actions | Core daily set | Adaptive replacements and planning |
| Verification | Full | Full |
| Life Map and character | Full | Full |
| Earned equipment | Full | Full |
| Weekly recap | Essential | Deeper history and patterns |
| System guidance | Concise tips | AI mentor and contextual guidance |
| Goal planning | One active direction | Deeper planning and adjustment |

Start with one PRO tier and two billing periods: monthly and annual. Do not add
coins, paid loot, or multiple confusing tiers. Price is a beta experiment, not
an architecture decision; test willingness to pay with real retained users
before fixing a global price.

## Shared Entitlement Architecture

Supabase is the source of truth for access, while each platform remains the
source of truth for its own transaction.

Required backend concepts:

- `subscription_customers`: user and platform customer identifiers.
- `subscription_events`: immutable verified store events.
- `entitlements`: current `free` or `pro` access with source and expiry.
- idempotent webhook handlers for Apple, Google Play, and Telegram.
- a read-only entitlement endpoint used by every client.

The client must never unlock PRO from a local boolean or an unverified purchase
payload. Restore purchases and account changes must converge on the same
server-side entitlement.

## iOS

- Use Apple In-App Purchase for digital PRO features offered in the iOS app.
- Configure one auto-renewable subscription group with monthly and annual
  products, restore purchases, and subscription management.
- Replace the placeholder bundle identifier and configure the Apple Developer
  team, certificates, provisioning, and App Store Connect record.
- Verify the CocoaPods setup and produce a signed archive on a Mac.
- Complete the privacy policy URL, App Privacy answers, location explanation,
  account deletion, and Sign in with Apple token revocation.
- Test through TestFlight on at least one older supported iPhone and one current
  device. Check cold start, map/location sessions, avatar memory, offline sync,
  Dynamic Type, safe areas, and permission denial paths.

## Android and Google Play

- Use Google Play Billing for digital PRO features unless a supported regional
  billing program is intentionally adopted later.
- Replace the placeholder application ID and configure an upload key and
  release signing. Never publish a debug-signed release.
- Build an Android App Bundle and target API 36 for new submissions after
  August 31, 2026.
- Complete Data Safety from actual collection and sharing behavior.
- Keep account deletion in the app and publish an external deletion-request URL.
- Test low-memory recovery, back navigation, notification permission, location
  denial, background timer recovery, and common screen densities.

## Telegram Mini App

TMA should be a companion entry point, not a full clone of the native app.
The current Flutter client depends on Isar and native capabilities, so shipping
the same build as a Mini App would add risk and produce an inferior experience.

TMA v1 scope:

- link a Telegram identity to an LEVL account;
- show today's primary action;
- support self-confirmation and simple timer actions;
- show compact progress and the weekly recap;
- invite a friend into LEVL;
- open the native app for location verification and the full character studio.

Build it as a small web client over the same Supabase domain APIs. Validate
Telegram `initData` on the server and never trust `initDataUnsafe`. Digital PRO
sales inside Telegram must use Telegram Stars; verified Star events then grant
the same server-side `pro` entitlement.

## Delivery Order

1. Finish reward inventory v1 and sync it across devices.
2. Fix production identifiers, signing, privacy, deletion, and crash reporting.
3. Add the platform-neutral entitlement schema and feature flags without a
   visible paywall.
4. Produce TestFlight and Google Play internal builds and fix device issues.
5. Add Apple and Google subscription products behind a controlled rollout.
6. Build the focused TMA companion and add Telegram Stars only when its free
   daily loop is useful by itself.

## Release Gates

- No secret or store credential in the client repository.
- Purchases restore correctly after reinstall and account change.
- Expired, refunded, and cancelled subscriptions remove PRO without deleting
  user data or earned progress.
- The app remains genuinely useful when subscription services are unavailable.
- A user can understand the price, renewal period, included value, and how to
  cancel before confirming a purchase.
