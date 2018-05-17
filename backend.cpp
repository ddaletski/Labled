#include "backend.h"


Backend::Backend(QObject *parent) : QObject(parent) {  }

///////////////////////////////////
/// \brief Backend::loadImages
/// \param imgPath
/// \param lblPath
///
void Backend::loadImages(const QString &imgPath, const QString &lblPath)
{
   _loader.loadImagesVoc(imgPath, lblPath);
   _iterator = _loader.begin();
}

//////////////////////////////////
/// \brief Backend::next
/// \param step
/// \return
///
QVariantMap Backend::next(int step)
{
    _iterator += step;
    QVariantMap res = *_iterator;
    return res;
}

////////////////////////////////
/// \brief Backend::save
/// \param annotation
///
void Backend::save(const QVariantMap& annotation)
{
    _loader.saveVoc(annotation);
}


/////////////////////////////////
/// \brief Backend::renameLabel
/// \param labelsDir
/// \param oldLabel
/// \param newLabel
///
void Backend::renameLabel(const QString &labelsDir, const QString &oldLabel, const QString &newLabel)
{

}


/////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////
/// \brief Backend::invertColor
/// \param color
/// \return
///
QColor Backend::invertColor(const QColor &color) {
    QColor c = color.toRgb();
    c.setRgbF(1.0 - c.redF(), 1.0 - c.greenF(), 1.0 - c.blueF());
    c.setAlpha(color.alpha());
    return c;
}


////////////////////////////////
/// \brief Backend::addRgba
/// \param color1
/// \param color2
/// \return
///
QColor Backend::addRgba(const QColor &color1, const QColor &color2) {
    QColor result(color1);
    result.setRgb(
                Common::bounded(result.red() + color2.red(), 0, 255),
                Common::bounded(result.green() + color2.green(), 0, 255),
                Common::bounded(result.blue() + color2.blue(), 0, 255),
                Common::bounded(result.alpha() + color2.alpha(), 0, 255)
                );
    return result;
}


/////////////////////////////////
/// \brief Backend::subRgba
/// \param color1
/// \param color2
/// \return
///
QColor Backend::subRgba(const QColor &color1, const QColor &color2) {
    QColor result(color1);
    result.setRgb(
                Common::bounded(result.red() - color2.red(), 0, 255),
                Common::bounded(result.green() - color2.green(), 0, 255),
                Common::bounded(result.blue() - color2.blue(), 0, 255),
                Common::bounded(result.alpha() - color2.alpha(), 0, 255)
                );
    return result;
}
