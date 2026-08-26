#include "sleepinhibitor.hpp"

#ifdef Q_OS_LINUX
#include <KSystemInhibitor>
#endif

#include <QWindow>
#include <QtGlobal>

SleepInhibitor::SleepInhibitor(QObject* parent) : QObject(parent) {}

bool SleepInhibitor::active() const { return m_active; }

void SleepInhibitor::setActive(bool active) {
    if (m_active == active) {
        return;
    }

    m_active = active;

#ifdef Q_OS_LINUX
    if (m_active) {
        m_inhibitor = std::make_unique<KSystemInhibitor>(QStringLiteral("Displaying a setlist"),
                                                         KSystemInhibitor::Type::Idle, nullptr, this);
    } else {
        m_inhibitor.reset();
    }
#endif

    emit activeChanged();
}
