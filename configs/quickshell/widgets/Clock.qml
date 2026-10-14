pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../components/popups"
import "../services"
import "../theme"

BarButton {
    id: root

    implicitWidth: row.implicitWidth + (LayoutTheme.barWidgetPadding * 2)
    popup: ClockPopup {}

    // Always open the calendar on the current month.
    onExpandedChanged: {
        if (root.expanded)
            CalendarService.goToToday();
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: LayoutTheme.barWidgetPadding

        Text {
            text: ClockService.date
            color: Colors.textSubtle
            font.pixelSize: Typography.size
            font.family: Typography.family
        }

        Text {
            text: ClockService.time
            color: Colors.text
            font.pixelSize: Typography.size
            font.family: Typography.family
        }
    }
}
