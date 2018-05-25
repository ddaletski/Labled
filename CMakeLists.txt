cmake_minimum_required(VERSION 3.1)

project(Labled LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 COMPONENTS Core Quick Xml Widgets REQUIRED)

FILE(GLOB HEADERS_H ${PROJECT_SOURCE_DIR}/cpp/*.h)
FILE(GLOB HEADERS_HPP ${PROJECT_SOURCE_DIR}/cpp/*.hpp)

file(GLOB SOURCES ${PROJECT_SOURCE_DIR}/cpp/*.cpp)

add_executable(${PROJECT_NAME} ${SOURCES} "qml.qrc")

target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick Qt5::Xml Qt5::Widgets)


if (WIN32)
    message("building win32 installer")
    add_custom_target(build_installer ${CMAKE_CURRENT_SOURCE_DIR}/build_installer_win32.cmd
        DEPENDS ${PROJECT_NAME})
else ()
    message("building linux installer")
    add_custom_target(build_installer ${CMAKE_CURRENT_SOURCE_DIR}/build_installer_linux.sh
        DEPENDS ${PROJECT_NAME})
endif ()

