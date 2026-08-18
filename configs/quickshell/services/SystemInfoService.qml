pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string osInfo: "Arch Linux"
    property string osId: "arch"
    property string osLike: ""
    property string kernelInfo: ""
    property string osVersionRaw: ""
    property string cpuRaw: ""
    property string ramRaw: ""
    property string gpuRaw: ""
    property string storageRaw: ""

    readonly property var distroMeta: resolveDistro(root.osId, root.osLike, root.osInfo)
    readonly property string distroDisplay: root.distroMeta.name
    readonly property string distroIcon: root.distroMeta.icon
    readonly property string kernelDisplay: formatKernel(root.kernelInfo)
    readonly property string versionDisplay: formatVersion(root.osVersionRaw)
    readonly property string cpuDisplay: formatCpu(root.cpuRaw)
    readonly property string ramDisplay: root.ramRaw
    readonly property string gpuDisplay: formatGpu(root.gpuRaw)
    readonly property string storageDisplay: root.storageRaw

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
            },
            "guix": {
                icon: "",
                name: "Guix"
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
            icon: "",
            name: formatDistro(pretty)
        };
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
