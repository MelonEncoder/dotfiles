import QtQuick
import "../../theme"

// Reusable animated "card" surface for popup/dropdown panels: background,
// border, radius, an open/close opacity+scale(+y) transition driven by
// `expanded`, keyboard focus while expanded, and a MouseArea that absorbs
// clicks so they don't fall through to a backdrop or other
// close-on-outside-click handler sitting behind the panel.
//
// Usage inside a PanelWindow:
//   PopupSurface {
//       id: panel
//       expanded: root.visible
//       anchors.centerIn: parent
//       width: 360
//       height: panelContent.implicitHeight
//       ...
//   }
Rectangle {
    id: root

    property bool expanded: false
    // y-offset the panel starts from while collapsed; set to 0 to disable
    // the slide-in and animate opacity/scale only.
    property int closedOffsetY: Animations.dropdownOffset

    color: Colors.background
    radius: Shape.radiusBackground
    border.width: Shape.borderWidth
    border.color: Colors.border

    opacity: root.expanded ? 1 : 0
    scale: root.expanded ? 1 : Animations.dropdownScaleClosed
    y: root.expanded ? 0 : root.closedOffsetY
    transformOrigin: Item.Center
    focus: root.expanded
    clip: true

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.duration_normal
            easing.type: Animations.easingStandard
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Animations.duration_slow
            easing.type: Animations.easingEmphasized
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: Animations.duration_slow
            easing.type: Animations.easingEmphasized
        }
    }

    MouseArea {
        anchors.fill: parent
    }
}
