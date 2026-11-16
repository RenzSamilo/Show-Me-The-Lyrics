// Run: node tests/text.test.js
const assert = require("assert");
const fs = require("fs");
const path = require("path");

const src = fs.readFileSync(path.join(__dirname, "../package/contents/code/text.js"), "utf8");
const T = new Function(src + "; return { clusters, breaksAnywhere, layoutRows };")();

// clusters: combining accent, decomposed Hangul, ZWJ emoji, skin tone stay with their base
assert.deepStrictEqual(T.clusters("ab"), ["a", "b"]);
assert.deepStrictEqual(T.clusters("éx"), ["é", "x"]);
assert.deepStrictEqual(T.clusters("한a"), ["한", "a"]);
assert.deepStrictEqual(T.clusters("\u{1F468}‍\u{1F469}!"), ["\u{1F468}‍\u{1F469}", "!"]);
assert.deepStrictEqual(T.clusters("\u{1F44D}\u{1F3FD}"), ["\u{1F44D}\u{1F3FD}"]);
assert.deepStrictEqual(T.clusters("한글"), ["한", "글"]);
assert.deepStrictEqual(T.clusters(""), []);

assert.strictEqual(T.breaksAnywhere("日"), true);   // kanji
assert.strictEqual(T.breaksAnywhere("あ"), true);   // hiragana
assert.strictEqual(T.breaksAnywhere("한"), false);  // hangul syllable
assert.strictEqual(T.breaksAnywhere("a"), false);

const ten = () => 10;
const rowsOf = (r) => r.glyphs.map((g) => g.row);

// words wrap whole
let r = T.layoutRows("aaa bbb ccc", 80, true, ten);
assert.deepStrictEqual(rowsOf(r), [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1]);
assert.deepStrictEqual(r.rowWidths, [80, 30]);

// no wrapping when off
r = T.layoutRows("aaa bbb ccc", 50, false, ten);
assert.deepStrictEqual(r.rowWidths, [110]);

// text without spaces (CJK) breaks anywhere, never past the edge
r = T.layoutRows("日本語日本語日", 30, true, ten);
assert.deepStrictEqual(rowsOf(r), [0, 0, 0, 1, 1, 1, 2]);
assert.ok(r.rowWidths.every((w) => w <= 30));

// one word wider than the line is broken instead of overflowing
r = T.layoutRows("abcdefgh", 30, true, ten);
assert.deepStrictEqual(r.rowWidths, [30, 30, 20]);

// korean wraps by word
r = T.layoutRows("한글 한글", 40, true, ten);
assert.deepStrictEqual(rowsOf(r), [0, 0, 0, 1, 1]);

// each glyph starts where the previous one ended
r = T.layoutRows("ab c", 100, true, ten);
assert.deepStrictEqual(r.glyphs.map((g) => g.x), [0, 10, 20, 30]);

console.log("text.js ok");
