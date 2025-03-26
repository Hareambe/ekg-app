#include "ecgsql.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QQmlContext>
#include <limits>
ECGSQL::ECGSQL(QQmlApplicationEngine *engine, QObject *parent)
    : QObject(parent), qmlEngine(engine) {
    networkManager = new QNetworkAccessManager(this);
}

void ECGSQL::saveECGData(const QVariantList &ekgLead1, const QVariantList &ekgLead2,
                         const QVariantList &ekgLead3, const QVariantList &ekgLead4,
                         const QVariantList &ekgLead5, const QVariantList &ekgLead6,
                         const QVariantList &ekgLead7, const QVariantList &ekgLead8,
                         const QVariantList &ekgLead9, const QVariantList &ekgLead10,
                         const QVariantList &ekgLead11, const QVariantList &ekgLead12) {
    if (ekgLead1.isEmpty() || ekgLead2.isEmpty() || ekgLead3.isEmpty() || ekgLead4.isEmpty() ||
        ekgLead5.isEmpty() || ekgLead6.isEmpty() || ekgLead7.isEmpty() || ekgLead8.isEmpty() ||
        ekgLead9.isEmpty() || ekgLead10.isEmpty() || ekgLead11.isEmpty() || ekgLead12.isEmpty()) {
        qDebug() << "❌ One or more leads are empty! Upload aborted.";
        return;
    }

    QUrl url(QString(SUPABASE_URL) + "ecg_data");
    QNetworkRequest request(url);
    request.setRawHeader("apikey", SUPABASE_API_KEY.toUtf8());
    request.setRawHeader("Content-Type", "application/json");
    request.setRawHeader("Prefer", "return=minimal");

    QJsonObject jsonData;
    jsonData.insert("lead1", QJsonArray::fromVariantList(ekgLead1));
    jsonData.insert("lead2", QJsonArray::fromVariantList(ekgLead2));
    jsonData.insert("lead3", QJsonArray::fromVariantList(ekgLead3));
    jsonData.insert("lead4", QJsonArray::fromVariantList(ekgLead4));
    jsonData.insert("lead5", QJsonArray::fromVariantList(ekgLead5));
    jsonData.insert("lead6", QJsonArray::fromVariantList(ekgLead6));
    jsonData.insert("lead7", QJsonArray::fromVariantList(ekgLead7));
    jsonData.insert("lead8", QJsonArray::fromVariantList(ekgLead8));
    jsonData.insert("lead9", QJsonArray::fromVariantList(ekgLead9));
    jsonData.insert("lead10", QJsonArray::fromVariantList(ekgLead10));
    jsonData.insert("lead11", QJsonArray::fromVariantList(ekgLead11));
    jsonData.insert("lead12", QJsonArray::fromVariantList(ekgLead12));

    QJsonObject finalJson;
    finalJson.insert("ecg_json", jsonData);

    QJsonArray jsonArray;
    jsonArray.append(finalJson);

    QNetworkReply *reply = networkManager->post(request, QJsonDocument(jsonArray).toJson(QJsonDocument::Compact));
    connect(reply, &QNetworkReply::finished, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            qDebug() << "✅ ECG Data Uploaded to Supabase!";
            emit notifyStatusChanged("✅ Data Uploaded!");
        } else {
            qDebug() << "❌ Upload Failed:" << reply->errorString();
            emit notifyStatusChanged("❌ Upload Failed:");
            qDebug() << "🔍 Response Data:" << reply->readAll();
        }
        reply->deleteLater();
    });
}

