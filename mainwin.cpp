#include "mainwin.h"

#include <QDebug>
#include <QSettings>

MainWin::MainWin(QSettings *settings, QWidget *parent)
    : QWidget(parent), m_settings(settings) {
    initUI();

    qDebug() << "MainWin constructor";
}

MainWin::~MainWin() {
}

void MainWin::initUI() {
    setWindowTitle("Mini Push All");
    setGeometry(100, 100, 800, 600);

    this->setWindowFlags(Qt::WindowCloseButtonHint | Qt::WindowMinimizeButtonHint);

    m_btnClose = new QPushButton("Close", this);
    m_btnClose->move(10, 10);
    connect(m_btnClose, &QPushButton::clicked, this, &MainWin::close);
}
