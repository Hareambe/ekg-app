#include "ecgemulate.h"
#include <QtMath>
#include <QDebug>

ECGEmulate::ECGEmulate(QObject *parent)
    : QObject(parent),
    m_serial(new QSerialPort(this)),
    m_timer(new QTimer(this)),
    m_samplingRate(250.0),
    m_timeCounter(0.0)
{
    // Connect the timer's timeout signal to the sendECGData slot.
    connect(m_timer, &QTimer::timeout, this, &ECGEmulate::sendECGData);
}

ECGEmulate::~ECGEmulate()
{
    stopEmulation();
    if (m_serial->isOpen()) {
        m_serial->close();
    }
}

void ECGEmulate::startEmulation(const QString &portName, qint32 baudRate)
{
    // Close the serial port if already open.
    if (m_serial->isOpen()) {
        m_serial->close();
    }

    // Configure the serial port.
    m_serial->setPortName(portName);
    m_serial->setBaudRate(baudRate);
    m_serial->setDataBits(QSerialPort::Data8);
    m_serial->setParity(QSerialPort::NoParity);
    m_serial->setStopBits(QSerialPort::OneStop);
    m_serial->setFlowControl(QSerialPort::NoFlowControl);

    // Try to open the serial port.
    if (!m_serial->open(QIODevice::WriteOnly)) {
        qDebug() << "Error: Unable to open serial port" << portName << ":" << m_serial->errorString();
        return;
    }
    qDebug() << "Serial port" << portName << "opened successfully";

    // Reset the time counter.
    m_timeCounter = 0.0;
    // Calculate the timer interval in milliseconds (1000 / sampling rate).
    int interval = static_cast<int>(1000.0 / m_samplingRate);
    m_timer->start(interval);
}

void ECGEmulate::stopEmulation()
{
    if (m_timer->isActive()) {
        m_timer->stop();
    }
    if (m_serial->isOpen()) {
        m_serial->close();
    }
}

void ECGEmulate::setSamplingRate(double rate)
{
    m_samplingRate = rate;
    if (m_timer->isActive()) {
        m_timer->stop();
        int interval = static_cast<int>(1000.0 / m_samplingRate);
        m_timer->start(interval);
    }
}

qint16 ECGEmulate::generateECGSample(double t)
{
    // For demonstration, use a simple sine wave.
    // Replace with a more realistic ECG waveform algorithm if desired.
    double sample = qSin(2 * M_PI * 1.0 * t);
    return static_cast<qint16>(sample * 32767);
}

void ECGEmulate::sendECGData()
{
    if (!m_serial->isOpen())
        return;

    qint16 sample = generateECGSample(m_timeCounter);
    QByteArray data(reinterpret_cast<const char*>(&sample), sizeof(sample));
    qint64 bytesWritten = m_serial->write(data);
    if (bytesWritten == -1) {
        qDebug() << "Write error:" << m_serial->errorString();
    } else {
        m_serial->flush(); // Ensure immediate transmission.
    }
    m_timeCounter += 1.0 / m_samplingRate;
}
