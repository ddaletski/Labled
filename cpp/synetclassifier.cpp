#include "synetclassifier.h"
#include <QFile>


bool SynetClassifier::Init(const QString &modelPath,
                           const QString &weightsPath,
                           const QString &classesPath,
                           double thresh,
                           size_t threads)
{
    _threshold = thresh;

    QFile classesFile(classesPath);
    if (!classesFile.open(QFile::ReadOnly)) {
        std::cerr << "can't read classes file" << std::endl;
        return false;
    }

    while(!classesFile.atEnd()) {
        QString class_entry = classesFile.readLine().trimmed();
        _classes.push_back(class_entry);
    }

    return SynetNetwork::Init(modelPath, weightsPath, threads);
}

QString SynetClassifier::Classify(const QImage &img)
{
    Forward(img);
    const Synet::Tensor<float>* dst = Output();
    std::vector<float> preds{dst->CpuData(), dst->CpuData() + dst->Size()};
    auto max_elem = std::max_element(preds.begin(), preds.end());

    if(*max_elem >= _threshold) {
        size_t class_idx = std::distance(preds.begin(), max_elem);
        return _classes.at(class_idx);
    } else {
        return "";
    }
}
