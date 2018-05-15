#include "imageloader.h"
#include <QDebug>
#include <QDir>
#include <QString>
#include <QFileInfo>
#include <QtXml>
#include <QImage>


template <class T>
static T bounded(T val, T min_val, T max_val) {
    return std::max(std::min(val, max_val), min_val);
}


ImagesLoader::ImagesLoader(QObject *parent) : QObject(parent) {
    _format = LabelsFormat::NO_FORMAT;
}

void ImagesLoader::ToStart() {
    _idx = 0;
}

void ImagesLoader::ToEnd() {
    _idx = _images.size() - 1;
}

int ImagesLoader::Index() {
    return _idx;
}

int ImagesLoader::Count() {
    return _images.size();
}

int ImagesLoader::Format() {
    return _format;
}

QVector<QString> ImagesLoader::DarknetLabels() {
    return _darknet_labels;
}

QVector<QPair<QString, QString> > ImagesLoader::GetPaths() {
    return _images;
}

bool ImagesLoader::IsStart() {
    return _idx <= 0;
}

bool ImagesLoader::IsEnd() {
    return _images.size() == 0 || (_idx >= _images.size() - 1);
}

void ImagesLoader::LoadImagesVoc(const QString &imagesDir, const QString &annotationsDir) {
    _format = LabelsFormat::VOC;

    QDir imagesDir_(imagesDir);
    QDir annotationsDir_(annotationsDir);

    QStringList images = imagesDir_.entryList(QStringList{"*.jpg", "*.png"});

    _images.clear();
    for(auto img_name : images) {
        QString img_path = imagesDir_.absoluteFilePath(img_name);

        QFileInfo img_fileinfo(img_path);
        QString xml_path = annotationsDir_.absoluteFilePath(img_fileinfo.completeBaseName() + ".xml");

        _images.push_back({img_path, xml_path});
    }

    _idx = 0;
    emit imagesLoaded();
}


void ImagesLoader::LoadImagesDarknet(const QString& imagesDir, const QString& annotationsDir, const QString& labelsFile) {
    _format = LabelsFormat::DARKNET;

    QFile labels_file(labelsFile);
    if(!labels_file.open(QIODevice::ReadOnly)) {
        return;
    }

    _darknet_labels.clear();
    for(QByteArray line = labels_file.readLine(); line.size(); line = labels_file.readLine()) {
        QString label(line);
        _darknet_labels.push_back(label.trimmed());
    }

    QDir imagesDir_(imagesDir);
    QDir annotationsDir_(annotationsDir);

    QStringList images = imagesDir_.entryList(QStringList{"*.jpg", "*.png"});

    _images.clear();
    for(auto img_name : images) {
        QString img_path = imagesDir_.absoluteFilePath(img_name);

        QFileInfo img_fileinfo(img_path);
        QString label_path = annotationsDir_.absoluteFilePath(img_fileinfo.completeBaseName() + ".txt");

        _images.push_back({img_path, label_path});
    }

    _idx = 0;
    emit imagesLoaded();
}


QVariantMap ImagesLoader::NextImage(int step) {
    if(_images.size() == 0)
        return {};

    _idx = bounded<int>(_idx + step, 0, _images.size()-1);

    QFile annotationFile(_images[_idx].second);
    if(!annotationFile.open(QIODevice::ReadOnly)) {
        return QVariantMap();
    }

    QVariantMap result;
    if(_format == LabelsFormat::VOC)
        result = VocToInner(annotationFile.readAll());
    else if(_format == LabelsFormat::DARKNET)
        result = DarknetToInner(annotationFile.readAll(), _darknet_labels);

    result["imgPath"] = _images[_idx].first;
    result["lblPath"] = _images[_idx].second;

    emit nextImageLoaded(result);
    return result;
}


