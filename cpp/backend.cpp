#include "backend.h"
#include <QDebug>
#include <QImage>

////////////////////////////////
/// \brief Backend::loadImages
/// \param imgPath
/// \param lblPath
/// \param onlyExisting
///
Backend::Backend()
{
    _detectorLoaded = _detector.Init("data/nets/detector.xml", "data/nets/detector.bin", "data/det_classes.txt");
    _classifierLoaded = _classifier.Init("data/nets/classifier.xml", "data/nets/classifier.bin", "data/clf_classes.txt");
}

void Backend::loadImages(const QString &imgPath, const QString &lblPath, bool onlyExisting) {
    _loader.loadImagesVoc(imgPath, lblPath, onlyExisting);
    _iterator = _loader.begin();
    _curIdx = 0;
}

//////////////////////////////////
/// \brief Backend::next
/// \param step
/// \return
///
QVariantMap Backend::next(int step) {
    _curIdx = Common::bounded<int>(_curIdx + step, 0, _loader.size()-1);
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
/// \brief Backend::imagesCount
/// \return
///
int Backend::imagesCount() {
    return _loader.size();
}

//////////////////////////
/// \brief Backend::currentIdx
/// \return
///
int Backend::currentIdx() {
    return _curIdx;
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

////////////////////////////////
/// \brief Backend::detect
/// \param imgPath
/// \return
///
QVariantList Backend::detect(const QString &imgPath) {
    if(!_detectorLoaded) {
        std::cout << "detector not loaded" << std::endl;
        return {};
    }
    QImage img(imgPath);

    try {
        auto regions = _detector.Detect(img);

        QVariantList result;
        for(auto reg : regions) {
            QVariantMap rect;
            rect["x"] = reg.x / img.width();
            rect["y"] = reg.y / img.height();
            rect["w"] = reg.w / img.width();
            rect["h"] = reg.h / img.height();
            rect["label"] = reg.cls;

            result.push_back(rect);
        }
        return result;

    } catch(...) {
        return {};
    }
}

///////////////////////////////////////
/// \brief Backend::predict
/// \param imgPath
/// \param roi
/// \return
///
QString Backend::classify(const QString &imgPath, float x, float y, float w, float h) {
    if(!_detectorLoaded) {
        std::cout << "classifier not loaded" << std::endl;
        return "";
    }
    QImage img(imgPath);

    QRect scaledRoi(x * img.width(), y * img.height(),
                    w * img.width(), h * img.height());
    img = img.copy(scaledRoi);
    return _classifier.Classify(img);
}

