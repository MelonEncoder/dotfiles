pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Wayland
import "../services" as Services

Item {
    id: root

    Component.onCompleted: {
        Services.LockService.lockSurface = lockSurface;
    }

    Component {
        id: lockSurface

        WlSessionLockSurface {
            id: surface

            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Theme.lock_base

                Rectangle {
                    anchors.fill: parent
                    color: Theme.lock_scrim
                }

                FocusScope {
                    id: focusRoot

                    anchors.fill: parent
                    focus: true

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.ArrowCursor

                        onPressed:
                            passwordInput.forceActiveFocus()
                    }

                    Column {
                        id: lockColumn

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }

                        width: Math.min(
                            parent.width -
                            (Theme.lock_screen_margin * 2),
                            Theme.lock_column_width
                        )

                        spacing: Theme.lock_column_spacing

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10

                            Text {
                                anchors.verticalCenter: parent.verticalCenter

                                text: "󰌾"
                                color: Theme.color_text

                                font.family: Theme.font_family_icon
                                font.pixelSize:
                                    Theme.lock_date_font_size + 6
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter

                                text: "Locked"
                                color: Theme.color_text

                                font.family:
                                    Theme.lock_body_font_family

                                font.pixelSize:
                                    Theme.lock_date_font_size + 6
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.lock_header_spacing

                            Item {
                                width: parent.width
                                height: timeText.implicitHeight

                                Text {
                                    id: timeText

                                    anchors.horizontalCenter:
                                        parent.horizontalCenter

                                    text: Services.ClockService.time

                                    horizontalAlignment:
                                        Text.AlignHCenter

                                    font.family:
                                        Theme.lock_time_font_family

                                    font.pixelSize:
                                        Theme.lock_time_font_size

                                    font.bold: true

                                    SequentialAnimation on color {
                                        loops: Animation.Infinite

                                        ColorAnimation {
                                            from: "#ff6b6b"
                                            to: "#ffb347"
                                            duration: 700
                                        }

                                        ColorAnimation {
                                            to: "#ffff66"
                                            duration: 700
                                        }

                                        ColorAnimation {
                                            to: "#6bff6b"
                                            duration: 700
                                        }

                                        ColorAnimation {
                                            to: "#6bd5ff"
                                            duration: 700
                                        }

                                        ColorAnimation {
                                            to: "#8b5cf6"
                                            duration: 700
                                        }

                                        ColorAnimation {
                                            to: "#ff6bff"
                                            duration: 700
                                        }

                                        ColorAnimation {
                                            to: "#ff6b6b"
                                            duration: 700
                                        }
                                    }
                                }
                            }

                            Item {
                                width: parent.width
                                height: dateText.implicitHeight

                                Text {
                                    id: dateText

                                    anchors.horizontalCenter:
                                        parent.horizontalCenter

                                    text: Services.ClockService.fullDate

                                    horizontalAlignment:
                                        Text.AlignHCenter

                                    color: Theme.color_text

                                    font.family:
                                        Theme.lock_body_font_family

                                    font.pixelSize:
                                        Theme.lock_date_font_size
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: Theme.lock_input_height

                            Rectangle {
                                id: inputFrame

                                property color frameBorderColor:
                                    Services.LockService.failedAttempt
                                        ? Theme.lock_error
                                        : Theme.color_accent_primary

                                anchors.fill: parent

                                radius: Theme.lock_input_radius
                                color: Theme.color_text

                                border.width:
                                    Theme.lock_input_border_width

                                border.color: frameBorderColor

                                Behavior on frameBorderColor {
                                    ColorAnimation {
                                        duration: Animations.duration_normal
                                        easing.type:
                                            Animations.easing_standard
                                    }
                                }

                                TextInput {
                                    id: passwordInput

                                    anchors.fill: parent

                                    anchors.leftMargin:
                                        Theme.lock_input_padding

                                    anchors.rightMargin:
                                        Theme.lock_input_padding

                                    verticalAlignment:
                                        TextInput.AlignVCenter

                                    color: Theme.color_background

                                    font.family:
                                        Theme.lock_body_font_family

                                    font.pixelSize:
                                        Theme.lock_input_font_size

                                    echoMode: TextInput.Password
                                    passwordCharacter: "•"

                                    selectByMouse: false
                                    focus: true

                                    enabled:
                                        Services.LockService.locked &&
                                        !Services.LockService.authenticating

                                    inputMethodHints:
                                        Qt.ImhSensitiveData |
                                        Qt.ImhNoPredictiveText |
                                        Qt.ImhNoAutoUpperCase

                                    onAccepted:
                                        Services.LockService.submitSecret(text)

                                    onTextEdited: {
                                        if (Services.LockService.failedAttempt)
                                            Services.LockService.failedAttempt = false;

                                        if (
                                            Services.LockService.statusText ===
                                                "Incorrect password" ||
                                            Services.LockService.statusText ===
                                                "Too many failed attempts" ||
                                            Services.LockService.statusText ===
                                                "Enter your password"
                                        ) {
                                            Services.LockService.statusText = "";
                                        }
                                    }

                                    Keys.onEscapePressed: {
                                        text = "";
                                        Services.LockService.failedAttempt = false;
                                        Services.LockService.statusText = "";
                                    }
                                }

                                Text {
                                    anchors.fill: parent

                                    anchors.leftMargin:
                                        Theme.lock_input_padding

                                    anchors.rightMargin:
                                        Theme.lock_input_padding

                                    verticalAlignment:
                                        Text.AlignVCenter

                                    text:
                                        passwordInput.text.length === 0
                                            ? "Input Password..."
                                            : ""

                                    color: Theme.lock_placeholder

                                    font.family:
                                        Theme.lock_body_font_family

                                    font.pixelSize:
                                        Theme.lock_input_font_size

                                    font.italic: true
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            height: Theme.lock_status_height

                            text:
                                Services.LockService.authenticating
                                    ? "Checking password..."
                                    : Services.LockService.statusText

                            visible: text.length > 0

                            horizontalAlignment:
                                Text.AlignHCenter

                            color:
                                Services.LockService.failedAttempt
                                    ? Theme.lock_error
                                    : Theme.color_text

                            font.family:
                                Theme.lock_body_font_family

                            font.pixelSize:
                                Theme.lock_status_font_size
                        }

                        Row {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            spacing: 16

                            Repeater {
                                model: [
                                    {
                                        icon: "󰒲",
                                        label: "Suspend",
                                        action: function() {
                                            Services.LockService.suspend();
                                        }
                                    },
                                    {
                                        icon: "󰤄",
                                        label: "Sleep",
                                        action: function() {
                                            Services.LockService.sleep();
                                        }
                                    },
                                    {
                                        icon: "󰑓",
                                        label: "Restart",
                                        action: function() {
                                            Services.LockService.reboot();
                                        }
                                    },
                                    {
                                        icon: "󰐥",
                                        label: "Shutdown",
                                        action: function() {
                                            Services.LockService.shutdown();
                                        }
                                    }
                                ]

                                Rectangle {
                                    id: powerOption

                                    required property var modelData

                                    property bool hovered:
                                        powerMouse.containsMouse

                                    width: 90
                                    height: 64

                                    radius: Theme.radius_normal * 2

                                    color:
                                        hovered
                                            ? Theme.color_overlay_light
                                            : "transparent"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration:
                                                Animations.duration_hover

                                            easing.type:
                                                Animations.easing_standard
                                        }
                                    }

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 6

                                        Text {
                                            anchors.horizontalCenter:
                                                parent.horizontalCenter

                                            text: powerOption.modelData.icon

                                            color: Theme.color_text

                                            font.family:
                                                Theme.font_family_icon

                                            font.pixelSize: 22
                                        }

                                        Text {
                                            anchors.horizontalCenter:
                                                parent.horizontalCenter

                                            text: powerOption.modelData.label

                                            color: Theme.color_text

                                            font.family:
                                                Theme.lock_body_font_family

                                            font.pixelSize:
                                                Theme.lock_status_font_size
                                        }
                                    }

                                    MouseArea {
                                        id: powerMouse

                                        anchors.fill: parent

                                        hoverEnabled: true
                                        cursorShape:
                                            Qt.PointingHandCursor

                                        onClicked:
                                            powerOption.modelData.action()
                                    }
                                }
                            }
                        }
                    }

                    Component.onCompleted:
                        passwordInput.forceActiveFocus()

                    onActiveFocusChanged: {
                        if (
                            activeFocus &&
                            Services.LockService.locked
                        ) {
                            passwordInput.forceActiveFocus();
                        }
                    }
                }
            }
        }
    }
}
