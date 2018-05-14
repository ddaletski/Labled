#include "converttool.hpp"
#include <QtCore>

ConvertTool::ConvertTool(QObject *parent) : QObject(parent) {  }


void ConvertTool::darknetToVoc(const QString& inputDir, const QString& outputDir,
                               const QString& imgDir, const QString& labelsListPath)
{
    _loader.LoadImagesDarknet(imgDir, inputDir, labelsListPath);

    QDir output_dir(outputDir);

    for(int i = 0; !_loader.IsEnd(); ++i) {
        QVariantMap inner = _loader.NextImage(1);
        for(auto rect: inner["boxes"].toList()) {
            qDebug() << rect;
        }
        QByteArray voc = ImagesLoader::InnerToVoc(inner);

        QFileInfo lblFileInfo(inner["lblPath"].toString());

        QString outLblName = lblFileInfo.completeBaseName() + QString(".") + lblFileInfo.suffix();
        QString outLblPath = output_dir.absoluteFilePath(outLblName);

//        QFile outFile(outLblPath);
//        if(!outFile.open(QFile::WriteOnly))
//                continue;
//
        qDebug() << "\n\n" << voc;
    //    outFile.write(voc);
        emit progressChanged((1.0 + i) / _loader.Count());
    }

    emit convertedDarknetToVoc();
}
