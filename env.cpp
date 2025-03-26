#include "env.h"
#include <QFile>
#include <QDebug>
#include <QMap>

// Helper function that parses the .env file from the Qt resource system.
static QMap<QString, QString> parseEnvFile() {
    QMap<QString, QString> envMap;
    QFile file(":/resources/.env");  // Make sure the .env file is correctly added to your resources.
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Failed to open .env file at :/resources/.env!";
        return envMap;
    }
    while (!file.atEnd()) {
        QByteArray line = file.readLine().trimmed();
        // Skip empty lines and comments
        if (line.isEmpty() || line.startsWith('#'))
            continue;
        QList<QByteArray> parts = line.split('=');
        if (parts.size() == 2) {
            QString key = QString(parts.at(0)).trimmed();
            QString value = QString(parts.at(1)).trimmed();
            envMap.insert(key, value);
        }
    }
    file.close();
    qDebug() << "Parsed .env file:" << envMap;
    return envMap;
}

// Global variables. They are non-const so they can be assigned at runtime.
QString SUPABASE_URL;
QString SUPABASE_API_KEY;

// This function initializes SUPABASE_URL and SUPABASE_API_KEY by reading from the .env file.
void initEnv() {
    QMap<QString, QString> envVars = parseEnvFile();
    SUPABASE_URL = envVars.value("SUPABASE_URL", "");
    SUPABASE_API_KEY = envVars.value("SUPABASE_API_KEY", "");
    qDebug() << "SUPABASE_URL:" << SUPABASE_URL;
    qDebug() << "SUPABASE_API_KEY:" << SUPABASE_API_KEY;
}
