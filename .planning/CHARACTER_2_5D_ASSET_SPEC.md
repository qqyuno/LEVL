# LEVL 2.5D Character Asset Pilot

## Current Pilot

- Front base: `levl/assets/character_v2/body/levl_body_male_front_base_v1.png`
- Canvas: 1024 x 1536 portrait
- Direction: serious premium progression app, realistic 2.5D, neutral pose
- Base outfit: matte charcoal, no logos or accessories
- Status: asset candidate for composition tests; it does not replace the
  existing premium face editor yet

## Non-Negotiable Quality Rules

- Preserve the approved face identity, proportions, skin tone, and hair quality.
- Keep the entire silhouette visible with relaxed arms separated from the torso.
- No fantasy armor, cartoon anatomy, glossy game-toy materials, or dramatic pose.
- Every angle must use the same body proportions, camera height, light, and crop.
- Do not expose a customization control until its selection visibly changes the
  character without seams or color spill.

## Production Asset Set

The first usable set requires these aligned views:

1. `front`
2. `front_three_quarter`
3. `side`
4. `back_three_quarter`
5. `back`

Each view will eventually contain separate transparent layers in this order:

1. body and skin base
2. lower garment
3. shoes
4. upper garment
5. hair and head foreground
6. accessory
7. earned effect or aura

## Next Character Slice

1. Validate the front base inside a 390 x 844 editor stage without replacing
   the current face preview.
2. Produce matching front-three-quarter and side assets.
3. Confirm that identity and body proportions remain stable across all views.
4. Extract the neutral outfit into replaceable top, lower, and shoe layers.
5. Only then connect swipe rotation and clothing controls to `AvatarConfig`.
