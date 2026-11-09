#include <QApplication>
#include <QDebug>
#include <QFile>
#include <QString>
#include <QJsonObject>
#include <QWebEngineSettings>
#include <QStandardPaths>
#include <QScreen>
#include <QDir>
#include <QMessageBox>

#include "mainwin.h"


MainWin::MainWin(QWidget *parent, QSettings *settings)  : QWidget(parent),  m_settings(settings) {
    initUI();

    qDebug() << "MainWin constructor";
}

MainWin::~MainWin() {
}

MainWin::initUI() {
    setWindowTitle("Mini Push All");
    setGeometry(100, 100, 800, 600);

    this->setWindowFlags(Qt::WindowCloseButtonHint | Qt::WindowMinimizeButtonHint);

    m_btnClose = new QPushButton("Close", this);
    m_btnClose->move(10, 10);
    connect(m_btnClose, &QPushButton::clicked, this, &MainWin::close);
}

