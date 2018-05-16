import QtQuick 2.5
import QtQuick.Window 2.2


Window {
    id: root
    visible: false
    property int _width
    property int _height

    width: _width
    height: _height
    maximumWidth: _width
    maximumHeight:_height
    minimumWidth: _width
    minimumHeight: _height

    modality: Qt.WindowModal

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

    Item {
        focus: true
        anchors.fill: parent
        Keys.onReturnPressed: accept()
        Keys.onEnterPressed: accept()
        Keys.onEscapePressed: reject()
    }
}
