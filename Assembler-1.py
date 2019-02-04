import sys
from PyQt4 import QtGui, QtCore
import subprocess


class Window(QtGui.QMainWindow):


    def __init__(self):
        super(Window, self).__init__()
        self.setGeometry(50, 50, 500, 300)
        self.setWindowTitle("Assembler")
        self.setWindowIcon(QtGui.QIcon('favicon.png'))

        extractAction = QtGui.QAction("&Quit", self)
        extractAction.setShortcut("Ctrl+Q")
        extractAction.setStatusTip('Leave The App')
        extractAction.triggered.connect(self.close_application)
        openFile = QtGui.QAction("&Open File", self)
        openFile.setShortcut("Ctrl+O")
        openFile.setStatusTip('Open File')
        openFile.triggered.connect(self.file_open)

        self.statusBar()

        mainMenu = self.menuBar()
        fileMenu = mainMenu.addMenu('&File')

        fileMenu.addAction(openFile)
        fileMenu.addAction(extractAction)

        self.home()


    def file_open(self):
        name = QtGui.QFileDialog.getOpenFileName(self, 'Open File')
        file = open(name, 'r')
        self.Assembly_try(file)


    def home(self):
        btn = QtGui.QPushButton("Quit", self)
        btn.clicked.connect(self.close_application)
        btn.resize(btn.minimumSizeHint())
        btn.move(0, 100)
        extractAction = QtGui.QAction(QtGui.QIcon('todachoppa.png'), 'Flee the Scene', self)
        extractAction.triggered.connect(self.close_application)

        self.toolBar = self.addToolBar("EXIT")
        self.toolBar.addAction(extractAction)

        checkBox = QtGui.QCheckBox('Shrink Window', self)
        checkBox.move(100, 25)
        checkBox.stateChanged.connect(self.enlarge_window)

        self.progress = QtGui.QProgressBar(self)
        self.progress.setGeometry(200, 80, 250, 20)

        self.btn = QtGui.QPushButton("Open File", self)
        self.btn.move(200, 120)
        self.btn.clicked.connect(self.download)

        QtGui.QApplication.setStyle(QtGui.QStyleFactory.create("Cleanlooks"))
        self.show()

    def Assembly_try(self, file):
        first_state = []
        second_state = []
        third_state = []
        array = {}
        Data = {}
        output = 0
        x = file.read()
        for line in file.read():
            array[line] = file.readlines()
            Data.append(line.split(' ', 1)[0])
        file.close()
        HOLD = open('textfile.txt', 'w')

        def assembly(value):
            if value == '$t0':
                donno = '01000'
            elif value == '$t1':
                donno = '01001'
            elif value == '$t2':
                donno = '01010'
            elif value == '$t3':
                donno = '01011'
            elif value == '$t4':
                donno = '01100'
            elif value == '$t5':
                donno = '01101'
            elif value == '$t6':
                donno = '01110'
            elif value == '$t7':
                donno = '01111'
            elif value == '$s0':
                donno = '10000'
            elif value == '$s1':
                donno = '10001'
            elif value == '$s2':
                donno = '10010'
            elif value == '$s3':
                donno = '10011'
            elif value == '$s4':
                donno = '10100'
            elif value == '$s5':
                donno = '10101'
            elif value == '$s6':
                donno = '10110'
            else:
                donno = '10111'
            return donno

        # test_lines = file.readlines()
        for line1 in Data:
            if   Data[line1] == 'add':
                output = '000000'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100000'

            elif Data[line1] == 'sub':
                output = '000000'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100010'

            elif Data[line1] == 'and':
                output = '000000'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100100'

            elif Data[line1] == 'or':
                output = '000000'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100101'

            elif Data[line1] == 'nor':
                output = '000000'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100111'

            elif Data[line1] == 'slt':
                output = '000000'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000101010'

            elif Data[line1] == 'addi':
                output = '001000'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'andi':
                output = '001100'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'ori':
                output = '001101'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'slti':
                output = '001010'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'lui':
                output = '001111'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'lw':
                output = '100011'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'lh':
                output = '100001'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'lb':
                output = '100000'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'sw':
                output = '101011'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'sh':
                output = '101001'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'sb':
                output = '101000'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            elif Data[line1] == 'j':
                output = '000010'
                third_state = array.partition(' ')[2:]
                third_state = int(third_state)
                bin_ = '{0:026b}'.format(third_state)
                output = output + bin_

            elif Data[line1] == 'jal':
                output = '000011'
                third_state = array.partition(' ')[2:]
                third_state = int(third_state)
                bin_ = '{0:026b}'.format(third_state)
                output = output + bin_

                # not complete , check those two


            elif Data[line1] == 'beq':
                output = '000100'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            else:
                output = '000101'
                first_state = array.partition(' ')[2:4]
                second_state = array.partition(' ')[6:8]
                third_state = array.partition(' ')[10:12]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_

            HOLD.write(output)

        HOLD.close()
        return HOLD


    def download(self):
        self.completed = 30
        self.file_open()

        while self.completed < 100:
            self.completed += 0.01
            self.progress.setValue(self.completed)


    def enlarge_window(self, state):
        if state == QtCore.Qt.Checked:
            self.setGeometry(50, 50, 1000, 600)
        else:
            self.setGeometry(50, 50, 500, 300)


    def close_application(self):
        choice = QtGui.QMessageBox.question(self, 'EXIT',
                                            "Are You Sure to Exit?",
                                            QtGui.QMessageBox.Yes | QtGui.QMessageBox.No)
        if choice == QtGui.QMessageBox.Yes:
            print("Extracting Naaaaaaoooww!!!!")
            sys.exit()
        else:
            pass


def run():
    app = QtGui.QApplication(sys.argv)
    GUI = Window()
    sys.exit(app.exec_())

run()