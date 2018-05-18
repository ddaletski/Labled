#include "backend.h"
#include <QDebug>

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
void Backend::save(const QVariantMap& annotation) {
    _loader.saveVoc(annotation);
}


/////////////////////////////////
/// \brief Backend::renameLabel
/// \param labelsDir
/// \param oldLabel
/// \param newLabel
///
void Backend::renameLabel(const QString &labelsDir, const QString &oldLabel, const QString &newLabel) {
    QDir labelsDir_(labelsDir);

    QStringList labels = labelsDir_.entryList(QStringList{"*.xml"});

    auto nameTag = [](const QString& name) {
        return QString("<name>") + name + QString("</name>");
    };

    for(auto lblName : labels) {
        QString lblPath = labelsDir_.absoluteFilePath(lblName);

        QFile lblFile(lblPath);
        if(!lblFile.open(QFile::ReadOnly))
            continue;

        QTextStream str(&lblFile);

        QString content = str.readAll();
        content.replace(nameTag(oldLabel), nameTag(newLabel));

        lblFile.close();
        if(!lblFile.open(QFile::WriteOnly))
            continue;

        str.reset();
        str << content;
        str.flush();
    }
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

    double distFromCenter = Common::distance(c.redF(), 0.5) +
                            Common::distance(c.greenF(), 0.5) +
                            Common::distance(c.blueF(), 0.5);


    if(distFromCenter < 0.1)
    {
        double shiftFromCenter = c.redF() + c.greenF() + c.blueF() - 1.5;
        double shift = shiftFromCenter < 0 ? -0.2 : 0.2;

        c.setRedF(c.redF() + shift);
        c.setGreenF(c.greenF() + shift);
        c.setBlueF(c.blueF() + shift);
    }
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
