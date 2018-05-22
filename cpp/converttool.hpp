#ifndef CONVERTTOOL_HPP
#define CONVERTTOOL_HPP

#include "common.hpp"
#include <QObject>
#include <QtCore>
#include "imageloader.h"
#include <QColor>


class ConvertWorker : public QObject {
    Q_OBJECT

public slots:
    void convertDarknetToVoc(const QString& inputDir, const QString& outputDir, const QString& imgDir, const QString& labelListPath);

signals:
    void progressChanged(double progress);
    void convertedDarknetToVoc();
};


class ConvertTool : public QObject
{
    Q_OBJECT
public:
    explicit ConvertTool(QObject *parent = nullptr);
    ~ConvertTool();
    Q_INVOKABLE void darknetToVoc(const QString& inputDir, const QString& outputDir, const QString& imgDir, const QString& labelListPath);

signals:
    void progressChanged(double progress);

    void convertDarknetToVoc(const QString& inputDir, const QString& outputDir, const QString& imgDir, const QString& labelListPath);
    void convertedDarknetToVoc();

public slots:

private:
    QThread _workerThread;
};

#endif // CONVERTTOOL_HPP
