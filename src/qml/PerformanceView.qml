import QtQuick
import QtQuick.Controls
import QtQuick.Pdf

Item {
    id: root

    signal exitPerformance()

    property int currentIndex: 0

    property int currentItemType: -1
    property url currentSource: ""
    property int currentPage: -1

    focus: true

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    /*
     * PDF document.
     *
     * This is sufficient for the first prototype.
     * Later we can replace this with a document cache
     * so that switching between pages does not repeatedly
     * load PDF files.
     */
    PdfDocument {
        id: pdfDocument
        source: ""

        onStatusChanged: {
            if (status === PdfDocument.Ready && root.currentItemType === 0) {
                root.showCurrentPdfPage()
            }
        }
    }

    PdfPageView {
        id: pdfView

        anchors.centerIn: parent

        visible: root.currentItemType === 0

        document: pdfDocument

        zoomEnabled: false
    }

    Image {
        id: imageView

        anchors.fill: parent

        visible: root.currentItemType === 1

        source: root.currentItemType === 1
                ? root.currentSource
                : ""

        fillMode: Image.PreserveAspectFit

        asynchronous: true
        cache: true
    }

    /*
     * Black frames don't need an actual image.
     * The background Rectangle already provides them.
     */
    function loadCurrent() {
        if (setlistModel.count === 0)
            return

        if (currentIndex < 0)
            currentIndex = 0

        if (currentIndex >= setlistModel.count)
            currentIndex =
                setlistModel.count - 1

        const item = setlistModel.itemAt(currentIndex)

        currentItemType = item.type
        currentSource = item.source
        currentPage = item.page

        if (currentItemType === 0) {
            if (pdfDocument.source !== currentSource) {
                // New PDF: load it, page will be set afterwards
                pdfView.goToPage(currentPage)
                pdfDocument.source = currentSource
            } else {
                // Same PDF: go to page
                showCurrentPdfPage()
            }
        }
    }

    function showCurrentPdfPage() {
        Qt.callLater(function() {
            pdfView.goToPage(currentPage)
            fitPdfPage()
        })
    }

    function fitPdfPage() {
        if (!pdfDocument || pdfDocument.status !== PdfDocument.Ready)
            return

        var size = pdfDocument.pagePointSize(currentPage)

        if (size.width <= 0 || size.height <= 0)
            return

        var pageRatio = size.width / size.height
        var areaRatio = width / height

        if (pageRatio > areaRatio) {
            pdfView.width = width
            pdfView.height = width / pageRatio
        } else {
            pdfView.height = height
            pdfView.width = height * pageRatio
        }

        pdfView.scaleToPage(pdfView.width, pdfView.height)
    }

    function next() {
        if (currentIndex >= setlistModel.count - 1)
            return

        currentIndex++

        loadCurrent()
    }

    function previous() {
        if (currentIndex <= 0)
            return

        currentIndex--

        loadCurrent()
    }

    Component.onCompleted: {
        loadCurrent()
        forceActiveFocus()
    }

    /*
     * If the performance view becomes visible again after
     * leaving it, make sure keyboard focus is restored.
     */
    onVisibleChanged: {
        if (visible) {
            forceActiveFocus()
            loadCurrent()
        }
    }

    /*
     * Tap the left half for previous, right half for next.
     */
    TapHandler {
        onTapped: function(point) {
            if (point.position.x < root.width / 2) {
                root.previous()
            } else {
                root.next()
            }
        }
    }

    /*
     * Horizontal swipe.
     */
    DragHandler {
        id: swipeHandler

        target: null

        property real startX: 0

        onActiveChanged: {
            if (active) {
                startX = centroid.position.x
                return
            }

            const deltaX =
                centroid.position.x - startX

            if (Math.abs(deltaX) < 80)
                return

            if (deltaX < 0)
                root.next()
            else
                root.previous()
        }
    }

    // Hide the controls after 2 seconds of inactivity.
    property bool controlsVisible: true

    Timer {
        id: hideTimer

        interval: 2000
        repeat: false

        onTriggered: {
            root.controlsVisible = false
        }
    }

    function showControls() {
        root.controlsVisible = true
        hideTimer.restart()
    }

    // Any mouse movement/activity wakes the controls up
    Item {
        anchors.fill: parent
        
        HoverHandler {
            onPointChanged: root.showControls()
        }

        TapHandler {
            onTapped: root.showControls()
        }
    }

    // Keyboard activity also wakes them up.
    Keys.onPressed: function(event) {
        root.showControls()

        switch (event.key) {
        case Qt.Key_Right:
        case Qt.Key_Down:
        case Qt.Key_Space:
            root.next()
            event.accepted = true
            break

        case Qt.Key_Left:
        case Qt.Key_Up:
            root.previous()
            event.accepted = true
            break

        case Qt.Key_Escape:
            root.exitPerformance()
            event.accepted = true
            break
        }
    }

    // Back button
    ToolButton {
        id: backButton

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 12

        icon.name: "go-previous"

        opacity: root.controlsVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        onClicked: root.exitPerformance()
    }

    // Fullscreen button
    ToolButton {
        id: fullscreenButton

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12

        icon.name: ApplicationWindow.window.visibility === Window.FullScreen
                    ? "view-restore"
                    : "view-fullscreen"

        opacity: root.controlsVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        onClicked: {
            if (ApplicationWindow.window.visibility === Window.FullScreen)
                ApplicationWindow.window.showNormal()
            else
                ApplicationWindow.window.showFullScreen()

            root.showControls()
        }
    }

    // Page counter
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        anchors.bottomMargin: 20

        width: 120
        height: 40

        radius: 20

        color: "#99000000"

        Label {
            anchors.centerIn: parent
            color: "white"
            text: (root.currentIndex + 1) + " / " + setlistModel.count
        }

        opacity: root.controlsVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }
}
