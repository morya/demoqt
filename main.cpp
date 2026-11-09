#include <QApplication>
#include <QDialog>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QSettings>
#include <QVBoxLayout>

#include "mainwin.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QSettings settings("gouboyun-morya", "demoqt");
    MainWin mainWin(&settings);
    mainWin.show();
    
    return app.exec();
}
