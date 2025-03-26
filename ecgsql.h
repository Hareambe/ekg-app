#ifndef ECGSQL_H
#define ECGSQL_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantList>
#include <QQmlApplicationEngine>
#include "env.h"   // Include the environment variables

class ECGSQL : public QObject {
    Q_OBJECT
public:
    explicit ECGSQL(QQmlApplicationEngine *engine, QObject *parent = nullptr);

    Q_INVOKABLE void saveECGData(const QVariantList &ekgLead1, const QVariantList &ekgLead2,
                                 const QVariantList &ekgLead3, const QVariantList &ekgLead4,
                                 const QVariantList &ekgLead5, const QVariantList &ekgLead6,
                                 const QVariantList &ekgLead7, const QVariantList &ekgLead8,
                                 const QVariantList &ekgLead9, const QVariantList &ekgLead10,
                                 const QVariantList &ekgLead11, const QVariantList &ekgLead12);

    Q_INVOKABLE void loadLatestECGData();

signals:
    void ecgDataLoaded(QVariantList ekgLead1, QVariantList ekgLead2, QVariantList ekgLead3,
                       QVariantList ekgLead4, QVariantList ekgLead5, QVariantList ekgLead6,
                       QVariantList ekgLead7, QVariantList ekgLead8, QVariantList ekgLead9,
                       QVariantList ekgLead10, QVariantList ekgLead11, QVariantList ekgLead12);

    void notifyStatusChanged(const QString &message);
private:
    QNetworkAccessManager *networkManager;
    QQmlApplicationEngine *qmlEngine;
};

#endif // ECGSQL_H
