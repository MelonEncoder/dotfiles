pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"

// Standardized dropdown surface for bar widgets (Clock, SystemTray,
// SystemInfo, MediaPlayer, ...): a full-screen transparent PopupWindow
// anchored to the triggering widget, with a dimming Backdrop and an
// animated panel (background/border/radius, opacity+scale+y transitions,
// escape-to-close, and a MouseArea that absorbs clicks so they don't reach
// the backdrop). Content is laid out in an internal ColumnLayout that also
// renders an optional uppercase header + divider driven by `text`, so every
// popup gets the same header treatment for free. The panel height always
// auto-sizes to its content; set `panelWidth` for a fixed content width.
//
// Usage:
//   HyprlandFocusGrab {
//       active: root.expanded
//       windows: [dropdown]
//       onCleared: root.expanded = false
//   }
//
//   BarPopupSurface {
//       id: dropdown
//       anchor.item: root
//       expanded: root.expanded
//       text: Strings.tr(Strings.keys.media)
//       panelWidth: 240 + (LayoutTheme.barWidgetPadding * 2)
//       onClose: root.expanded = false
//
//       Text { Layout.fillWidth: true; text: "..." }
//       Row { ... }
//   }
PopupWindow {
    id: root

    property bool expanded: false
    property string text: ""

    property alias panelX: panel.x
    property alias panelY: panel.y
    property int panelWidth: root.contentWidth + (LayoutTheme.barWidgetPadding * 2)
    property int panelHeight: root.contentHeight + (LayoutTheme.barWidgetPadding * 2)

    readonly property alias contentWidth: frame.implicitWidth
    readonly property alias contentHeight: frame.implicitHeight
    property alias contentSpacing: frame.spacing

    default property alias content: frame.data

    signal close

    visible: root.expanded
    implicitWidth: root.screen ? root.screen.width : 0
    implicitHeight: root.screen ? root.screen.height : 0
    color: "transparent"

    Backdrop {
        expanded: root.expanded
        onClose: root.close()
    }

    Rectangle {
        id: panel

        width: root.panelWidth
        height: root.panelHeight

        radius: Shape.radiusBackground
        color: Colors.background
        border.width: Shape.borderWidth
        border.color: Colors.border
        clip: true

        opacity: root.expanded ? 1 : 0
        scale: root.expanded ? 1 : Animations.dropdownScaleClosed
        transformOrigin: Item.Top
        focus: root.expanded
        Keys.onEscapePressed: root.close()

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.dropdown
                easing.type: Animations.easingEmphasized
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Animations.dropdown
                easing.type: Animations.easingEmphasized
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: Animations.dropdown
                easing.type: Animations.easingEmphasized
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: frame
            anchors.fill: parent
            anchors.margins: LayoutTheme.barWidgetPadding
            spacing: 6

            Text {
                Layout.fillWidth: true
                visible: root.text.length > 0
                text: root.text
                color: Colors.textSubtle
                font.pixelSize: Typography.xs
                font.family: Typography.family
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1
                leftPadding: 2
                bottomPadding: 2
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Colors.borderSubtle
                visible: root.text.length > 0
            }
        }
    }
}
