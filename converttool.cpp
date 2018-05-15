#include "converttool.hpp"
#include <QtCore>

/************************* ConvertTool ***********************************/

ConvertTool::ConvertTool(QObject *parent) : QObject(parent) {
    ConvertWorker* worker = new ConvertWorker;
    worker->moveToThread(&_workerThread);

    connect(&_workerThread, &QThread::finished, worker, &QObject::deleteLater);
    connect(this, &ConvertTool::convertDarknetToVoc, worker, &ConvertWorker::convertDarknetToVoc);
    connect(worker, &ConvertWorker::progressChanged, this, &ConvertTool::progressChanged);
    connect(worker, &ConvertWorker::convertedDarknetToVoc, this, &ConvertTool::convertedDarknetToVoc);

    _workerThread.start();
}

ConvertTool::~ConvertTool() {
    _workerThread.quit();
    _workerThread.wait();
}


void ConvertTool::darknetToVoc(const QString& inputDir, const QString& outputDir,
                               const QString& imgDir, const QString& labelsListPath)
{
    emit convertDarknetToVoc(inputDir, outputDir, imgDir, labelsListPath);
}


/************************* ConvertWorker ***********************************/
void ConvertWorker::convertDarknetToVoc(const QString& inputDir, const QString& outputDir, const QString& imgDir, const QString& labelListPath) {
    ImagesLoader _loader;
    _loader.LoadImagesDarknet(imgDir, inputDir, labelListPath);

    QDir output_dir(outputDir);

    for(int i = 0; !_loader.IsEnd(); ++i) {
        QVariantMap inner = _loader.NextImage(1);
        QByteArray voc = ImagesLoader::InnerToVoc(inner);

        QFileInfo lblFileInfo(inner["lblPath"].toString());

        QString outLblName = lblFileInfo.completeBaseName() + QString(".xml");
        QString outLblPath = output_dir.absoluteFilePath(outLblName);

        QFile outFile(outLblPath);
        if(!outFile.open(QFile::WriteOnly))
                continue;

        outFile.write(voc);
        if(i % 10 == 0)
            emit progressChanged((1.0 + i) / _loader.Count());
    }

    emit convertedDarknetToVoc();
}
