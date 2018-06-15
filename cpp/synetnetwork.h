#ifndef SYNETNETWORK_H
#define SYNETNETWORK_H

#include <QObject>
#include <Synet/Synet.h>

class SynetNetwork
{
public:
    typedef Synet::Network<float> Net;
    virtual bool Init(const QString& modelPath,
                      const QString& weightsPath,
                      size_t threads=1);

    void Forward(const QImage& img);
    const Net::Tensor* Output();

    size_t width();
    size_t height();
    size_t channels();

protected:
    Net _net;
    size_t _channels;
    size_t _height;
    size_t _width;
};

#endif // SYNETNETWORK_H