void ECGSQL::loadLatestECGData() {
    QUrl url(SUPABASE_URL + "ecg_data?order=timestamp.desc&limit=1");
    QNetworkRequest request(url);
    qDebug() << "SUPABASE_URL:" << SUPABASE_URL;
    qDebug() << "SUPABASE_API_KEY:" << SUPABASE_API_KEY;
    request.setRawHeader("apikey", SUPABASE_API_KEY.toUtf8());
    request.setRawHeader("Content-Type", "application/json");

    QNetworkReply *reply = networkManager->get(request);
    connect(reply, &QNetworkReply::finished, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray responseData = reply->readAll();
            qDebug() << "🔍 Raw API Response:" << responseData;

            QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData);
            if (!jsonDoc.isArray() || jsonDoc.array().isEmpty()) {
                qDebug() << "❌ No ECG data found!";
            } else {
                QJsonObject ecgJson = jsonDoc.array().first().toObject()["ecg_json"].toObject();
                QVariantList ekgLeads[12];
                for (int i = 0; i < 12; i++) {
                    QString key = QString("lead%1").arg(i + 1);
                    ekgLeads[i] = ecgJson[key].toArray().toVariantList();
                }

                if (!qmlEngine) {
                    qDebug() << "❌ QML Engine not set!";
                    return;
                }

                // Optionally expose individual leads to QML
                for (int i = 0; i < 12; i++) {
                    if (!ekgLeads[i].isEmpty()) {
                        qmlEngine->rootContext()->setContextProperty(QString("ekgLead%1").arg(i + 1),
                                                                     QVariant::fromValue(ekgLeads[i]));
                    } else {
                        qDebug() << QString("⚠ ekgLead%1 is empty, not exposing to QML").arg(i + 1);
                    }
                }

                // Define groups by lead indices (0-indexed)
                QVector<QVector<int>> groups;
                groups.append(QVector<int>() << 0 << 5 << 6 << 9);   // Group 1: leads 1-4
                groups.append(QVector<int>() << 1 << 4 << 7 << 10);   // Group 2: leads 5-8
                groups.append(QVector<int>() << 2 << 3 << 8 << 11); // Group 3: leads 9-12

                QVariantList ekgLine1, ekgLine2, ekgLine3;

                // Process each group: concatenate lead data with 50 empty (NaN) points between each lead,
                // then adjust the y values (group 1: add 4, group 2: no change, group 3: subtract 4)
                for (int g = 0; g < groups.size(); g++) {
                    QVariantList groupPoints;
                    QVector<int> groupIndices = groups[g];
                    for (int idx = 0; idx < groupIndices.size(); idx++) {
                        int leadIndex = groupIndices[idx];
                        QVariantList currentLead = ekgLeads[leadIndex];
                        // Append all points of the current lead
                        for (int j = 0; j < currentLead.size(); j++) {
                            groupPoints.append(currentLead[j]);
                        }
                        // Insert 50 empty points (NaN) if not the last lead in the group
                        if (idx != groupIndices.size() - 1) {
                            for (int k = 0; k < 50; k++) {
                                groupPoints.append(std::numeric_limits<double>::quiet_NaN());
                            }
                        }
                    }
                    // Adjust y values based on group
                    for (int i = 0; i < groupPoints.size(); i++) {
                        double val = groupPoints[i].toDouble();
                        if (!std::isnan(val)) {
                            if (g == 0) {           // Group 1: add 5
                                val += 5.5;
                            } else if (g == 2) {    // Group 3: subtract 5
                                val -= 5.5;
                            }
                        }
                        groupPoints[i] = val;
                    }
                    // Assign to the corresponding ekgLine variable
                    if (g == 0) {
                        ekgLine1 = groupPoints;
                    } else if (g == 1) {
                        ekgLine2 = groupPoints;
                    } else if (g == 2) {
                        ekgLine3 = groupPoints;
                    }
                }

                // Expose the grouped series to QML
                qmlEngine->rootContext()->setContextProperty("ekgLine1", QVariant::fromValue(ekgLine1));
                qmlEngine->rootContext()->setContextProperty("ekgLine2", QVariant::fromValue(ekgLine2));
                qmlEngine->rootContext()->setContextProperty("ekgLine3", QVariant::fromValue(ekgLine3));

                qDebug() << "✅ ECG Data Loaded and Grouped into ekgLine1, ekgLine2, ekgLine3!";
                emit notifyStatusChanged("✅ Data Loaded From the Database!");
            }
        } else {
            qDebug() << "❌ Load Failed:" << reply->errorString();
            emit notifyStatusChanged("❌ Load Failed:");

            qDebug() << "🔍 Response Data:" << reply->readAll();
        }
        reply->deleteLater();
    });
}
