#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QFile>
#include <QTextStream>
#include <QProcess>

QString Addresses_List[] = {"32'h0000_0000;","32'h0000_000A;","32'h0000_0014;","32'h0000_001E;","32'h0000_0028;","32'h0000_0032;","32'h0000_003C;","32'h0000_0046;"};

QString Forced_Address = "";

QString Extension = "";

QString Forced_REQ = "8'b1111_1111";

QString Forced_CBE = "4'b0110;";

QString Masters[4];
uint8_t MasterInd = 0;

QString Slaves [4];
uint8_t SlaveInd  = 0;

QTextEdit *REQ_Delays[4];
uint8_t DelayInd  = 0;

QTextEdit *Dt_no[4];
uint8_t Dt_noInd  = 0;

QComboBox *Operation[4];
uint8_t OpInd = 0;

QString TB_includes_defs = "`timescale 1ns / 1ps\n`include \"../../PCI.srcs/sources_1/new/PCI.v\"\n";

QString TB_beg = "module PCI_testB();\n\nreg [7:0] FORCED_REQ_N;\n\nreg [3:0] Forced_DataTfNo_A;\nreg [3:0] Forced_DataTfNo_B;\nreg [3:0] Forced_DataTfNo_C;\nreg [3:0] Forced_DataTfNo_D;\nreg [3:0] Forced_DataTfNo_E;\nreg [3:0] Forced_DataTfNo_F;\nreg [3:0] Forced_DataTfNo_G;\nreg [3:0] Forced_DataTfNo_H;\n\nreg [31:0] FORCED_ADDRESS_A;\nreg [31:0] FORCED_ADDRESS_B;\nreg [31:0] FORCED_ADDRESS_C;\nreg [31:0] FORCED_ADDRESS_D;\nreg [31:0] FORCED_ADDRESS_E;\nreg [31:0] FORCED_ADDRESS_F;\nreg [31:0] FORCED_ADDRESS_G;\nreg [31:0] FORCED_ADDRESS_H;\n\nreg [3:0] FORCED_CBE_N_A;\nreg [3:0] FORCED_CBE_N_B;\nreg [3:0] FORCED_CBE_N_C;\nreg [3:0] FORCED_CBE_N_D;\nreg [3:0] FORCED_CBE_N_E;\nreg [3:0] FORCED_CBE_N_F;\nreg [3:0] FORCED_CBE_N_G;\nreg [3:0] FORCED_CBE_N_H;\nreg CLK, RST_N, Forced_Frame, Forced_IRDY, Forced_TRDY;\nreg [1:0] mode;\ninteger i;\n";

QString TB_Fixed = "\ninitial\nbegin\n\t$dumpfile(\"Simulation.vcd\");\n\t$dumpvars(0,PCI_testB);\nend\ninitial\nbegin\n\tfor (i = 0; i < 160; i = i + 1)\n\tbegin\n\t\t#5 CLK = !CLK;\n\tend\n\t#2 $finish;\nend\nPCI pci(CLK, RST_N, FORCED_REQ_N, mode,Forced_Frame,Forced_IRDY, Forced_TRDY,FORCED_ADDRESS_A, FORCED_ADDRESS_B, FORCED_ADDRESS_C, FORCED_ADDRESS_D, FORCED_ADDRESS_E, FORCED_ADDRESS_F, FORCED_ADDRESS_G, FORCED_ADDRESS_H,FORCED_CBE_N_A, FORCED_CBE_N_B, FORCED_CBE_N_C, FORCED_CBE_N_D, FORCED_CBE_N_E, FORCED_CBE_N_F, FORCED_CBE_N_G, FORCED_CBE_N_H,Forced_DataTfNo_A, Forced_DataTfNo_B, Forced_DataTfNo_C, Forced_DataTfNo_D, Forced_DataTfNo_E, Forced_DataTfNo_F, Forced_DataTfNo_G, Forced_DataTfNo_H);\n\ninitial\nbegin\nCLK <= 1'b0;\nRST_N <= 1'b0;\nmode <= 2'b00;\n\nForced_Frame <= 1'b0;\nForced_IRDY <= 1'b0;\nForced_TRDY <= 1'b0;\n#10\nRST_N  <= 1;\n\n";

