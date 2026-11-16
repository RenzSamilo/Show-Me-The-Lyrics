import QtQuick
import "../code/style.js" as Style
import "../code/text.js" as TextUtil

// One line drawn letter by letter, so each letter can have its own colour and offset
// (gradient, rainbow, karaoke fill, wave). Wraps itself; see code/text.js.
// shortcut: letters are placed individually, so kerning/ligatures are lost and complex
// scripts would break; LyricLine falls back to a plain Text for those.
Item {
    id: fx

    required property var cfg
    property string text
    property font font
    property real progress: 0
    property real fxTime: 0

    readonly property var glyphs: layout(text, width, font)
    implicitHeight: glyphs.height

    FontMetrics { id: fm; font: fx.font }
    // The same text as one unwrapped line. When letters come from a fallback font (Korean,
    // Japanese... in a Latin-only font) they are taller than this font's own metrics; the
    // probe gives the real row height and baseline, so rows don't overlap or get cut off.
    Text { id: probe; visible: false; font: fx.font; text: fx.text }
    readonly property real rowHeight: Math.max(fm.height, probe.implicitHeight)

    function layout(text, maxW, font) {
        var rows = TextUtil.layoutRows(text, maxW, fx.cfg.wrap, function (c) { return fm.advanceWidth(c); });
        var lineH = fx.rowHeight;
        rows.glyphs.forEach(function (g) {
            g.x += (maxW - rows.rowWidths[g.row]) * fx.cfg.alignment / 2;
            g.y = g.row * lineH;
        });
        return { list: rows.glyphs, height: rows.rowWidths.length * lineH };
    }

    function colorAt(i, n) {
        if (cfg.karaoke && i < progress * n) return cfg.karaokeColor;
        if (cfg.colorMode === 2) return Qt.hsla((((i * 0.035 - fxTime * cfg.rainbowSpeed / 100) % 1) + 1) % 1, 0.9, 0.68, 1);
        if (cfg.colorMode === 1) return Style.mix(cfg.textColor, cfg.textColor2, n > 1 ? i / (n - 1) : 0);
        return cfg.textColor;
    }

    Repeater {
        id: rep
        model: fx.glyphs.list
        Text {
            required property var modelData
            required property int index
            x: modelData.x
            // line every letter up on the row's baseline: letters from different fonts
            // have different heights
            y: modelData.y + (probe.baselineOffset - baselineOffset)
                + (fx.cfg.wave ? Math.sin(fx.fxTime * fx.cfg.waveSpeed / 100 * 8 + index * 0.55) * fx.cfg.waveAmplitude : 0)
            text: modelData.c
            font: fx.font
            color: fx.colorAt(index, rep.count)
            style: fx.cfg.outline ? Text.Outline : Text.Normal
            styleColor: fx.cfg.outlineColor
        }
    }
}
