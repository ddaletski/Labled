import QtQuick 2.5
import QtQuick.Dialogs 1.2


FileDialog {
    title: "Please choose a file"
    folder: shortcuts.home
    selectFolder: true
    selectMultiple: false
}
