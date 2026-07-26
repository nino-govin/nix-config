import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property string icon:        "menu"
    property int    size:        16
    property color  color:       "#d8dee9"
    property real   strokeWidth: 2.0

    implicitWidth:  size
    implicitHeight: size

    readonly property var _paths: ({
        wifi:      "M2 8.5a15 15 0 0 1 20 0 M5.5 12a10 10 0 0 1 13 0 M9 15.5a5 5 0 0 1 6 0 M12 19h.01",
        bluetooth: "M7 7l10 10-5 5V2l5 5L7 17",
        airplane:  "M12 2l3 7 7 2-7 2-3 7-3-7-7-2 7-2z",
        moon:      "M20 14.5A8.5 8.5 0 1 1 9.5 4a7 7 0 0 0 10.5 10.5z",
        sun:       "M12 5V2M12 22v-3M5 12H2M22 12h-3M5.6 5.6L3.5 3.5M20.5 20.5l-2.1-2.1M18.4 5.6l2.1-2.1M3.5 20.5l2.1-2.1M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8z",
        music:     "M9 18V5l11-2v13M9 18a3 3 0 1 1-6 0 3 3 0 0 1 6 0zM20 16a3 3 0 1 1-6 0 3 3 0 0 1 6 0z",
        mic:       "M12 2a3 3 0 0 0-3 3v6a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3zM5 11a7 7 0 0 0 14 0M12 18v3",
        speaker:   "M4 9h4l6-5v16l-6-5H4V9zM16 9a4 4 0 0 1 0 6",
        power:     "M12 2v9M6 6a8 8 0 1 0 12 0",
        lock:      "M6 11V8a6 6 0 0 1 12 0v3M5 11h14v9H5z",
        logout:    "M9 3H4v18h5M14 8l5 4-5 4M19 12H8",
        restart:   "M20 12a8 8 0 1 1-2.9-6.2M20 4v5h-5",
        suspend:   "M12 3a9 9 0 1 0 9 9M12 3v6l4 2",
        check:     "M4 12l5 5 11-11",
        alert:     "M12 3l10 18H2zM12 10v4M12 17h.01",
        download:  "M12 3v12M7 11l5 5 5-5M5 21h14",
        code:      "M9 6l-6 6 6 6M15 6l6 6-6 6",
        chat:      "M4 4h16v12H8l-4 4z",
        browser:   "M3 12a9 9 0 1 0 18 0 9 9 0 0 0-18 0zM3 12h18M12 3a14 14 0 0 1 0 18 14 14 0 0 1 0-18z",
        terminal:  "M4 5h16v14H4zM7 9l3 3-3 3M12 15h5",
        folder:    "M3 6h6l2 2h10v10H3z",
        cpu:       "M8 8h8v8H8zM8 2v3M12 2v3M16 2v3M8 19v3M12 19v3M16 19v3M2 8h3M2 12h3M2 16h3M19 8h3M19 12h3M19 16h3",
        gpu:       "M4 7h16v10H4zM8 7V4M12 7V4M16 7V4M8 17v3M12 17v3M16 17v3",
        ram:       "M4 9h16v6H4zM7 9V6M11 9V6M15 9V6M17 9V6",
        battery:   "M2 9h16v6H2zM18 11h2v2h-2z",
        zap:       "M13 2L3 14h9l-1 8 10-12h-9l1-8z",
        menu:      "M4 7h16M4 12h16M4 17h16",
        gear:      "M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8zM12 2v3M12 19v3M4.2 4.2l2.1 2.1M17.7 17.7l2.1 2.1M2 12h3M19 12h3M4.2 19.8l2.1-2.1M17.7 6.3l2.1-2.1",
        edit:      "M12 20h9M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"
    })

    Shape {
        width:           24
        height:          24
        scale:           root.size / 24
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.strokeWidth
            fillColor:   "transparent"
            capStyle:    ShapePath.RoundCap
            joinStyle:   ShapePath.RoundJoin
            PathSvg { path: root._paths[root.icon] ?? root._paths.menu }
        }
    }
}
