import QtQuick
import ".."
import "../../../services"

Column {
    width: parent ? parent.width : 0
    spacing: 12

    SettingsGroup {
        SettingsToggleRow {
            width: parent.width
            title: "Show Clawd"
            detail: "Animated companion following Claude Code sessions"
            checked: SettingsService.draftValue("clawdWidget")
            showSeparator: true
            onToggleRequested: SettingsService.setDraftValue("clawdWidget", !checked)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Size"
            detail: "Screen pixels per sprite pixel"
            value: SettingsService.draftValue("clawdScale")
            minimum: 3; maximum: 8; step: 1; decimals: 0; suffix: "×"
            showSeparator: true
            onValueRequested: value => SettingsService.setDraftValue("clawdScale", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Activity"
            detail: "How often the crab wanders, jumps and pokes widgets"
            value: SettingsService.draftValue("clawdActivity")
            minimum: 0.5; maximum: 2.0; step: 0.1; decimals: 1; suffix: "×"
            onValueRequested: value => SettingsService.setDraftValue("clawdActivity", value)
        }
    }

    SettingsGroup {
        SettingsSliderRow {
            width: parent.width
            title: "Sound volume"
            detail: "Master volume of every crab sound"
            value: SettingsService.draftValue("clawdVolume")
            minimum: 0; maximum: 100; step: 5; decimals: 0; suffix: "%"
            showSeparator: true
            onValueRequested: value => SettingsService.setDraftValue("clawdVolume", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Alerts"
            detail: "Claude needs you or finished its turn"
            value: SettingsService.draftValue("clawdVolumeAlerts")
            minimum: 0; maximum: 100; step: 5; decimals: 0; suffix: "%"
            showSeparator: true
            onValueRequested: value => SettingsService.setDraftValue("clawdVolumeAlerts", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Handling"
            detail: "Grabs, shakes, throws, splats and crashes"
            value: SettingsService.draftValue("clawdVolumeHandling")
            minimum: 0; maximum: 100; step: 5; decimals: 0; suffix: "%"
            showSeparator: true
            onValueRequested: value => SettingsService.setDraftValue("clawdVolumeHandling", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Stunts"
            detail: "Jumps, landings, pokes, grapple, balloon and parachute"
            value: SettingsService.draftValue("clawdVolumeStunts")
            minimum: 0; maximum: 100; step: 5; decimals: 0; suffix: "%"
            showSeparator: true
            onValueRequested: value => SettingsService.setDraftValue("clawdVolumeStunts", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Ambient"
            detail: "Footsteps, snoring, typing and idle activities"
            value: SettingsService.draftValue("clawdVolumeAmbient")
            minimum: 0; maximum: 100; step: 5; decimals: 0; suffix: "%"
            onValueRequested: value => SettingsService.setDraftValue("clawdVolumeAmbient", value)
        }
    }
}
