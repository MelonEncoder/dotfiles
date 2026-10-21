pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "../widgets"
import "../theme"

Scope {
    Variants {
        model: Quickshell.screens

        Item {
            id: screenGroup
            required property var modelData

            PanelWindow {
                id: root

                readonly property int section_margin: 12
                readonly property int widget_spacing: 8
                readonly property int inner_spacing: 8
                readonly property int popup_offset_y: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
                readonly property int tray_item_size: 22
    			readonly property int tray_icon_size: 16

                anchors {
                    top: true
                    left: true
                    right: true
                }

                screen: screenGroup.modelData
                color: "transparent"
                // Extra transparent space below the bar so widget shadows
                // aren't cut off; it isn't reserved and doesn't take input.
                implicitHeight: barContent.implicitHeight + LayoutTheme.barPadding + Shape.shadowBlur + Shape.shadowOffsetY
                exclusiveZone: barContent.implicitHeight + LayoutTheme.barPadding
                mask: Region {
                    item: barContent
                }

                Item {
                    id: barContent

                    // One shadow pass over the whole row, so every widget
                    // casts the same shadow as the popups (see PopupShadow).
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Colors.shadow
                        shadowBlur: 1.0
                        blurMax: Shape.shadowBlur
                        shadowVerticalOffset: Shape.shadowOffsetY
                        shadowHorizontalOffset: 0
                    }

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
