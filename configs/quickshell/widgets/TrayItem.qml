pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../theme"

/*
  TrayItem

  One system tray row: icon + title. Left click activates the item (or opens
  its menu if it's menu-only), right click opens its menu. Used by the control
  panel's "Background Apps" list (TrayItems). `menuOpened` /
  `menuClosed` let the owning popup pause its focus grab while a menu shows.
*/

Rectangle {
    id: root

    required property var modelData

    readonly property bool hovered: trayMouse.containsMouse
    readonly property bool pressed: trayMouse.pressed
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
    radius: Shape.radiusNormal
    color: root.pressed ? Colors.surfacePressed : (root.hovered ? Colors.surfaceHover : "transparent")
    implicitWidth: trayRow.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
    implicitHeight: trayRow.implicitHeight + (LayoutTheme.barWidgetPadding * 2)

    Behavior on color {
        ColorAnimation {
            duration: Animations.duration_hover
            easing.type: Animations.easingStandard
        }
    }

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

    MouseArea {
        id: trayMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function (mouse) {
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
}
