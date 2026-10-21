import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../theme"

Rectangle {
    id: root
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property var activeToplevel: Hyprland.activeToplevel
    readonly property bool focusedWorkspaceHasWindows: focusedWorkspace && focusedWorkspace.toplevels && focusedWorkspace.toplevels.values.length > 0
    readonly property bool activeOnFocusedWorkspace: focusedWorkspace && activeToplevel && activeToplevel.workspace.id === focusedWorkspace.id
    // Names to use instead of the desktop entry name, keyed by lowercase app id.
    readonly property var nameOverrides: ({
            "app.zen_browser.zen": "Zen",
            "zen": "Zen"
        })
    readonly property string windowTitle: {
        var workspaceLabel = "[" + (focusedWorkspace ? focusedWorkspace.id : "?") + "]";
        if (!focusedWorkspaceHasWindows || !activeOnFocusedWorkspace)
            return workspaceLabel;

        var appId = activeToplevel.wayland && activeToplevel.wayland.appId ? activeToplevel.wayland.appId : "";
        if (appId.length === 0)
            return workspaceLabel;
        return appName(appId);
    }

    function appName(appId: string): string {
        var override = nameOverrides[appId.toLowerCase()];
        if (override)
            return override;

        // Re-evaluate when the set of installed applications changes.
        DesktopEntries.applications;
        var entry = DesktopEntries.heuristicLookup(appId);
        if (entry && entry.name && entry.name.length > 0)
            return entry.name;

        return simplifyAppId(appId);
    }

    function simplifyAppId(appId: string): string {
        var simple = appId;
        var slash = simple.lastIndexOf("/");
        if (slash >= 0 && slash + 1 < simple.length)
            simple = simple.slice(slash + 1);

        var dot = simple.lastIndexOf(".");
        if (dot >= 0 && dot + 1 < simple.length)
            simple = simple.slice(dot + 1);

        simple = simple.replace(/[-_]+/g, " ");
        if (simple.length === 0)
            return "App";
        return simple.charAt(0).toUpperCase() + simple.slice(1);
    }

    radius: Shape.radiusNormal
    color: Colors.background
    border.width: Shape.borderWidth
    border.color: Colors.border
    implicitHeight: LayoutTheme.barWidgetHeight
    implicitWidth: Math.min(420, label.implicitWidth + (LayoutTheme.barWidgetPadding * 2))

    Text {
        id: label
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: LayoutTheme.barWidgetPadding
        anchors.rightMargin: LayoutTheme.barWidgetPadding
        anchors.verticalCenter: parent.verticalCenter
        text: root.windowTitle
        color: Colors.text
        font.pixelSize: Typography.size
        font.family: Typography.family
        elide: Text.ElideRight
    }
}
