#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QtCore>
#include <QQmlContext>


#include "backend.h"
#include "croptool.h"
#include "converttool.hpp"


int main(int argc, char *argv[])
{
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    CropTool cropTool;
    ConvertTool convertTool;
    Backend backend;

    engine.rootContext()->setContextProperty("CropToolBackend", &cropTool);
    engine.rootContext()->setContextProperty("ConvertToolBackend", &convertTool);
    engine.rootContext()->setContextProperty("Backend", &backend);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    QObject* rootObject = engine.rootObjects()[0];
    if(!rootObject) {
        throw "Qml not loaded";
    }

    return app.exec();
}
