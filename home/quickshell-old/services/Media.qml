import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property var players: Mpris.players?.values ?? []

    readonly property var active: {
        const ps = players
        if (!ps || ps.length === 0) return null
        for (let i = 0; i < ps.length; i++) {
            if (ps[i].isPlaying) return ps[i]
        }
        for (let i = 0; i < ps.length; i++) {
            if (ps[i].playbackState !== MprisPlaybackState.Stopped) return ps[i]
        }
        return ps[0]
    }

    readonly property bool available: active !== null
    readonly property string title:  active?.trackTitle  ?? ""
    readonly property string artist: active?.trackArtist ?? ""
    readonly property string album:  active?.trackAlbum  ?? ""
    readonly property string artUrl: {
        const raw = active?.trackArtUrl ?? ""
        if (raw !== "") return raw
        const url = active?.metadata?.["xesam:url"] ?? ""
        const m = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([A-Za-z0-9_-]{11})/)
        if (m) return "https://img.youtube.com/vi/" + m[1] + "/hqdefault.jpg"
        return ""
    }
    readonly property bool   isPlaying: active?.isPlaying ?? false
    readonly property real   position:  active?.position ?? 0
    readonly property real   length:    active?.length ?? 0
    readonly property bool   canPlay:     active?.canPlay ?? false
    readonly property bool   canPause:    active?.canPause ?? false
    readonly property bool   canNext:     active?.canGoNext ?? false
    readonly property bool   canPrev:     active?.canGoPrevious ?? false
    readonly property bool   canSeek:     active?.canSeek ?? false

    function togglePlay() { active?.togglePlaying() }
    function next()       { if (active?.canGoNext) active.next() }
    function previous()   { if (active?.canGoPrevious) active.previous() }
    function seekTo(ms)   { if (active?.canSeek) active.position = ms }
}
