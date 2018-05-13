#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QUrl>


#include "imageloader.h"


int main(int argc, char *argv[])
{
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    QObject* rootObject = engine.rootObjects()[0];


    ImagesLoader loader;
    QObject::connect(rootObject, SIGNAL(sigLoadImages(QUrl, QUrl)), &loader, SLOT(LoadImages(QUrl, QUrl)));
    QObject::connect(&loader, SIGNAL(imagesLoaded()), rootObject, SLOT(imagesLoaded()));

    QObject::connect(rootObject, SIGNAL(sigNextImage(int)), &loader, SLOT(NextImage(int)));
    QObject::connect(&loader, SIGNAL(nextImageLoaded(QVariant, QVariant)), rootObject, SLOT(nextImageLoaded(QVariant, QVariant)));

    QObject::connect(rootObject, SIGNAL(sigSaveImage(QVariant)),&loader, SLOT(SaveImage(QVariant)));

    return app.exec();
}
