from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot


if __name__ == "__main__":
    def main():
        import sys
    
        # Create an instance of the application
        app = QGuiApplication(sys.argv)
        # Create QML engine
        engine = QQmlApplicationEngine()

        # And register it in the context of QML

    #    engine.rootContext().setContextProperty("calculator", calculator)

        # Load the qml file into the engine
        try:
            engine.load("main.qml")
        except Exception as ex:
            print(ex)
            return
    
        engine.quit.connect(app.quit)
        sys.exit(app.exec_())

    main()