#ifndef CROPTOOL_H
#define CROPTOOL_H

#include <QObject>
#include <QtCore>

#include "imageloader.h"

class CropTool : public QObject
{
    Q_OBJECT
public:
    explicit CropTool(QObject *parent = nullptr);
    Q_INVOKABLE void Crop(const QUrl& imgDir, const QUrl& annDir, const QUrl& outDir, const QString& pattern);

signals:
    void progressChanged(double progress);

private:
    ImagesLoader _loader;
};

#endif // CROPTOOL_H
