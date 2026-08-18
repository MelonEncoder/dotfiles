pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland
import "../services" as Services
import "../theme"
import "../components/ui"

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
                color: LockScreenTheme.base

                Rectangle {
                    anchors.fill: parent
                    color: LockScreenTheme.scrim
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
                            (LockScreenTheme.margin * 2),
                            LockScreenTheme.columnWidth
                        )

                        spacing: LockScreenTheme.columnSpacing

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10

                            Text {
                                anchors.verticalCenter: parent.verticalCenter

                                text: "󰌾"
                                color: Colors.text

                                font.family: Typography.iconFamily
                                font.pixelSize:
                                    LockScreenTheme.dateFontSize + 6
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter

                                text: "Locked"
                                color: Colors.text

                                font.family:
                                    LockScreenTheme.bodyFontFamily

                                font.pixelSize:
                                    LockScreenTheme.dateFontSize + 6
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: LockScreenTheme.headerSpacing

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
                                        LockScreenTheme.timeFontFamily

                                    font.pixelSize:
                                        LockScreenTheme.timeFontSize

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

                                    color: Colors.text

                                    font.family:
                                        LockScreenTheme.bodyFontFamily

                                    font.pixelSize:
                                        LockScreenTheme.dateFontSize
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: LockScreenTheme.inputHeight

                            Rectangle {
                                id: inputFrame

                                property color frameBorderColor:
                                    Services.LockService.failedAttempt
                                        ? LockScreenTheme.error
                                        : Colors.accentPrimary

                                anchors.fill: parent

                                radius: LockScreenTheme.inputRadius
                                color: Colors.text

                                border.width:
                                    LockScreenTheme.inputBorderWidth

                                border.color: frameBorderColor

                                Behavior on frameBorderColor {
                                    ColorAnimation {
                                        duration: Animations.duration_normal
                                        easing.type:
                                            Animations.easingStandard
                                    }
                                }

                                TextInput {
                                    id: passwordInput

                                    anchors.fill: parent

                                    anchors.leftMargin:
                                        LockScreenTheme.inputPadding

                                    anchors.rightMargin:
                                        LockScreenTheme.inputPadding

                                    verticalAlignment:
                                        TextInput.AlignVCenter

                                    color: Colors.background

                                    font.family:
                                        LockScreenTheme.bodyFontFamily

                                    font.pixelSize:
                                        LockScreenTheme.inputFontSize

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
                                        LockScreenTheme.inputPadding

                                    anchors.rightMargin:
                                        LockScreenTheme.inputPadding

                                    verticalAlignment:
                                        Text.AlignVCenter

                                    text:
                                        passwordInput.text.length === 0
                                            ? "Input Password..."
                                            : ""

                                    color: LockScreenTheme.placeholder

                                    font.family:
                                        LockScreenTheme.bodyFontFamily

                                    font.pixelSize:
                                        LockScreenTheme.inputFontSize

                                    font.italic: true
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            height: LockScreenTheme.statusHeight

                            text:
                                Services.LockService.authenticating
                                    ? "Checking password..."
                                    : Services.LockService.statusText

                            visible: text.length > 0

                            horizontalAlignment:
                                Text.AlignHCenter

                            color:
                                Services.LockService.failedAttempt
                                    ? LockScreenTheme.error
                                    : Colors.text

                            font.family:
                                LockScreenTheme.bodyFontFamily

                            font.pixelSize:
                                LockScreenTheme.statusFontSize
                        }

                        Row {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            spacing: 16

                            Repeater {
                                model: Services.PowerService.actions.filter(
                                    a => a.action !== "lock"
                                )

                                SquareButton {
                                    id: button
                                    required property var modelData

                                    iconName: modelData.iconName
                                    text: modelData.action

                                    size: 100
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
