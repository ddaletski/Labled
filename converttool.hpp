#ifndef CONVERTTOOL_HPP
#define CONVERTTOOL_HPP

#include "common.hpp"
#include <QObject>
#include <QtCore>
#include "imageloader.h"
#include <QColor>


class ConvertWorker : public QObject {
    Q_OBJECT

public slots:
    void convertDarknetToVoc(const QString& inputDir, const QString& outputDir, const QString& imgDir, const QString& labelListPath);

signals:
    void progressChanged(double progress);
    void convertedDarknetToVoc();
};


class ConvertTool : public QObject
{
    Q_OBJECT
public:
    explicit ConvertTool(QObject *parent = nullptr);
    ~ConvertTool();
    Q_INVOKABLE void darknetToVoc(const QString& inputDir, const QString& outputDir, const QString& imgDir, const QString& labelListPath);

    Q_INVOKABLE void renameLabel(const QString& labelsDir, const QString& oldLabel, const QString& newLabel);

    Q_INVOKABLE QColor invertColor(const QColor& color) {
        QColor c = color.toRgb();
        c.setRgbF(1.0 - c.redF(), 1.0 - c.greenF(), 1.0 - c.blueF());
        c.setAlpha(color.alpha());
        return c;
    }
    Q_INVOKABLE QColor addRgba(const QColor& color1, const QColor& color2) {
        QColor result(color1);
        result.setRgb(
                    Common::bounded(result.red() + color2.red(), 0, 255),
                    Common::bounded(result.green() + color2.green(), 0, 255),
                    Common::bounded(result.blue() + color2.blue(), 0, 255),
                    Common::bounded(result.alpha() + color2.alpha(), 0, 255)
                    );
        return result;
    }
    Q_INVOKABLE QColor subRgba(const QColor& color1, const QColor& color2) {
        QColor result(color1);
        result.setRgb(
                    Common::bounded(result.red() - color2.red(), 0, 255),
                    Common::bounded(result.green() - color2.green(), 0, 255),
                    Common::bounded(result.blue() - color2.blue(), 0, 255),
                    Common::bounded(result.alpha() - color2.alpha(), 0, 255)
                    );
        return result;
    }

signals:
    void progressChanged(double progress);

    void convertDarknetToVoc(const QString& inputDir, const QString& outputDir, const QString& imgDir, const QString& labelListPath);
    void convertedDarknetToVoc();

public slots:

private:
    QThread _workerThread;
};

#endif // CONVERTTOOL_HPP
