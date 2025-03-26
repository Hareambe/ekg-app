#ifndef ECGEMULATE_H
#define ECGEMULATE_H

#include <QObject>
#include <QSerialPort>
#include <QTimer>

class ECGEmulate : public QObject
{
    Q_OBJECT
public:
    explicit ECGEmulate(QObject *parent = nullptr);
    ~ECGEmulate();

    // Start the emulation on a given serial port with specified baud rate.
    Q_INVOKABLE void startEmulation(const QString &portName, qint32 baudRate = QSerialPort::Baud9600);

    // Stop the emulation.
    Q_INVOKABLE void stopEmulation();

    // Set the sampling rate (in Hz) for ECG data generation.
    Q_INVOKABLE void setSamplingRate(double rate);

private slots:
    // Slot to generate and send ECG data at each timer timeout.
    void sendECGData();

private:
    // Generate a synthetic ECG sample based on time.
    qint16 generateECGSample(double t);

    QSerialPort *m_serial;
    QTimer *m_timer;
    double m_samplingRate; // in Hz (e.g., 250 Hz)
    double m_timeCounter;  // keeps track of time elapsed in seconds
};

#endif // ECGEMULATE_H
