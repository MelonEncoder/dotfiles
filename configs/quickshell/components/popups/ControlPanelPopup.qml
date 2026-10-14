pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../surfaces"
import "../ui"
import "../../widgets"
import "../../theme"
import "../../services"

/*
  ControlPanelPopup

  Layout, top to bottom:
    1. power actions row (PowerService)
    2. brightness + volume sliders
    3. 2-column grid of service tiles (toggle + dropdown); a tile's dropdown
       opens a details section spanning both columns below the grid row
    4. system tray icons
*/

BarPopupSurface {
    id: root

    required property Item anchorItem

    // Name of the tile whose details section is open ("" for none).
    property string openSection: ""
    readonly property bool menuOpen: trayIcons.menuOpen

    function toggleSection(name: string): void {
        root.openSection = root.openSection === name ? "" : name;
    }

    anchor.item: anchorItem
    text: Strings.tr(Strings.keys.quick_settings)

    panelX: root.width - panelWidth - LayoutTheme.barPadding
    panelY: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    panelWidth: 360

    onExpandedChanged: {
        if (!root.expanded)
            root.openSection = "";
    }

    onOpenSectionChanged: {
        WifiService.setScanning(root.openSection === "wifi");
        if (root.openSection === "bluetooth")
            BluetoothService.discover();
    }

    // Power actions
    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Repeater {
            model: PowerService.actions

            SquareButton {
                id: powerButton
                required property var modelData

                Layout.fillWidth: true
                Layout.preferredHeight: LayoutTheme.barWidgetHeight * 1.5
                size: LayoutTheme.barWidgetHeight * 1.5
                iconSize: Typography.xxl
                iconName: powerButton.modelData.iconName
                accentColor: Colors.accentPrimary

                onClicked: {
                    root.close();
                    PowerService.runAction(powerButton.modelData.action);
                }
            }
        }
    }

    // Sliders
    Brightness {
        Layout.fillWidth: true
    }

    Volume {
        Layout.fillWidth: true
    }

    // Service tiles
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: 6
        rowSpacing: 6

        ToggleTile {
            // Equal preferred widths keep both columns the same size.
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            icon: WifiService.enabled ? "󰖩" : "󰖪"
            title: Strings.tr(Strings.keys.wifi)
            subtitle: WifiService.status
            checked: WifiService.enabled
            expanded: root.openSection === "wifi"
            onToggled: WifiService.toggle()
            onExpandClicked: root.toggleSection("wifi")
        }

        ToggleTile {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            icon: BluetoothService.enabled ? "󰂯" : "󰂲"
            title: Strings.tr(Strings.keys.bluetooth)
            subtitle: BluetoothService.status
            checked: BluetoothService.enabled
            expanded: root.openSection === "bluetooth"
            onToggled: BluetoothService.toggle()
            onExpandClicked: root.toggleSection("bluetooth")
        }

        ExpandSection {
            Layout.columnSpan: 2
            expanded: root.openSection === "wifi"

            WifiNetworks {
                Layout.fillWidth: true
            }
        }

        ExpandSection {
            Layout.columnSpan: 2
            expanded: root.openSection === "bluetooth"

            BluetoothDevices {
                Layout.fillWidth: true
            }
        }
    }

    // System tray
    TrayIcons {
        id: trayIcons
        Layout.fillWidth: true
    }
}
