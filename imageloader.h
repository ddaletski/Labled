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
    void nextImage();
    void saveImage(const QVariant& rects);

signals:
    void nextImageLoaded(QVariant, QVariant);
    void imageSaved();

private:
    QUrl _currentImage;
    QQueue<QUrl> _images;
    QVector<QUrl> _annotations;
};


#endif // IMAGELOADER_H
