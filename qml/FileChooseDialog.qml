import QtQuick 2.5
import QtQuick.Dialogs 1.2


FileDialog {
    title: "Please choose a file"
    folder: shortcuts.home
    selectFolder: true
    selectMultiple: false

    function filePath() {
        return urlToStr(fileUrl)
    }

    function strToUrl(str) {
        return "file:" + str
    }

    function urlToStr(url) {
        var s = "" + url
        s = s.replace(/^file:\/\/(?:\/([A-Z]:))?/, "$1")
        return s
    }
}
