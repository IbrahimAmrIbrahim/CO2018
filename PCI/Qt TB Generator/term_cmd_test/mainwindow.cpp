#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QFile>
#include <QTextStream>

QString Addresses_List[] = {"32'h0000_0000;","32'h0000_000A;","32'h0000_0014;","32'h0000_001E;","32'h0000_0028;","32'h0000_0032;","32'h0000_003C;","32'h0000_0046;"};
//QString Addresses_List[] = {"A","B","C","D","E","F","G","H"};

QString Forced_Adresses[] = {"QW","ER","AS","ZX"};
QString Forced_Address = "";

QString Forced_REQuests[4];
QString Forced_REQ = "8'b1111_1111";

QString Forced_CBE = "4'b0110;";

QString Masters[4];
uint8_t MasterInd = 0;

QString Slaves [4];
uint8_t SlaveInd  = 0;

QTextEdit *REQ_Delays[4];
uint8_t DelayInd  = 0;

QString All = "Dev";

QTextEdit *Dt_no[4];
uint8_t Dt_noInd  = 0;

QComboBox *Operation[4];
uint8_t OpInd = 0;

QString TB_includes_defs = "`timescale 1ns / 1ps\n`include \"../../CO2018/PCI/PCI.srcs/sources_1/new/PCI.v\"\n module PCI_tb();\nreg [7:0] FORCED_REQ_N;\nreg [31:0] FORCED_ADDRESS;\nreg [3:0] FORCED_CBE_N;\nreg [3:0] Forced_DataTfNo;\nreg CLK, RST_N;\ninteger i = 0;";
QString TB_beg = "\ninitial\nbegin\nCLK <= 0;\nRST_N <= 0;\n#12\nRST_N  <= 1;";
QString TB_Fixed = "\ninitial\nbegin\n\t$dumpfile(\"Simulation.vcd\");\n\t$dumpvars(0,PCI_tb);\nend\ninitial\nbegin\n\tfor (i = 0; i < 160; i = i + 1)\n\tbegin\n\t\t#5 CLK = !CLK;\n\tend\n\t#2 $finish;\nend\nPCI pci(CLK, RST_N, FORCED_REQ_N, mode,FORCED_ADDRESS_A, FORCED_ADDRESS_B, FORCED_ADDRESS_C, FORCED_ADDRESS_D, FORCED_ADDRESS_E, FORCED_ADDRESS_F, FORCED_ADDRESS_G, FORCED_ADDRESS_H,FORCED_CBE_N_A, FORCED_CBE_N_B, FORCED_CBE_N_C, FORCED_CBE_N_D, FORCED_CBE_N_E, FORCED_CBE_N_F, FORCED_CBE_N_G, FORCED_CBE_N_H,	Forced_DataTfNo_A, Forced_DataTfNo_B, Forced_DataTfNo_C, Forced_DataTfNo_D, Forced_DataTfNo_E, Forced_DataTfNo_F, Forced_DataTfNo_G, Forced_DataTfNo_H);";
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
           }
           if(Masters[i] == "Dev2")
           {
                Forced_REQ[10] = QString::number(Forced_REQ[1].unicode() & 0).at(0);
           }
           if(Masters[i] == "Dev3")
           {
                Forced_REQ[9] = QString::number(Forced_REQ[2].unicode() & 0).at(0);
           }
           if(Masters[i] == "Dev4")
           {
                Forced_REQ[8] = QString::number(Forced_REQ[3].unicode() & 0).at(0);
           }
           if(Masters[i] == "Dev5")
           {
                Forced_REQ[6] = QString::number(Forced_REQ[4].unicode() & 0).at(0);
           }
           if(Masters[i] == "Dev6")
           {
                Forced_REQ[5] = QString::number(Forced_REQ[5].unicode() & 0).at(0);
           }
           if(Masters[i] == "Dev7")
           {
                Forced_REQ[4] = QString::number(Forced_REQ[6].unicode() & 0).at(0);
           }
           if(Masters[i] == "Dev8")
           {
                Forced_REQ[3] = QString::number(Forced_REQ[7].unicode() & 0).at(0);
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

            TB_Body[i] = "\n#" + REQ_Delays[i]->toPlainText() +";\nFORCED_REQ_N <= " + Forced_REQ + ";\nFORCED_ADDRESS <= " + Forced_Address + "\nFORCED_CBE_N <= " + Forced_CBE + "\nForced_DataTfNo <= " + Dt_no[i]->toPlainText() + ";\n";
            Forced_REQ = "8'b1111_1111";
       }

       MasterInd = 0;
       SlaveInd  = 0;
       DelayInd  = 0;
       Dt_noInd  = 0;
       Forced_REQ = "8'b1111_1111";
       QFile file("/home/ubunzer/Documents/Qt term cmd test/File.v");
       if (file.open(QIODevice::ReadWrite)) {
           file.resize(0);
           QTextStream stream(&file);
           stream << TB_includes_defs << TB_Fixed << TB_beg << TB_Body[0] << TB_Body[1] << TB_Body[2] << TB_Body[3] << "end\nendmodule";
       }

}

void MainWindow::Dev1(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev1";
        MasterInd++;

        ui->Time1->show();
        ui->DtNo1->show();

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
    }

}
void MainWindow::Dev2(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev2";
        MasterInd++;

        ui->Time2->show();
        ui->DtNo2->show();

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
    }
}
void MainWindow::Dev3(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev3";
        MasterInd++;

        ui->Time3->show();
        ui->DtNo3->show();

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

    }
}
void MainWindow::Dev4(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev4";
        MasterInd++;

        ui->Time4->show();
        ui->DtNo4->show();

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

    }
}
void MainWindow::Dev5(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev5";
        MasterInd++;

        ui->Time5->show();
        ui->DtNo5->show();

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

    }
}
void MainWindow::Dev6(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev6";
        MasterInd++;

        ui->Time6->show();
        ui->DtNo6->show();

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

    }
}
void MainWindow::Dev7(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev7";
        MasterInd++;

        ui->Time7->show();
        ui->DtNo7->show();

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

    }
}
void MainWindow::Dev8(QString MODE){

    if (MODE == "Master"){
        Masters[MasterInd] = "Dev8";
        MasterInd++;

        ui->Time8->show();
        ui->DtNo8->show();

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

    }
}

