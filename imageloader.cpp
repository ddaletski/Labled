#include "imageloader.h"
#include <QDebug>
#include <QDir>
#include <QUrl>
#include <QFileInfo>
#include <QtXml>
#include <QImage>


template <class T>
static T bounded(T val, T min_val, T max_val) {
    return std::max(std::min(val, max_val), min_val);
}


ImagesLoader::ImagesLoader(QObject *parent) : QObject(parent) {  }

void ImagesLoader::ToStart() {
    _idx = 0;
}

void ImagesLoader::ToEnd() {
    _idx = _images.size() - 1;
}

void ImagesLoader::LoadImages(const QUrl &imagesDir, const QUrl &annotationsDir) {
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
    emit imagesLoaded();
}

QPair<QUrl, QVariantList> ImagesLoader::NextImage(int step) {
    if(_images.size() == 0)
        return {QUrl(), QVariantList()};

    _idx = bounded<int>(_idx + step, 0, _images.size()-1);

    QUrl qmlImageUrl = (QString("file:") + _images[_idx].first.toString());

    QVariantList list = LoadAnnotations();
    emit nextImageLoaded(qmlImageUrl, list);

    return {qmlImageUrl, list};
}


void ImagesLoader::SaveImage(const QVariant &rects) {
    QVariantList rects_ = rects.toList();
    DumpAnnotations(rects_);
}


QVariantList ImagesLoader::LoadAnnotations() {
    QVariantList result;
    QDomDocument doc;

    QFile xmlFile(_images[_idx].second.toString());
    if(!xmlFile.open(QIODevice::ReadOnly)) {
        return QVariantList();
    }
    doc.setContent(&xmlFile);

    QDomNodeList objects = doc.elementsByTagName("object");

    for(int i = 0; i < objects.size(); ++i) {
        QDomElement object = objects.at(i).toElement();

        QString label = object.elementsByTagName("name").at(0).toElement().text();

        QDomNode bbox = object.elementsByTagName("bndbox").at(0);
        QDomNodeList boxChilds = bbox.childNodes();

        int xmin=0, ymin=0, xmax=0, ymax=0;
        for(int i = 0; i < boxChilds.size(); ++i) {
            QDomElement coord = boxChilds.at(i).toElement();
            int val = coord.text().toInt();

            if(coord.tagName() == "xmin")
                xmin = val;
            else if(coord.tagName() == "xmax")
                xmax = val;
            else if(coord.tagName() == "ymin")
                ymin = val;
            else if(coord.tagName() == "ymax")
                ymax = val;
        }


        QVariantMap map;
        map["x"] = xmin;
        map["y"] = ymin;
        map["width"] = xmax-xmin;
        map["height"] = ymax-ymin;
        map["label"] = label;
        result.push_back(map);
    }

    return result;
}


static QDomElement tag(QDomDocument& doc, const QString& tagName) {
    QDomElement tag = doc.createElement(tagName);
    return tag;
}


static QDomElement textTag(QDomDocument& doc, const QString& tagName, const QString& text) {
    QDomElement tag = doc.createElement(tagName);

    QDomText textValue = doc.createTextNode(text);
    tag.appendChild(textValue);

    return tag;
}


void ImagesLoader::DumpAnnotations(const QVariantList &json) {
    QUrl currentImage = _images[_idx].first;
    QImage img = QImage(currentImage.toString());

    QFileInfo xml_file = QFileInfo(_images[_idx].second.toString());
    QString dir = QFileInfo(xml_file.path()).fileName();

    QDomDocument doc;
    QDomElement annotation = doc.createElement("annotation");

    annotation.appendChild(textTag(doc, "folder", dir));
    annotation.appendChild(textTag(doc, "path", xml_file.absoluteFilePath()));
    annotation.appendChild(textTag(doc, "filename", xml_file.fileName()));

    QDomElement source = tag(doc, "source");
    source.appendChild(textTag(doc, "database", "unknown"));

    QDomElement size = tag(doc, "size");
    size.appendChild(textTag(doc, "width", QString::number(img.width())));
    size.appendChild(textTag(doc, "height", QString::number(img.height())));
    size.appendChild(textTag(doc, "depth", "3"));
    annotation.appendChild(size);

    annotation.appendChild(textTag(doc, "segmented", "0"));

    for(QVariant _rect : json) {
        QVariantMap rect = _rect.toMap();

        QString label = rect["label"].toString();
        QString xmin = QString::number(rect["x"].toInt());
        QString ymin = QString::number(rect["y"].toInt());
        QString xmax = QString::number(rect["x"].toInt() + rect["width"].toInt());
        QString ymax = QString::number(rect["y"].toInt() + rect["height"].toInt());

        QDomElement object = tag(doc, "object");
        object.appendChild(textTag(doc, "name", label));
        object.appendChild(textTag(doc, "pose", "unspecified"));
        object.appendChild(textTag(doc, "truncated", "0"));
        object.appendChild(textTag(doc, "difficult", "0"));

        QDomElement bndbox = tag(doc, "bndbox");
        bndbox.appendChild(textTag(doc, "xmin", xmin));
        bndbox.appendChild(textTag(doc, "ymin", ymin));
        bndbox.appendChild(textTag(doc, "xmax", xmax));
        bndbox.appendChild(textTag(doc, "ymax", ymax));

        object.appendChild(bndbox);

        annotation.appendChild(object);
    }

    doc.appendChild(annotation);

    QFile xmlFile(xml_file.absoluteFilePath());
    if(!xmlFile.open(QIODevice::WriteOnly)) {
        return;
    }

    QByteArray bytearr = doc.toByteArray();
    xmlFile.write(bytearr, bytearr.size());
}
