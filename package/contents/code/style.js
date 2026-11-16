// Style helpers and the built-in presets. A preset stores every Style + Animation key
// (see config/main.xml) except fontSize, so applying one never leaves stale settings behind.

var base = {
    fontFamily: "", bold: true, italic: false, uppercase: false, letterSpacing: 0,
    textColor: "#ffffff", colorMode: 0, textColor2: "#ff7ab8", inactiveColor: "#ffffff",
    outline: false, outlineColor: "#000000",
    shadowMode: 2, shadowColor: "#000000", shadowStrength: 60,
    backdrop: false, backdropColor: "#000000", backdropOpacity: 50, backdropRadius: 12,
    transition: 1, transitionMs: 300,
    karaoke: false, karaokeColor: "#ffd54a",
    wave: false, waveAmplitude: 4, waveSpeed: 50, rainbowSpeed: 30
};

// colorMode: 0 solid, 1 gradient, 2 rainbow. shadowMode: 0 none, 1 glow, 2 drop shadow.
// transition: 0 none, 1 scroll, 2 fade, 3 pop.
var builtin = [
    { name: "Clean", style: {} },
    { name: "Neon", style: { textColor: "#e9b8ff", inactiveColor: "#b77bd6", shadowMode: 1, shadowColor: "#c13bff", shadowStrength: 100, transition: 2 } },
    { name: "Stage", style: { uppercase: true, letterSpacing: 2, textColor: "#fff6d6", outline: true, outlineColor: "#3a2a00", shadowMode: 1, shadowColor: "#ffc94a", shadowStrength: 70, transition: 3 } },
    { name: "Rainbow Wave", style: { colorMode: 2, wave: true, waveAmplitude: 5, shadowStrength: 40 } },
    { name: "Karaoke", style: { textColor: "#f2e6c8", karaoke: true, karaokeColor: "#ffb300", outline: true, outlineColor: "#2b1d00" } },
    { name: "Sunset", style: { colorMode: 1, textColor: "#ffb347", textColor2: "#ff5e8a", inactiveColor: "#ffd9b0", shadowColor: "#5a1030" } },
    { name: "Retro", style: { fontFamily: "monospace", uppercase: true, letterSpacing: 3, textColor: "#7dffb0", inactiveColor: "#3fae74", shadowMode: 1, shadowColor: "#00ff88", shadowStrength: 50, transition: 0 } },
    { name: "Whisper", style: { bold: false, italic: true, textColor: "#dfe6f5", inactiveColor: "#aab4c8", shadowMode: 0, transition: 2, transitionMs: 700 } },
    { name: "Midnight", style: { colorMode: 1, textColor: "#8ec5ff", textColor2: "#b69cff", inactiveColor: "#7f95c9", shadowMode: 1, shadowColor: "#2f6bff", shadowStrength: 80 } },
    { name: "Subtitle", style: { bold: false, shadowMode: 0, backdrop: true, backdropOpacity: 65, backdropRadius: 6, transition: 0 } },
    { name: "Party", style: { colorMode: 2, rainbowSpeed: 80, uppercase: true, wave: true, waveAmplitude: 8, waveSpeed: 90, outline: true, transition: 3 } }
];

function resolve(overrides) {
    return Object.assign({}, base, overrides);
}

// Current values of every preset key, read from a config map.
function capture(cfg) {
    var out = {};
    Object.keys(base).forEach(function (k) { out[k] = cfg[k]; });
    return out;
}

function font(cfg, px) {
    var f = {
        pixelSize: Math.max(1, Math.round(px)), bold: cfg.bold, italic: cfg.italic,
        letterSpacing: cfg.letterSpacing
    };
    if (cfg.fontFamily) f.family = cfg.fontFamily;
    return Qt.font(f);
}

function mix(a, b, t) {
    a = Qt.color(a); b = Qt.color(b);
    return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
}

function alpha(c, a) {
    c = Qt.color(c);
    return Qt.rgba(c.r, c.g, c.b, a);
}
