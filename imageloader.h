#ifndef IMAGELOADER_H
#define IMAGELOADER_H

#include <QObject>
#include <QQueue>
#include <QVector>
#include <QString>
#include <QVariantMap>


class ImagesLoader : public QObject {
    Q_OBJECT

public:
    enum LabelsFormat {
        NO_FORMAT = 0,
        VOC = 1,
        DARKNET = 2,
    };

    ImagesLoader(QObject *parent = nullptr);
    void ToStart();
    void ToEnd();
    int Index();
    bool IsStart();
    bool IsEnd();
    int Count();
    int Format();
    QVector<QString> DarknetLabels();

    static QByteArray InnerToVoc(const QVariantMap& inner);
    static QVariantMap VocToInner(const QByteArray& xml);

    static QByteArray InnerToDarknet(const QVariantMap& inner, const QVector<QString>& labelsList);
    static QVariantMap DarknetToInner(const QString& darknet, const QVector<QString>& labelsList);

public slots:
    void LoadImagesVoc(const QString& imagesDir, const QString& annotationsDir);
    void LoadImagesDarknet(const QString& imagesDir, const QString& annotationsDir, const QString& labelsFile);
    QVariantMap NextImage(int step);
    void SaveImage(const QVariant& annotation);

signals:
    void nextImageLoaded(QVariant);
    void imagesLoaded();
    void imageSaved();

private:
    QVector<QPair<QString, QString>> _images;
    size_t _idx;

    LabelsFormat _format;
    QVector<QString> _darknet_labels;
};


#endif // IMAGELOADER_H
