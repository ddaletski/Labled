#ifndef SYNETDETECTOR_H
#define SYNETDETECTOR_H

#include "synetnetwork.h"
#include <QImage>


class SynetDetector : public SynetNetwork {
public:
    struct Region {
        float x;
        float y;
        float w;
        float h;
        QString cls;
        float prob;
    };

    virtual bool Init(const QString& modelPath,
                      const QString& weightsPath,
                      const QString& classesPath,
                      double thresh=0.5,
                      double overlap=0.4,
                      size_t threads=1);

    virtual std::vector<Region> Detect(const QImage& img);
private:
    double _detectionThreshold;
    double _maxOverlap;
    QVector<QString> _classes;
};

#endif // SYNETDETECTOR_H
