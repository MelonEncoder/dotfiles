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

    ScreenshotControls {
        Layout.fillWidth: true
    }

    Brightness {
        Layout.fillWidth: true
        panelScreenName: root.screen ? root.screen.name : ""
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

    PowerProfiles {
        Layout.fillWidth: true
    }
}
