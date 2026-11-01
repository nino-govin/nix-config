import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../theme"
import "../widgets"

PanelWindow {
    id: root

    WlrLayershell.namespace:     "quickshell-notifs"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { right: true; top: true }
    implicitWidth:  380
    implicitHeight: _stack.implicitHeight + 40
    color: "transparent"
    visible: _server.trackedNotifications.count > 0

    NotificationServer {
        id: _server
        keepOnReload:         false
        actionsSupported:     true
        bodySupported:        true
        bodyMarkupSupported:  false
        persistenceSupported: true
    }

    function _variant(n) {
        if (n.urgency === NotificationUrgency.Critical) return "warning"
        const cat = n.hints?.["category"] ?? ""
        if (cat === "transfer.complete") return "download"
        if (cat === "success")           return "success"
        return "neutral"
    }

    function _iconForVariant(v, n) {
        if (v === "warning")  return "alert"
        if (v === "download") return "download"
        if (v === "success")  return "check"
        return "check"
    }

    Column {
        id: _stack
        anchors {
            top: parent.top; right: parent.right
            topMargin: 20; rightMargin: 20
        }
        width:   340
        spacing: 10

        Repeater {
            model: _server.trackedNotifications

            NotificationCard {
                width:    parent.width
                variant:  root._variant(modelData)
                iconName: root._iconForVariant(variant, modelData)
                title:    modelData.summary
                body:     modelData.body
                timeStr:  ""
                compact:  false
                showActions: modelData.actions.length > 0

                onDismissed:        modelData.dismiss()
                onAction1Triggered: modelData.dismiss()
                onAction2Triggered: {
                    if (modelData.actions.length > 0) modelData.actions[0].invoke()
                    modelData.dismiss()
                }

                Timer {
                    interval: modelData.expireTimeout > 0 ? modelData.expireTimeout * 1000 : 8000
                    running:  true
                    onTriggered: modelData.expire()
                }
            }
        }
    }
}
