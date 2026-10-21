pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"

// Standardized dropdown surface for bar widgets (Clock, ControlPanel,
// MediaPlayer, ...): a full-screen transparent PopupWindow
// anchored to the triggering widget, with a click-outside Backdrop, a drop shadow and an
// animated panel (background/border/radius, escape-to-close, and a
// MouseArea that absorbs clicks so they don't reach the backdrop).
//
// Opening/closing is an explicit "open" state with Transitions rather than
// per-property Behaviors, because closing has to happen in order: animate
// the panel out, *then* hide the window. (Binding `visible` straight to
// `expanded` hid the window instantly, so the close animation never showed.) Content is laid out in an internal ColumnLayout that also
// renders an optional uppercase header + divider driven by `text`, so every
// popup gets the same header treatment for free. The panel height always
// auto-sizes to its content; set `panelWidth` for a fixed content width.
//
// Usually created by a BarButton, which sets `anchorItem`, drives
// `expanded`, and handles `close`:
//
//   BarButton {
//       popup: BarPopupSurface {
//           text: Strings.tr(Strings.keys.media)
//           panelWidth: 240 + (LayoutTheme.barWidgetPadding * 2)
//
//           Text { Layout.fillWidth: true; text: "..." }
//       }
//   }
PopupWindow {
    id: root

    property bool expanded: false
    property string text: ""
    // Bar widget the popup hangs off of (set by BarButton).
    property Item anchorItem: null

    property alias panelX: panel.x
    property alias panelY: panel.y
    property int panelWidth: root.contentWidth + (LayoutTheme.barWidgetPadding * 2)
    property int panelHeight: root.contentHeight + (LayoutTheme.barWidgetPadding * 2)

    readonly property alias contentWidth: frame.implicitWidth
    readonly property alias contentHeight: frame.implicitHeight
    property alias contentSpacing: frame.spacing

    default property alias content: frame.data

    signal close

    anchor.item: root.anchorItem

    visible: false // driven by the "open" state below
    implicitWidth: root.screen ? root.screen.width : 0
    implicitHeight: root.screen ? root.screen.height : 0
    color: "transparent"

    Backdrop {
        expanded: root.expanded
        onClose: root.close()
    }

    PopupShadow {
        target: panel
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

        // Closed values; the "open" state overrides them.
        opacity: 0
        scale: Animations.dropdownScaleClosed
        transformOrigin: Item.Top
        focus: root.expanded
        Keys.onEscapePressed: root.close()

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

    // PopupWindow isn't an Item, so its states live in a StateGroup.
    StateGroup {
        states: State {
            name: "open"
            when: root.expanded

            PropertyChanges {
                root.visible: true
                panel.opacity: 1
                panel.scale: 1
            }
        }

        transitions: [
            Transition {
                to: "open"

                // `visible` isn't animated, so it flips to true right away.
                NumberAnimation {
                    target: panel
                    properties: "opacity,scale"
                    duration: Animations.dropdown
                    easing.type: Animations.easingEmphasized
                }
            },
            Transition {
                from: "open"

                SequentialAnimation {
                    NumberAnimation {
                        target: panel
                        properties: "opacity,scale"
                        duration: Animations.dropdown
                        easing.type: Animations.easingEmphasized
                    }
                    PropertyAction {
                        target: root
                        property: "visible"
                    }
                }
            }
        ]
    }
}
