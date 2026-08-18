pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "../components/ui"
import "../theme"

Scope {
    id: root

    property bool visible: false
    property int focusedIndex: -1
    readonly property int gridColumns: 5
    readonly property int cellSize: 150

    function open(): void {
        root.visible = true;
        root.focusedIndex = 0;
    }

    function close(): void {
        root.visible = false;
        root.focusedIndex = -1;
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "power-menu"
        description: "Open the power options menu"
        triggerDescription: "SUPER+SHIFT+E"
        onPressed: root.visible ? root.close() : root.open()
    }

    IpcHandler {
        target: "power-options"
        function open(): void {
            root.open();
        }
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: powerWindows.instances
        onCleared: root.close()
    }

    Variants {
        id: powerWindows
        model: root.visible ? Quickshell.screens : []

        PanelWindow {
            id: win
            required property var modelData

            screen: modelData
            visible: root.visible
            color: "transparent"
            focusable: root.visible
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            implicitWidth: modelData.width
            implicitHeight: modelData.height

            Rectangle {
                anchors.fill: parent
                color: LauncherTheme.overlay
                opacity: root.visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_normal
                        easing.type: Animations.easingStandard
                    }
                }
            }

            Rectangle {
                id: panel
                anchors.centerIn: parent
                width: root.cellSize * 5
                height: panelContent.implicitHeight + (LayoutTheme.barWidgetPadding * 2)
                radius: Shape.radiusBackground
                color: Colors.background
                border.width: Shape.borderWidth
                border.color: Colors.border
                opacity: root.visible ? 1 : 0
                scale: root.visible ? 1 : Animations.dropdownScaleClosed
                transformOrigin: Item.Center
                z: 1
                focus: root.visible

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_normal
                        easing.type: Animations.easingStandard
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Animations.duration_slow
                        easing.type: Animations.easingEmphasized
                    }
                }

                Keys.onPressed: event => {
                    var count = Services.PowerService.actions.length;
                    var cols = root.gridColumns;
                    var idx = root.focusedIndex < 0 ? 0 : root.focusedIndex;
                    switch (event.key) {
                    case Qt.Key_Right:
                    case Qt.Key_Tab:
                        root.focusedIndex = (idx + 1) % count;
                        break;
                    case Qt.Key_Left:
                    case Qt.Key_Backtab:
                        root.focusedIndex = (idx - 1 + count) % count;
                        break;
                    case Qt.Key_Down:
                        root.focusedIndex = Math.min(idx + cols, count - 1);
                        break;
                    case Qt.Key_Up:
                        root.focusedIndex = Math.max(idx - cols, 0);
                        break;
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        if (root.focusedIndex >= 0)
                            Services.PowerService.runAction(Services.PowerService.actions[root.focusedIndex].action);
                        break;
                    case Qt.Key_Escape:
                        root.close();
                        break;
                    default:
                        return;
                    }
                    event.accepted = true;
                }

                GridLayout {
                    id: panelContent
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: LayoutTheme.barWidgetPadding
                    columns: root.gridColumns
                    rowSpacing: 4
                    columnSpacing: 4

                    Text {
                        Layout.columnSpan: root.gridColumns
                        Layout.fillWidth: true
                        text: Services.Strings.tr(Services.Strings.keys.system)
                        color: Colors.textSubtle
                        font.pixelSize: Typography.xs
                        font.family: Typography.family
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 1
                        leftPadding: 2
                        bottomPadding: 2
                    }

                    Rectangle {
                        Layout.columnSpan: root.gridColumns
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colors.borderSubtle
                    }

                    Repeater {
                        model: Services.PowerService.actions

                        SquareButton {
                            id: optionItem
                            required property var modelData
                            required property int index
                            focused: root.focusedIndex === index

                            Layout.fillWidth: true
                            Layout.preferredHeight: root.cellSize
                            size: root.cellSize
                            iconName: optionItem.modelData.iconName
                            text: Services.Strings.tr(Services.Strings.keys["power_" + optionItem.modelData.action])
                            accentColor: Colors.accentPrimary

                            onEntered: root.focusedIndex = optionItem.index
                            onClicked: Services.PowerService.runAction(optionItem.modelData.action)
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                z: 0
                onClicked: root.close()
            }
        }
    }
}
