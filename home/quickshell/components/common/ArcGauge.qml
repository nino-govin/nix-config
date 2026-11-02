import QtQuick
import "../theme"

Item {
    id: root

    property var segments: []
    property var markers: []
    property color trackColor: Theme.surfaceBorderColor
    property real thickness: 14
    property real markerOverhang: 4
    readonly property real padding: thickness / 2 + markerOverhang
    readonly property real radius: Math.max(0, width / 2 - padding)
    readonly property real centerY: padding + radius

    implicitWidth: 240
    implicitHeight: implicitWidth / 2 + padding

    onSegmentsChanged: canvas.requestPaint()
    onMarkersChanged: canvas.requestPaint()
    onTrackColorChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()

    Canvas {
        id: canvas

        anchors.fill: parent

        function angle(value: real): real {
            return Math.PI + Math.PI * Math.max(0, Math.min(1, value));
        }

        onPaint: {
            const context = getContext("2d");
            const centerX = width / 2;
            context.clearRect(0, 0, width, height);
            context.lineWidth = root.thickness;

            context.lineCap = "round";
            context.strokeStyle = root.trackColor;
            context.beginPath();
            context.arc(centerX, root.centerY, root.radius, angle(0), angle(1));
            context.stroke();

            context.lineCap = "butt";
            let start = 0;
            for (const segment of root.segments) {
                const end = Math.min(1, start + Math.max(0, segment.value));
                if (end > start) {
                    context.strokeStyle = segment.color;
                    context.fillStyle = segment.color;
                    context.beginPath();
                    context.arc(centerX, root.centerY, root.radius, angle(start), angle(end));
                    context.stroke();
                    for (const edge of [0, 1]) {
                        if (edge < start || edge > end)
                            continue;
                        const edgeAngle = angle(edge);
                        const capStart = edge === 0 ? edgeAngle - Math.PI : edgeAngle;
                        context.beginPath();
                        context.arc(centerX + root.radius * Math.cos(edgeAngle),
                            root.centerY + root.radius * Math.sin(edgeAngle),
                            root.thickness / 2, capStart, capStart + Math.PI);
                        context.fill();
                    }
                }
                start = end;
            }

            const inner = root.radius - root.thickness / 2 - root.markerOverhang;
            const outer = root.radius + root.thickness / 2 + root.markerOverhang;
            context.lineCap = "round";
            for (const marker of root.markers) {
                const markerAngle = angle(marker.value);
                context.lineWidth = marker.width || 2;
                context.strokeStyle = marker.color;
                context.beginPath();
                context.moveTo(centerX + inner * Math.cos(markerAngle), root.centerY + inner * Math.sin(markerAngle));
                context.lineTo(centerX + outer * Math.cos(markerAngle), root.centerY + outer * Math.sin(markerAngle));
                context.stroke();
            }
        }
    }
}
