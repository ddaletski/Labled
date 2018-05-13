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
            QPair<QUrl, QVariantList> pair = _loader.NextImage(1);

            if(!pair.second.size())
                continue;

            QImage img(pair.first.toLocalFile());

            for(QVariant object : pair.second) {
                QVariantMap obj = object.toMap();
                QImage cropped = img.copy(obj["x"].toInt(), obj["y"].toInt(), obj["width"].toInt(), obj["height"].toInt());

                QStringList filenameSplitted = pair.first.fileName().split('.');
                QString fileName = filenameSplitted.at(0);
                QString fileExtension = filenameSplitted.at(1);

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
