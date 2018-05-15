#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QtCore>
#include <QQmlContext>


#include "imageloader.h"
#include "croptool.h"
#include "converttool.hpp"


int main(int argc, char *argv[])
{
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    CropTool cropTool;
    ConvertTool convertTool;

//    convertTool.darknetToVoc("C:\\Users\\denis.daletski\\Dropbox\\detection\\0", "C:\\Users\\denis.daletski\\Desktop\\out", "C:\\Users\\denis.daletski\\Dropbox\\detection\\0", "C:\\Users\\denis.daletski\\Desktop\\labels.txt");
//    return app.exec();

    engine.rootContext()->setContextProperty("cropToolBackend", &cropTool);
    engine.rootContext()->setContextProperty("convertToolBackend", &convertTool);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    QObject* rootObject = engine.rootObjects()[0];
    if(!rootObject) {
        throw "Qml not loaded";
    }

    ImagesLoader loader;
    {
        QObject::connect(rootObject, SIGNAL(sigLoadImages(QString, QString)), &loader, SLOT(LoadImagesVoc(QString, QString)));
        QObject::connect(&loader, SIGNAL(imagesLoaded()), rootObject, SLOT(imagesLoaded()));

        QObject::connect(rootObject, SIGNAL(sigNextImage(int)), &loader, SLOT(NextImage(int)));
        QObject::connect(&loader, SIGNAL(nextImageLoaded(QVariant)), rootObject, SLOT(nextImageLoaded(QVariant)));

        QObject::connect(rootObject, SIGNAL(sigSaveImage(QVariant)),&loader, SLOT(SaveImage(QVariant)));
    }


    QObject* cropToolObject = rootObject->findChild<QObject*>("cropTool");
    if(!cropToolObject) {
        throw "Crop tool qml not loaded";
    }

    return app.exec();
}
