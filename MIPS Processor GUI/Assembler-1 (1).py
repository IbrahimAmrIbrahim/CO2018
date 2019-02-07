import sys

from PyQt4 import QtGui, QtCore
import subprocess


class Window(QtGui.QMainWindow):                               # dh class 7att feh l 7aga


    def __init__(self):                                     # dh l initial function ly b3rf feha 4oiet 7agat lzom l interface
        super(Window, self).__init__()
        self.setGeometry(50, 50, 500, 300)                       # b3ml set ll geometry w l 4a4a httl3 fen
        self.setWindowTitle("Assembler")                         # esm l window
        self.setWindowIcon(QtGui.QIcon('favicon.png'))           # l sora

        extractAction = QtGui.QAction("&Quit", self)
        extractAction.setShortcut("Ctrl+Q")                        # e5tsar ll close
        extractAction.setStatusTip('Leave The App')
        extractAction.triggered.connect(self.close_application)
        openFile = QtGui.QAction("&Open File", self)
        openFile.setShortcut("Ctrl+O")
        openFile.setStatusTip('Open File')
        openFile.triggered.connect(self.file_open)

        self.statusBar()

        mainMenu = self.menuBar()
        fileMenu = mainMenu.addMenu('&File')

        fileMenu.addAction(openFile)                                # 34an y open l file
        fileMenu.addAction(extractAction)                           # hy3ml extraction

        self.home()


    def file_open(self):                                            # deh l function l ms2ola 3n enoh yft7 l file
        name = QtGui.QFileDialog.getOpenFileName(self, 'Open File')
        file = open(name, 'r')
        self.Assembly_try(file)                                     # dh esm l function ly bttrgm l assembly

        # dh l home ly b set feh 4oiet 7agat w
        # zy eny a7dd lma ados 3 button eh ly hy7sl w kda


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

    # dh function m3mola 34an a3ml check 3la no3 l reg we a7ot l code bta3ha

    def Assembly_try(self, file):               # deh function l assembly ly bttrgm l binary
        # dol tlata variables b7ot fehom lqym bta3t l 7aga 34an a3rf atrgm

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

        first_state = []
        second_state = []
        third_state = []
        final_field = []
        y = 0
        HOLD = open("textfile1.txt", "w")
        for line1 in file:  # deh for loop bt3dy 3la kol element fe l file
            field = line1.split(",")
            field1 = field[0]
            field_new = field1.split(" ")
            field_new += field[1:]
            if (y == 0):
                final_field += field_new
                y = 1
            else:
                final_field += ["#"] + field_new

        num_lines = sum(1 for line in open('aa.txt'))
        counter = 0
        summation = 0
        while (summation < num_lines):
            if final_field[counter] == 'add':
                output = '000000'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100000'
                HOLD.write(output + '\n')

            elif final_field[counter] == 'sub':
                output = '000000'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100010'
                HOLD.write(output + '\n')

            elif final_field[counter] == 'and':
                output = '000000'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100100'
                HOLD.write(output + '\n')

            elif final_field[counter] == 'or':
                output = '000000'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100101'
                HOLD.write(output + '\n')

            elif final_field[counter] == 'nor':
                output = '000000'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100111'
                HOLD.write(output + '\n')

            elif final_field[counter] == 'slt':
                output = '000000'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000101010'
                HOLD.write(output + '\n')

            elif final_field[counter] == 'addi':
                output = '001000'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'andi':
                output = '001100'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'ori':
                output = '001101'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'slti':
                output = '001010'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'lui':
                output = '001111'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'lw':
                output = '100011'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'lh':
                output = '100001'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'lb':
                output = '100000'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'sw':
                output = '101011'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'sh':
                output = '101001'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'sb':
                output = '101000'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'j':
                output = '000010'
                third_state = final_field[2:]
                third_state = int(third_state)
                bin_ = '{0:026b}'.format(third_state)
                output = output + bin_
                HOLD.write(output + '\n')

            elif final_field[counter] == 'jal':
                output = '000011'
                third_state = final_field[2:]
                third_state = int(third_state)
                bin_ = '{0:026b}'.format(third_state)
                output = output + bin_
                HOLD.write(output + '\n')

            # not complete , check those two

            elif final_field[counter] == 'beq':
                output = '000100'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            else:
                output = '000101'
                first_state = final_field[counter + 1]
                second_state = final_field[counter + 2]
                third_state = final_field[counter + 3]
                third_state = int(third_state)
                bin_ = '{0:016b}'.format(third_state)
                output = output + assembly(second_state) + assembly(first_state) + bin_
                HOLD.write(output + '\n')

            counter += 5
            summation += 1
        HOLD.close()
        file.close()
        return (HOLD)

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