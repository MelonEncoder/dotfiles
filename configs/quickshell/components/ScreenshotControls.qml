import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../services"
import "ui"

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

        StyledButton {
            Layout.fillWidth: true
            size: LayoutTheme.barWidgetHeight * 1.5
            icon: "󰍹"
            iconSize: Typography.iconSm
            text: Strings.tr(Strings.keys.fullscreen)
            onClicked: root.trigger("output")
        }

        StyledButton {
            Layout.fillWidth: true
            size: LayoutTheme.barWidgetHeight * 1.5
            icon: "󰹑"
            iconSize: Typography.iconSm
            text: Strings.tr(Strings.keys.region)
            onClicked: root.trigger("region")
        }
    }
    Process {
        id: screenshotProc
    }
}
