import QtQuick
import ".."
import "../../../services"

Column {
    width: parent ? parent.width : 0
    spacing: 12

    SettingsGroup {
        SettingsChoiceRow {
            width: parent.width
            title: "Visibility"
            detail: "Show widgets only on an empty desktop, always, or never"
            value: SettingsService.draftValue("floatingWidgetVisibilityMode")
            options: [
                { value: "desktop", label: "Desktop only" },
                { value: "always", label: "Always" },
                { value: "hidden", label: "Hidden" }
            ]
            showSeparator: true
            onValueRequested: value => SettingsService.setDraftValue("floatingWidgetVisibilityMode", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Widget scale"
            detail: "Scale desktop cards while keeping automatic placement"
            value: SettingsService.draftValue("floatingWidgetScale")
            minimum: 0.70; maximum: 1.35; step: 0.05; decimals: 2; suffix: "×"
            showSeparator: true
            onValueRequested: value => SettingsService.setDraftValue("floatingWidgetScale", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Opacity"
            detail: "Adjust the opacity of the complete desktop widget layer"
            value: SettingsService.draftValue("floatingWidgetOpacity")
            minimum: 0.35; maximum: 1.0; step: 0.05; decimals: 2
            showSeparator: true
            onValueRequested: value => SettingsService.setDraftValue("floatingWidgetOpacity", value)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Lock placement"
            detail: "Keep the current automatic placement instead of recomputing it"
            checked: SettingsService.draftValue("floatingWidgetLockPlacement")
            onToggleRequested: SettingsService.setDraftValue("floatingWidgetLockPlacement", !checked)
        }
    }

    SettingsGroup {
        SettingsToggleRow { width: parent.width; title: "Clock"; detail: "Large desktop clock"; checked: SettingsService.draftValue("clockWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("clockWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Weather"; detail: "Current weather summary"; checked: SettingsService.draftValue("weatherWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("weatherWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Calendar"; detail: "Monthly calendar"; checked: SettingsService.draftValue("calendarWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("calendarWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "CPU temperature"; detail: "Processor thermal card"; checked: SettingsService.draftValue("cpuTemperatureWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("cpuTemperatureWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "CPU usage"; detail: "Processor utilization card"; checked: SettingsService.draftValue("cpuUsageWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("cpuUsageWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "GPU temperature"; detail: "Shown only when a supported GPU is available"; checked: SettingsService.draftValue("gpuTemperatureWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("gpuTemperatureWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "GPU usage"; detail: "Dedicated GPU load and VRAM, shown while it is active"; checked: SettingsService.draftValue("gpuUsageWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("gpuUsageWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "UV index"; detail: "Requires configured weather data"; checked: SettingsService.draftValue("uvIndexWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("uvIndexWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Humidity"; detail: "Requires configured weather data"; checked: SettingsService.draftValue("humidityWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("humidityWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Air quality"; detail: "Shown only when air-quality data is available"; checked: SettingsService.draftValue("airQualityWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("airQualityWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Download"; detail: "Incoming network throughput"; checked: SettingsService.draftValue("networkDownloadWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("networkDownloadWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Upload"; detail: "Outgoing network throughput"; checked: SettingsService.draftValue("networkUploadWidget"); showSeparator: true; onToggleRequested: SettingsService.setDraftValue("networkUploadWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Disk"; detail: "Root filesystem usage"; checked: SettingsService.draftValue("diskUsageWidget"); onToggleRequested: SettingsService.setDraftValue("diskUsageWidget", !checked) }
    }

    SettingsGroup {
        SettingsToggleRow {
            width: parent.width
            title: "Claude crab"
            detail: "Animated companion following Claude Code sessions"
            checked: SettingsService.draftValue("clawdWidget")
            showSeparator: true
            onToggleRequested: SettingsService.setDraftValue("clawdWidget", !checked)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Crab size"
            detail: "Screen pixels per sprite pixel"
            value: SettingsService.draftValue("clawdScale")
            minimum: 3; maximum: 8; step: 1; decimals: 0; suffix: "×"
            showSeparator: true
            onValueRequested: value => SettingsService.setDraftValue("clawdScale", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Crab activity"
            detail: "How often the crab wanders, jumps and pokes widgets"
            value: SettingsService.draftValue("clawdActivity")
            minimum: 0.5; maximum: 2.0; step: 0.1; decimals: 1; suffix: "×"
            onValueRequested: value => SettingsService.setDraftValue("clawdActivity", value)
        }
    }
}
