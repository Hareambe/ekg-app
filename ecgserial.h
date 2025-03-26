#ifndef ECGSERIAL_H
#define ECGSERIAL_H

#include <QObject>
#include <QVariantList>
#include <QQmlApplicationEngine>

class ECGSerial : public QObject {
    Q_OBJECT

public:
    explicit ECGSerial(QQmlApplicationEngine *engine, QObject *parent = nullptr);
    Q_INVOKABLE void generateFakeECGData();  // ✅ Only generate once


signals:
    void notifyStatusChanged(const QString &message);


private:
    QVariantList ekgLeads[12];  // ✅ Store 12-lead ECG data
    QQmlApplicationEngine *qmlEngine;  // ✅ Pointer to the QML Engine
    void setContextProperties();  // ✅ Function to expose data dynamically
};

#endif // ECGSERIAL_H
