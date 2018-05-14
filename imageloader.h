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
    int Index();
    bool IsStart();
    bool IsEnd();
    int Count();

    QByteArray InnerToVoc(const QVariantMap& inner);
    QVariantMap VocToInner(const QByteArray& xml);

    QByteArray InnerToDarknet(const QVariantMap& inner, const QStringList& labelsList);
    QVariantMap DarknetToInner(const QString& darknet, const QStringList& labelsList);

public slots:
    void LoadImages(const QUrl& imagesDir, const QUrl& annotationsDir);
    QVariantMap NextImage(int step);
    void SaveImage(const QVariant& annotation);

signals:
    void nextImageLoaded(QVariant);
    void imagesLoaded();
    void imageSaved();

private:
    QVector<QPair<QString, QString>> _images;
    size_t _idx;
};


#endif // IMAGELOADER_H
