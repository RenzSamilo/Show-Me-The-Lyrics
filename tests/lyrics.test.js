// Run: node tests/lyrics.test.js
const assert = require("assert");
const fs = require("fs");
const path = require("path");

const src = fs.readFileSync(path.join(__dirname, "../package/contents/code/lyrics.js"), "utf8");
const L = new Function(src + "; return { parseLrc, indexAt, cleanTitle, pickBest, query };")();

const lines = L.parseLrc("[ar: Someone]\n[00:01.50]first\n[01:02.00][00:10.00]chorus\n[00:20.00]\nno stamp\n[00:05:25]colon");
assert.deepStrictEqual(lines.map((l) => l.t), [1500, 5250, 10000, 20000, 62000]);
assert.deepStrictEqual(lines.map((l) => l.text), ["first", "colon", "chorus", "", "chorus"]);

assert.strictEqual(L.indexAt(lines, 0), -1);
assert.strictEqual(L.indexAt(lines, 1500), 0);
assert.strictEqual(L.indexAt(lines, 19999), 2);
assert.strictEqual(L.indexAt(lines, 999999), 4);
assert.strictEqual(L.indexAt([], 5), -1);

assert.strictEqual(L.cleanTitle("Song - Remastered 2011"), "Song");
assert.strictEqual(L.cleanTitle("Song (feat. X) [Live]"), "Song");

const results = [
    { duration: 200, syncedLyrics: null },
    { duration: 215, syncedLyrics: "[00:01.00]far" },
    { duration: 202, syncedLyrics: "[00:01.00]near" },
];
assert.strictEqual(L.pickBest(results, 200).duration, 202);
assert.strictEqual(L.pickBest(results, 300), null);
assert.strictEqual(L.pickBest([], 200), null);

assert.strictEqual(L.query({ a: "x y&z", b: "", c: 0, d: 3 }), "a=x%20y%26z&d=3");

console.log("lyrics.js ok");
