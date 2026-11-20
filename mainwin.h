#pragma once

#include <QPushButton>
#include <QWidget>

class QSettings;
class RangeSelector;
class Recorder;
class ChatBox;

class MainWin : public QWidget {
    Q_OBJECT
public:
    MainWin(QSettings *settings, QWidget *parent = nullptr);

    ~MainWin();

private:
    void initUI();

    RangeSelector *m_rangeSelector = nullptr;
    Recorder *m_recorder = nullptr;
    ChatBox *m_chatBox = nullptr;
    QSettings *m_settings = nullptr;

    QPushButton *m_btnClose = nullptr;
};
