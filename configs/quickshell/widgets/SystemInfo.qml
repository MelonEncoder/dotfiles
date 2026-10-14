pragma ComponentBehavior: Bound

import QtQuick
import "../components/popups"
import "../services"
import "../theme"

BarButton {
    id: root

    implicitWidth: osIcon.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
    popup: SystemInfoPopup {
        distroDisplay: SystemInfoService.distroDisplay
        distroIcon: SystemInfoService.distroIcon
        kernelDisplay: SystemInfoService.kernelDisplay
        versionDisplay: SystemInfoService.versionDisplay
        cpuDisplay: SystemInfoService.cpuDisplay
        gpuDisplay: SystemInfoService.gpuDisplay
        ramDisplay: SystemInfoService.ramDisplay
        storageDisplay: SystemInfoService.storageDisplay
    }

    Text {
        id: osIcon
        anchors.centerIn: parent
        text: SystemInfoService.distroIcon
        color: Colors.text
        font.pixelSize: Typography.icon
        font.family: Typography.iconFamily
    }
}
