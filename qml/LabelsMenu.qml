import QtQuick 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2


Item {
    id: root
    property var model
    property int defaultLabel: -1
    signal sigChangeColor(int labelIndex, color newColor)
    signal sigDeleteLabel(int labelIndex)


    ColorChooseDialog {
        id: colorDialog

        onAccepted: {
            if(label >= 0) {
                sigChangeColor(label, color)
                label = -1
            }
            var s = ""
        }

        onRejected: {
            label = -1
        }
    }


    ColumnLayout {
        anchors.fill: parent

        Label {
            id: defaultLabelTitle
            text: qsTr("Default label: \n") + (defaultLabel >= 0 ? model[defaultLabel].name : "")
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                id: filterTitle
                text: qsTr("Filter: ")
            }

            TextField {
                id: filterInput
                placeholderText: "filter regexp"
                Layout.fillWidth: true
            }
        }

        ListView {
            id: labelsList
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: proxyModel(root.model, filterInput.text)

            orientation: ListView.Vertical
            spacing: 10

            delegate: Rectangle {
                width: root.width
                height: txt.height + 10

                border.color: root.model[modelData].color

                Text {
                    id: txt
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10 + height
                        rightMargin: 10 + height
                    }
                    text: root.model[modelData].name
                }

                Item {
                    id: makeDefault
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: height

                    Rectangle {
                        anchors.centerIn: parent
                        height: 10
                        width: height
                        radius: height / 2
                        color: root.defaultLabel == modelData ? root.model[modelData].color : "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(root.defaultLabel == modelData)
                                root.defaultLabel = -1
                            else
                                root.defaultLabel = modelData
                        }
                    }
                }

                Image {
                    id: deleteLabel
                    anchors {
                        right: parent.right
                        rightMargin: 5
                        verticalCenter: parent.verticalCenter
                    }
                    height: txt.height
                    width: height
                    source: "/img/garbage_can.png"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.sigDeleteLabel(index)
                    }
                }

                MouseArea {
                    anchors.fill: txt
                    onClicked: {
                        colorDialog.label = index
                        colorDialog.open()
                    }
                }
            }
        }
    }

    function proxyModel(labelsList, filter) {
        var model = []
        for(var i in labelsList) {
            if(matches(labelsList[i].name, filter))
                model.push(i)
        }
        return model
    }

    function matches(str, regexp) {
        return str.toString().search(regexp) >= 0
    }
}
