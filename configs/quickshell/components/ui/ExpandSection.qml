import QtQuick
import QtQuick.Layouts
import "../../theme"

/*
  ExpandSection

  Surface that animates open/closed around its content (same height/opacity
  animation as Dropdown's body). Children land in a ColumnLayout, so use
  Layout.* attached properties on them:

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

    Layout.fillWidth: true
    Layout.preferredHeight: root.expanded ? root.openHeight : 0
    implicitHeight: root.expanded ? root.openHeight : 0

    visible: root.expanded || opacity > 0.01
    opacity: root.expanded ? 1 : 0
    clip: true

    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: Animations.dropdownSection
            easing.type: Animations.easingEmphasized
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.dropdownSection
            easing.type: Animations.easingEmphasized
        }
    }

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
