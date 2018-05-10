#include "imageloader.h"
#include <QDebug>

void ImagesLoader::loadImages(const QUrl &imagesDir, const QUrl &annotationsDir) {
    qDebug() << "IN: " << imagesDir << ", AN: " << annotationsDir;
}

void ImagesLoader::nextImage() {
    QVariantList list;

    QVariantMap map;
    map["x"] = 10;
    map["y"] = 20;
    map["width"] = 100;
    map["height"] = 30;
    map["label"] = "lolka";

    list.push_back(map);

    emit nextImageLoaded( QUrl("file:/home/denis/Desktop/1.png"), list);
}

void ImagesLoader::saveImage(const QVariant &rects) {
    QVariantList _rects = rects.toList();

    for(auto _rect : _rects) {
        QVariantMap rect = _rect.toMap();
        qDebug() << rect["x"] << ", " << rect["y"] << ", " << rect["width"] << ", " << rect["height"] << " : " << rect["label"];
    }
}