QString TB_Body[4] = {"","","",""};


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    ui->Mode1->addItem("Mode");
    ui->Mode1->addItem("Slave");
    ui->Mode1->addItem("Master");

    ui->Mode2->addItem("Mode");
    ui->Mode2->addItem("Slave");
    ui->Mode2->addItem("Master");

    ui->Mode3->addItem("Mode");
    ui->Mode3->addItem("Slave");
    ui->Mode3->addItem("Master");

    ui->Mode4->addItem("Mode");
    ui->Mode4->addItem("Slave");
    ui->Mode4->addItem("Master");

    ui->Mode5->addItem("Mode");
    ui->Mode5->addItem("Slave");
    ui->Mode5->addItem("Master");

    ui->Mode6->addItem("Mode");
    ui->Mode6->addItem("Slave");
    ui->Mode6->addItem("Master");

    ui->Mode7->addItem("Mode");
    ui->Mode7->addItem("Slave");
    ui->Mode7->addItem("Master");

    ui->Mode8->addItem("Mode");
    ui->Mode8->addItem("Slave");
    ui->Mode8->addItem("Master");

    ui->Operation1->addItem("Operation");
    ui->Operation1->addItem("Mem Write");
    ui->Operation1->addItem("Mem Read");

    ui->Operation2->addItem("Operation");
    ui->Operation2->addItem("Mem Write");
    ui->Operation2->addItem("Mem Read");

    ui->Operation3->addItem("Operation");
    ui->Operation3->addItem("Mem Write");
    ui->Operation3->addItem("Mem Read");

    ui->Operation4->addItem("Operation");
    ui->Operation4->addItem("Mem Write");
    ui->Operation4->addItem("Mem Read");

    ui->Operation5->addItem("Operation");
    ui->Operation5->addItem("Mem Write");
    ui->Operation5->addItem("Mem Read");

    ui->Operation6->addItem("Operation");
    ui->Operation6->addItem("Mem Write");
    ui->Operation6->addItem("Mem Read");

    ui->Operation7->addItem("Operation");
    ui->Operation7->addItem("Mem Write");
    ui->Operation7->addItem("Mem Read");

    ui->Operation8->addItem("Operation");
    ui->Operation8->addItem("Mem Write");
    ui->Operation8->addItem("Mem Read");

        connect(ui->Mode1, SIGNAL(activated(QString)), this, SLOT(Dev1(QString)));
        connect(ui->Mode2, SIGNAL(activated(QString)), this, SLOT(Dev2(QString)));
        connect(ui->Mode3, SIGNAL(activated(QString)), this, SLOT(Dev3(QString)));
        connect(ui->Mode4, SIGNAL(activated(QString)), this, SLOT(Dev4(QString)));
        connect(ui->Mode5, SIGNAL(activated(QString)), this, SLOT(Dev5(QString)));
        connect(ui->Mode6, SIGNAL(activated(QString)), this, SLOT(Dev6(QString)));
        connect(ui->Mode7, SIGNAL(activated(QString)), this, SLOT(Dev7(QString)));
        connect(ui->Mode8, SIGNAL(activated(QString)), this, SLOT(Dev8(QString)));
        connect(ui->Generate, SIGNAL(clicked(bool))  , this, SLOT(Drop()));
        connect(ui->WaveForm,SIGNAL(clicked(bool)), this, SLOT(Make()));

}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::Drop()
{
    ui->Label1->setText(Masters[0]);
    ui->Label2->setText(Masters[1]);
    ui->Label3->setText(Masters[2]);
    ui->Label4->setText(Masters[3]);

    ui->Label5->setText(Slaves[0]);
    ui->Label6->setText(Slaves[1]);
    ui->Label7->setText(Slaves[2]);
    ui->Label8->setText(Slaves[3]);

       for (int i = 0; i < MasterInd; i++)
       {
           if (Masters[i] == "Dev1")
           {
                Forced_REQ[11] = QString::number(Forced_REQ[0].unicode() & 0).at(0);
                Extension = "_A";
           }
           if(Masters[i] == "Dev2")
           {
                Forced_REQ[10] = QString::number(Forced_REQ[1].unicode() & 0).at(0);
                Extension = "_B";
           }
           if(Masters[i] == "Dev3")
           {
                Forced_REQ[9] = QString::number(Forced_REQ[2].unicode() & 0).at(0);
                Extension = "_C";
           }
           if(Masters[i] == "Dev4")
           {
                Forced_REQ[8] = QString::number(Forced_REQ[3].unicode() & 0).at(0);
                Extension = "_D";
           }
           if(Masters[i] == "Dev5")
           {
                Forced_REQ[6] = QString::number(Forced_REQ[4].unicode() & 0).at(0);
                Extension = "_E";
           }
           if(Masters[i] == "Dev6")
           {
                Forced_REQ[5] = QString::number(Forced_REQ[5].unicode() & 0).at(0);
                Extension = "_F";
           }
           if(Masters[i] == "Dev7")
           {
                Forced_REQ[4] = QString::number(Forced_REQ[6].unicode() & 0).at(0);
                Extension = "_G";
           }
           if(Masters[i] == "Dev8")
           {
                Forced_REQ[3] = QString::number(Forced_REQ[7].unicode() & 0).at(0);
                Extension = "_H";
           }


           if(Slaves[i] == "Dev1")
           {
                Forced_Address = Addresses_List[0];
           }
           if(Slaves[i] == "Dev2")
           {
                Forced_Address = Addresses_List[1];
           }
           if(Slaves[i] == "Dev3")
           {
                Forced_Address = Addresses_List[2];
           }
           if(Slaves[i] == "Dev4")
           {
                Forced_Address = Addresses_List[3];
           }
           if(Slaves[i] == "Dev5")
           {
                Forced_Address = Addresses_List[4];
           }
           if(Slaves[i] == "Dev6")
           {
                Forced_Address = Addresses_List[5];
           }
           if(Slaves[i] == "Dev7")
           {
                Forced_Address = Addresses_List[6];
           }
           if(Slaves[i] == "Dev8")
           {
                Forced_Address = Addresses_List[7];
           }


           if(Operation[i]->currentText() == "Mem Write")
           {
               Forced_CBE = "4'b0111;";
           }
           else if (Operation[i]->currentText() == "Mem Read")
           {
               Forced_CBE = "4'b0110;";
           }

            TB_Body[i] = "\n#" + REQ_Delays[i]->toPlainText() +";\nFORCED_REQ_N <= "  + Forced_REQ + ";\nFORCED_ADDRESS" + Extension + "<= "   + Forced_Address + "\nFORCED_CBE_N" + Extension + "<= "   + Forced_CBE + "\nForced_DataTfNo" + Extension + "<= "   + Dt_no[i]->toPlainText() + ";\n#20\n"+ "FORCED_CBE_N" + Extension + "<= "   + QString::number(0) + ";\n" + "FORCED_REQ_N <= 8'b1111_1111;\n" + "\n#"+ QString::number((20+(Dt_no[i]->toPlainText().toInt()*10)));
            Forced_REQ = "8'b1111_1111";
       }

       MasterInd = 0;
       SlaveInd  = 0;
       DelayInd  = 0;
       Dt_noInd  = 0;

       Forced_REQ = "8'b1111_1111";

       QFile file("/media/ubunzer/WINDOWS/Documents and Settings/Almonzer/Documents/3rdYear/CO/Projects/PCI/PCI_Repo/CO2018/PCI/Qt TB Generator/Generated Test Bench/test_bench.v");
       if (file.open(QIODevice::ReadWrite)) {
           file.resize(0);
           QTextStream stream(&file);
           stream << TB_includes_defs << TB_beg << TB_Fixed << TB_Body[0] << TB_Body[1] << TB_Body[2] << TB_Body[3] << "RST_N <= 0;\nend\nendmodule";
       }

}

