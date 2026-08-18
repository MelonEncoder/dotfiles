pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "popups"
import "../theme"
import "../services"

Rectangle {
    id: root
    property bool expanded: false
    property bool menuOpen: false
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed

    implicitWidth: label.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
    implicitHeight: LayoutTheme.barWidgetHeight
    radius: Shape.radiusNormal
    color: root.pressed ? Colors.surfacePressed : (root.hovered ? Colors.surfaceHover : Colors.surface)
    border.width: Shape.borderWidth
    border.color: Colors.border

    Behavior on color {
        ColorAnimation {
            duration: Animations.duration_hover
            easing.type: Animations.easingStandard
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.expanded ? "" : ""
        color: Colors.text
        font.pixelSize: Typography.size
        font.family: Typography.iconFamily
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    HyprlandFocusGrab {
        active: root.expanded && !root.menuOpen
        windows: [dropdown]
        onCleared: root.expanded = false
    }

    PopupWindow {
        id: dropdown
        anchor.item: root
        visible: root.expanded
        implicitWidth: dropdown.screen.width
        implicitHeight: dropdown.screen.height
        color: "transparent"

        Backdrop {
            expanded: root.expanded
            onClose: root.expanded = false
        }

        Rectangle {
            id: panel
            x: dropdown.width - width - LayoutTheme.barPadding
            y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
            width: Math.max(180, trayList.implicitWidth + (LayoutTheme.barWidgetPadding * 2))
            height: trayList.implicitHeight + (LayoutTheme.barWidgetPadding * 2)
            radius: Shape.radiusBackground
            color: Colors.background
            border.width: Shape.borderWidth
            border.color: Colors.border
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : Animations.dropdownScaleClosed
            focus: root.expanded
            Keys.onEscapePressed: root.expanded = false

            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.dropdown
                    easing.type: Animations.easingEmphasized
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Animations.dropdown
                    easing.type: Animations.easingEmphasized
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: Animations.dropdown
                    easing.type: Animations.easingEmphasized
                }
            }

            ColumnLayout {
                id: trayList
                anchors.centerIn: parent
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: Strings.tr(Strings.keys.system_tray)
                    color: Colors.textSubtle
                    font.pixelSize: Typography.xs
                    font.family: Typography.family
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1
                    leftPadding: 2
                    bottomPadding: 2
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Colors.borderSubtle
                }

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
                            anchor.edges: Edges.Bottom
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
        }
    }
}
