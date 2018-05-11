#include "imageloader.h"
#include <QDebug>
#include <QDir>
#include <QUrl>
#include <QFileInfo>


template <class T>
static T bounded(T val, T min_val, T max_val) {
    return std::max(std::min(val, max_val), min_val);
}


void ImagesLoader::loadImages(const QUrl &imagesDir, const QUrl &annotationsDir) {
    QDir imagesDir_(imagesDir.toLocalFile());
    QDir annotationsDir_(annotationsDir.toLocalFile());

    QStringList images = imagesDir_.entryList(QStringList{"*.jpg", "*.png"});
    QStringList annotations = annotationsDir_.entryList(QStringList{"*.xml"});

    _images.clear();
    for(auto img_name : images) {
        QUrl img_path = imagesDir_.absoluteFilePath(img_name);

        QFileInfo img_fileinfo(img_path.toString());
        QUrl xml_path = annotationsDir_.absoluteFilePath(img_fileinfo.baseName() + ".xml");

        _images.push_back({img_path, xml_path});
    }

    _idx = 0;
}


void ImagesLoader::nextImage(int step) {
    if(_images.size() == 0)
        return;

    QVariantList list;

    QVariantMap map;
    map["x"] = 10;
    map["y"] = 20;
    map["width"] = 100;
    map["height"] = 30;
    map["label"] = "lolka";

    list.push_back(map);

    _idx = bounded<int>(_idx + step, 0, _images.size()-1);

    QUrl qmlImageUrl = (QString("file:") + _images[_idx].first.toString());
    qDebug() << qmlImageUrl;
    emit nextImageLoaded(qmlImageUrl, list);
}


void ImagesLoader::saveImage(const QVariant &rects) {
    QVariantList _rects = rects.toList();

    for(auto _rect : _rects) {
        QVariantMap rect = _rect.toMap();
        qDebug() << rect["x"] << ", " << rect["y"] << ", " << rect["width"] << ", " << rect["height"] << " : " << rect["label"];
    }
}
