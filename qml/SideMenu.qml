import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

ColumnLayout {
    id: root

    property alias defaultLabel: labelsMenu.defaultLabel
    property alias darkBoxes: configMenu.darkBoxes
    property alias showLabels: configMenu.showLabels
    property alias labelsSize: configMenu.labelsSize
    property alias enableLabelsShortcuts: configMenu.enableLabelsShortcuts
    property var labelsList: []

    signal unsavedChanges()
    signal updateLabels()


    LabelsMenu {
        id: labelsMenu
        //                        Layout.preferredHeight: bounded(0.2 * model.length, 1, 2)
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop

        model: root.labelsList

        onSigChangeColor: {
            root.labelsList[labelIndex].color = newColor
            root.updateLabels()
        }

        onSigDeleteLabel: {
            console.log("L: ", labelIndex)

            imageArea.rects = imageArea.rects.filter(function (r) {
                return r.label != labelIndex
            })

            for(var i in imageArea.rects) {
                if (imageArea.rects[i].label > labelIndex) {
                    --(imageArea.rects[i].label)
                }
            }

            imageArea.updateRects()
            root.labelsList.splice(labelIndex, 1)
            root.updateLabels()

            root.unsavedChanges()
        }
    }

    HorizontalLine {
        Layout.fillHeight: true
        lineHeight: 1
    }

    ConfigurationMenu {
        id: configMenu
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
    }

} // ColumnLayout
