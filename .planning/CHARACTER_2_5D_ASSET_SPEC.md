# LEVL 2.5D Character Asset Pilot

## Current Pilot

- Front base: `levl/assets/character_v2/body/levl_body_male_front_base_v1.png`
- Canvas: 1024 x 1536 portrait
- Direction: serious premium progression app, realistic 2.5D, neutral pose
- Base outfit: matte charcoal, no logos or accessories
- Status: integrated and visually verified in the separate full-screen outfit
  studio; the existing premium face editor remains a separate working flow
- Wardrobe pilot: four aligned front composites (`Focus`, `Momentum`,
  `Operator`, `Breakthrough`) with preview, equip state, rarity, and real
  level/streak gates. The selection is persisted through `AvatarConfig.top`.

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

1. Produce matching front-three-quarter and side assets.
2. Confirm that identity and body proportions remain stable across all views.
3. Extract the approved front composites into replaceable top, lower, and shoe
   layers without changing the wardrobe contract.
4. Add a reward inventory source so event outfits (including football kits)
   can be granted without hard-coding ownership in the UI.
5. Add swipe rotation after at least three aligned views pass visual review.
