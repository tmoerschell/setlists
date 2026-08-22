import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root

    signal openFolder()
    signal startPerformance()

    property int selectedIndex: -1

    header: ToolBar {
        RowLayout {
            anchors.fill: parent

            Button {
                text: "Folder"

                onClicked: root.openFolder()
            }

            Label {
                text: "Setlist"
                font.bold: true

                Layout.fillWidth: true
            }

            Button {
                text: "Add black frame"

                onClicked: setlistModel.addBlack()
            }

            Button {
                text: "Clear"

                enabled: setlistModel.count > 0

                onClicked: {
                    setlistModel.clear()
                    root.selectedIndex = -1
                }
            }

            Button {
                text: "Perform"

                enabled: setlistModel.count > 0

                onClicked: root.startPerformance()
            }
        }
    }

    ListView {
        id: listView

        anchors.fill: parent
        anchors.margins: 16

        model: setlistModel

        spacing: 4

        clip: true

        delegate: Rectangle {
            required property int index
            required property int itemType
            required property string displayName

            width: listView.width
            height: 56

            radius: 4

            color: index === root.selectedIndex
                   ? "#404040"
                   : "#202020"

            border.color: "#505050"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8

                Label {
                    text: (index + 1) + "."
                    color: "white"

                    horizontalAlignment:
                        Text.AlignRight

                    Layout.preferredWidth: 40
                }

                Label {
                    text: itemType === 2
                          ? "BLACK FRAME"
                          : displayName

                    color: "white"

                    Layout.fillWidth: true

                    elide: Text.ElideRight
                }

                Button {
                    text: "↑"

                    enabled: index > 0

                    onClicked: {
                        setlistModel.move(index, index - 1)
                    }
                }

                Button {
                    text: "↓"

                    enabled: index < setlistModel.count - 1

                    onClicked: {
                        setlistModel.move(index, index + 1)
                    }
                }

                Button {
                    text: "×"

                    onClicked: {
                        setlistModel.remove(index)

                        if (root.selectedIndex === index)
                            root.selectedIndex = -1
                    }
                }
            }

            TapHandler {
                onTapped: {
                    root.selectedIndex = index
                }
            }
        }
    }

    Label {
        anchors.centerIn: parent

        visible: setlistModel.count === 0

        text: "Setlist is empty"

        opacity: 0.5
    }
}
