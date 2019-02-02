import sys
from PyQt4.QtGui import *

# Create an PyQT4 application object.
from typing import List

a = QApplication(sys.argv)

# The QWidget widget is the base class of all user interface objects in PyQt4.
w = QWidget()

# Get filename using QFileDialog
filename = QFileDialog.getOpenFileName(w, 'Open File', '/')

first_state  = []
second_state = []
third_state  = []
output = 0
with open(filename, "r") as ins:
    array = []  # type: List[str]
    Data = []
    for line in ins:
        array.append(line)
        Data = array.partition(' ')[0]

file = open('textfile.txt','w')

def assembly (value):
    if   value == '$t0'  :
        donno = '01000'
    elif value == '$t1'  :
        donno = '01001'
    elif value == '$t2'  :
        donno = '01010'
    elif value == '$t3'  :
        donno = '01011'
    elif value == '$t4'  :
        donno = '01100'
    elif value == '$t5'  :
        donno = '01101'
    elif value == '$t6'  :
        donno = '01110'
    elif value == '$t7'  :
        donno = '01111'
    elif value == '$s0'  :
        donno = '10000'
    elif value == '$s1'  :
        donno = '10001'
    elif value == '$s2'  :
        donno = '10010'
    elif value == '$s3'  :
        donno = '10011'
    elif value == '$s4'  :
        donno = '10100'
    elif value == '$s5'  :
        donno = '10101'
    elif value == '$s6'  :
        donno = '10110'
    else :
        donno = '10111'
    return donno
#test_lines = file.readlines()
for line1 in Data:
    if   Data[line1]  == 'add' :
        output = '000000'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100000'

    elif Data[line1]  == 'sub' :
        output = '000000'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100010'

    elif Data[line1]  == 'and' :
        output = '000000'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100100'

    elif  Data[line1] == 'or'  :
        output = '000000'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100101'

    elif Data[line1]  == 'nor' :
        output = '000000'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000100111'

    elif Data[line1]  == 'slt' :
        output = '000000'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        output = output + assembly(first_state) + assembly(second_state) + assembly(third_state) + '00000101010'

    elif Data[line1]  == 'addi':
        output = '001000'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  =='andi' :
        output = '001100'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  == 'ori' :
        output = '001101'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  =='slti' :
        output = '001010'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  == 'lui' :
        output = '001111'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  == 'lw'  :
        output = '100011'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  == 'lh'  :
        output = '100001'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  == 'lb'  :
        output = '100000'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  == 'sw'  :
        output = '101011'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  == 'sh'  :
        output = '101001'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  == 'sb'  :
        output = '101000'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    elif Data[line1]  == 'j'   :
        output = '000010'
        third_state = array.partition(' ')[2:]
        third_state = int(third_state)
        bin_ = '{0:026b}'.format(third_state)
        output = output + bin_

    elif Data[line1]  == 'jal' :
        output = '000011'
        third_state = array.partition(' ')[2:]
        third_state = int(third_state)
        bin_ = '{0:026b}'.format(third_state)
        output = output + bin_


        # not complete , check those two


    elif Data[line1]  == 'beq' :
        output = '000100'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    else :
        output = '000101'
        first_state = array.partition(' ')[2:4]
        second_state = array.partition(' ')[6:8]
        third_state = array.partition(' ')[10:12]
        third_state = int(third_state)
        bin_ = '{0:016b}'.format(third_state)
        output = output + assembly(second_state) + assembly(first_state) + bin_

    file.write(output)

file.close()
sys.exit(a.exec_())