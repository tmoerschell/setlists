import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root

    width: 1200
    height: 800

    visible: true

    title: "Setlists"

    property int currentView: 0

    /*
     * 0 = folder
     * 1 = setlist editor
     * 2 = performance
     */

    StackLayout {
        anchors.fill: parent

        currentIndex: root.currentView

        FolderView {
            onOpenEditor: {
                root.currentView = 1
            }

            onStartPerformance: {
                root.currentView = 2
            }
        }

        SetlistView {
            onOpenFolder: {
                root.currentView = 0
            }

            onStartPerformance: {
                root.currentView = 2
            }
        }

        PerformanceView {
            onExitPerformance: {
                root.currentView = 1
            }
        }
    }
}
