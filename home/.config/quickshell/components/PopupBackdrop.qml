import QtQuick

// Full-screen transparent backdrop for popup windows.
// Closes the popup when clicking outside or pressing ESC.
//
// Usage inside a PopupWindow:
//   PopupBackdrop {
//       expanded: root.expanded
//       onClose: root.expanded = false
//   }
Rectangle {
    id: root
    property bool expanded: false
    signal close()

    anchors.fill: parent
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        enabled: root.expanded
        onClicked: root.close()
    }
}
