pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root
    property bool expanded: false
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed
    property string osInfo: "Arch Linux"
    property string osId: "arch"
    property string osLike: ""
    property string kernelInfo: ""
    property string osVersionRaw: ""
    property var distroMeta: resolveDistro(root.osId, root.osLike, root.osInfo)
    property string distroDisplay: root.distroMeta.name
    property string distroIcon: root.distroMeta.icon
    property string kernelDisplay: formatKernel(root.kernelInfo)
    property string versionDisplay: formatVersion(root.osVersionRaw)
    readonly property int popupWidth: 310
    property string cpuRaw: ""
    property string ramRaw: ""
    property string gpuRaw: ""
    property string storageRaw: ""
    property string cpuDisplay: formatCpu(root.cpuRaw)
    property string ramDisplay: root.ramRaw
    property string gpuDisplay: formatGpu(root.gpuRaw)
    property string storageDisplay: root.storageRaw

    function formatDistro(value: string): string {
        var text = value.trim();
        if (text.length === 0)
            return "Linux";
        return text.replace(/\s+/g, " ");
    }

    function formatKernel(value: string): string {
        var text = value.trim();
        if (text.length === 0)
            return "";
        var dash = text.indexOf("-");
        if (dash > 0)
            text = text.slice(0, dash);
        return text;
    }

    function formatVersion(value: string): string {
        var text = value.trim();
        if (text.length === 0)
            return "";
        return text.replace(/\s+/g, " ");
    }

    function formatCpu(value: string): string {
        var text = value.trim();
        if (text.length === 0)
            return "";
        return text.replace(/\(R\)/g, "").replace(/\(TM\)/g, "").replace(/\s+/g, " ").trim();
    }

    function formatGpu(value: string): string {
        var text = value.trim();
        if (text.length === 0)
            return "";
        var match = text.match(/\[([^\]]+)\]/);
        if (match)
            return match[1];
        return text;
    }

    function resolveDistro(id: string, like: string, pretty: string): var {
        var key = (id || "").toLowerCase().trim();
        var likeTokens = (like || "").toLowerCase().split(/\s+/);
        var map = {
            "arch": {
                icon: "",
                name: "Arch Linux"
            },
            "nixos": {
                icon: "",
                name: "NixOS"
            },
            "ubuntu": {
                icon: "",
                name: "Ubuntu"
            },
            "debian": {
                icon: "",
                name: "Debian"
            },
            "fedora": {
                icon: "",
                name: "Fedora"
            },
            "opensuse": {
                icon: "",
                name: "openSUSE"
            },
            "manjaro": {
                icon: "",
                name: "Manjaro"
            },
            "gentoo": {
                icon: "",
                name: "Gentoo"
            }
        };

        if (map[key])
            return map[key];
        for (var i = 0; i < likeTokens.length; i++) {
            var token = likeTokens[i];
            if (map[token])
                return map[token];
        }
        return {
            icon: "",
            name: formatDistro(pretty)
        };
    }

    implicitWidth: osIcon.implicitWidth + (Theme.bar_widget_padding * 2)
    implicitHeight: Theme.bar_widget_height
    radius: Theme.radius_normal
    color: root.pressed ? Theme.color_surface_pressed : (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
    border.width: Theme.border_width
    border.color: Theme.color_border

    component HwRow: RowLayout {
        required property string icon
        required property string label
        required property string value
        Layout.fillWidth: true
        spacing: 8
        visible: value.length > 0

        Text {
            text: icon
            color: Theme.color_text_subtle
            font.pixelSize: Theme.font_size_icon
            font.family: Theme.font_family_icon
        }

        Text {
            text: label
            color: Theme.color_text_subtle
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: value
            color: Theme.color_text
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family
            Layout.maximumWidth: 200
            elide: Text.ElideRight
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.duration_hover
            easing.type: Animations.easing_standard
        }
    }

    Text {
        id: osIcon
        anchors.centerIn: parent
        text: root.distroIcon
        color: Theme.color_text
        font.pixelSize: Theme.font_size_icon
        font.family: Theme.font_family_icon
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    HyprlandFocusGrab {
        active: root.expanded
        windows: [dropdown]
        onCleared: root.expanded = false
    }

    PopupWindow {
        id: dropdown
        anchor.item: root
        visible: root.expanded
        implicitWidth: dropdown.screen.width
        implicitHeight: dropdown.screen.height
        color: "transparent"

        PopupBackdrop {
            expanded: root.expanded
            onClose: root.expanded = false
        }

        Rectangle {
            id: dropdownPanel
            y: Theme.bar_widget_height + (Theme.bar_padding * 2)
            width: root.popupWidth + (Theme.bar_widget_padding * 2)
            height: popupContent.implicitHeight + (Theme.bar_widget_padding * 2)
            radius: Theme.radius_background
            color: Theme.color_background
            border.width: Theme.border_width
            border.color: Theme.color_border
            clip: true
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : Animations.dropdown_scale_closed
            transformOrigin: Item.Top
            focus: root.expanded
            Keys.onEscapePressed: root.expanded = false

            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.duration_dropdown
                    easing.type: Animations.easing_emphasized
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Animations.duration_dropdown
                    easing.type: Animations.easing_emphasized
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: Animations.duration_dropdown
                    easing.type: Animations.easing_emphasized
                }
            }

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                id: popupContent
                anchors.fill: parent
                anchors.margins: Theme.bar_widget_padding
                spacing: 6
                width: root.popupWidth

                Text {
                    Layout.fillWidth: true
                    text: Strings.tr(Strings.keys.system)
                    color: Theme.color_text_subtle
                    font.pixelSize: Theme.font_size_xs
                    font.family: Theme.font_family
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1
                    leftPadding: 2
                    bottomPadding: 2
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.color_border_subtle
                }

                Rectangle {
                    id: aboutItem
                    Layout.fillWidth: true
                    Layout.preferredHeight: aboutContent.implicitHeight + (Theme.bar_widget_padding * 2)
                    radius: Theme.radius_normal
                    color: Theme.color_surface

                    ColumnLayout {
                        id: aboutContent
                        anchors.fill: parent
                        anchors.margins: Theme.bar_widget_padding
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: root.distroDisplay
                                    elide: Text.ElideRight
                                    color: Theme.color_text
                                    font.pixelSize: Theme.font_size_title
                                    font.family: Theme.font_family
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: root.kernelDisplay.length > 0 ? (Strings.tr(Strings.keys.kernel) + " " + root.kernelDisplay) : ""
                                    visible: text.length > 0
                                    color: Theme.color_text_subtle
                                    font.pixelSize: Theme.font_size
                                    font.family: Theme.font_family
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: root.versionDisplay.length > 0 ? (Strings.tr(Strings.keys.version) + " " + root.versionDisplay) : ""
                                    visible: text.length > 0
                                    color: Theme.color_text_subtle
                                    font.pixelSize: Theme.font_size
                                    font.family: Theme.font_family
                                }
                            }

                            Text {
                                text: root.distroIcon
                                color: Theme.color_text
                                font.pixelSize: Theme.font_size_icon_lg
                                font.family: Theme.font_family_icon
                            }
                        }
                    }
                }

                Rectangle {
                    id: hwItem
                    Layout.fillWidth: true
                    implicitHeight: hwContent.implicitHeight + (Theme.bar_widget_padding * 2)
                    radius: Theme.radius_normal
                    color: Theme.color_surface
                    visible: root.cpuDisplay.length > 0 || root.gpuDisplay.length > 0 || root.ramDisplay.length > 0 || root.storageDisplay.length > 0

                    ColumnLayout {
                        id: hwContent
                        anchors.fill: parent
                        anchors.margins: Theme.bar_widget_padding
                        spacing: 4

                        HwRow {
                            icon: "󰻠"
                            label: Strings.tr(Strings.keys.cpu)
                            value: root.cpuDisplay
                        }

                        HwRow {
                            icon: "󰢮"
                            label: Strings.tr(Strings.keys.gpu)
                            value: root.gpuDisplay
                        }

                        HwRow {
                            icon: "󰍛"
                            label: Strings.tr(Strings.keys.ram)
                            value: root.ramDisplay
                        }

                        HwRow {
                            icon: "󰆼"
                            label: Strings.tr(Strings.keys.storage)
                            value: root.storageDisplay
                        }
                    }
                }
            }
        }
    }

    StdioCollector {
        id: osProbeOut
        waitForEnd: true
        onStreamFinished: {
            var lines = text.trim().split("\n");
            if (lines.length > 0 && lines[0].length > 0)
                root.osInfo = lines[0];
            if (lines.length > 1 && lines[1].length > 0)
                root.osId = lines[1];
            if (lines.length > 2)
                root.osLike = lines[2];
            if (lines.length > 3)
                root.osVersionRaw = lines[3];
            if (lines.length > 4 && lines[4].length > 0)
                root.kernelInfo = lines[4];
        }
    }

    Process {
        id: osProbe
        stdout: osProbeOut
        command: ["sh", "-c", ". /etc/os-release 2>/dev/null; printf '%s\\n' \"${PRETTY_NAME:-Linux}\" \"${ID:-linux}\" \"${ID_LIKE:-}\" \"${VERSION_ID:-${VERSION:-}}\"; uname -r"]
    }

    StdioCollector {
        id: hwProbeOut
        waitForEnd: true
        onStreamFinished: {
            var lines = text.trim().split("\n");
            if (lines.length > 0 && lines[0].length > 0)
                root.cpuRaw = lines[0];
            if (lines.length > 1 && lines[1].length > 0)
                root.ramRaw = lines[1];
            if (lines.length > 2 && lines[2].length > 0)
                root.gpuRaw = lines[2];
            if (lines.length > 3 && lines[3].length > 0)
                root.storageRaw = lines[3];
        }
    }

    Process {
        id: hwProbe
        stdout: hwProbeOut
        command: ["sh", "-c", "grep 'model name' /proc/cpuinfo | head -1 | sed 's/.*: //'; free -h | awk '/^Mem:/ {print $2}'; lspci 2>/dev/null | grep -iE 'vga compatible|3d controller' | head -1 | sed 's/.*: //' | sed 's/ (rev [^)]*)//'; df -h / | awk 'NR==2 {print $2}'"]
    }

    Component.onCompleted: {
        osProbe.running = true;
        hwProbe.running = true;
    }
}
