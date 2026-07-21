import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

// Shared notification header block: app name on top, an accent bar below it
// (a lighter track filled with the urgency color), then the app icon and
// summary. Used by both the toast popup (Notifications.qml) and the
// notification history list (NotificationBell.qml) so the two stay visually
// in sync.
ColumnLayout {
    id: root

    // The notification-like object; expects appName, appIcon, summary, urgency
    required property var notification

    // Fill amount for the accent bar, 0..1. Defaults to fully filled, which
    // suits contexts with no countdown (e.g. the history list). The toast
    // passes its animated timeout progress here instead.
    property real progress: 1.0

    // Size of the rounded app-icon container
    property int iconSize: 28

    // Font sizes — callers can shrink these to fit tighter spaces
    property real appNameFontSize: Theme.font_size_xl
    property real summaryFontSize: Theme.font_size

    // Height of the accent/expiration bar
    property int barHeight: 2

    // Gap between the app name row and the bar, and between the icon and app name
    property int rowSpacing: 6

    // Extra spacing between the accent bar and the summary text, on top of rowSpacing
    property int summaryTopPadding: 4

    readonly property color accentColor: notification.urgency === NotificationUrgency.Critical ? Theme.notification_accent_critical : (notification.urgency === NotificationUrgency.Low ? Theme.notification_accent_low : Theme.notification_accent_normal)

    spacing: root.rowSpacing

    // Icon + app name
    RowLayout {
        Layout.fillWidth: true
        spacing: root.rowSpacing

        Item {
            id: iconContainer
            readonly property string iconSource: root.notification.appIcon || ""
            visible: iconSource !== ""
            Layout.preferredWidth: visible ? root.iconSize : 0
            Layout.preferredHeight: visible ? root.iconSize : 0
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: Theme.radius_normal
                color: Theme.notification_icon_background
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 3
                    source: iconContainer.iconSource
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                }
            }
        }

        Text {
            visible: text.length > 0
            text: root.notification.appName || ""
            color: Theme.color_text
            font.pixelSize: root.appNameFontSize
            font.family: Theme.font_family
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    // Accent bar — a lighter track is always visible, filled with the urgency color
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: root.barHeight
        radius: root.barHeight / 2
        color: Theme.color_overlay_light
        clip: true

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * root.progress
            radius: parent.radius
            color: root.accentColor
        }
    }

    // Summary
    Text {
        Layout.fillWidth: true
        Layout.topMargin: root.summaryTopPadding
        text: root.notification.summary || ""
        color: Theme.color_text
        font.pixelSize: root.summaryFontSize
        font.family: Theme.font_family
        font.bold: true
        wrapMode: Text.Wrap
    }
}
