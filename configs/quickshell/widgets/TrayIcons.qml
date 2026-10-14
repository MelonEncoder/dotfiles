pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../theme"

/*
  TrayIcons

  Compact wrapping row of system tray icons for the control panel. Left
  click activates an item (or opens its menu if it's menu-only), right click
  opens its menu. `menuOpen` is true while a tray menu is showing so the
  owning popup can pause its focus grab.
*/

Rectangle {
    id: root

    property bool menuOpen: false
    readonly property int iconButtonSize: LayoutTheme.barWidgetHeight

    visible: SystemTray.items.values.length > 0
    Layout.fillWidth: true
    implicitHeight: iconFlow.implicitHeight + (LayoutTheme.barWidgetPadding)
    radius: Shape.radiusNormal
    color: Colors.surface

    Flow {
        id: iconFlow
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: Math.round(LayoutTheme.barWidgetPadding / 2)
        }
        spacing: 4

        Repeater {
            model: SystemTray.items

            Rectangle {
                id: trayItem
                required property var modelData
                property bool hovered: trayMouse.containsMouse
                property bool pressed: trayMouse.pressed

                width: root.iconButtonSize
                height: root.iconButtonSize
                radius: Shape.radiusNormal
                color: pressed ? Colors.surfacePressed : (hovered ? Colors.surfaceHover : "transparent")

                Behavior on color {
                    ColorAnimation {
                        duration: Animations.duration_hover
                        easing.type: Animations.easingStandard
                    }
                }

                IconImage {
                    anchors.centerIn: parent
                    source: {
                        var s = (trayItem.modelData.icon || "").toString();
                        if (s.startsWith("image://icon/") && s.indexOf("?fallback=") === -1)
                            return s + "?fallback=application-x-executable";
                        return s;
                    }
                    implicitSize: 16
                    asynchronous: true
                }

                QsMenuAnchor {
                    id: trayMenu
                    menu: trayItem.modelData && trayItem.modelData.hasMenu ? trayItem.modelData.menu : null
                    anchor.item: trayItem
                    onClosed: root.menuOpen = false
                }

                MouseArea {
                    id: trayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: function (mouse) {
                        if (!trayItem.modelData)
                            return;
                        if (mouse.button === Qt.RightButton && trayItem.modelData.hasMenu) {
                            root.menuOpen = true;
                            trayMenu.open();
                        } else if (mouse.button === Qt.LeftButton) {
                            if (!trayItem.modelData.onlyMenu) {
                                trayItem.modelData.activate();
                            } else if (trayItem.modelData.hasMenu) {
                                root.menuOpen = true;
                                trayMenu.open();
                            }
                        }
                    }
                }
            }
        }
    }
}
