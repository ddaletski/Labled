#include "synetdetector.h"
#include <functional>
#include <QtCore>
#include <QFile>

bool SynetDetector::Init(const QString &modelPath,
                         const QString &weightsPath,
                         const QString &classesPath,
                         double threshold,
                         double overlap,
                         size_t threads)
{
    QFile classesFile(classesPath);
    if (!classesFile.open(QFile::ReadOnly)) {
        std::cerr << "can't read classes file" << std::endl;
        return false;
    }

    while(!classesFile.atEnd()) {
        QString class_entry = classesFile.readLine().trimmed();
        _classes.push_back(class_entry);
    }

    std::cout << _classes.size() << std::endl;

    _detectionThreshold = threshold;
    _maxOverlap = overlap;
    return SynetNetwork::Init(modelPath, weightsPath, threads);
}


std::vector<SynetDetector::Region> SynetDetector::Detect(const QImage &img)
{
    Forward(img);

    std::vector<Synet::Region<float>> regions;
    regions = _net.GetRegions(_width, _height, _detectionThreshold, _maxOverlap);

    double xscale = 1.0 * img.width() / _width;
    double yscale = 1.0 * img.height() / _height;


    std::vector<Region> outRegions;
    for (size_t i = 0; i < regions.size(); i++)
    {
        auto r = regions[i];
        std::cout << r.id << std::endl;
        Region region = { r.x, r.y, r.w, r.h, _classes.at(r.id), r.prob };

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

        outRegions.push_back(region);
    }

    return outRegions;
}
