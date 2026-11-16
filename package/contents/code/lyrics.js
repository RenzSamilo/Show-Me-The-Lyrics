// Pure helpers: LRC parsing, line lookup, LRCLIB lookup. No QML types, so tests/lyrics.test.js can load it in node.

var API = "https://lrclib.net/api";

// "[01:02.50][02:10.00]text" -> [{t: 62500, text}, {t: 130000, text}], sorted by time.
function parseLrc(text) {
    var out = [];
    var stamp = /\[(\d+):(\d+(?:[.:]\d+)?)\]/g;
    (text || "").split(/\r?\n/).forEach(function (raw) {
        var times = [], m, end = 0;
        stamp.lastIndex = 0;
        while ((m = stamp.exec(raw)) && m.index === end) {
            times.push(Math.round((parseInt(m[1], 10) * 60 + parseFloat(m[2].replace(":", "."))) * 1000));
            end = stamp.lastIndex;
        }
        var body = raw.slice(end).trim();
        times.forEach(function (t) { out.push({ t: t, text: body }); });
    });
    return out.sort(function (a, b) { return a.t - b.t; });
}

// Index of the last line starting at or before ms; -1 before the first line.
function indexAt(lines, ms) {
    var lo = 0, hi = lines.length - 1, ans = -1;
    while (lo <= hi) {
        var mid = (lo + hi) >> 1;
        if (lines[mid].t <= ms) { ans = mid; lo = mid + 1; } else { hi = mid - 1; }
    }
    return ans;
}

// "Song - Remastered 2011" / "Song (feat. X)" -> "Song", for the fuzzy search fallback.
function cleanTitle(title) {
    return (title || "").replace(/\s+-\s+.*$/, "").replace(/\s*[(\[][^)\]]*[)\]]/g, "").trim();
}

// From search results, the synced entry whose duration is closest to ours.
function pickBest(results, durationSec) {
    var best = null, bestDiff = Infinity;
    (results || []).forEach(function (r) {
        if (!r.syncedLyrics) return;
        var diff = durationSec > 0 ? Math.abs((r.duration || 0) - durationSec) : 0;
        if (diff < bestDiff) { best = r; bestDiff = diff; }
    });
    // More than 10s off is almost certainly a different recording.
    return bestDiff <= 10 ? best : null;
}

function query(params) {
    return Object.keys(params).filter(function (k) { return params[k] !== "" && params[k] !== 0; })
        .map(function (k) { return k + "=" + encodeURIComponent(params[k]); }).join("&");
}

function getJson(url, cb) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        var data = null;
        if (xhr.status === 200) { try { data = JSON.parse(xhr.responseText); } catch (e) {} }
        cb(data, xhr.status);
    };
    xhr.open("GET", url);
    xhr.setRequestHeader("User-Agent", "SMTL/0.1");
    xhr.send();
}

// cb(lines) with parsed synced lyrics, [] when the track has none, or null on a network error (don't cache).
function fetchLyrics(track, artist, album, durationSec, cb) {
    var exact = { track_name: track, artist_name: artist, album_name: album, duration: Math.round(durationSec) };
    getJson(API + "/get?" + query(exact), function (hit, status) {
        if (hit && hit.syncedLyrics) return cb(parseLrc(hit.syncedLyrics));
        if (status !== 200 && status !== 404) return cb(null);
        getJson(API + "/search?" + query({ track_name: cleanTitle(track), artist_name: artist }), function (list, status2) {
            if (!list) return cb(status2 === 404 ? [] : null);
            var best = pickBest(list, durationSec);
            cb(best ? parseLrc(best.syncedLyrics) : []);
        });
    });
}
