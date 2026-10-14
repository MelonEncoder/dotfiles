pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

/*
  TrayItems

  System tray list for the control panel's expandable "Background Apps"
  section: one TrayItem row per tray item. `menuOpen` is true while a tray
  menu is showing so the owning popup can pause its focus grab.
*/

ColumnLayout {
    id: root

    property bool menuOpen: false
    readonly property int count: SystemTray.items.values.length

    spacing: 2

    Repeater {
        model: SystemTray.items

        TrayItem {
            onMenuOpened: root.menuOpen = true
            onMenuClosed: root.menuOpen = false
        }
    }
}
