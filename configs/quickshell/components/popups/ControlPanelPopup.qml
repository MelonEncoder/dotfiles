pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../surfaces"
import ".."
import "../../theme"
import "../../services"

BarPopupSurface {
    id: root

    required property Item anchorItem

    anchor.item: anchorItem
    text: Strings.tr(Strings.keys.quick_settings)

    panelX: root.width - panelWidth - LayoutTheme.barPadding
    panelY: LayoutTheme.barWidgetHeight + (LayoutTheme.barPadding * 2)
    panelWidth: 360

    Brightness {
        Layout.fillWidth: true
    }

    Volume {
        Layout.fillWidth: true
    }

    Wifi {
        Layout.fillWidth: true
    }

    Bluetooth {
        Layout.fillWidth: true
    }
}
