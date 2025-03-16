#include "ecgloader.h"


ECGLoader::ECGLoader(QQmlApplicationEngine *engine, QObject *parent)
    : QObject(parent), qmlEngine(engine) {}

void ECGLoader::readECGData() {
    qDebug() << "[ECGLoader] Starting readECGData()";

    QString filePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/first_patient_data.hdf5";
    qDebug() << "[ECGLoader] File path:" << filePath;

    if (!QFile::exists(filePath)) {
        qDebug() << "[ECGLoader ERROR] HDF5 file not found at:" << filePath;
        return;
    }

    try {
        qDebug() << "[ECGLoader] Opening HDF5 file...";
        HighFive::File file(filePath.toStdString(), HighFive::File::ReadOnly);
        qDebug() << "[ECGLoader] HDF5 file opened successfully.";

        if (!file.exist("first_patient")) {
            qDebug() << "[ECGLoader ERROR] Dataset 'first_patient' not found.";
            return;
        }

        HighFive::DataSet dataset = file.getDataSet("first_patient");
        std::vector<size_t> dims = dataset.getDimensions();

        if (dims.size() != 2 || dims[1] != 12) {
            qDebug() << "[ECGLoader ERROR] Invalid dataset dimensions: " << dims;
            return;
        }

        std::vector<std::vector<double>> fullData(dims[0], std::vector<double>(dims[1]));
        dataset.read(fullData);
        qDebug() << "[ECGLoader] Successfully read dataset.";

        // ✅ Clear previous data
        for (int i = 0; i < 12; i++) {
            ekgLeads[i].clear();
        }
        ekgLeadMin.clear();
        ekgLeadMax.clear();

        // ✅ Initialize min/max values
        double leadMin[12], leadMax[12];
        for (int i = 0; i < 12; i++) {
            leadMin[i] = std::numeric_limits<double>::max();
            leadMax[i] = std::numeric_limits<double>::lowest();
        }

        // ✅ Populate lead data
        for (size_t i = 0; i < dims[0]; ++i) {
            for (size_t lead = 0; lead < 12; ++lead) {
                double valueInMillivolts = fullData[i][lead];
                ekgLeads[lead].append(valueInMillivolts);

                // Track min/max for each lead
                if (valueInMillivolts < leadMin[lead]) leadMin[lead] = valueInMillivolts;
                if (valueInMillivolts > leadMax[lead]) leadMax[lead] = valueInMillivolts;
            }
        }

        // ✅ Store min/max values in QVariantLists for QML
        for (int i = 0; i < 12; i++) {
            ekgLeadMin.append(leadMin[i]);
            ekgLeadMax.append(leadMax[i]);
            qDebug() << "[ECGLoader] Lead" << (i + 1) << "Min:" << leadMin[i] << "Max:" << leadMax[i];
        }

        // ✅ Expose all leads to QML after data is loaded
        for (int i = 0; i < 12; i++) {
            qmlEngine->rootContext()->setContextProperty(QString("ekgLead%1").arg(i + 1),
                                                         QVariant::fromValue(ekgLeads[i]));
        }

        qmlEngine->rootContext()->setContextProperty("ekgLeadMin", QVariant::fromValue(ekgLeadMin));
        qmlEngine->rootContext()->setContextProperty("ekgLeadMax", QVariant::fromValue(ekgLeadMax));

        qDebug() << "[ECGLoader] ECG Data Loaded! Emitting signal...";
        emit ecgDataLoaded();  // ✅ Notify QML

    } catch (const HighFive::Exception& e) {
        qDebug() << "[ECGLoader ERROR] HighFive Exception: " << e.what();
        return;
    } catch (const std::exception& e) {
        qDebug() << "[ECGLoader ERROR] Standard Exception: " << e.what();
        return;
    }
}
