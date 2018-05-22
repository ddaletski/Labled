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

template<class T>
T distance(const T& a, const T& b) {
    return (a - b) * (a - b);
}

}

#endif // COMMON_HPP
