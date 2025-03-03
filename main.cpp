#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QStandardPaths>
#include <QVariantList>
#include <H5File.hpp>
#include <limits>
#include <QFile>

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Path to the HDF5 file
    QString filePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/first_patient_data.hdf5";
    qDebug() << "[EKG-APP] File path:" << filePath;

    if (!QFile::exists(filePath)) {
        qDebug() << "[ERROR] HDF5 file not found at:" << filePath;
        return -1;
    }

    QVariantList ekgGraphData[12];  // Store 12 leads' data separately for QML
    QVariantList ekgLeadMin, ekgLeadMax;  // Store min & max for each lead

    try {
        qDebug() << "[EKG-APP] Opening HDF5 file...";
        HighFive::File file(filePath.toStdString(), HighFive::File::ReadOnly);
        qDebug() << "[EKG-APP] HDF5 file opened successfully.";

        // Verify dataset existence
        if (!file.exist("first_patient")) {
            qDebug() << "[ERROR] Dataset 'first_patient' not found.";
            return -1;
        }

        HighFive::DataSet dataset = file.getDataSet("first_patient");
        qDebug() << "[EKG-APP] Dataset 'first_patient' accessed.";

        // Get dataset dimensions
        std::vector<size_t> dims = dataset.getDimensions();
        if (dims.size() != 2 || dims[1] != 12) {
            qDebug() << "[ERROR] Invalid dataset dimensions. Expected [4096, 12] but got:" << dims;
            return -1;
        }
        qDebug() << "[EKG-APP] Dataset dimensions:" << dims[0] << "x" << dims[1];

        // **Read the full dataset (4096 samples × 12 leads)**
        std::vector<std::vector<double>> fullData(dims[0], std::vector<double>(dims[1]));
        dataset.read(fullData);
        qDebug() << "[EKG-APP] Successfully read dataset.";

        // **Initialize min/max values for each lead**
        double leadMin[12], leadMax[12];
        for (int i = 0; i < 12; i++) {
            leadMin[i] = std::numeric_limits<double>::max();
            leadMax[i] = std::numeric_limits<double>::lowest();
        }

        // **Extract each lead using 4096 × 12 loop**
        for (size_t i = 0; i < dims[0]; ++i) {  // Iterate over 4096 samples
            for (size_t lead = 0; lead < 12; ++lead) {  // Iterate over 12 leads
                double valueInMillivolts = fullData[i][lead]; // Convert to mV
                ekgGraphData[lead].append(valueInMillivolts);

                // Track min/max for each lead
                if (valueInMillivolts < leadMin[lead]) leadMin[lead] = valueInMillivolts;
                if (valueInMillivolts > leadMax[lead]) leadMax[lead] = valueInMillivolts;
            }
        }

        // Store min/max values in QVariantLists for QML
        for (int i = 0; i < 12; i++) {
            ekgLeadMin.append(leadMin[i]);
            ekgLeadMax.append(leadMax[i]);
            qDebug() << "[EKG-APP] Lead" << (i + 1) << "Min:" << leadMin[i] << "Max:" << leadMax[i];
        }

    } catch (const HighFive::Exception& e) {
        qDebug() << "[ERROR] HighFive Exception:" << e.what();
        return -1;
    } catch (const std::exception& e) {
        qDebug() << "[ERROR] Standard Exception:" << e.what();
        return -1;
    }

    // Expose all 12 leads to QML
    for (int i = 0; i < 12; i++) {
        engine.rootContext()->setContextProperty(QString("ekgLead%1").arg(i + 1), ekgGraphData[i]);
    }
    // Expose min/max values to QML
    engine.rootContext()->setContextProperty("ekgLeadMin", ekgLeadMin);
    engine.rootContext()->setContextProperty("ekgLeadMax", ekgLeadMax);

    qDebug() << "[EKG-APP] Loading QML UI...";
    engine.loadFromModule("ekg-app", "Main");  // ✅ Match with URI in CMakeLists.txt

    if (engine.rootObjects().isEmpty()) {
        qDebug() << "[ERROR] Failed to load QML UI.";
        return -1;
    }

    qDebug() << "[EKG-APP] Running application.";
    return app.exec();
}
