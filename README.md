# SMTL

Show Me The Lyrics: a KDE Plasma 6 widget that shows time-synced lyrics for the song playing on Spotify, on the desktop, in a panel, or as a click-through overlay above your windows.

Lyrics come from [LRCLIB](https://lrclib.net); playback is read over MPRIS, so no Spotify login is needed.

## Install

```bash
kpackagetool6 -t Plasma/Applet -i package
```

After changing the code, update the installed copy and restart Plasma to load it:

```bash
kpackagetool6 -t Plasma/Applet -u package
```

```bash
systemctl --user restart plasma-plasmashell
```

Then right-click the desktop or a panel → Add Widgets → "Show Me The Lyrics". Right-click the widget → Configure for the menu.

## Try it without installing

```bash
plasmawindowed "$PWD/package"
```

## Settings

- **General**: Spotify only or any player, sync offset, what to show when paused or when a song has no synced lyrics.
- **Presets**: live previews; click one to apply it, or save your current style as your own. Includes a Minecraft set, and Shuffle, which picks a random preset from the ones you tick for every line.
- **Style**: font, colours (solid, gradient, rainbow), outline, glow or drop shadow, backdrop.
- **Animation**: line transition, karaoke fill, wave, rainbow speed.
- **Layout**: lines before/after, alignment, spacing, size and opacity of the other lines.
- **Overlay**: on-screen HUD position, margins, width, opacity.

## Bundled font

The Minecraft presets use [Monocraft](https://github.com/IdreesInc/Monocraft) (SIL Open Font License 1.1), shipped in `package/contents/fonts/` with its licence. It is a look-alike; Mojang's own font is not included.

## Tests

```bash
node tests/lyrics.test.js
```

```bash
node tests/text.test.js
```

## Layout of the code

- `package/contents/code/lyrics.js`: LRC parsing and the LRCLIB lookup.
- `package/contents/code/text.js`: letter splitting and wrapping for the letter-by-letter effects.
- `package/contents/code/style.js`: built-in presets and style helpers.
- `package/contents/ui/main.qml`: player tracking, position, lyric state.
- `package/contents/ui/LyricsView.qml`, `LyricLine.qml`, `FxText.qml`: rendering.
- `package/contents/ui/Overlay.qml`: the layer-shell overlay (Wayland).
- `package/contents/ui/config/`: the settings pages.
