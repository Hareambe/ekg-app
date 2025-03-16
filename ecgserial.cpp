#include "ecgserial.h"
#include <QDebug>
#include <QtMath>
#include <QQmlContext>

ECGSerial::ECGSerial(QQmlApplicationEngine *engine, QObject *parent)
    : QObject(parent), qmlEngine(engine) {
    // ✅ Initialize 12 leads with empty data (no auto-generation)
    for (int i = 0; i < 12; i++) {
        ekgLeads[i].resize(4096, 0.0);
    }

    setContextProperties();  // ✅ Expose empty data to QML initially
}

void ECGSerial::generateFakeECGData() {
    qDebug() << "✅ Generating Fake ECG Data...";

    static double t = 0.0;

    // ✅ Generate 4096 samples for 12 leads
    for (int lead = 0; lead < 12; lead++) {
        ekgLeads[lead].clear();
        for (int i = 0; i < 4096; i++) {
            double value = qSin(2 * M_PI * (t + i) / 4096) * (0.5 + lead * 0.1);
            ekgLeads[lead].append(value);
        }
    }

    t += 1.0;  // ✅ Simulate time progression

    setContextProperties();  // ✅ Update QML dynamically
    emit ecgDataUpdated();  // ✅ Notify QML that data is ready
}

// ✅ Dynamically expose the ECG data to QML
void ECGSerial::setContextProperties() {
    if (!qmlEngine) return;

    for (int i = 0; i < 12; i++) {
        qmlEngine->rootContext()->setContextProperty(
            QString("ekgLead%1").arg(i + 1), ekgLeads[i]);
    }

    qDebug() << "✅ ECG Data Exposed to QML!";
}
