pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../components/ui"
import "../services"

// Bluetooth device list (connected + available) for the control panel's
// expandable Bluetooth section. State lives in BluetoothService.
ColumnLayout {
    id: root

    // Shown instead of an empty-list message when the adapter is missing/off.
    readonly property string adapterProblem: {
        if (!BluetoothService.available)
            return Languages.tr(Languages.keys.bt_unavailable);
        if (!BluetoothService.enabled)
            return Languages.tr(Languages.keys.bt_disabled);
        return "";
    }

    spacing: 3

    ListSection {
        title: Languages.tr(Languages.keys.connected)
        model: BluetoothService.getConnectedDevices()
        emptyText: root.adapterProblem || Languages.tr(Languages.keys.none_connected)
        delegate: ListRow {
            required property var modelData
            iconSource: Quickshell.iconPath(modelData.icon)
            text: modelData.name
            onClicked: BluetoothService.disconnect(modelData)
        }
    }

    ListSection {
        title: Languages.tr(Languages.keys.available)
        model: BluetoothService.getAvailableDevices()
        emptyText: root.adapterProblem || (BluetoothService.discovering ? Languages.tr(Languages.keys.scanning) : Languages.tr(Languages.keys.none_available))
        delegate: ListRow {
            required property var modelData
            iconSource: Quickshell.iconPath(modelData.icon)
            text: modelData.name
            onClicked: BluetoothService.connect(modelData)
        }
    }
}
