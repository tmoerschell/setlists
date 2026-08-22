#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "setlistmodel.hpp"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    SetlistModel setlistModel;
    engine.rootContext()->setContextProperty("setlistModel", &setlistModel);

    engine.loadFromModule("Setlists", "Main");

    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    return app.exec();
}
