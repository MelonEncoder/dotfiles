import QtQuick

// Invisible full-screen click catcher for popup windows: closes the popup
// when clicking outside the panel. Pair it with a PopupShadow on the panel
// rather than dimming the screen.
//
// Usage inside a PopupWindow:
//   Backdrop {
//       expanded: root.expanded
//       onClose: root.expanded = false
//   }
MouseArea {
    id: root
    property bool expanded: false
    signal close

    anchors.fill: parent
    enabled: root.expanded
    onClicked: root.close()
}
