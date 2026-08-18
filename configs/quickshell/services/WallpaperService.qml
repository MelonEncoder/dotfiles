pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

/*
  WallpaperService

  Central place for wallpaper state: discovering wallpapers on disk, tracking
  which one is active, and persisting the selection across restarts. Both
  Wallpaper.qml (the background renderer) and WallpaperPicker.qml (the
  selector UI) bind to this instead of managing their own copies of the
  state, so a selection made in the picker is immediately reflected on the
  background.

  Register this file as a singleton in your qmldir, e.g.:
      singleton WallpaperService 1.0 WallpaperService.qml
*/

Singleton {
    id: root

    // -------------------------------------------------------------------------
    // Wallpaper directory + discovery
    // -------------------------------------------------------------------------

    readonly property string wallpaperDirectory:
        Qt.resolvedUrl("../wallpapers")
            .toString()
            .replace(/^file:\/\//, "")

    property alias wallpaperModel: wallpaperModelInternal

    ListModel {
        id: wallpaperModelInternal
    }

    function refreshWallpapers(): void {
        scanProcess.running = false;

        scanProcess.exec([
            "bash",
            "-lc",
            "find -L \"" +
                root.wallpaperDirectory +
                "\" -maxdepth 1 -type f \\(" +
                " -iname '*.jpg'" +
                " -o -iname '*.jpeg'" +
                " -o -iname '*.png'" +
                " -o -iname '*.webp'" +
                " -o -iname '*.bmp'" +
                " \\) -printf '%f\\n' | sort"
        ]);
    }

    Process {
        id: scanProcess

        stdout: StdioCollector {
            id: scanOutput
            waitForEnd: true

            onStreamFinished: {
                wallpaperModelInternal.clear();

                var raw = text.trim();
                var lines = raw.length > 0 ? raw.split("\n") : [];

                for (var i = 0; i < lines.length; i++) {
                    var fileName = lines[i].trim();
                    if (fileName.length > 0)
                        wallpaperModelInternal.append({ fileName: fileName });
                }

                if (root.pendingRandom && wallpaperModelInternal.count > 0) {
                    root.pendingRandom = false;
                    root.currentWallpaper = wallpaperModelInternal.get(
                        Math.floor(Math.random() * wallpaperModelInternal.count)
                    ).fileName;
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // Current wallpaper
    // -------------------------------------------------------------------------

    property string currentWallpaper: ""
    property bool pendingRandom: WallpaperTheme.wallpaper === "random"

    readonly property string currentWallpaperPath:
        currentWallpaper.length > 0 ? root.pathFor(currentWallpaper) : ""

    function pathFor(fileName: string): string {
        return Qt.resolvedUrl(root.wallpaperDirectory + "/" + fileName).toString();
    }

    function selectWallpaper(fileName: string): void {
        if (!fileName || fileName === root.currentWallpaper)
            return;

        root.pendingRandom = false;
        root.currentWallpaper = fileName;
        stateFile.setText(fileName);
    }

    // -------------------------------------------------------------------------
    // Persisted selection — survives shell restarts
    // -------------------------------------------------------------------------

    FileView {
        id: stateFile
        path: Quickshell.statePath("wallpaper")
        preload: true
        printErrors: false

        onLoaded: {
            var saved = stateFile.text().trim();
            if (saved.length > 0) {
                root.pendingRandom = false;
                root.currentWallpaper = saved;
            }
        }
    }

    Component.onCompleted: root.refreshWallpapers()
}
