import QtQuick
import "../../theme"

// Full-screen darkening backdrop for popup windows.
// Closes the popup when clicking outside or pressing ESC.
//
// Usage inside a PopupWindow:
//   Backdrop {
//       expanded: root.expanded
//       onClose: root.expanded = false
//   }
Rectangle {
    id: root
    property bool expanded: false
    signal close

    anchors.fill: parent
    color: Colors.overlayDark
    opacity: root.expanded ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.duration_normal
            easing.type: Animations.easingStandard
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.expanded
        onClicked: root.close()
    }
}
