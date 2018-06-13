cmake_minimum_required(VERSION 3.1)

project(Labled LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(SIMD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Simd)
set(SYNET_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Synet)

add_definitions(-DSYNET_SIMD_LIBRARY_ENABLE)
add_definitions(-DSYNET_GEMM_SIMD_LIBRARY)

find_package(Qt5 COMPONENTS Core Quick Xml Widgets REQUIRED)

include_directories(${SIMD_DIR}/src)
include_directories(${SYNET_DIR}/src)
add_subdirectory(${SIMD_DIR}/prj/cmake simd EXCLUDE_FROM_ALL)
add_subdirectory(${SYNET_DIR}/prj/cmake synet EXCLUDE_FROM_ALL)

FILE(GLOB HEADERS_H ${PROJECT_SOURCE_DIR}/cpp/*.h)
FILE(GLOB HEADERS_HPP ${PROJECT_SOURCE_DIR}/cpp/*.hpp)

file(GLOB SOURCES ${PROJECT_SOURCE_DIR}/cpp/*.cpp)

add_executable(${PROJECT_NAME} ${SOURCES} "qml.qrc")

target_link_libraries(${PROJECT_NAME} Simd -lpthread Qt5::Core Qt5::Quick Qt5::Xml Qt5::Widgets)
