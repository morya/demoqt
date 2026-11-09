#pragma once

#include <QWidget>


class MainWin : public QWidget {
    Q_OBJECT
public:
    MainWin(QWidget *parent, QSettings *settings);

    ~MainWin();

private:
    void initUI();

    RangeSelector *m_rangeSelector;
    Recorder *m_recorder;
    ChatBox *m_chatBox;
    QSettings *m_settings;

    QPushButton *m_btnClose;
};
