import QtQuick
import ".."
import "../../../services"

Column {
    width: parent ? parent.width : 0
    spacing: 12

    SettingsGroup {
        SettingsToggleRow {
            width: parent.width
            title: "Keep awake"
            detail: "Stop hypridle so the session never locks or suspends on idle"
            checked: IdleInhibitService.inhibited
            onToggleRequested: IdleInhibitService.toggle()
        }
    }

    SettingsGroup {
        SettingsChoiceRow {
            width: parent.width
            title: "Power profile"
            detail: "CPU governor, refresh rate and compositor effects"
            value: PowerProfileService.mode
            options: [
                { value: "economy", label: "Economy" },
                { value: "balanced", label: "Balanced" },
                { value: "performance", label: "Performance" }
            ]
            onValueRequested: value => PowerProfileService.setMode(value)
        }
    }
}
