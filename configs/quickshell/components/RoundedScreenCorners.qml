pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes as QtShapes
import "../theme"

// Fake rounded screen corners: four small non-interactive windows, one
// pinned to each corner of the screen, that mask the screen's real
// (square) corner pixels into rounded ones. Purely decorative --
// independent of the bar's own shape, and click-through (empty mask).
// Follows the technique from end-4/dots-hyprland's RoundCorner.qml:
// https://github.com/end-4/dots-hyprland/blob/main/dots/.config/quickshell/ii/modules/common/widgets/RoundCorner.qml
Item {
    id: roundedScreenCorners

    required property var screen
    // Offsets top-anchored corners down by this amount, so the top two
    // corners sit right below the bar instead of at the bare screen edge.
    property int topOffset: 0

    // corner: 0 = top-left, 1 = top-right, 2 = bottom-left, 3 = bottom-right
    component RoundCorner: Item {
        id: rc

        property int corner: 0
        property int size: Shape.radiusLarge
        property color color: Colors.background

        readonly property bool isTop: rc.corner === 0 || rc.corner === 1
        readonly property bool isLeft: rc.corner === 0 || rc.corner === 2

        implicitWidth: rc.size
        implicitHeight: rc.size

        QtShapes.Shape {
            id: shape
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true
            preferredRendererType: QtShapes.Shape.CurveRenderer

            QtShapes.ShapePath {
                id: shapePath
                strokeWidth: 0
                fillColor: rc.color
                pathHints: QtShapes.ShapePath.PathSolid & QtShapes.ShapePath.PathNonIntersecting

                startX: rc.isLeft ? 0 : rc.size
                startY: rc.isTop ? 0 : rc.size

                PathAngleArc {
                    moveToStart: false
                    centerX: rc.size - shapePath.startX
                    centerY: rc.size - shapePath.startY
                    radiusX: rc.size
                    radiusY: rc.size
                    startAngle: {
                        if (rc.corner === 0) return 180; // top-left
                        if (rc.corner === 1) return -90; // top-right
                        if (rc.corner === 2) return 90; // bottom-left
                        return 0; // bottom-right
                    }
                    sweepAngle: 90
                }

                PathLine {
                    x: shapePath.startX
                    y: shapePath.startY
                }
            }
        }
    }

    component CornerWindow: PanelWindow {
        id: cornerWindow

        required property var modelData
        required property int cornerIndex
        // Offsets top-anchored corners down by this amount, so the top two
        // corners sit right below the bar instead of at the bare screen edge.
        property int topOffset: 0

        screen: cornerWindow.modelData
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        focusable: false
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:screen-corners"
        mask: Region {}

        anchors {
            top: cornerWindow.cornerIndex === 0 || cornerWindow.cornerIndex === 1
            left: cornerWindow.cornerIndex === 0 || cornerWindow.cornerIndex === 2
            right: cornerWindow.cornerIndex === 1 || cornerWindow.cornerIndex === 3
            bottom: cornerWindow.cornerIndex === 2 || cornerWindow.cornerIndex === 3
        }

        margins.top: cornerWindow.topOffset

        implicitWidth: cornerShape.implicitWidth
        implicitHeight: cornerShape.implicitHeight

        RoundCorner {
            id: cornerShape
            corner: cornerWindow.cornerIndex
        }
    }

    CornerWindow { modelData: roundedScreenCorners.screen; cornerIndex: 0; topOffset: roundedScreenCorners.topOffset }
    CornerWindow { modelData: roundedScreenCorners.screen; cornerIndex: 1; topOffset: roundedScreenCorners.topOffset }
    CornerWindow { modelData: roundedScreenCorners.screen; cornerIndex: 2 }
    CornerWindow { modelData: roundedScreenCorners.screen; cornerIndex: 3 }
}
