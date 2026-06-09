# LEVL Avatar v2 Pipeline

## Goal

Build a premium customizable full-body avatar for LEVL without hiring a full-time artist.
The avatar must feel serious, mobile-first, iOS-ready, and close to the LEVL visual identity:
warm white, near-black, muted gold, restrained premium productivity style.

## Direction

Do not draw the final character procedurally in Flutter.
Use a high-quality source asset pipeline, then render optimized 2.5D layers for the app.

Preferred path:

1. Source a strong 3D/2.5D base character.
2. Refine style in Blender or a similar tool.
3. Render controlled asset sets:
   - front
   - left 3/4
   - side
   - right 3/4
   - back
4. Export mobile-friendly PNG/WebP layers.
5. Assemble in Flutter with a manifest-driven layered renderer.

## Possible Sources

- Ready Player Me: fast full-body avatar prototype, but can look generic.
- Reallusion Character Creator: higher quality, better premium potential, license/export must be checked.
- Marketplace rigged model: Sketchfab, CGTrader, Unity Asset Store, commercial license required.
- Mixamo/Blender: animation and rendering pipeline for idle states.

## Asset Strategy

Start small and high quality.

Phase 1:
- face only
- neutral serious expression
- 3-5 face variants
- clean LEVL lighting

Phase 2:
- head and upper body
- hair variants
- skin tone variants
- expression variants

Phase 3:
- full body base
- body type variants
- five rotation angles

Phase 4:
- clothing layers
- shoes
- accessories
- state/aura layers

Phase 5:
- idle animation frames
- blink
- subtle head movement
- breathing
- progress states: focus, tired, satisfied, overloaded, returned

## Flutter Implementation

Use a manifest-based renderer:

```json
{
  "faceShape": "oval_01",
  "skinTone": "tone_02",
  "hair": "short_01",
  "body": "athletic_01",
  "top": "blazer_01",
  "pants": "tailored_01",
  "shoes": "sneaker_01",
  "accessory": "watch_01",
  "state": "focus",
  "angle": "front"
}
```

Flutter renders layers in order:

1. shadow
2. body
3. face
4. facial features
5. hair
6. clothes
7. shoes
8. accessories
9. aura/state
10. foreground effect

## iOS Constraints

- Prefer optimized WebP/PNG sequences over live heavy 3D on the main screen.
- Keep assets compressed and grouped by angle/state.
- Avoid WebView-based 3D for core daily screens unless performance is proven.
- Use 3D only as a source pipeline or optional preview later.

## Current Decision

The procedural Flutter avatar is only a technical prototype.
The production avatar should be generated or sourced as real visual assets, then implemented as a layered 2.5D system.

## Full-Body Rotating Character Plan

Use a hybrid 2.5D approach for the first production version:

1. Build or buy one premium rigged full-body base model.
2. Style it in Blender to match LEVL: serious, clean, modern, not fantasy and not cartoon.
3. Render five locked angles:
   - front
   - front-left 3/4
   - side
   - front-right 3/4
   - back
4. Render each angle in the same lighting setup and camera framing.
5. Export optimized WebP/PNG sprites for iOS.
6. In Flutter, swipe changes `viewAngle` and crossfades between the five rendered angles.
7. Idle life is added in Flutter:
   - breathing
   - subtle head/torso movement
   - blink and gaze movement for face views
   - state aura based on progress
8. Clothing is added as layers after the base body is stable:
   - body
   - hair/head
   - top
   - pants
   - shoes
   - accessories
   - foreground state effects

This avoids shipping a heavy realtime 3D scene in daily screens while still giving the user the feeling of a rotating character. True realtime 3D can be added later for a dedicated preview/customizer screen if performance is proven on iPhone.

## Best Asset Source Options

Recommended practical path with a small budget:

1. Buy a commercial-license rigged human base from CGTrader, Sketchfab, Unity Asset Store, or Reallusion.
2. Use Blender for pose, lighting, camera, clothing tests, and turntable renders.
3. Use Mixamo only for quick idle animation references, not as final visual style.
4. Use AI images for concept direction and clothing references, not as the only production source for the full-body model.

Avoid relying on pure generated full-body PNGs for final customization. They look good as pictures, but they are hard to keep consistent across angles, outfits, and future updates.

## Next Avatar Milestones

1. Finish face: no hair-color bleed, no face tinting, stable asset switching.
2. Add face states: focused, tired, satisfied, overloaded, returned.
3. Create one full-body base concept in the LEVL style.
4. Choose model source and license.
5. Render first five-angle full-body prototype.
6. Build Flutter angle switcher.
7. Add first clothing set.
