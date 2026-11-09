#include <QApplication>
#include <QDialog>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QSettings>
#include <QVBoxLayout>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QSettings settings("gouboyun-morya", "demoqt");

    QDialog dialog;
    dialog.setWindowTitle(QStringLiteral("demo-settings"));

    auto *label = new QLabel(QStringLiteral("当前登录URL:"), &dialog);
    auto *loginUrlEdit = new QLineEdit(&dialog);
    // 启动时从 QSettings 读取 loginUrl，回填到输入框
    loginUrlEdit->setText(settings.value(QStringLiteral("loginUrl")).toString());

    auto *saveButton = new QPushButton(QStringLiteral("Save"), &dialog);
    auto *cancelButton = new QPushButton(QStringLiteral("Cancel"), &dialog);

    auto *buttonLayout = new QHBoxLayout;
    buttonLayout->addStretch();
    buttonLayout->addWidget(saveButton);
    buttonLayout->addWidget(cancelButton);

    auto *mainLayout = new QVBoxLayout(&dialog);
    mainLayout->addWidget(label);
    mainLayout->addWidget(loginUrlEdit);
    mainLayout->addLayout(buttonLayout);

    // Save：将输入框内容写入 QSettings 键值 loginUrl
    QObject::connect(saveButton, &QPushButton::clicked, [&settings, loginUrlEdit] {
        settings.setValue(QStringLiteral("loginUrl"), loginUrlEdit->text());
        settings.sync();
    });
    // Cancel：关闭程序
    QObject::connect(cancelButton, &QPushButton::clicked, &dialog, &QDialog::reject);

    return dialog.exec();
}
