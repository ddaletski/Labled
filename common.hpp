#ifndef COMMON_HPP
#define COMMON_HPP

#include <QObject>
#include <QtCore>


namespace Common {

template<class T>
T bounded(const T& val, const T& minVal, const T& maxVal) {
    if(val < minVal)
        return minVal;
    else if (val > maxVal)
        return maxVal;
    else
        return val;
}

}

#endif // COMMON_HPP
