pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Bar
    readonly property int barPadding: 6
    readonly property int barWidgetPadding: 8
    readonly property int barWidgetHeight:
        Typography.size + (barWidgetPadding * 2)
    readonly property int barWidgetIconSize:
        barWidgetHeight - 8
}
