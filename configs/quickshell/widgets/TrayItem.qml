pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../components/ui"
import "../theme"

/*
  TrayItem

  One system tray row: icon + title. Left click activates the item (or opens
  its menu if it's menu-only), right click opens its menu. Used by the control
  panel's "Background Apps" list (TrayItems). `menuOpened` /
  `menuClosed` let the owning popup pause its focus grab while a menu shows.
*/

HoverSurface {
    id: root

    required property var modelData
    readonly property string itemLabel: {
        if (!root.modelData)
            return "?";
        var text = (root.modelData.tooltipTitle || root.modelData.title || root.modelData.id || "?") + "";
        return text.length > 0 ? text : "?";
    }

    signal menuOpened()
    signal menuClosed()

    function openMenu(): void {
        root.menuOpened();
        trayMenu.open();
    }

    Layout.fillWidth: true
    baseColor: "transparent"
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: trayRow.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
    implicitHeight: trayRow.implicitHeight + (LayoutTheme.barWidgetPadding * 2)

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        width: parent.width - (LayoutTheme.barWidgetPadding * 2)
        spacing: 8

        IconImage {
            source: {
                var s = (root.modelData.icon || "").toString();
                if (s.startsWith("image://icon/") && s.indexOf("?fallback=") === -1)
                    return s + "?fallback=application-x-executable";
                return s;
            }
            implicitSize: 16
            visible: source.toString() !== "" && status === Image.Ready
            asynchronous: true
        }

        Text {
            Layout.fillWidth: true
            text: root.itemLabel
            color: Colors.text
            font.pixelSize: Typography.size
            font.family: Typography.family
            elide: Text.ElideRight
        }
    }

    QsMenuAnchor {
        id: trayMenu
        menu: root.modelData && root.modelData.hasMenu ? root.modelData.menu : null
        anchor.item: root
        onClosed: root.menuClosed()
    }

    onClicked: mouse => {
        if (!root.modelData)
            return;
        if (mouse.button === Qt.RightButton && root.modelData.hasMenu) {
            root.openMenu();
        } else if (mouse.button === Qt.LeftButton) {
            if (!root.modelData.onlyMenu)
                root.modelData.activate();
            else if (root.modelData.hasMenu)
                root.openMenu();
        }
    }
}
