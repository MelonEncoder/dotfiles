pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../surfaces"
import "../../theme"
import "../../services"

BarPopupSurface {
    id: root

    required property Item anchorItem
    property bool menuOpen: false

    anchor.item: anchorItem
    text: Strings.tr(Strings.keys.system_tray)
    contentSpacing: 2

    panelX: root.width - panelWidth - LayoutTheme.barPadding
    panelY: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    panelWidth: Math.max(180, contentWidth + (LayoutTheme.barWidgetPadding * 2))

    Repeater {
        model: SystemTray.items

        Rectangle {
            id: trayItem
            required property var modelData
            Layout.fillWidth: true
            property bool hovered: trayHover.containsMouse
            property bool pressed: trayHover.pressed
            readonly property string itemLabel: {
                if (!modelData)
                    return "?";
                var text = (modelData.tooltipTitle || modelData.title || modelData.id || "?") + "";
                return text.length > 0 ? text : "?";
            }
            radius: Shape.radiusNormal
            color: pressed ? Colors.surfacePressed : (hovered ? Colors.surfaceHover : "transparent")
            implicitWidth: trayRow.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
            implicitHeight: trayRow.implicitHeight + (LayoutTheme.barWidgetPadding * 2)

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            RowLayout {
                id: trayRow
                anchors.centerIn: parent
                width: parent.width - (LayoutTheme.barWidgetPadding * 2)
                spacing: 8

                IconImage {
                    id: trayIcon
                    source: {
                        var s = (trayItem.modelData.icon || "").toString();
                        if (s.startsWith("image://icon/") && s.indexOf("?fallback=") === -1)
                            return s + "?fallback=application-x-executable";
                        return s;
                    }
                    implicitSize: 16
                    visible: source.toString() !== "" && status === Image.Ready
                    asynchronous: true
                }

                Text {
                    id: trayName
                    Layout.fillWidth: true
                    text: trayItem.itemLabel
                    color: Colors.text
                    font.pixelSize: Typography.size
                    font.family: Typography.family
                    elide: Text.ElideRight
                }
            }

            QsMenuAnchor {
                id: trayMenu
                menu: trayItem.modelData && trayItem.modelData.hasMenu ? trayItem.modelData.menu : null
                anchor.item: trayItem
                onClosed: root.menuOpen = false
            }

            MouseArea {
                id: trayHover
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
