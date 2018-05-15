#include "croptool.h"
#include <QImage>


/****************** CropTool *****************************/

CropTool::CropTool(QObject *parent) : QObject(parent) {
    CropWorker* worker = new CropWorker;
    worker->moveToThread(&_workerThread);

    connect(&_workerThread, &QThread::finished, worker, &QObject::deleteLater);
    connect(this, &CropTool::workerRun, worker, &CropWorker::Crop);
    connect(worker, &CropWorker::progressChanged, this, &CropTool::progressChanged);
    connect(worker, &CropWorker::done, this, &CropTool::done);
    _workerThread.start();
}

CropTool::~CropTool() {
    _workerThread.quit();
    _workerThread.wait();
}


void CropTool::Crop(const QString &imgDir, const QString &annDir, const QString &outDir, const QString &pattern) {
    emit workerRun(imgDir, annDir, outDir, pattern);
}


/****************** CropWorker *****************************/

void CropWorker::Crop(const QString& imgDir, const QString& annDir, const QString& outDir, const QString& pattern) {
    ImagesLoader _loader;

    _loader.LoadImagesVoc(imgDir, annDir);
    _loader.ToStart();
    QDir outputDirectory(outDir);

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

        if(i % 10)
            emit progressChanged((i+1.0) / _loader.Count());
    }

    emit done();
}
