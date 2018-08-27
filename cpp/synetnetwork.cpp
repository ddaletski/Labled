#include "synetnetwork.h"
#include <QImage>
#include <QtCore>
#include <QColor>

bool SynetNetwork::Init(const QString &modelPath, const QString &weightsPath, size_t threads)
{
    Synet::SetThreadNumber(threads);

    if (_net.Load(modelPath.toStdString(), weightsPath.toStdString())) {
        Net::Tensor * src = _net.Src()[0];
        _channels = src->Shape()[1];
        _height = src->Shape()[2];
        _width = src->Shape()[3];
        return true;
    }

    std::cerr << "can't load model: (" << modelPath.data() << ", " << weightsPath.data() << ")" << std::endl;
    return false;
}

void SynetNetwork::Forward(const QImage &img)
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
}

const SynetNetwork::Net::Tensor* SynetNetwork::Output()
{
    return _net.Dst()[0];
}
