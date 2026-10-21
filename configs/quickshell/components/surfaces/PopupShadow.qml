import QtQuick
import QtQuick.Effects
import "../../theme"

// Drop shadow that follows a popup panel's geometry and open/close
// animation (position, size, radius, opacity, scale). Declare it as a
// sibling *before* the panel so it renders underneath; it can't be a child
// because panels clip their contents.
//
// Usage:
//   PopupShadow { target: panel }
//   PopupSurface { id: panel; ... }
RectangularShadow {
    id: root
    required property Item target

    x: root.target.x
    y: root.target.y
    width: root.target.width
    height: root.target.height
    radius: root.target.radius ?? 0
    opacity: root.target.opacity
    scale: root.target.scale
    transformOrigin: root.target.transformOrigin
    visible: root.target.visible && root.target.opacity > 0

    color: Colors.shadow
    blur: Shape.shadowBlur
    offset.y: Shape.shadowOffsetY
}
