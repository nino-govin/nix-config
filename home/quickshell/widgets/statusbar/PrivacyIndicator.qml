import QtQuick
import "../../components/common"
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    readonly property bool revealed: SettingsService.statusBarShowPrivacy && PrivacyService.anyActive
    readonly property var entries: [
        { active: PrivacyService.microphoneActive, icon: Icons.microphone, apps: PrivacyService.microphoneApps },
        { active: PrivacyService.cameraActive, icon: Icons.camera, apps: PrivacyService.cameraApps },
        { active: PrivacyService.screencastActive, icon: Icons.screenShare, apps: PrivacyService.screencastApps }
    ].filter(entry => entry.active)
    readonly property string appsText: PrivacyService.unique(entries
        .reduce((names, entry) => names.concat(entry.apps), [])).join(", ")
    readonly property bool expanded: hover.hovered && appsText !== ""

    visible: width > 0.5
    width: revealed ? content.width + 20 : 0
    height: 26
    radius: height / 2
    color: Theme.dangerColor
    opacity: revealed ? 1 : 0
    clip: true

    Behavior on width {
        MotionAnimation { type: MotionAnimation.FastSpatial }
    }

    Behavior on opacity {
        MotionAnimation { type: MotionAnimation.FastEffects }
    }

    Row {
        id: content

        anchors.verticalCenter: parent.verticalCenter
        x: 10
        height: parent.height
        spacing: 8

        Repeater {
            model: root.entries

            Text {
                required property var modelData
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.icon
                color: Theme.dangerTextColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 15
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: root.expanded ? Math.min(implicitWidth, 260) : 0
            visible: width > 0.5
            text: root.appsText
            elide: Text.ElideRight
            color: Theme.dangerTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 13
            font.weight: Font.Medium

            Behavior on width {
                MotionAnimation { type: MotionAnimation.FastSpatial }
            }
        }
    }

    HoverHandler {
        id: hover
    }
}
