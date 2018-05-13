#include "croptool.h"

CropTool::CropTool(QObject *parent) : QObject(parent) { }

void CropTool::Crop(const QUrl &imgDir, const QUrl &annDir) {
    _loader.LoadImages(imgDir, annDir);
    _loader.ToStart();

    QPair<QUrl, QVariantList> pair = _loader.NextImage(1);
    while(pair.second.size()) {

        pair = _loader.NextImage(1);
    }
}
