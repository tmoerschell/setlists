cmake_minimum_required(VERSION 3.21)

project(setlists
    VERSION 0.1
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core
    Gui
    Quick
    QuickControls2
    Pdf
)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(setlists
    src/main.cpp
)

qt_add_qml_module(setlists
    URI Setlists
    VERSION 1.0

    QML_FILES
        src/qml/Main.qml
        src/qml/FolderView.qml
        src/qml/PerformanceView.qml
        src/qml/SetlistView.qml

    SOURCES
        src/setlistmodel.cpp
        src/setlistmodel.hpp
)

target_link_libraries(setlists
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Pdf
)

set_target_properties(setlists PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
