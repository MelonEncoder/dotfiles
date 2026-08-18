import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../services"

Item {
    id: root

    function trigger(mode: string): void {
        screenshotProc.exec(["hyprshot", "-z", "-m", mode,]);
    }

    implicitWidth: 280
    implicitHeight: screenshotContent.implicitHeight
    width: implicitWidth
    height: implicitHeight
    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    RowLayout {
        id: screenshotContent
        width: parent.width
        spacing: 6

        Rectangle {
            id: fullscreenButton
            property bool hovered: fullscreenMouse.containsMouse
            property bool pressed: fullscreenMouse.pressed
            Layout.fillWidth: true
            Layout.preferredHeight: LayoutTheme.barWidgetHeight * 1.5
            radius: Shape.radiusNormal
            color: pressed ? Colors.surfacePressed : (hovered ? Colors.surfaceHover : Colors.surface)

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "󰍹"
                    color: Colors.text
                    font.pixelSize: Typography.iconSm
                    font.family: Typography.iconFamily
                }

                Text {
                    text: Strings.tr(Strings.keys.fullscreen)
                    color: Colors.text
                    font.pixelSize: Typography.size
                    font.family: Typography.family
                }
            }

            MouseArea {
                id: fullscreenMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.trigger("output")
            }
        }

        Rectangle {
            id: regionButton
            property bool hovered: regionMouse.containsMouse
            property bool pressed: regionMouse.pressed
            Layout.fillWidth: true
            Layout.preferredHeight: LayoutTheme.barWidgetHeight * 1.5
            radius: Shape.radiusNormal
            color: pressed ? Colors.surfacePressed : (hovered ? Colors.surfaceHover : Colors.surface)

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easingStandard
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "󰹑"
                    color: Colors.text
                    font.pixelSize: Typography.iconSm
                    font.family: Typography.iconFamily
                }

                Text {
                    text: Strings.tr(Strings.keys.region)
                    color: Colors.text
                    font.pixelSize: Typography.size
                    font.family: Typography.family
                }
            }

            MouseArea {
                id: regionMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.trigger("region")
            }
        }
    }
    Process {
        id: screenshotProc
    }
}
