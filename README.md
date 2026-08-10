# Retro Chronicle

A newspaper looking theme for Batocera EmulationStation, monochrome by default with optional accent colours. Supports both light and dark mode.

## Install

Copy the `es-theme-retro-chronicle` folder to `/userdata/themes/` on the device, then pick
**Retro Chronicle** under _System Settings > Theme_. Theme options appear under _UI Settings >
Theme Configuration_.

## GPU Warning

It's a very lightweight theme, however some of the graphic options do use procedural shaders. Set any screen grade with `(static)` in the name to fully disable shaders on the theme.

## Aspect ratios

Geometry is selected by a direct numeric comparison on `<include>`, not by ratio name, so every panel should be automatically covered (including ones Batocera does not directly name).

Each band is a separate file of plain literal variables, there are no conditional variable definitions anywhere in the
theme, because the engine does not seem to evaluate them reliably and a failed condition silently yields an empty value:

| Band        | Covers       |
| ----------- | ------------ |
| < 1.20      | 1:1, 8:7     |
| 1.20 – 1.45 | 5:4, 4:3     |
| 1.45 – 1.70 | 3:2, 16:10   |
| 1.70 – 2.00 | 16:9         |
| 2.00 – 2.90 | 19.5:9, 21:9 |
| > 2.90      | 32:9         |

Headline size, carousel logo count, list line count, column split and the grid layout all dynamically change per band. This is the first time I attempt this, so it may not work on all resolutions, it'd be great to learn about edge cases from the community.

## Credits

- All fonts sit under `SIL Open Font License`. Licences in `_inc/fonts/`.
- Colour system logos derived from the **Meringue** theme by K_Thod.
- Monochrome system logos derived from **es-theme-animetaverse**, topped up with desaturated Meringue logos for systems it does not cover.
- Hardware plates derived from Meringue controller art, procedurally desaturated and halftoned with a python script.

Logos and console art remain the property of their respective rights holders.
