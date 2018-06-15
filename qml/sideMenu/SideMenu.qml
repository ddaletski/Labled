import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import "../common"

ColumnLayout {
    id: root

    property alias defaultLabel: labelsMenu.defaultLabel
    property alias boxesFillMode: configMenu.boxesFillMode
    property alias showLabels: configMenu.showLabels
    property alias labelsSize: configMenu.labelsSize
    property alias enableLabelsShortcuts: configMenu.enableLabelsShortcuts
    property alias validationMode: configMenu.validationMode
    property alias autoClassify: configMenu.autoClassify
    property var labelsList: []

    signal unsavedChanges()
    signal updateLabels()
    signal renameLabel(int labelIndex, string newName, bool all)


    function deleteLabel(labelIndex) {
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


    LabelEditDialog {
        id: labelEditDialog

        onAccepted: {
            renameLabel(label, text, applyToAll)
            label = -1
        }

        onRejected: {
            label = -1
        }
    }

    LabelsMenu {
        id: labelsMenu
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop

        model: root.labelsList

        onSigChangeColor: {
            root.labelsList[labelIndex].color = newColor
            root.updateLabels()
        }

        onSigEditLabel: {
            labelEditDialog.text = root.labelsList[labelIndex].name
            labelEditDialog.label = labelIndex
            labelEditDialog.open()
        }

        onSigDeleteLabel: {
            deleteLabel(labelIndex)
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
