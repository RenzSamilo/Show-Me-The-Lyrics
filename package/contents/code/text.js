// Pure text helpers for the letter-by-letter renderer (FxText). No QML types, so
// tests/text.test.js can load it in node.

// Split into what a reader sees as one letter: a base character plus any combining
// marks, variation selectors, Hangul medial/final jamo, emoji skin tones and ZWJ joins.
// shortcut: hand-picked ranges, not full Unicode grapheme rules; scripts that need
// shaping across letters (Arabic, Indic, Thai) never reach here, LyricLine draws them whole.
function clusters(text) {
    var out = [], joinNext = false;
    Array.from(text || "").forEach(function (c) {
        var cp = c.codePointAt(0);
        var attaches = joinNext
            || (cp >= 0x0300 && cp <= 0x036F) || (cp >= 0x1AB0 && cp <= 0x1AFF)
            || (cp >= 0x1DC0 && cp <= 0x1DFF) || (cp >= 0x20D0 && cp <= 0x20FF)
            || (cp >= 0xFE00 && cp <= 0xFE0F) || (cp >= 0xFE20 && cp <= 0xFE2F)
            || (cp >= 0x1160 && cp <= 0x11FF) || (cp >= 0x1F3FB && cp <= 0x1F3FF)
            || cp === 0x200D || cp === 0x3099 || cp === 0x309A;
        if (attaches && out.length) out[out.length - 1] += c;
        else out.push(c);
        joinNext = cp === 0x200D;
    });
    return out;
}

// Chinese and Japanese are written without spaces: a line may break after any character.
// (Korean uses spaces, so it wraps by word like Latin text.)
function breaksAnywhere(cluster) {
    var cp = cluster.codePointAt(0);
    return (cp >= 0x2E80 && cp <= 0x9FFF) || (cp >= 0xF900 && cp <= 0xFAFF)
        || (cp >= 0xFF00 && cp <= 0xFFEF) || cp >= 0x20000;
}

// Place letters left to right, wrapping at word boundaries (or anywhere for CJK, or inside
// a word wider than the whole line). measure(cluster) returns its advance width.
// Returns { glyphs: [{c, x, row}], rowWidths: [w per row] }.
function layoutRows(text, maxW, wrap, measure) {
    var glyphs = [], rowWidths = [], x = 0, row = 0, word = [], wordW = 0;
    function newRow() { rowWidths.push(x); x = 0; row++; }
    function flush() {
        if (wrap && x > 0 && x + wordW > maxW) newRow();
        word.forEach(function (g) {
            if (wrap && x > 0 && x + g.w > maxW) newRow();
            glyphs.push({ c: g.c, x: x, row: row });
            x += g.w;
        });
        word = []; wordW = 0;
    }
    clusters(text).forEach(function (c) {
        var w = measure(c);
        word.push({ c: c, w: w }); wordW += w;
        if (c === " " || breaksAnywhere(c)) flush();
    });
    flush();
    rowWidths.push(x);
    return { glyphs: glyphs, rowWidths: rowWidths };
}
