#ifndef CROPTOOL_H
#define CROPTOOL_H

#include <QObject>
#include "imageloader.h"

class CropTool : public QObject
{
    Q_OBJECT
public:
    explicit CropTool(QObject *parent = nullptr);

signals:

public slots:
    void Crop(const QUrl& imgDir, const QUrl& annDir);

private:
    ImagesLoader _loader;
};

#endif // CROPTOOL_H
