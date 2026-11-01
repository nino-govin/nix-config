import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property int  volumePercent: Math.round(volume * 100)
    readonly property string sinkName: sink?.description ?? sink?.name ?? "—"

    signal changed

    property PwObjectTracker _tracker: PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    property Connections _sinkConn: Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() { root.changed() }
        function onMutedChanged()  { root.changed() }
    }

    function setVolume(v) {
        if (!sink?.audio) return
        sink.audio.volume = Math.max(0, Math.min(1.5, v))
        if (sink.audio.muted && v > 0) sink.audio.muted = false
    }

    function setMuted(m) {
        if (!sink?.audio) return
        sink.audio.muted = m
    }

    function toggleMute() {
        if (!sink?.audio) return
        sink.audio.muted = !sink.audio.muted
    }
}
