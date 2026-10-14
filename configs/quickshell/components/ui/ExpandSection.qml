import QtQuick
import QtQuick.Layouts
import "../../theme"

/*
  ExpandSection

  Surface that animates open/closed around its content (height + opacity).
  Children land in a ColumnLayout, so use Layout.* attached properties on
  them. Opening/closing is an explicit "open" state with Transitions, so the
  section is shown before it grows and only hidden after it has shrunk:

      ExpandSection {
          expanded: panel.openSection === "wifi"
          WifiNetworks { Layout.fillWidth: true }
      }
*/

Item {
    id: root

    property bool expanded: false
    default property alias content: column.data

    readonly property int sectionMargin: Math.round(LayoutTheme.barWidgetPadding / 2)
    readonly property int openHeight: column.implicitHeight + (root.sectionMargin * 2)

    // Closed values; the "open" state overrides them.
    Layout.fillWidth: true
    Layout.preferredHeight: 0
    visible: false
    opacity: 0
    clip: true

    states: State {
        name: "open"
        when: root.expanded

        PropertyChanges {
            root.visible: true
            root.opacity: 1
            root.Layout.preferredHeight: root.openHeight
        }
    }

    transitions: [
        Transition {
            to: "open"

            // `visible` isn't animated, so it flips to true right away.
            NumberAnimation {
                properties: "opacity,Layout.preferredHeight"
                duration: Animations.dropdownSection
                easing.type: Animations.easingEmphasized
            }
        },
        Transition {
            from: "open"

            SequentialAnimation {
                NumberAnimation {
                    properties: "opacity,Layout.preferredHeight"
                    duration: Animations.dropdownSection
                    easing.type: Animations.easingEmphasized
                }
                PropertyAction {
                    property: "visible"
                }
            }
        }
    ]

    Rectangle {
        // Fixed to the open height so content doesn't reflow mid-animation.
        width: parent.width
        height: root.openHeight
        radius: Shape.radiusNormal
        color: Colors.surface

        ColumnLayout {
            id: column
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: root.sectionMargin
            }
            spacing: 3
        }
    }
}
