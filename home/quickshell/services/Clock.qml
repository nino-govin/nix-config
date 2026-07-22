import QtQuick

QtObject {
    readonly property string time: Qt.formatTime(now, "HH:mm")
    readonly property string date: Qt.formatDate(now, "dddd d MMMM yyyy")
    property var    now:  new Date()

    property Timer _t: Timer {
        interval: 1000
        running:  true
        repeat:   true
        onTriggered: now = new Date()
    }
}
