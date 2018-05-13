#ifndef IMAGELOADER_H
#define IMAGELOADER_H

#include <QObject>
#include <QQueue>
#include <QVector>
#include <QUrl>
#include <QVariantMap>


class ImagesLoader : public QObject {
    Q_OBJECT

public:
    explicit ImagesLoader(QObject *parent = nullptr);
    void ToStart();
    void ToEnd();

public slots:
    void LoadImages(const QUrl& imagesDir, const QUrl& annotationsDir);
    QPair<QUrl, QVariantList> NextImage(int step);
    void SaveImage(const QVariant& rects);

signals:
    void nextImageLoaded(QVariant, QVariant);
    void imagesLoaded();
    void imageSaved();

private:
    QUrl _currentImage;
    QVector<QPair<QUrl, QUrl>> _images;
    size_t _idx;

    QVariantList LoadAnnotations();
    void DumpAnnotations(const QVariantList& json);
};


#endif // IMAGELOADER_H
