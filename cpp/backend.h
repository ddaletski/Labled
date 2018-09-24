#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QtCore>
#include <QColor>
#include "imageloader.h"
#include <memory>

////////////////////////////
/// \brief The Backend class
///
class Backend : public QObject
{
    Q_OBJECT
public:
    Backend();
    Q_INVOKABLE void loadImages(const QString& imgPath, const QString& lblPath, bool onlyExisting=false);
    Q_INVOKABLE QVariantMap next(int step);
    Q_INVOKABLE void save(const QVariantMap& annotation);
    Q_INVOKABLE int imagesCount();
    Q_INVOKABLE int currentIdx();

    Q_INVOKABLE void renameLabel(const QString& labelsDir, const QString& oldLabel, const QString& newLabel);

    Q_INVOKABLE QColor invertColor(const QColor& color);
    Q_INVOKABLE QColor addRgba(const QColor& color1, const QColor& color2);
    Q_INVOKABLE QColor subRgba(const QColor& color1, const QColor& color2);

private:
    ImagesLoader _loader;
    ImagesLoader::iterator _iterator;
    int _curIdx;
};

#endif // BACKEND_H
