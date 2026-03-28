// Quickshell configuration
//
// This is a placeholder config for Quickshell (DMS bar backend).
// Quickshell provides the bar UI for Dank Material Shell.
//
// TODO: Customize for your setup

import Quickshell
import QtQuick

QuickshellScreen {
    id: screen

    // Bar position (bottom of screen)
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right

    // Bar height
    implicitHeight: 32

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#282a36"  // Dracula background
    }

    // Placeholder content
    Text {
        anchors.centerIn: parent
        text: "Niri + DMS Bar (placeholder)"
        color: "#f8f8f2"
        font.family: "JetBrains Mono"
        font.pixelSize: 12
    }
}
