#ifndef SYNET_CLASSIFIER_H
#define SYNET_CLASSIFIER_H

#include <Synet/Synet.h>
#include <QtCore>

class SynetClassifier {
public:
    typedef Synet::Network<float> Net;
    virtual bool Init(const std::string& modelPath,
                      const std::string& weightsPath,
                      double thresh=0.5,
                      size_t threads=1);

    virtual std::vector<size_t> Classify(const QImage& img);


    size_t width();
    size_t height();
    size_t channels();

private:
    Net _net;
    size_t _channels;
    size_t _height;
    size_t _width;
    double _detectionThreshold;
    double _maxOverlap;
};


#endif // SYNET_CLASSIFIER_H
