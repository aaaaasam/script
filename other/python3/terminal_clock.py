#!/usr/bin/env python3
# _*_ encoding: utf-8 _*_

from datetime import datetime
import os
from time import sleep

num = {
    0: {1:'11111', 2:'10001', 3:'10001', 4:'10001', 5:'10001', 6:'10001', 7:'11111'},
    1: {1:'00100', 2:'10100', 3:'00100', 4:'00100', 5:'00100', 6:'00100', 7:'11111'},
    2: {1:'11111', 2:'00001', 3:'00001', 4:'11111', 5:'10000', 6:'10000', 7:'11111'},
    3: {1:'11111', 2:'00001', 3:'00001', 4:'11111', 5:'00001', 6:'00001', 7:'11111'},
    4: {1:'10001', 2:'10001', 3:'10001', 4:'11111', 5:'00001', 6:'00001', 7:'00001'},
    5: {1:'11111', 2:'10000', 3:'10000', 4:'11111', 5:'00001', 6:'00001', 7:'11111'},
    6: {1:'11111', 2:'10000', 3:'10000', 4:'11111', 5:'10001', 6:'10001', 7:'11111'},
    7: {1:'11111', 2:'10001', 3:'10001', 4:'00001', 5:'00001', 6:'00001', 7:'00001'},
    8: {1:'11111', 2:'10001', 3:'10001', 4:'11111', 5:'10001', 6:'10001', 7:'11111'},
    9: {1:'11111', 2:'10001', 3:'10001', 4:'11111', 5:'00001', 6:'00001', 7:'11111'}
}

def get_time_to_str():
    _time = datetime.now().strftime('%H:%M:%S')
    date_str = ''
    width, high = os.get_terminal_size()

    for i in range(1,8):
        if i == 3 or i == 5:
            date_str = date_str + (
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[0])][i]]) + '   ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[1])][i]]) + '  #  ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[3])][i]]) + '   ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[4])][i]]) + '  #  ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[6])][i]]) + '   ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[7])][i]])
            ).center(width)
        elif i == 7:
            date_str = date_str + (
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[0])][i]]) + '   ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[1])][i]]) + '     ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[3])][i]]) + '   ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[4])][i]]) + '     ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[6])][i]]) + '   ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[7])][i]])
            ).center(width)
        else:
            date_str = date_str + (
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[0])][i]]) + '   ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[1])][i]]) + '     ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[3])][i]]) + '   ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[4])][i]]) + '     ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[6])][i]]) + '   ' +
                ''.join([' ' if x == '0' else '#' for x in num[int(_time[7])][i]])
            ).center(width)
    return high, date_str



if __name__ == "__main__":
    while True:
        high, date_str = get_time_to_str()
        os.system('clear')
        empty_line = (high - 9) // 2
        for i in range(empty_line):
            print()
        print(date_str)
        sleep(1)