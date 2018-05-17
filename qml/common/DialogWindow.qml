import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4


Window {
    id: root
    visible: false
    property alias _width: loader.width
    property alias _height: loader.height
    property alias content: loader.sourceComponent

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
        focus: true
        Keys.onReturnPressed: accept()
        Keys.onEnterPressed: accept()
        Keys.onEscapePressed: reject()
    }
}
