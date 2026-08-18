pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../components/popups"
import "../theme"
import "../services"

Scope {
    id: root

    // -------------------------------------------------------------------------
    // Wallpaper state lives in WallpaperService; this file only owns picker UI
    // -------------------------------------------------------------------------

    // -------------------------------------------------------------------------
    // Picker state
    // -------------------------------------------------------------------------

    property bool selectorVisible: false
    property int selectedIndex: 0
    property string statusText: ""

    // -------------------------------------------------------------------------
    // Picker layout
    // -------------------------------------------------------------------------

    readonly property int window_margin: 48
    readonly property int content_padding: 22
    readonly property int section_spacing: 16

    readonly property int grid_columns: 3
    readonly property int max_visible_rows: 3
    readonly property int grid_spacing: 12

    readonly property int thumbnail_width: 300
    readonly property int thumbnail_height: 200

    readonly property int preview_margin: 6
    readonly property int caption_height: 28
    readonly property int caption_padding: 8

    readonly property int window_radius: 18
    readonly property int preview_radius: 12
    readonly property int caption_radius: 0

    readonly property int selected_border_width: 2
    readonly property int default_border_width: 0

    // GridView reserves a full cellWidth/cellHeight (thumbnail + spacing) per
    // column/row -- including a trailing gap after the last one -- so the
    // panel must size for that, not just the visible content.
    readonly property int windowContentWidth:
        (grid_columns * (thumbnail_width + grid_spacing)) +
        (content_padding * 2)

    readonly property int gridViewHeight:
        max_visible_rows * (thumbnail_height + grid_spacing)

    // -------------------------------------------------------------------------
    // Initialization
    // -------------------------------------------------------------------------

    Component.onCompleted: {
        WallpaperService.refreshWallpapers();
        root.syncSelectionToCurrent();
    }

    Connections {
        target: WallpaperService.wallpaperModel
        function onCountChanged() {
            root.syncSelectionToCurrent();
        }
    }

    // Keeps the picker's selection pointed at whatever WallpaperService
    // reports as current (e.g. after an async scan or an external change).
    function syncSelectionToCurrent(): void {
        var model = WallpaperService.wallpaperModel;

        if (model.count <= 0 || WallpaperService.currentWallpaper.length === 0) {
            root.clampSelection();
            return;
        }

        for (var j = 0; j < model.count; j++) {
            if (model.get(j).fileName === WallpaperService.currentWallpaper) {
                root.selectedIndex = j;
                break;
            }
        }

        root.clampSelection();
    }

    // -------------------------------------------------------------------------
    // Wallpaper helpers
    // -------------------------------------------------------------------------

    function clampSelection(): void {
        var count = WallpaperService.wallpaperModel.count;

        if (count <= 0) {
            selectedIndex = 0;
            return;
        }

        selectedIndex = Math.min(Math.max(selectedIndex, 0), count - 1);
    }

    function selectedWallpaperName(): string {
        if (WallpaperService.wallpaperModel.count <= 0)
            return "";

        var selectedWallpaper = WallpaperService.wallpaperModel.get(selectedIndex);

        return selectedWallpaper && selectedWallpaper.fileName
            ? selectedWallpaper.fileName
            : "";
    }

    // -------------------------------------------------------------------------
    // Picker controls
    // -------------------------------------------------------------------------

    function toggleSelector(): void {
        selectorVisible = !selectorVisible;
        statusText = "";

        WallpaperService.refreshWallpapers();
        clampSelection();
    }

    function closeSelector(): void {
        selectorVisible = false;
        statusText = "";
    }

    // -------------------------------------------------------------------------
    // Apply wallpaper
    // -------------------------------------------------------------------------

    function applySelectedWallpaper(): void {
        var name = selectedWallpaperName();

        if (name.length === 0) {
            statusText = "No wallpaper selected";
            return;
        }

        WallpaperService.selectWallpaper(name);

        statusText = "Applied " + name;

        selectorVisible = false;
    }

    // -------------------------------------------------------------------------
    // Shortcut
    // -------------------------------------------------------------------------

    GlobalShortcut {
        appid: "quickshell"
        name: "wallpaper-selector"
        description: "Open wallpaper selector"
        triggerDescription: "SUPER+W"
        onPressed: root.toggleSelector()
    }

    // -------------------------------------------------------------------------
    // Focus handling
    // -------------------------------------------------------------------------

    HyprlandFocusGrab {
        active: root.selectorVisible
        windows: selectorWindows.instances
        onCleared: root.closeSelector()
    }

    // -------------------------------------------------------------------------
    // Picker windows
    // -------------------------------------------------------------------------

    Variants {
        id: selectorWindows
        model: root.selectorVisible ? Quickshell.screens : []

        PanelWindow {
            id: selectorWindow

            required property var modelData

            visible: root.selectorVisible
            screen: modelData
            color: "transparent"
            focusable: root.selectorVisible
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            implicitWidth: modelData.width
            implicitHeight: modelData.height

            // -------------------------------------------------------------
            // Backdrop
            // -------------------------------------------------------------

            Backdrop {
                expanded: root.selectorVisible
                onClose: root.closeSelector()
            }

            // -------------------------------------------------------------
            // Picker panel
            // -------------------------------------------------------------

            Rectangle {
                id: panel
                anchors.centerIn: parent

                width: Math.min(root.windowContentWidth, parent.width - (root.window_margin * 2))
                height: panelContent.implicitHeight + (root.content_padding * 2)

                radius: root.window_radius
                color: Colors.background
                opacity: root.selectorVisible ? 1 : 0
                scale: root.selectorVisible ? 1 : Animations.dropdownScaleClosed
                y: root.selectorVisible ? 0 : Animations.dropdownOffset
                z: 1
                focus: root.selectorVisible
                clip: true

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_normal
                        easing.type: Animations.easingStandard
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Animations.duration_slow
                        easing.type: Animations.easingEmphasized
                    }
                }

                Behavior on y {
                    NumberAnimation {
                        duration: Animations.duration_slow
                        easing.type: Animations.easingEmphasized
                    }
                }

                // Absorb clicks so the backdrop doesn't fire through the panel
                MouseArea {
                    anchors.fill: parent
                }

                Keys.onPressed: event => {
                    var count = WallpaperService.wallpaperModel.count;
                    var cols = root.grid_columns;
                    var idx = root.selectedIndex < 0 ? 0 : root.selectedIndex;

                    if (count <= 0) {
                        event.accepted = false;
                        return;
                    }

                    switch (event.key) {
                    case Qt.Key_Right:
                        root.selectedIndex = (idx + 1) % count;
                        break;
                    case Qt.Key_Left:
                        root.selectedIndex = (idx - 1 + count) % count;
                        break;
                    case Qt.Key_Down:
                        root.selectedIndex = Math.min(idx + cols, count - 1);
                        break;
                    case Qt.Key_Up:
                        root.selectedIndex = Math.max(idx - cols, 0);
                        break;
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        root.applySelectedWallpaper();
                        break;
                    case Qt.Key_Escape:
                        root.closeSelector();
                        break;
                    default:
                        event.accepted = false;
                        return;
                    }
                    event.accepted = true;
                }

                ColumnLayout {
                    id: panelContent
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: root.content_padding
                    spacing: root.section_spacing

                    // -----------------------------------------------------
                    // Title
                    // -----------------------------------------------------

                    Text {
                        Layout.fillWidth: true
                        text: Strings.tr(Strings.keys.wallpaper)
                        color: Colors.textSubtle
                        font.pixelSize: Typography.xs
                        font.family: Typography.family
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 1
                        leftPadding: 2
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colors.borderSubtle
                    }

                    // -----------------------------------------------------
                    // Wallpaper grid
                    // -----------------------------------------------------

                    GridView {
                        id: gridView

                        Layout.fillWidth: true
                        Layout.preferredHeight: root.gridViewHeight

                        cellWidth: root.thumbnail_width + root.grid_spacing
                        cellHeight: root.thumbnail_height + root.grid_spacing

                        model: WallpaperService.wallpaperModel
                        currentIndex: root.selectedIndex
                        keyNavigationWraps: true
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        onCurrentIndexChanged: {
                            if (currentIndex < 0)
                                return;

                            root.selectedIndex = currentIndex;
                        }

                        Connections {
                            target: root
                            function onSelectedIndexChanged() {
                                if (gridView.currentIndex !== root.selectedIndex)
                                    gridView.currentIndex = root.selectedIndex;
                            }
                        }

                        // ---------------------------------------------
                        // Wallpaper thumbnail
                        // ---------------------------------------------

                        delegate: Item {
                            id: wallpaper

                            required property int index
                            required property string fileName

                            readonly property bool selected: GridView.isCurrentItem
                            property bool hovered: mouseArea.containsMouse

                            width: root.thumbnail_width
                            height: root.thumbnail_height

                            ClippingRectangle {
                                anchors.fill: parent

                                radius: root.preview_radius
                                color: (wallpaper.selected || wallpaper.hovered) ? Colors.overlayLight : Colors.overlayDark
                                border.width: wallpaper.selected ? root.selected_border_width : root.default_border_width
                                border.color: Colors.accentPrimary
                                clip: true

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Animations.duration_hover
                                        easing.type: Animations.easingStandard
                                    }
                                }

                                ClippingRectangle {
                                    anchors.fill: parent
                                    anchors.margins: root.preview_margin

                                    radius: Math.max(root.preview_radius - root.preview_margin, 0)
                                    color: "transparent"
                                    clip: true

                                    Image {
                                        anchors.fill: parent

                                        source: WallpaperService.pathFor(wallpaper.fileName)
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: false
                                    }
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: root.preview_margin

                                    height: root.caption_height
                                    radius: root.caption_radius
                                    color: WallpaperTheme.caption

                                    Text {
                                        anchors.fill: parent
                                        anchors.leftMargin: root.caption_padding
                                        anchors.rightMargin: root.caption_padding

                                        text: wallpaper.fileName
                                        color: Colors.text
                                        font.pixelSize: Typography.size
                                        font.family: Typography.family
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: gridView.currentIndex = wallpaper.index
                                onDoubleClicked: {
                                    gridView.currentIndex = wallpaper.index;
                                    root.applySelectedWallpaper();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
