#include "logger.h"

// Returns the singleton instance of Logger.
Logger* Logger::instance() {
    static Logger logger;
    return &logger;
}

// Private constructor.
Logger::Logger(QObject *parent)
    : QObject(parent)
{
}

// Returns the latest debug message.
QString Logger::latestMessage() const {
    return m_latestMessage;
}

// Sets the latest debug message and emits a signal if it changes.
void Logger::setLatestMessage(const QString &message) {
    if (m_latestMessage != message) {
        m_latestMessage = message;
        emit latestMessageChanged();
    }
}
