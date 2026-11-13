import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../components/state"
import "../../components/theme"
import "../../components/common"

Item {
    id: root

    readonly property string path: OverlayState.screenshotPath
    readonly property string fileName: path.split("/").pop()
    readonly property string directory: path.slice(0, path.lastIndexOf("/"))

    function annotate(): void {
        Quickshell.execDetached(["satty", "--filename", path, "--output-filename", path,
            "--copy-command", "wl-copy", "--early-exit"]);
        OverlayState.hideScreenshot();
    }

    function remove(): void {
        Quickshell.execDetached(["rm", "-f", path]);
        OverlayState.hideScreenshot();
    }

    HoverHandler {
        onHoveredChanged: OverlayState.screenshotHovered = hovered
    }

    RowLayout {
        anchors {
            fill: parent
            margins: 14
            rightMargin: 14 + ShellMetrics.panelScreenEdgeOverlap
        }
        spacing: 14

        Rectangle {
            Layout.preferredWidth: 168
            Layout.fillHeight: true
            radius: ShellMetrics.radiusLarge
            color: Theme.panelSurfaceColor
            clip: true

            Image {
                anchors.fill: parent
                source: root.path !== "" ? "file://" + root.path : ""
                sourceSize.width: 336
                fillMode: Image.PreserveAspectCrop
                cache: false
                asynchronous: true
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: {
                    Quickshell.execDetached(["xdg-open", root.path]);
                    OverlayState.hideScreenshot();
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: "Screenshot"
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.bodyMedium
                font.weight: Font.Medium
            }

            Text {
                Layout.fillWidth: true
                text: "Copied · " + root.fileName
                elide: Text.ElideMiddle
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.labelSmall
            }

            Item {
                Layout.fillHeight: true
            }

            Row {
                spacing: 4

                IconButton {
                    icon: Icons.annotate
                    onClicked: root.annotate()
                }

                IconButton {
                    icon: Icons.folder
                    onClicked: {
                        Quickshell.execDetached(["xdg-open", root.directory]);
                        OverlayState.hideScreenshot();
                    }
                }

                IconButton {
                    icon: Icons.trash
                    danger: true
                    onClicked: root.remove()
                }

                IconButton {
                    icon: Icons.close
                    onClicked: OverlayState.hideScreenshot()
                }
            }
        }
    }
}
