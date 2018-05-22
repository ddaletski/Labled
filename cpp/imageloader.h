#ifndef IMAGELOADER_H
#define IMAGELOADER_H

#include <QObject>
#include <QQueue>
#include <QVector>
#include <QString>
#include <QVariantMap>
#include "common.hpp"


class ImagesLoader : public QObject {
    Q_OBJECT

public:
    enum LabelsFormat {
        NO_FORMAT = 0,
        VOC = 1,
        DARKNET = 2,
    };

    class iterator : public std::iterator<std::bidirectional_iterator_tag, QVariantMap> {

    public:
        explicit iterator(ImagesLoader* loader, size_t idx) : _loader(loader), _idx(idx) {}
        explicit iterator() : _loader(nullptr), _idx(0) {}

        QVariantMap operator*() const {
            if(_loader && _loader->size() > _idx)
                return (*_loader)[_idx];
            else
                return QVariantMap();
        }

        iterator& operator++() {
            return operator += (1);
        }

        iterator& operator--() {
            return operator -= (1);
        }

        iterator& operator+=(int step) {
            if(_loader && !_loader->empty())
                _idx = Common::bounded<int>(_idx + step, 0, _loader->size()-1);
            return (*this);
        }

        iterator& operator-=(int step) {
            return operator +=(-step);
        }

        bool operator == (const iterator& other) {
            return _idx == other._idx && _loader == other._loader;
        }

        bool operator != (const iterator& other) {
            return !(*this == other);
        }

    private:
        int _idx;
        ImagesLoader* _loader;
    };


    ImagesLoader();

    iterator begin() { return iterator(this, 0); }
    iterator end() { return iterator(this, size()); }
    size_t size();
    bool empty();
    int Format();

    const QVector<QPair<QString, QString>>& paths();
    void setPaths(const QVector<QPair<QString, QString>>& paths);

    QVector<QString> darknetLabels();

    static QByteArray innerToVoc(const QVariantMap& inner);
    static QVariantMap vocToInner(const QByteArray& xml);

    static QByteArray innerToDarknet(const QVariantMap& inner, const QVector<QString>& labelsList);
    static QVariantMap darknetToInner(const QString& darknet, const QVector<QString>& labelsList);

    static void saveVoc(const QVariantMap& annotation);

    void loadImagesVoc(const QString& imagesDir, const QString& annotationsDir, bool onlyExisting=false);
    void loadImagesDarknet(const QString& imagesDir, const QString& annotationsDir, const QString& labelsFile, bool onlyExisting=false);

private:
    QVariantMap load(const QString& annotationPath);
    QVariantMap operator[] (size_t idx);

    QVector<QPair<QString, QString>> _paths;
    LabelsFormat _format;
    QVector<QString> _darknet_labels;

    bool _onlyExistingAnnotations;
};


#endif // IMAGELOADER_H
