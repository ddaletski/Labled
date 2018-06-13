#ifndef SYNETDETECTOR_H
#define SYNETDETECTOR_H

#include <Synet/Synet.h>
#include <Simd/SimdLib.hpp>
#include <QImage>


class SynetDetector {
public:
    typedef Synet::Network<float> Net;
    virtual bool Init(const std::string& modelPath,
                      const std::string& weightsPath,
                      double thresh=0.5,
                      double overlap=0.4,
                      size_t threads=1);

    virtual std::vector<Synet::Region<float>> Detect(const QImage& img);

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

#endif // SYNETDETECTOR_H
