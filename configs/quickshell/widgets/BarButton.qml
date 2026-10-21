pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../components/ui"
import "../theme"

/*
  BarButton

  Base for bar widgets that open a popup: a bordered HoverSurface that
  toggles `expanded` on click, a focus grab that closes the popup when
  focus leaves it, and the popup itself.

  `popup` is a Component -- a template, not an instance -- so each popup
  is only created the first time its widget opens (then kept, so reopening
  is instant). BarButton wires the popup's `anchorItem`, `expanded`, and
  `close` itself; a popup can expose `menuOpen: true` to pause the focus
  grab while one of its own menus is showing.

      BarButton {
          implicitWidth: icon.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
          popup: ClockPopup {}

          Text { id: icon; anchors.centerIn: parent; text: "..." }
      }
*/

HoverSurface {
    id: root

    property bool expanded: false
    property Component popup: null

    readonly property var popupItem: popupLoader.item
    property bool popupCreated: false
    // Hyprland drops a focus grab on a window created in the same tick, so
    // the grab is only armed one event-loop turn after the popup exists.
    property bool grabReady: false

    implicitHeight: LayoutTheme.barWidgetHeight
    border.width: Shape.borderWidth
    border.color: Colors.border
    active: root.expanded

    onClicked: root.expanded = !root.expanded
    onExpandedChanged: {
        if (root.expanded)
            root.popupCreated = true;
    }

    LazyLoader {
        id: popupLoader
        active: root.popupCreated && root.popup !== null
        component: root.popup

        onItemChanged: {
            const popup = popupLoader.item;
            if (!popup)
                return;
            popup.anchorItem = root;
            popup.expanded = Qt.binding(() => root.expanded);
            popup.close.connect(() => root.expanded = false);
            Qt.callLater(() => root.grabReady = true);
        }
    }

    HyprlandFocusGrab {
        active: root.expanded && root.grabReady && root.popupItem.menuOpen !== true
        windows: root.popupItem ? [root.popupItem] : []
        onCleared: root.expanded = false
    }
}
