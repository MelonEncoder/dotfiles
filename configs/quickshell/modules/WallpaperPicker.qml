pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
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
    property int carouselIndex: 0
    property string statusText: ""

    readonly property int carouselLoopCount: 200

    readonly property int virtualWallpaperCount:
        WallpaperService.wallpaperModel.count > 0
            ? WallpaperService.wallpaperModel.count * carouselLoopCount
            : 0

    // -------------------------------------------------------------------------
    // Picker layout
    // -------------------------------------------------------------------------

    readonly property int window_margin: 24
    readonly property int content_padding: 8
    readonly property int content_spacing: 10

    readonly property int visible_preview_count: 3
    readonly property int preview_spacing: 12

    readonly property int preview_width: 345
    readonly property int preview_height: 230

    readonly property real selected_preview_scale: 1.16
    readonly property real inactive_preview_scale:
        1 / selected_preview_scale

    readonly property int selected_preview_width:
        Math.round(
            preview_width * selected_preview_scale
        )

    readonly property int selected_preview_height:
        Math.round(
            preview_height * selected_preview_scale
        )

    readonly property int preview_slot_width:
        selected_preview_width

    readonly property int preview_slot_height:
        selected_preview_height

    readonly property int list_surface_height:
        preview_slot_height + (content_padding * 2)

    readonly property int preview_margin: 6
    readonly property int caption_height: 28
    readonly property int caption_padding: 8

    readonly property int window_radius: 18
    readonly property int preview_radius: 12
    readonly property int caption_radius: 0

    readonly property int window_border_width: 2
    readonly property int selected_border_width: 2
    readonly property int default_border_width: 0

    readonly property int windowContentWidth:
        (visible_preview_count * preview_slot_width) +
        ((visible_preview_count - 1) * preview_spacing) +
        (content_padding * 2)

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
                root.carouselIndex = j;
                break;
            }
        }

        root.clampSelection();
        root.recenterCarousel();
    }

    // -------------------------------------------------------------------------
    // Wallpaper helpers
    // -------------------------------------------------------------------------

    function wrappedIndex(index: int): int {
        var count = WallpaperService.wallpaperModel.count;

        if (count <= 0)
            return 0;

        var wrapped = index % count;

        return wrapped < 0
            ? wrapped + count
            : wrapped;
    }

    function baseCarouselIndex(): int {
        var count = WallpaperService.wallpaperModel.count;

        if (count <= 0)
            return 0;

        return Math.floor(carouselLoopCount / 2) * count;
    }

    function recenterCarousel(): void {
        if (WallpaperService.wallpaperModel.count <= 0) {
            carouselIndex = 0;
            return;
        }

        carouselIndex =
            baseCarouselIndex() +
            wrappedIndex(carouselIndex);
    }

    function clampSelection(): void {
        if (WallpaperService.wallpaperModel.count <= 0) {
            selectedIndex = 0;
            carouselIndex = 0;
            return;
        }

        selectedIndex = wrappedIndex(selectedIndex);
    }

    function selectedWallpaperName(): string {
        if (WallpaperService.wallpaperModel.count <= 0)
            return "";

        var selectedWallpaper =
            WallpaperService.wallpaperModel.get(selectedIndex);

        return selectedWallpaper &&
            selectedWallpaper.fileName
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

    function moveSelection(delta: int): void {
        var count = WallpaperService.wallpaperModel.count;

        if (count <= 0)
            return;

        carouselIndex += delta;
        selectedIndex = wrappedIndex(carouselIndex);

        if (
            carouselIndex < count ||
            carouselIndex >= (virtualWallpaperCount - count)
        ) {
            recenterCarousel();
        }
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

        triggerDescription: "SUPER+SHIFT+W"

        onPressed:
            root.toggleSelector()
    }

    // -------------------------------------------------------------------------
    // Focus handling
    // -------------------------------------------------------------------------

    HyprlandFocusGrab {
        active: root.selectorVisible

        windows: selectorWindows.instances

        onCleared:
            root.closeSelector()
    }

    // -------------------------------------------------------------------------
    // Picker windows
    // -------------------------------------------------------------------------

    Variants {
        id: selectorWindows

        model:
            root.selectorVisible
                ? Quickshell.screens
                : []

        PanelWindow {
            id: selectorWindow

            required property var modelData

            visible: root.selectorVisible

            screen: modelData

            color: "transparent"

            focusable: root.selectorVisible

            exclusiveZone: 0

            WlrLayershell.layer:
                WlrLayer.Overlay

            WlrLayershell.keyboardFocus:
                WlrKeyboardFocus.Exclusive

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            implicitWidth: modelData.width
            implicitHeight: modelData.height

            // -------------------------------------------------------------
            // Overlay
            // -------------------------------------------------------------

            Rectangle {
                anchors.fill: parent

                color: Colors.background

                opacity: root.selectorVisible
                    ? 1
                    : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration:
                            Animations.duration_normal

                        easing.type:
                            Animations.easingStandard
                    }
                }
            }

            // -------------------------------------------------------------
            // Picker panel
            // -------------------------------------------------------------

            Rectangle {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                anchors.verticalCenter:
                    parent.verticalCenter

                width: Math.min(
                    root.windowContentWidth,
                    parent.width -
                        (root.window_margin * 2)
                )

                implicitHeight:
                    root.list_surface_height

                radius:
                    root.window_radius

                color:
                    Colors.background

                border.width:
                    root.window_border_width

                border.color:
                    WallpaperTheme.windowBorder

                Rectangle {
                    id: listSurface

                    anchors.centerIn: parent

                    width: parent.width
                    height: root.list_surface_height

                    radius: root.window_radius

                    color: "transparent"

                    border.width: 0

                    clip: false

                    // -----------------------------------------------------
                    // Wallpaper carousel
                    // -----------------------------------------------------

                    ListView {
                        id: listView

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter:
                            parent.verticalCenter

                        anchors.leftMargin:
                            root.content_padding

                        anchors.rightMargin:
                            root.content_padding

                        height:
                            root.preview_slot_height

                        model:
                            root.virtualWallpaperCount

                        orientation:
                            ListView.Horizontal

                        spacing:
                            root.preview_spacing

                        snapMode:
                            ListView.SnapToItem

                        clip: false

                        currentIndex:
                            root.carouselIndex

                        boundsBehavior:
                            Flickable.StopAtBounds

                        onCurrentIndexChanged: {
                            if (
                                currentIndex < 0 ||
                                WallpaperService.wallpaperModel.count <= 0
                            )
                                return;

                            root.carouselIndex =
                                currentIndex;

                            root.selectedIndex =
                                root.wrappedIndex(
                                    currentIndex
                                );

                            if (
                                currentIndex <
                                    WallpaperService.wallpaperModel.count ||
                                currentIndex >=
                                    (
                                        root.virtualWallpaperCount -
                                        WallpaperService.wallpaperModel.count
                                    )
                            ) {
                                root.recenterCarousel();

                                positionViewAtIndex(
                                    root.carouselIndex,
                                    ListView.Center
                                );
                            }
                        }

                        Component.onCompleted:
                            positionViewAtIndex(
                                root.carouselIndex,
                                ListView.Center
                            )

                        Connections {
                            target: root

                            function onCarouselIndexChanged() {
                                listView.positionViewAtIndex(
                                    root.carouselIndex,
                                    ListView.Center
                                );
                            }
                        }

                        // -------------------------------------------------
                        // Wallpaper preview
                        // -------------------------------------------------

                        delegate: Item {
                            id: wallpaper

                            required property int index

                            readonly property int wallpaperIndex:
                                root.wrappedIndex(index)

                            readonly property var wallpaperItem:
                                WallpaperService.wallpaperModel.count > 0
                                    ? WallpaperService.wallpaperModel.get(
                                        wallpaperIndex
                                    )
                                    : null

                            readonly property string fileName:
                                wallpaperItem &&
                                wallpaperItem.fileName
                                    ? wallpaperItem.fileName
                                    : ""

                            readonly property bool selected:
                                root.selectedIndex ===
                                wallpaperIndex

                            width:
                                root.preview_slot_width

                            height:
                                root.preview_slot_height

                            Rectangle {
                                anchors.centerIn: parent

                                width:
                                    root.selected_preview_width

                                height:
                                    root.selected_preview_height

                                radius:
                                    root.preview_radius

                                color:
                                    wallpaper.selected
                                        ? Colors.overlayLight
                                        : Colors.overlayDark

                                border.width:
                                    wallpaper.selected
                                        ? root.selected_border_width
                                        : root.default_border_width

                                border.color:
                                    wallpaper.selected
                                        ? Colors.text
                                        : Colors.borderSubtle

                                z:
                                    wallpaper.selected
                                        ? 1
                                        : 0

                                scale:
                                    wallpaper.selected
                                        ? 1
                                        : root.inactive_preview_scale

                                transformOrigin:
                                    Item.Bottom

                                Behavior on scale {
                                    enabled:
                                        !wallpaper.selected

                                    NumberAnimation {
                                        duration:
                                            Animations.duration_slow

                                        easing.type:
                                            Animations.easingEmphasized
                                    }
                                }

                                Image {
                                    anchors.fill: parent

                                    anchors.margins:
                                        root.preview_margin

                                    source:
                                        WallpaperService.pathFor(
                                            wallpaper.fileName
                                        )

                                    fillMode:
                                        Image.PreserveAspectCrop

                                    asynchronous: true
                                    cache: false

                                    clip: true
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom

                                    anchors.margins:
                                        root.preview_margin

                                    height:
                                        root.caption_height

                                    radius:
                                        root.caption_radius

                                    color:
                                        WallpaperTheme.caption

                                    Text {
                                        anchors.fill: parent

                                        anchors.leftMargin:
                                            root.caption_padding

                                        anchors.rightMargin:
                                            root.caption_padding

                                        text:
                                            wallpaper.fileName

                                        color:
                                            Colors.text

                                        font.pixelSize:
                                            Typography.size

                                        font.family:
                                            Typography.family

                                        verticalAlignment:
                                            Text.AlignVCenter

                                        elide:
                                            Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    root.carouselIndex =
                                        wallpaper.index

                                    root.selectedIndex =
                                        wallpaper.wallpaperIndex
                                }

                                onDoubleClicked: {
                                    root.carouselIndex =
                                        wallpaper.index

                                    root.selectedIndex =
                                        wallpaper.wallpaperIndex

                                    root.applySelectedWallpaper()
                                }
                            }
                        }
                    }
                }

                // ---------------------------------------------------------
                // Keyboard controls
                // ---------------------------------------------------------

                Keys.onLeftPressed: function(event) {
                    root.moveSelection(-1);
                    event.accepted = true;
                }

                Keys.onRightPressed: function(event) {
                    root.moveSelection(1);
                    event.accepted = true;
                }

                Keys.onPressed: function(event) {
                    if (
                        event.key === Qt.Key_Return ||
                        event.key === Qt.Key_Enter
                    ) {
                        root.applySelectedWallpaper();
                        event.accepted = true;
                    }
                }

                Keys.onEscapePressed: function(event) {
                    root.closeSelector();
                    event.accepted = true;
                }

                focus:
                    root.selectorVisible
            }

            // -------------------------------------------------------------
            // Click outside to close
            // -------------------------------------------------------------

            MouseArea {
                anchors.fill: parent

                acceptedButtons:
                    Qt.LeftButton

                z: -1

                onClicked:
                    root.closeSelector()
            }
        }
    }
}
