import QtQuick
import "../code/style.js" as Style

// One line drawn letter by letter, so each letter can have its own colour and offset
// (gradient, rainbow, karaoke fill, wave). Wraps at word boundaries itself.
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

    function layout(text, maxW, font) {
        var out = [], rowWidths = [], x = 0, row = 0, word = [], wordW = 0;
        function flush() {
            if (fx.cfg.wrap && x > 0 && x + wordW > maxW) { rowWidths.push(x); x = 0; row++; }
            word.forEach(function (g) { out.push({ c: g.c, x: x, row: row }); x += g.w; });
            word = []; wordW = 0;
        }
        Array.from(text).forEach(function (c) {
            var w = fm.advanceWidth(c);
            word.push({ c: c, w: w }); wordW += w;
            if (c === " ") flush();
        });
        flush();
        rowWidths.push(x);
        var lineH = fm.height;
        out.forEach(function (g) {
            g.x += (maxW - rowWidths[g.row]) * fx.cfg.alignment / 2;
            g.y = g.row * lineH;
        });
        return { list: out, height: (row + 1) * lineH };
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
            y: modelData.y + (fx.cfg.wave ? Math.sin(fx.fxTime * fx.cfg.waveSpeed / 100 * 8 + index * 0.55) * fx.cfg.waveAmplitude : 0)
            text: modelData.c
            font: fx.font
            color: fx.colorAt(index, rep.count)
            style: fx.cfg.outline ? Text.Outline : Text.Normal
            styleColor: fx.cfg.outlineColor
        }
    }
}
