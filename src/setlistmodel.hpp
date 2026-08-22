#pragma once

#include <QAbstractListModel>
#include <QUrl>
#include <QVector>

class SetlistModel : public QAbstractListModel {
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

   public:
    enum ItemType { PdfPage = 0, Image = 1, Black = 2 };
    Q_ENUM(ItemType)

    enum Roles { TypeRole = Qt::UserRole + 1, SourceRole, PageRole, DisplayNameRole };

    explicit SetlistModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = {}) const override;

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addFile(const QUrl& url);
    Q_INVOKABLE void addPdfPages(const QUrl& url);
    Q_INVOKABLE void addImage(const QUrl& url);

    Q_INVOKABLE void addBlack();
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE void move(int from, int to);
    Q_INVOKABLE void clear();

    Q_INVOKABLE bool save(const QUrl& url) const;
    Q_INVOKABLE bool load(const QUrl& url);

    Q_INVOKABLE QVariantMap itemAt(int index) const;

   signals:
    void countChanged();

   private:
    struct Item {
        ItemType type;
        QUrl source;
        int page = -1;
        QString displayName;
    };

    QVector<Item> m_items;

    bool isImageFile(const QString& path) const;
    bool isPdfFile(const QString& path) const;
};