void MainWindow::Make()
{
    Wave.setWorkingDirectory("/media/ubunzer/WINDOWS/Documents and Settings/Almonzer/Documents/3rdYear/CO/Projects/PCI/PCI_Repo/CO2018/PCI/Qt TB Generator/Generated Test Bench");
    Wave.start("make",QStringList()<< "all");
    Wave.waitForStarted();
    Wave.waitForFinished();
}

void MainWindow::Dev1(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev1";
        MasterInd++;

        ui->Time1->show();
        ui->DtNo1->show();
        ui->Operation1->show();

        REQ_Delays[DelayInd] = ui->Time1;
        DelayInd++;

        Dt_no[Dt_noInd] = ui->DtNo1;
        Dt_noInd++;

        Operation[OpInd] = ui->Operation1;
        OpInd++;
    }
    else if (MODE == "Slave"){
        Slaves[SlaveInd] = "Dev1";
        SlaveInd++;

        ui->Time1->hide();
        ui->DtNo1->hide();
        ui->Operation1->hide();
    }

}
void MainWindow::Dev2(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev2";
        MasterInd++;

        ui->Time2->show();
        ui->DtNo2->show();
        ui->Operation2->show();

        REQ_Delays[DelayInd] = ui->Time2;
        DelayInd++;

        Dt_no[Dt_noInd] = ui->DtNo2;
        Dt_noInd++;

        Operation[OpInd] = ui->Operation2;
        OpInd++;
    }
    else if (MODE == "Slave"){
        Slaves[SlaveInd] = "Dev2";
        SlaveInd++;

        ui->Time2->hide();
        ui->DtNo2->hide();
        ui->Operation2->hide();
    }
}
void MainWindow::Dev3(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev3";
        MasterInd++;

        ui->Time3->show();
        ui->DtNo3->show();
        ui->Operation3->show();

        REQ_Delays[DelayInd] = ui->Time3;
        DelayInd++;

        Dt_no[Dt_noInd] = ui->DtNo3;
        Dt_noInd++;

        Operation[OpInd] = ui->Operation3;
        OpInd++;
    }
    else if (MODE == "Slave"){
        Slaves[SlaveInd] = "Dev3";
        SlaveInd++;

        ui->Time3->hide();
        ui->DtNo3->hide();
        ui->Operation3->hide();

    }
}
void MainWindow::Dev4(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev4";
        MasterInd++;

        ui->Time4->show();
        ui->DtNo4->show();
        ui->Operation4->show();

        REQ_Delays[DelayInd] = ui->Time4;
        DelayInd++;

        Dt_no[Dt_noInd] = ui->DtNo4;
        Dt_noInd++;

        Operation[OpInd] = ui->Operation4;
        OpInd++;
    }
    else if (MODE == "Slave"){
        Slaves[SlaveInd] = "Dev4";
        SlaveInd++;

        ui->Time4->hide();
        ui->DtNo4->hide();
        ui->Operation4->hide();

    }
}
void MainWindow::Dev5(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev5";
        MasterInd++;

        ui->Time5->show();
        ui->DtNo5->show();
        ui->Operation5->show();

        REQ_Delays[DelayInd] = ui->Time5;
        DelayInd++;

        Dt_no[Dt_noInd] = ui->DtNo5;
        Dt_noInd++;

        Operation[OpInd] = ui->Operation5;
        OpInd++;
    }
    else if (MODE == "Slave"){
        Slaves[SlaveInd] = "Dev5";
        SlaveInd++;

        ui->Time5->hide();
        ui->DtNo5->hide();
        ui->Operation5->hide();

    }
}
void MainWindow::Dev6(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev6";
        MasterInd++;

        ui->Time6->show();
        ui->DtNo6->show();
        ui->Operation6->show();

        REQ_Delays[DelayInd] = ui->Time6;
        DelayInd++;

        Dt_no[Dt_noInd] = ui->DtNo6;
        Dt_noInd++;

        Operation[OpInd] = ui->Operation6;
        OpInd++;
    }
    else if (MODE == "Slave"){
        Slaves[SlaveInd] = "Dev6";
        SlaveInd++;

        ui->Time6->hide();
        ui->DtNo6->hide();
        ui->Operation6->hide();

    }
}
void MainWindow::Dev7(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev7";
        MasterInd++;

        ui->Time7->show();
        ui->DtNo7->show();
        ui->Operation7->show();

        REQ_Delays[DelayInd] = ui->Time7;
        DelayInd++;

        Dt_no[Dt_noInd] = ui->DtNo7;
        Dt_noInd++;

        Operation[OpInd] = ui->Operation7;
        OpInd++;
    }
    else if (MODE == "Slave"){
        Slaves[SlaveInd] = "Dev7";
        SlaveInd++;

        ui->Time7->hide();
        ui->DtNo7->hide();
        ui->Operation7->hide();

    }
}
void MainWindow::Dev8(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev8";
        MasterInd++;

        ui->Time8->show();
        ui->DtNo8->show();
        ui->Operation8->show();

        REQ_Delays[DelayInd] = ui->Time8;
        DelayInd++;

        Dt_no[Dt_noInd] = ui->DtNo8;
        Dt_noInd++;

        Operation[OpInd] = ui->Operation8;
        OpInd++;
    }
    else if (MODE == "Slave"){
        Slaves[SlaveInd] = "Dev8";
        SlaveInd++;

        ui->Time8->hide();
        ui->DtNo8->hide();
        ui->Operation8->hide();

    }
}

