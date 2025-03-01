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
    QVariantList ekgGraphData; // Store first lead data for QML
    double minValue = std::numeric_limits<double>::max();
    double maxValue = std::numeric_limits<double>::lowest();

    try {
        qDebug() << "[EKG-APP] Opening HDF5 file...";
        HighFive::File file(filePath.toStdString(), HighFive::File::ReadOnly);
        qDebug() << "[EKG-APP] HDF5 file opened successfully.";

        // List all datasets/groups in the file
        auto groups = file.listObjectNames();
        qDebug() << "[EKG-APP] Found datasets/groups:";
        for (const auto& group : groups) {
            qDebug() << "  -" << QString::fromStdString(group);
        }

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

        // Read the full dataset (4096 samples × 12 leads)
        std::vector<std::vector<double>> fullData(dims[0], std::vector<double>(dims[1]));
        dataset.read(fullData);
        qDebug() << "[EKG-APP] Successfully read dataset.";

        // Extract first lead (column 0) and track min/max values
        for (size_t i = 0; i < dims[0]; ++i) {
            double valueInMillivolts = fullData[i][0] * 1000.0; // Convert to mV
            ekgGraphData.append(valueInMillivolts);

            minValue = std::min(minValue, valueInMillivolts);
            maxValue = std::max(maxValue, valueInMillivolts);
        }

        qDebug() << "[EKG-APP] First lead data processed.";
        qDebug() << "[EKG-APP] Data points:" << ekgGraphData.size();
        qDebug() << "[EKG-APP] Min (mV):" << minValue << "| Max (mV):" << maxValue;

    } catch (const HighFive::Exception& e) {
        qDebug() << "[ERROR] HighFive Exception:" << e.what();
        return -1;
    } catch (const std::exception& e) {
        qDebug() << "[ERROR] Standard Exception:" << e.what();
        return -1;
    }

    // Expose processed data to QML
    engine.rootContext()->setContextProperty("ekgGraphData", ekgGraphData);

    qDebug() << "[EKG-APP] Loading QML UI...";
    engine.loadFromModule("ekg-app", "Main");  // ✅ Match with URI in CMakeLists.txt

    if (engine.rootObjects().isEmpty()) {
        qDebug() << "[ERROR] Failed to load QML UI.";
        return -1;
    }


    qDebug() << "[EKG-APP] Running application.";
    return app.exec();
}
