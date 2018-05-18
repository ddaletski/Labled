import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import "../common"


ColumnLayout {
    id: root
    property var model
    property int defaultLabel: -1
    signal sigChangeColor(int labelIndex, color newColor)
    signal sigDeleteLabel(int labelIndex)
    signal sigEditLabel(int labelIndex)

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


    Label {
        id: defaultLabelTitle
        text: qsTr("Default label: ") + (defaultLabel >= 0 ? model[defaultLabel].name : "")
        Layout.preferredWidth: root.width
        clip: true
    }

    RowLayout {
        z: labelsList.z + 1
        Layout.preferredWidth: root.width

        Label {
            id: filterTitle
            text: qsTr("Filter: ")
        }

        TextField {
            id: filterInput
            placeholderText: "filter regexp"
            selectByMouse: true
        }
    }

    ListView {
        id: labelsList

        Layout.fillHeight: true
        model: proxyModel(root.model, filterInput.text)

        orientation: ListView.Vertical
        spacing: 10

        delegate: Rectangle {
            width: root.width
            height: row.height

            border.color: root.model[modelData].color
            border.width: 2

            RowLayout {
                id: row
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 5
                    rightMargin: 2
                }
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter

                Item {
                    id: makeDefault
                    height: txt.height
                    width: height

                    Rectangle {
                        id: makeDefaultRect
                        anchors.centerIn: parent
                        height: txt.height
                        width: height
                        radius: height / 2
                        color: root.defaultLabel == modelData ? "gray" : "white"
                        border.color: "gray"
                        border.width: 2
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

                Text {
                    id: txt
                    clip: true
                    text: root.model[modelData].name
                    Layout.fillWidth: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.sigEditLabel(modelData)
                        }
                    }
                }


                Image {
                    id: changeColor
                    height: 10
//                    height: 0.75 * txt.height
                    width: height

                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    source: "/img/color_palette.svg"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            colorDialog.label = modelData
                            colorDialog.color = root.model[modelData].color
                            colorDialog.open()
                        }

                    }
                }

                Image {
                    id: deleteLabel
                    height: txt.height
                    width: height

                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    source: "/img/diag_cross.svg"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.sigDeleteLabel(modelData)
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
        //        model = model.sort(function(a, b) {
        //            var name1 = labelsList[a].name
        //            var name2 = labelsList[b].name
        //            if(name1 < name2)
        //                return -1
        //            else if (name1 > name2)
        //                return 1
        //            else
        //                return 0
        //        })
        return model
    }

    function matches(str, regexp) {
        return str.toString().search(regexp) >= 0
    }
}
