import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Page {
    id: root

    signal openEditor()
    signal startPerformance()

    header: ToolBar {
        RowLayout {
            anchors.fill: parent

            Label {
                text: "Folder"
                font.bold: true

                Layout.fillWidth: true
            }

            Button {
                text: "Open"
                onClicked: openSetlistDialog.open()
            }

            Button {
                text: "Save"
                onClicked: saveSetlistDialog.open()
            }

            Button {
                text: "Edit"
                onClicked: root.openEditor()
            }

            Button {
                text: "Perform"
                enabled: setlistModel.count > 0
                onClicked: root.startPerformance()
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent

        spacing: 16

        Label {
            text: "Add PDF or image files"
            font.pixelSize: 24

            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: "Add files..."

            Layout.alignment: Qt.AlignHCenter

            onClicked: fileDialog.open()
        }

        Label {
            text: "Files are appended to the setlist."

            opacity: 0.6

            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: setlistModel.count
                  + " pages in setlist"

            opacity: 0.6

            Layout.alignment: Qt.AlignHCenter
        }
    }

    FileDialog {
        id: fileDialog
        title: "Add files to setlist"
        fileMode: FileDialog.OpenFiles

        nameFilters: [
            "PDF and images (*.pdf *.png *.jpg *.jpeg *.webp *.bmp *.gif)",
            "PDF (*.pdf)",
            "Images (*.png *.jpg *.jpeg *.webp *.bmp *.gif)"
        ]

        onAccepted: {
            for (const url of selectedFiles) {
                setlistModel.addFile(url)
            }
        }
    }

    FileDialog {
        id: openSetlistDialog
        title: "Open setlist"
        fileMode: FileDialog.OpenFile

        nameFilters: [
            "Setlist files (*.json)"
        ]

        onAccepted: {
            if (!setlistModel.load(selectedFile)) {
                console.log("Failed to load setlist:", selectedFile)
            }
        }
    }

    FileDialog {
        id: saveSetlistDialog
        title: "Save setlist"
        fileMode: FileDialog.SaveFile

        nameFilters: [
            "Setlist files (*.json)"
        ]

        defaultSuffix: "json"

        onAccepted: {
            if (!setlistModel.save(selectedFile)) {
                console.log("Failed to save setlist:", selectedFile)
            }
        }
    }
}
