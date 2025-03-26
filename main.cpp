#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QFile>
#include <QSerialPortInfo>


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
#include "ecgserial.h"
#include "ecgsql.h"
#include "ecgemulate.h"
#include "env.h"
void listAvailablePorts() {
    const auto ports = QSerialPortInfo::availablePorts();
    if (ports.isEmpty()) {
        qDebug() << "No serial ports available.";
    } else {
        for (const QSerialPortInfo &port : ports) {
            qDebug() << "Port Name:" << port.portName();
            qDebug() << "Description:" << port.description();
            qDebug() << "Manufacturer:" << port.manufacturer();
            qDebug() << "System Location:" << port.systemLocation();
            qDebug() << "-----------------------------";
        }
    }
}



int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    initEnv();


    ECGEmulate ecgEmulate;
    engine.rootContext()->setContextProperty("ecgEmulate", &ecgEmulate);

    ECGSQL ecgSql(&engine);
    engine.rootContext()->setContextProperty("ecgSql", &ecgSql);
    ECGSerial ecgSerial(&engine);  // ✅ Pass engine to ECGSerial
    engine.rootContext()->setContextProperty("ecgSerial", &ecgSerial);
    qDebug() << "Available TLS Backends:" << QSslSocket::availableBackends();

    if (QSslSocket::supportsSsl()) {
        qDebug() << "✅ OpenSSL is correctly loaded!";
    } else {
        qDebug() << "❌ OpenSSL NOT found! Make sure libssl/libcrypto are in the APK.";
    }
    listAvailablePorts();
    engine.loadFromModule("ekg-app", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    qDebug() << "Application started.";
    return app.exec();
}
