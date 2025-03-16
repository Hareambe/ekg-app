#ifndef ECGLOADER_H
#define ECGLOADER_H

#include <QObject>
#include <QDebug>
#include <QStandardPaths>
#include <QVariantList>
#include <QFile>
#include <H5File.hpp>
#include <limits>
#include <QQmlApplicationEngine>
#include <QQmlContext>

class ECGLoader : public QObject {
    Q_OBJECT

public:
    explicit ECGLoader(QQmlApplicationEngine *engine, QObject *parent = nullptr);
    Q_INVOKABLE void readECGData();  // ✅ Load data when button is clicked

signals:
    void ecgDataLoaded();  // ✅ Notify QML when data is ready

private:
    QQmlApplicationEngine *qmlEngine;  // ✅ Store QML Engine reference
    QVariantList ekgLeads[12];  // ✅ Stores ECG data for 12 leads
    QVariantList ekgLeadMin, ekgLeadMax;  // ✅ Stores min & max for each lead
};

#endif // ECGLOADER_H
