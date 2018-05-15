#ifndef CROPTOOL_H
#define CROPTOOL_H

#include <QObject>
#include <QtCore>

#include "imageloader.h"

class CropWorker : public QObject {
    Q_OBJECT

public slots:
    void Crop(const QString& imgDir, const QString& annDir, const QString& outDir, const QString& pattern);

signals:
    void progressChanged(double progress);
    void done();
};



class CropTool : public QObject
{
    Q_OBJECT
public:
    explicit CropTool(QObject *parent = nullptr);
    ~CropTool();
    Q_INVOKABLE void Crop(const QString& imgDir, const QString& annDir, const QString& outDir, const QString& pattern);

signals:
    void workerRun(const QString& imgDir, const QString& annDir, const QString& outDir, const QString& pattern);
    void progressChanged(double progress);
    void done();

private:
    QThread _workerThread;
};

#endif // CROPTOOL_H
