import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4


Window {
    id: root
    visible: false
    property alias content: loader.sourceComponent

    readonly property int _width: loader.width + 10
    readonly property int _height: loader.height + 6
    width: _width
    height: _height
    maximumWidth: _width
    maximumHeight:_height
    minimumWidth: _width
    minimumHeight: _height

    modality: Qt.WindowModal
    flags: Qt.Dialog

    signal accepted()
    signal rejected()

    function open() {
        visible = true
    }

    function close() {
        visible = false
    }

    function accept() {
        accepted()
        close()
    }

    function reject() {
        rejected()
        close()
    }

    Loader {
        id: loader
        anchors.centerIn: parent
        focus: true
        Keys.onReturnPressed: accept()
        Keys.onEnterPressed: accept()
        Keys.onEscapePressed: reject()
    }
}
