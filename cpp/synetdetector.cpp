#include "synetdetector.h"
#include <functional>

bool SynetDetector::Init(const std::string &modelPath,
                         const std::string &weightsPath,
                         double threshold,
                         double overlap,
                         size_t threads)
{
    Synet::SetThreadNumber(threads);

    if (_net.Load(modelPath, weightsPath)) {
        Net::Tensor * src = _net.Src()[0];
        _channels = src->Shape()[1];
        _height = src->Shape()[2];
        _width = src->Shape()[3];
        _detectionThreshold = threshold;
        _maxOverlap = overlap;
        return true;
    }

    return false;
}


std::vector<Synet::Region<float>> SynetDetector::Detect(const QImage &img)
{
    QImage image = img.scaled(_width, _height).convertToFormat(QImage::Format_BGR30);
    std::vector<float> inputVector(_channels * _height * _width);

    std::function<float(QRgb)> ext_color[] = {
        [](QRgb c) { return QColor(c).blueF(); },
        [](QRgb c) { return QColor(c).greenF(); },
        [](QRgb c) { return QColor(c).redF(); },
    };

    for(int k = 0; k < _channels/3; ++k) {
        for(int i = 0; i < _height; ++i) {
            QRgb* line = (QRgb*)image.scanLine(i);
            for(int j = 0; j < _width; ++j) {
                inputVector[k * _width * _height + i * _width + j] = ext_color[k](line[j]);
            }
        }
    }

    Net::Tensor * src = _net.Src()[0];
    std::copy(inputVector.begin(), inputVector.end(), src->CpuData());

    _net.Forward();
    Net::Tensor * dst = _net.Dst()[0];

    std::vector<Synet::Region<float>> regions;
    regions = _net.GetRegions(_width, _height, _detectionThreshold, _maxOverlap);

    double xscale = 1.0 * img.width() / _width;
    double yscale = 1.0 * img.height() / _height;


    for (size_t i = 0; i < regions.size(); i++)
    {
        Synet::Region<float>& region = regions[i];

        region.x -= region.w / 2;
        region.y -= region.h / 2;

        if (region.x < 0) {
            region.w += region.x;
            region.x = 0;
        } else if (region.x + region.w >= _width) {
            region.w = _width - region.x - 1;
        }

        if (region.y < 0) {
            region.h += region.y;
            region.y = 0;
        } else if (region.y + region.h >= _height) {
            region.h = _height - region.y - 1;
        }

        region.y *= yscale;
        region.x *= xscale;
        region.h *= yscale;
        region.w *= xscale;
    }

    return regions;
}

size_t SynetDetector::width()
{
    return _width;
}

size_t SynetDetector::height()
{
    return _height;
}

size_t SynetDetector::channels()
{
    return _channels;
}
