#pragma once

#include <qqml.h>

#include <QObject>
#include <QtGlobal>

#ifdef Q_OS_LINUX
#include <KSystemInhibitor>
#include <memory>
#endif

class SleepInhibitor : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)

   public:
    explicit SleepInhibitor(QObject* parent = nullptr);

    bool active() const;
    void setActive(bool active);

   signals:
    void activeChanged();

   private:
    bool m_active = false;
#ifdef Q_OS_LINUX
    std::unique_ptr<KSystemInhibitor> m_inhibitor = nullptr;
#endif
};
