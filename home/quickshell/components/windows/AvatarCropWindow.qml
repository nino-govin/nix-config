import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../../widgets/settings"

FloatingWindow {
    id: root

    readonly property real viewportSize: 340
    readonly property string outputDirectory: (Quickshell.env("XDG_DATA_HOME")
        || Quickshell.env("HOME") + "/.local/share") + "/quickshell"
    property url source: ""
    property real zoom: 1
    property real offsetX: 0
    property real offsetY: 0
    readonly property real baseScale: image.implicitWidth > 0 && image.implicitHeight > 0
        ? viewportSize / Math.min(image.implicitWidth, image.implicitHeight) : 1
    readonly property real scale: baseScale * zoom

    signal cropped(string path)

    function open(fileUrl: url): void {
        source = fileUrl;
        zoom = 1;
        visible = true;
    }

    function clampOffsets(): void {
        const width = image.implicitWidth * scale;
        const height = image.implicitHeight * scale;
        offsetX = Math.min(0, Math.max(viewportSize - width, offsetX));
        offsetY = Math.min(0, Math.max(viewportSize - height, offsetY));
    }

    function center(): void {
        offsetX = (viewportSize - image.implicitWidth * scale) / 2;
        offsetY = (viewportSize - image.implicitHeight * scale) / 2;
    }

    function setZoom(next: real): void {
        const previous = scale;
        zoom = Math.max(1, Math.min(6, next));
        const ratio = scale / previous;
        const middle = viewportSize / 2;
        offsetX = middle - (middle - offsetX) * ratio;
        offsetY = middle - (middle - offsetY) * ratio;
        clampOffsets();
    }

    function apply(): void {
        const size = Math.round(viewportSize / scale);
        const x = Math.round(-offsetX / scale);
        const y = Math.round(-offsetY / scale);
        const output = outputDirectory + "/avatar-" + Date.now() + ".png";
        cropper.output = output;
        cropper.command = ["sh", "-c",
            "mkdir -p \"$(dirname \"$2\")\" && rm -f \"$(dirname \"$2\")\"/avatar-*.png "
            + "&& magick \"$1\" -auto-orient -crop \"$3\" +repage -resize 512x512 \"$2\" "
            + "&& cp \"$2\" \"$HOME/.face\"",
            "sh", decodeURIComponent(source.toString().replace(/^file:\/\//, "")), output,
            size + "x" + size + "+" + x + "+" + y];
        cropper.running = true;
    }

    title: "Crop profile picture"
    visible: false
    color: Theme.shellBackgroundColor
    implicitWidth: 420
    implicitHeight: 520
    minimumSize: Qt.size(420, 520)
    maximumSize: Qt.size(420, 520)

    Process {
        id: cropper
        property string output: ""
        onExited: exitCode => {
            if (exitCode === 0) {
                root.cropped(output);
                root.visible = false;
            }
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 24
        }
        spacing: 16

        Text {
            text: "Crop profile picture"
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 17
            font.weight: Font.DemiBold
        }

        ClippingRectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.viewportSize
            Layout.preferredHeight: root.viewportSize
            radius: ShellMetrics.radiusLarge
            color: Theme.surfaceContainerColor

            Image {
                id: image
                x: root.offsetX
                y: root.offsetY
                width: implicitWidth * root.scale
                height: implicitHeight * root.scale
                source: root.source
                autoTransform: true
                smooth: true
                mipmap: true
                onStatusChanged: if (status === Image.Ready) root.center()
            }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    const context = getContext("2d");
                    context.reset();
                    context.fillStyle = "rgba(0, 0, 0, 0.55)";
                    context.fillRect(0, 0, width, height);
                    context.globalCompositeOperation = "destination-out";
                    context.beginPath();
                    context.arc(width / 2, height / 2, width / 2, 0, 2 * Math.PI);
                    context.fill();
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 2
                border.color: Theme.accentColor
            }

            MouseArea {
                property real startX: 0
                property real startY: 0
                property real startOffsetX: 0
                property real startOffsetY: 0

                anchors.fill: parent
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                onPressed: mouse => {
                    startX = mouse.x;
                    startY = mouse.y;
                    startOffsetX = root.offsetX;
                    startOffsetY = root.offsetY;
                }
                onPositionChanged: mouse => {
                    root.offsetX = startOffsetX + mouse.x - startX;
                    root.offsetY = startOffsetY + mouse.y - startY;
                    root.clampOffsets();
                }
                onWheel: wheel => root.setZoom(root.zoom * (wheel.angleDelta.y > 0 ? 1.1 : 1 / 1.1))
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Drag to move · scroll to zoom"
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 11
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }

            SettingsActionButton {
                label: "Cancel"
                onClicked: root.visible = false
            }

            SettingsActionButton {
                label: cropper.running ? "Saving…" : "Apply"
                primary: true
                enabled: !cropper.running && image.status === Image.Ready
                onClicked: root.apply()
            }
        }
    }
}