void ImagesLoader::SaveImage(const QVariant &annotation) {
    QString currentImage = _images[_idx].first;
    QFileInfo annotationFileInfo = QFileInfo(_images[_idx].second);

    QFile annotationFile(annotationFileInfo.absoluteFilePath());
    if(!annotationFile.open(QIODevice::WriteOnly)) {
        return;
    }
    QByteArray result = InnerToVoc(annotation.toMap());

    annotationFile.write(result, result.size());
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


QByteArray ImagesLoader::InnerToVoc(const QVariantMap& inner) {
    QString imgPath = inner["imgPath"].toString();
    QImage img = QImage(imgPath);

    QFileInfo img_file = QFileInfo(imgPath);
    QString dir = img_file.fileName();

    QDomDocument doc;
    QDomElement annotation = doc.createElement("annotation");

    annotation.appendChild(textTag(doc, "folder", dir));
    annotation.appendChild(textTag(doc, "path", img_file.absoluteFilePath()));
    annotation.appendChild(textTag(doc, "filename", img_file.fileName()));

    QDomElement source = tag(doc, "source");
    source.appendChild(textTag(doc, "database", "unknown"));

    QDomElement size = tag(doc, "size");
    size.appendChild(textTag(doc, "width", QString::number(img.width())));
    size.appendChild(textTag(doc, "height", QString::number(img.height())));
    size.appendChild(textTag(doc, "depth", "3"));
    annotation.appendChild(size);

    annotation.appendChild(textTag(doc, "segmented", "0"));

    for(QVariant _rect : inner["boxes"].toList()) {
        QVariantMap rect = _rect.toMap();

        QString label = rect["label"].toString();
        QString xmin = QString::number(int(rect["x"].toDouble() * img.width()));
        QString ymin = QString::number(int(rect["y"].toDouble() * img.height()));
        QString xmax = QString::number(int((rect["x"].toDouble() + rect["width"].toDouble()) * img.width()));
        QString ymax = QString::number(int((rect["y"].toDouble() + rect["height"].toDouble()) * img.height()));

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

    return doc.toByteArray();
}


QVariantMap ImagesLoader::VocToInner(const QByteArray& xml) {
    QVariantMap result;
    QVariantList list;
    QDomDocument doc;

    doc.setContent(xml);

    QDomNodeList objects = doc.elementsByTagName("object");
    QString imgPath = doc.elementsByTagName("path").at(0).toElement().text();

    QDomElement size = doc.elementsByTagName("size").at(0).toElement();
    double imgWidth = size.elementsByTagName("width").at(0).toElement().text().toInt();
    double imgHeight = size.elementsByTagName("height").at(0).toElement().text().toInt();

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
        map["x"] = xmin / imgWidth;
        map["y"] = ymin / imgHeight;
        map["width"] = (xmax-xmin) / imgWidth;
        map["height"] = (ymax-ymin) / imgHeight;
        map["label"] = label;
        list.push_back(map);
    }

    result.insert("boxes", list);
    result.insert("imgPath", imgPath);

    return result;
}


QByteArray ImagesLoader::InnerToDarknet(const QVariantMap& inner, const QVector<QString>& labelsList) {
    QByteArray result;
    QTextStream str(&result);

    for(QVariant _rect : inner["boxes"].toList()) {
        QVariantMap rect = _rect.toMap();

        int label = labelsList.indexOf(rect["label"].toString());
        double xmin = rect["x"].toDouble();
        double ymin = rect["y"].toDouble();
        double width = rect["width"].toDouble();
        double height = rect["height"].toDouble();

        double xcenter = xmin + 0.5 * width;
        double ycenter = ymin + 0.5 * height;

        str << label << " "
                << QString::number(xcenter) << " "
                << QString::number(ycenter) << " "
                << QString::number(width) << " "
                << QString::number(height) << "\n";
    }
    return result;
}


QVariantMap ImagesLoader::DarknetToInner(const QString& darknet, const QVector<QString>& labelsList) {
    QString dn = darknet;
    QTextStream str(&dn);

    QVariantList boxes;

    while(!str.atEnd()) {
        QString line_s = str.readLine();
        QTextStream line(&line_s);

        double x, y, width, height;
        int label;

        line >> label >> x >> y >> width >> height;

        QVariantMap box;
        box["x"] = std::max(x-0.5*width, 0.0);
        box["y"] = std::max(y-0.5*height, 0.0);
        box["width"] = width;
        box["height"] = height;
        box["label"] = labelsList[label];

        boxes.push_back(box);
    }

    QVariantMap result;
    result["boxes"] = boxes;

    return result;
}
