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
    3. 2-column grid of service tiles (toggle + dropdown): Wi-Fi, Bluetooth,
       Background Apps (system tray). A tile's dropdown opens a details
       section spanning both columns below its grid row
*/

BarPopupSurface {
    id: root

    required property Item anchorItem

    // Name of the tile whose details section is open ("" for none).
    property string openSection: ""
    readonly property bool menuOpen: trayItems.menuOpen

    function toggleSection(name: string): void {
        root.openSection = root.openSection === name ? "" : name;
    }

    anchor.item: anchorItem
    text: Strings.tr(Strings.keys.quick_settings)

    panelX: root.width - panelWidth - LayoutTheme.barPadding
    panelY: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    panelWidth: 400
    contentSpacing: 10

    onExpandedChanged: {
        if (!root.expanded) {
            root.openSection = "";
            volumeControl.expanded = false;
        }
    }

    onOpenSectionChanged: {
        WifiService.setScanning(root.openSection === "wifi");
        if (root.openSection === "bluetooth")
            BluetoothService.discover();
    }

    // Power actions
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: PowerService.actions

            SquareButton {
                id: powerButton
                required property var modelData

                Layout.fillWidth: true
                Layout.preferredHeight: LayoutTheme.barWidgetHeight * 2
                size: LayoutTheme.barWidgetHeight * 2
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
        id: volumeControl
        Layout.fillWidth: true
    }

    // Service tiles
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: 8
        rowSpacing: 8

        ToggleTile {
            // Equal preferred widths keep both columns the same size.
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            tileHeight: LayoutTheme.barWidgetHeight * 2
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
            tileHeight: LayoutTheme.barWidgetHeight * 2
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

        // Background apps (system tray). Nothing to toggle, so both halves
        // of the tile open the list.
        ToggleTile {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            tileHeight: LayoutTheme.barWidgetHeight * 2
            icon: "󰀻"
            title: Strings.tr(Strings.keys.background_apps)
            subtitle: Strings.tr(Strings.keys.apps_running).arg(trayItems.count)
            expanded: root.openSection === "tray"
            onToggled: root.toggleSection("tray")
            onExpandClicked: root.toggleSection("tray")
        }

        ExpandSection {
            Layout.columnSpan: 2
            expanded: root.openSection === "tray"

            TrayItems {
                id: trayItems
                Layout.fillWidth: true
            }
        }
    }
}
