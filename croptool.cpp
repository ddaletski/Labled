#include "croptool.h"
#include <QImage>


CropTool::CropTool(QObject *parent) : QObject(parent) { }


void CropTool::Crop(const QUrl &imgDir, const QUrl &annDir, const QUrl &outDir, const QString &pattern) {
    _loader.LoadImages(imgDir, annDir);
    _loader.ToStart();
    QDir outputDirectory(outDir.toLocalFile());

    QMap<QString, int> namesMap;

    for(int i = 0; !_loader.IsEnd(); ++i) {
        try {
            QVariantMap map = _loader.NextImage(1);
            if(map.empty())
                continue;

            QVariantList boxes = map["boxes"].toList();
            QString imgPath = map["imgPath"].toString();

            if(!boxes.size())
                continue;

            QFileInfo imgFile(imgPath);
            QImage img(imgPath);

            for(QVariant object : boxes) {
                QVariantMap obj = object.toMap();

                int x =      obj["x"].toFloat() * img.width();
                int y =      obj["y"].toFloat() * img.height();
                int width =  obj["width"].toFloat() * img.width();
                int height = obj["height"].toFloat() * img.height();

                QImage cropped = img.copy(x, y, width, height);

                QString fileName = imgFile.completeBaseName();
                QString fileExtension = imgFile.suffix();

                QString outname = QString(pattern)
                        .replace(QString("{name}"), fileName)
                        .replace(QString("{label}"), obj["label"].toString())
                        .replace(QString("{ext}"), fileExtension);

                if(namesMap.find(outname) == namesMap.end()) {
                    namesMap[outname] = 0;
                }
                int index = namesMap[outname]++;

                outname = outname.replace(QString("{index}"), QString::number(index));
                QString outpath = outputDirectory.absoluteFilePath(outname);

                cropped.save(outpath);
            }

        } catch (...) {
        }

        if(i % 100 == 0)
            emit progressChanged((i+1.0) / _loader.Count());
    }

    emit progressChanged(1);
}
