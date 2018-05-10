import QtQuick 2.4

Item {
    id: root
    property alias model: labelsList.model

    signal sigChooseColor(int labelIndex)

    ListView {
        id: labelsList
        anchors.fill: parent
        orientation: ListView.Vertical
        spacing: 10

        delegate: Rectangle {
            width: root.width
            height: txt.height
            border.color: modelData.color
            Text {
                id: txt
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 10
                    rightMargin: 10
                }
                text: modelData.name
            }

            MouseArea {
                anchors.fill: txt
                onClicked: {
                    root.sigChooseColor(index)
                }
            }
        }
    }

}
