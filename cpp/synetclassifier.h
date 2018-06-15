#ifndef SYNET_CLASSIFIER_H
#define SYNET_CLASSIFIER_H

#include "synetnetwork.h"
#include <QtCore>


class SynetClassifier : public SynetNetwork {
public:
    virtual bool Init(const QString& modelPath,
                      const QString& weightsPath,
                      const QString& classesPath,
                      double thresh=0.5,
                      size_t threads=1);

    virtual QString Classify(const QImage& img);

private:
    double _threshold;
    QVector<QString> _classes;
};


#endif // SYNET_CLASSIFIER_H
