#include "setlistmodel.hpp"

#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QPdfDocument>

SetlistModel::SetlistModel(QObject* parent) : QAbstractListModel(parent) {}

int SetlistModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;

    return m_items.size();
}

QVariant SetlistModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size()) {
        return {};
    }

    const Item& item = m_items.at(index.row());

    switch (role) {
        case TypeRole:
            return item.type;

        case SourceRole:
            return item.source;

        case PageRole:
            return item.page;

        case DisplayNameRole:
            return item.displayName;

        default:
            return {};
    }
}

QHash<int, QByteArray> SetlistModel::roleNames() const {
    return {{TypeRole, "itemType"}, {SourceRole, "source"}, {PageRole, "page"}, {DisplayNameRole, "displayName"}};
}

bool SetlistModel::isPdfFile(const QString& path) const {
    return QFileInfo(path).suffix().compare(QStringLiteral("pdf"), Qt::CaseInsensitive) == 0;
}

bool SetlistModel::isImageFile(const QString& path) const {
    const QString suffix = QFileInfo(path).suffix().toLower();

    return suffix == "png" || suffix == "jpg" || suffix == "jpeg" || suffix == "webp" || suffix == "bmp" ||
           suffix == "gif";
}

void SetlistModel::addFile(const QUrl& url) {
    const QString path = url.toLocalFile();

    if (isPdfFile(path)) {
        addPdfPages(url);
    } else if (isImageFile(path)) {
        addImage(url);
    }
}

void SetlistModel::addPdfPages(const QUrl& url) {
    const QString path = url.toLocalFile();

    QPdfDocument document;

    if (document.load(path) != QPdfDocument::Error::None) {
        return;
    }

    const int pages = document.pageCount();

    if (pages <= 0) {
        return;
    }

    const QFileInfo info(path);

    beginInsertRows({}, m_items.size(), m_items.size() + pages - 1);

    for (int page = 0; page < pages; ++page) {
        Item item;

        item.type   = PdfPage;
        item.source = url;
        item.page   = page;

        item.displayName = QStringLiteral("%1 — page %2").arg(info.fileName()).arg(page + 1);

        m_items.append(item);
    }

    endInsertRows();

    emit countChanged();
}

void SetlistModel::addImage(const QUrl& url) {
    const QFileInfo info(url.toLocalFile());

    const int row = m_items.size();

    beginInsertRows({}, row, row);

    Item item;

    item.type        = Image;
    item.source      = url;
    item.page        = -1;
    item.displayName = info.fileName();

    m_items.append(item);

    endInsertRows();

    emit countChanged();
}

void SetlistModel::addBlack() {
    const int row = m_items.size();

    beginInsertRows({}, row, row);

    Item item;

    item.type        = Black;
    item.page        = -1;
    item.displayName = QStringLiteral("Black frame");

    m_items.append(item);

    endInsertRows();

    emit countChanged();
}

void SetlistModel::remove(int index) {
    if (index < 0 || index >= m_items.size()) {
        return;
    }

    beginRemoveRows({}, index, index);
    m_items.removeAt(index);
    endRemoveRows();

    emit countChanged();
}

void SetlistModel::move(int from, int to) {
    if (from < 0 || from >= m_items.size() || to < 0 || to >= m_items.size() || from == to) {
        return;
    }

    /*
     * Qt's destination index is expressed relative to the
     * model before the move. When moving downward, the
     * destination therefore needs to be one past the
     * requested final position.
     */
    const int destination = (from < to) ? to + 1 : to;

    beginMoveRows({}, from, from, {}, destination);

    m_items.move(from, to);

    endMoveRows();
}

void SetlistModel::clear() {
    if (m_items.isEmpty()) {
        return;
    }

    beginResetModel();
    m_items.clear();
    endResetModel();

    emit countChanged();
}

bool SetlistModel::save(const QUrl& url) const {
    const QString path = url.toLocalFile();

    if (path.isEmpty()) return false;

    QJsonArray items;

    for (const Item& item : m_items) {
        QJsonObject object;

        object["type"]        = static_cast<int>(item.type);
        object["source"]      = item.source.toString();
        object["page"]        = item.page;
        object["displayName"] = item.displayName;

        items.append(object);
    }

    QJsonObject root;
    root["version"] = 1;
    root["items"]   = items;

    QFile file(path);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) return false;

    const QJsonDocument document(root);

    file.write(document.toJson(QJsonDocument::Indented));

    return true;
}

bool SetlistModel::load(const QUrl& url) {
    const QString path = url.toLocalFile();

    if (path.isEmpty()) return false;

    QFile file(path);

    if (!file.open(QIODevice::ReadOnly)) return false;

    QJsonParseError error;
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &error);

    if (error.error != QJsonParseError::NoError) return false;

    if (!document.isObject()) return false;

    const QJsonObject root = document.object();

    if (root["version"].toInt() != 1) return false;

    const QJsonArray items = root["items"].toArray();

    QVector<Item> newItems;

    for (const QJsonValue& value : items) {
        if (!value.isObject()) return false;

        const QJsonObject object = value.toObject();

        const int type = object["type"].toInt(-1);

        if (type < PdfPage || type > Black) return false;

        Item item;

        item.type        = static_cast<ItemType>(type);
        item.source      = QUrl(object["source"].toString());
        item.page        = object["page"].toInt(-1);
        item.displayName = object["displayName"].toString();

        newItems.append(item);
    }

    beginResetModel();
    m_items = std::move(newItems);
    endResetModel();

    emit countChanged();

    return true;
}

QVariantMap SetlistModel::itemAt(int index) const {
    QVariantMap result;

    if (index < 0 || index >= m_items.size()) return result;

    const Item& item = m_items.at(index);

    result["type"]        = item.type;
    result["source"]      = item.source;
    result["page"]        = item.page;
    result["displayName"] = item.displayName;

    return result;
}
