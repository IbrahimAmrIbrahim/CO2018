#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

public slots:
    void Dev1(QString);
    void Dev2(QString);
    void Dev3(QString);
    void Dev4(QString);
    void Dev5(QString);
    void Dev6(QString);
    void Dev7(QString);
    void Dev8(QString);
    void Drop();
private:
    Ui::MainWindow *ui;
};

#endif // MAINWINDOW_H
