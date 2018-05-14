#ifndef CONVERTTOOL_HPP
#define CONVERTTOOL_HPP

#include <QObject>
#include "imageloader.h"

class ConvertTool : public QObject
{
    Q_OBJECT
public:
    explicit ConvertTool(QObject *parent = nullptr);
    Q_INVOKABLE void darknetToVoc(const QString& inputDir, const QString& outputDir, const QString& imgDir, const QString& labelListPath);

signals:
    void convertedDarknetToVoc();
    void convertedVocToDarknet();
    void progressChanged(int progress);

public slots:

private:
    ImagesLoader _loader;
};

#endif // CONVERTTOOL_HPP
