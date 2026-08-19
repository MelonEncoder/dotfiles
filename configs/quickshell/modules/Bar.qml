pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import "../components"
import "../theme"

Scope {
    Variants {
        model: Quickshell.screens

        Item {
            id: screenGroup
            required property var modelData

            RoundedScreenCorners {
                screen: screenGroup.modelData
                topOffset: root.implicitHeight
            }

            PanelWindow {
            id: root

            readonly property int section_margin: 12
            readonly property int widget_spacing: 8
            readonly property int inner_spacing: 6
            readonly property int popup_offset_y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
            readonly property int tray_item_size: 22
			readonly property int tray_icon_size: 16

            anchors {
                top: true
                left: true
                right: true
            }

            screen: screenGroup.modelData
            color: Colors.background
            implicitHeight: barContent.implicitHeight + (LayoutTheme.barPadding * 2)

            Item {
                id: barContent
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: LayoutTheme.barPadding
                anchors.leftMargin: LayoutTheme.barPadding
                anchors.rightMargin: LayoutTheme.barPadding
                implicitHeight: Math.max(leftRow.implicitHeight, centerRow.implicitHeight, rightRow.implicitHeight)

                Item {
                    id: leftSection
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width / 3
                    height: leftRow.implicitHeight
                    RowLayout {
                        id: leftRow
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: root.widget_spacing
                        SystemInfo {
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Workspaces {
                            Layout.alignment: Qt.AlignVCenter
                        }
                        CurrentWindow {
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Item {
                    id: centerSection
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width / 3
                    height: centerRow.implicitHeight
                    RowLayout {
                        id: centerRow
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: root.widget_spacing
                        NotificationCenter {
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Clock {
                            Layout.alignment: Qt.AlignVCenter
                        }
                        MediaPlayer {
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Item {
                    id: rightSection
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width / 3
                    height: rightRow.implicitHeight
                    RowLayout {
                        id: rightRow
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: root.widget_spacing
                        PrivacyIndicator {
                            Layout.alignment: Qt.AlignVCenter
                        }

                        IdleInhibitor {
                            Layout.alignment: Qt.AlignVCenter
                        }
                        SystemTray {
                            Layout.alignment: Qt.AlignVCenter
                        }
                        BatteryStatus {
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ControlPanel {
                            Layout.alignment: Qt.AlignVCenter
                            screen: screenGroup.modelData
                        }
                    }
                }
            }
            }
        }
    }
}
