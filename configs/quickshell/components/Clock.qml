pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "popups"
import "../services"
import "../theme"

Item {
    id: root
    property bool expanded: false
    implicitWidth: widget.implicitWidth
    implicitHeight: LayoutTheme.barWidgetHeight

    Rectangle {
        id: widget
        radius: Shape.radiusNormal
        color: widgetMouse.pressed ? Colors.surfacePressed : (widgetMouse.containsMouse ? Colors.surfaceHover : Colors.surface)
        border.width: Shape.borderWidth
        border.color: Colors.border
        implicitWidth: row.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
        implicitHeight: LayoutTheme.barWidgetHeight

        Behavior on color {
            ColorAnimation {
                duration: Animations.duration_hover
                easing.type: Animations.easingStandard
            }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: LayoutTheme.barWidgetPadding

            Text {
                text: ClockService.date
                color: Colors.textSubtle
                font.pixelSize: Typography.size
                font.family: Typography.family
            }

            Text {
                text: ClockService.time
                color: Colors.text
                font.pixelSize: Typography.size
                font.family: Typography.family
            }
        }

        MouseArea {
            id: widgetMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                dropdown.calYear = new Date().getFullYear();
                dropdown.calMonth = new Date().getMonth() + 1;
                root.expanded = !root.expanded;
            }
        }
    }

    HyprlandFocusGrab {
        active: root.expanded
        windows: [dropdown]
        onCleared: root.expanded = false
    }

    ClockPopup {
        id: dropdown
        anchorItem: root
        expanded: root.expanded
        onClose: root.expanded = false
    }
}
