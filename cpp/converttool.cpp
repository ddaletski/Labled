#include "converttool.hpp"
#include <QtCore>

/************************* ConvertTool ***********************************/

//////////////////////////////////
/// \brief ConvertTool::ConvertTool
/// \param parent
///
ConvertTool::ConvertTool(QObject *parent) : QObject(parent) {
    ConvertWorker* worker = new ConvertWorker;
    worker->moveToThread(&_workerThread);

    connect(&_workerThread, &QThread::finished, worker, &QObject::deleteLater);
    connect(this, &ConvertTool::convertDarknetToVoc, worker, &ConvertWorker::convertDarknetToVoc);
    connect(this, &ConvertTool::convertVocToDarknet, worker, &ConvertWorker::convertVocToDarknet);
    connect(worker, &ConvertWorker::progressChanged, this, &ConvertTool::progressChanged);
    connect(worker, &ConvertWorker::convertedDarknetToVoc, this, &ConvertTool::convertedDarknetToVoc);
    connect(worker, &ConvertWorker::convertedVocToDarknet, this, &ConvertTool::convertedVocToDarknet);

    _workerThread.start();
}

ConvertTool::~ConvertTool() {
    _workerThread.quit();
    _workerThread.wait();
}


/////////////////////////////////
/// \brief ConvertTool::darknetToVoc
/// \param inputDir
/// \param outputDir
/// \param imgDir
/// \param labelsListPath
///
void ConvertTool::darknetToVoc(const QString& inputDir, const QString& outputDir,
                               const QString& imgDir, const QString& labelsListPath)
{
    emit convertDarknetToVoc(inputDir, outputDir, imgDir, labelsListPath);
}

/////////////////////////////////
/// \brief ConvertTool::vocToDarknet
/// \param inputDir
/// \param outputDir
/// \param labelListPath
///
void ConvertTool::vocToDarknet(const QString &inputDir, const QString &outputDir, const QString &labelListPath)
{
    emit convertVocToDarknet(inputDir, outputDir, labelListPath);
}


/************************* ConvertWorker ***********************************/

void ConvertWorker::convertDarknetToVoc(const QString& inputDir, const QString& outputDir, const QString& imgDir, const QString& labelListPath) {
    ImagesLoader _loader;
    _loader.loadImagesDarknet(imgDir, inputDir, labelListPath);

    QDir output_dir(outputDir);

    int i = 0;
    for(auto inner : _loader) {
        QByteArray voc = ImagesLoader::innerToVoc(inner);

        QFileInfo lblFileInfo(inner["lblPath"].toString());

        QString outLblName = lblFileInfo.completeBaseName() + QString(".xml");
        QString outLblPath = output_dir.absoluteFilePath(outLblName);

        QFile outFile(outLblPath);
        if(!outFile.open(QFile::WriteOnly))
                continue;

        outFile.write(voc);

        if(i % 10 == 0)
            emit progressChanged((1.0 + i) / _loader.size());
        ++i;
    }

    emit convertedDarknetToVoc();
}

void ConvertWorker::convertVocToDarknet(const QString& inputDir, const QString& outputDir, const QString& labelsListPath) {
    QDir input_dir(inputDir);
    QDir output_dir(outputDir);
    QVector<QString> labelsList;

    {
        QFile labels_file(labelsListPath);
        if(!labels_file.open(QIODevice::ReadOnly)) {
            return;
        }

        for(QByteArray line = labels_file.readLine(); line.size(); line = labels_file.readLine()) {
            QString label(line);
            labelsList.push_back(label.trimmed());
        }
    }

    QFileInfoList vocFiles = input_dir.entryInfoList(QStringList({"*.xml"}));

    int i = 0;
    for(QFileInfo vocFile : vocFiles) {
        QFile xmlFile(vocFile.absoluteFilePath());
        if(!xmlFile.open(QFile::ReadOnly))
            continue;

        QVariantMap inner = ImagesLoader::vocToInner(xmlFile.readAll());
        QByteArray darknet = ImagesLoader::innerToDarknet(inner, labelsList);

        QString outLblName = vocFile.completeBaseName() + QString(".txt");
        QString outLblPath = output_dir.absoluteFilePath(outLblName);

        QFile outFile(outLblPath);
        if(!outFile.open(QFile::WriteOnly))
                continue;

        outFile.write(darknet);

        if(i % 10 == 0)
            emit progressChanged((1.0 + i) / vocFiles.size());
        ++i;
    }

    emit convertedVocToDarknet();
}
