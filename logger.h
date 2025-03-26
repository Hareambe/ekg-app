#ifndef LOGGER_H
#define LOGGER_H

#include <QObject>
#include <QString>

class Logger : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString latestMessage READ latestMessage NOTIFY latestMessageChanged)
public:
    // Returns the singleton instance of Logger.
    static Logger* instance();

    // Getter for the latest debug message.
    QString latestMessage() const;

    // Setter to update the latest debug message.
    void setLatestMessage(const QString &message);

signals:
    void latestMessageChanged();

private:
    // Private constructor for the singleton pattern.
    explicit Logger(QObject *parent = nullptr);

    QString m_latestMessage;
};

#endif // LOGGER_H
