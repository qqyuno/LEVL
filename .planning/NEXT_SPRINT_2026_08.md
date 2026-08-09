# LEVL Next Sprint: Weekly Change

## Objective

Turn separate completed actions into a clear seven-day story so the user sees
that LEVL records real change, not only checkmarks.

## Scope

1. Add a weekly recap screen opened from the dashboard and Life Map.
2. Show three signals only: verified actions, strongest sphere, and route nodes
   opened during the week.
3. Generate one short system observation from deterministic local data.
4. Add a return-after-absence state that offers one realistic restart action
   without punishment or a broken-streak message.
5. Track recap opened and restart action accepted using the private analytics
   layer already in place.

## Product Rules

- No dense charts, generic motivation, or comparison with other people.
- The recap must fit on one mobile screen before scrolling.
- The system may describe observed activity but must not invent causes or
  psychological conclusions.
- Missing days are neutral context, not failure.
- The next action remains the primary call to action.

## Acceptance Criteria

- The recap renders correctly at 390 x 844 and on a compact iPhone viewport.
- Empty, partial, and complete weeks have intentional states.
- No private goal, proof, note, image, link, or coordinate enters analytics.
- Widget tests cover the three weekly states and the restart action.
- Flutter tests, analyzer review, and a Windows debug build complete before the
  slice is committed.

## After This Sprint

Create the full-body 2.5D asset pilot: one base body, five views, one neutral
outfit, and a separate focused character editor. Social features begin only
after nickname and privacy rules are specified.
