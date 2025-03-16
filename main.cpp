#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include "ecgloader.h"  // ✅ Include ECGLoader

/*
int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    ECGLoader ecgLoader(&engine);  // ✅ Pass engine reference
    engine.rootContext()->setContextProperty("ecgLoader", &ecgLoader);

    qDebug() << "[EKG-APP] Loading QML UI...";
    engine.loadFromModule("ekg-app", "Main");

    if (engine.rootObjects().isEmpty()) {
        qDebug() << "[ERROR] Failed to load QML UI.";
        return -1;
    }

    qDebug() << "[EKG-APP] Running application.";
    return app.exec();
}
*/
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "ecgserial.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    ECGSerial ecgSerial(&engine);  // ✅ Pass engine to ECGSerial
    engine.rootContext()->setContextProperty("ecgSerial", &ecgSerial);

    engine.loadFromModule("ekg-app", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
