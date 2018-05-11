#ifndef IMAGELOADER_H
#define IMAGELOADER_H

#include <QObject>
#include <QQueue>
#include <QVector>
#include <QUrl>
#include <QVariantMap>


class ImagesLoader : public QObject {
    Q_OBJECT

public slots:
    void loadImages(const QUrl& imagesDir, const QUrl& annotationsDir);
    void nextImage(int step);
    void saveImage(const QVariant& rects);

signals:
    void nextImageLoaded(QVariant, QVariant);
    void imageSaved();

private:
    QUrl _currentImage;
    QVector<QPair<QUrl, QUrl>> _images;
    size_t _idx;
};


#endif // IMAGELOADER_H
