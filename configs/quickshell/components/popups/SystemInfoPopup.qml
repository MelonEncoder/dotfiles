pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../surfaces"
import "../../theme"
import "../../services"

BarPopupSurface {
    id: root

    required property Item anchorItem
    property string distroDisplay: ""
    property string distroIcon: ""
    property string kernelDisplay: ""
    property string versionDisplay: ""
    property string cpuDisplay: ""
    property string gpuDisplay: ""
    property string ramDisplay: ""
    property string storageDisplay: ""
    readonly property int popupWidth: 310

    anchor.item: anchorItem
    text: Strings.tr(Strings.keys.system)

    panelY: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    panelWidth: root.popupWidth + (LayoutTheme.barWidgetPadding * 2)

    component HwRow: RowLayout {
        required property string icon
        required property string label
        required property string value
        Layout.fillWidth: true
        spacing: 8
        visible: value.length > 0

        Text {
            text: parent.icon
            color: Colors.textSubtle
            font.pixelSize: Typography.icon
            font.family: Typography.iconFamily
        }

        Text {
            text: parent.label
            color: Colors.textSubtle
            font.pixelSize: Typography.size
            font.family: Typography.family
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: parent.value
            color: Colors.text
            font.pixelSize: Typography.size
            font.family: Typography.family
            Layout.maximumWidth: 200
            elide: Text.ElideRight
        }
    }

    Rectangle {
        id: aboutItem
        Layout.fillWidth: true
        Layout.preferredHeight: aboutContent.implicitHeight + (LayoutTheme.barWidgetPadding * 2)
        radius: Shape.radiusNormal
        color: Colors.surface

        ColumnLayout {
            id: aboutContent
            anchors.fill: parent
            anchors.margins: LayoutTheme.barWidgetPadding
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: root.distroDisplay
                        elide: Text.ElideRight
                        color: Colors.text
                        font.pixelSize: Typography.title
                        font.family: Typography.family
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.kernelDisplay.length > 0 ? (Strings.tr(Strings.keys.kernel) + " " + root.kernelDisplay) : ""
                        visible: text.length > 0
                        color: Colors.textSubtle
                        font.pixelSize: Typography.size
                        font.family: Typography.family
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.versionDisplay.length > 0 ? (Strings.tr(Strings.keys.version) + " " + root.versionDisplay) : ""
                        visible: text.length > 0
                        color: Colors.textSubtle
                        font.pixelSize: Typography.size
                        font.family: Typography.family
                    }
                }

                Text {
                    text: root.distroIcon
                    color: Colors.text
                    font.pixelSize: Typography.iconLg
                    font.family: Typography.iconFamily
                }
            }
        }
    }

    Rectangle {
        id: hwItem
        Layout.fillWidth: true
        implicitHeight: hwContent.implicitHeight + (LayoutTheme.barWidgetPadding * 2)
        radius: Shape.radiusNormal
        color: Colors.surface
        visible: root.cpuDisplay.length > 0 || root.gpuDisplay.length > 0 || root.ramDisplay.length > 0 || root.storageDisplay.length > 0

        ColumnLayout {
            id: hwContent
            anchors.fill: parent
            anchors.margins: LayoutTheme.barWidgetPadding
            spacing: 4

            HwRow {
                icon: "󰻠"
                label: Strings.tr(Strings.keys.cpu)
                value: root.cpuDisplay
            }

            HwRow {
                icon: "󰢮"
                label: Strings.tr(Strings.keys.gpu)
                value: root.gpuDisplay
            }

            HwRow {
                icon: "󰍛"
                label: Strings.tr(Strings.keys.ram)
                value: root.ramDisplay
            }

            HwRow {
                icon: "󰆼"
                label: Strings.tr(Strings.keys.storage)
                value: root.storageDisplay
            }
        }
    }
}
