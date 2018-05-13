#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QtCore>
#include <QQmlContext>


#include "imageloader.h"
#include "croptool.h"


int main(int argc, char *argv[])
{
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    CropTool cropTool;

    engine.rootContext()->setContextProperty("cropToolBackend", &cropTool);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    QObject* rootObject = engine.rootObjects()[0];
    if(!rootObject) {
        throw "Qml not loaded";
    }

    ImagesLoader loader;
    {
        QObject::connect(rootObject, SIGNAL(sigLoadImages(QUrl, QUrl)), &loader, SLOT(LoadImages(QUrl, QUrl)));
        QObject::connect(&loader, SIGNAL(imagesLoaded()), rootObject, SLOT(imagesLoaded()));

        QObject::connect(rootObject, SIGNAL(sigNextImage(int)), &loader, SLOT(NextImage(int)));
        QObject::connect(&loader, SIGNAL(nextImageLoaded(QVariant, QVariant)), rootObject, SLOT(nextImageLoaded(QVariant, QVariant)));

        QObject::connect(rootObject, SIGNAL(sigSaveImage(QVariant)),&loader, SLOT(SaveImage(QVariant)));
    }


    QObject* cropToolObject = rootObject->findChild<QObject*>("cropTool");
    if(!cropToolObject) {
        throw "Crop tool qml not loaded";
    }

    //CropTool cropTool;

    return app.exec();
}
