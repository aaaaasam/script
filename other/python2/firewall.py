#!/usr/bin/env python
# _*_ coding: utf-8 _*_

'''
######
读取wtmp文件，丢弃掉暴力破解ssh密码的IP地址
######

#如果你是centos 需要安装下面的两个步骤，如果是Ubuntu 直接安装pyutmp 就好。
yum install -y gcc python-devel epel-release python-pip
# 安装pyutmp安装需要的依赖程序

pip install Cython pyutmp
# 安装cython(pyutmp 安装需要)和pyutmp

vim /usr/lib64/python2.7/optparse.py
更改 file.write(self.format_help().encode(encoding, "replace")) --> file.write(self.format_help())

echo '*/6 * * * * root /usr/local/bin/firewall -w monitor' >> /etc/crontab
#时间最好和脚本保持一致，避免数据重复写入，导致误封(当前是0.1小时，刚好等于六分钟)。
'''



import time
import json
import os
import re
import sys
import commands
from optparse import OptionParser
from pyutmp import UtmpFile as utmp

# 创建日志存储目录
def Make_log_dir(log_dir):
    if not os.path.isdir(log_dir):
        os.mkdir(log_dir)

# 数字转换为IP地址
def int_ip2str(int_ip):
    lst = []
    for i in xrange(4):
        shift_n = 8 * i
        lst.insert(0, str((int_ip >> shift_n) & 0xff))
    return ".".join(lst[::-1])

# 获取错误的登录错误的IP地址和错误登录次数
def Get_ip_login_error_count_table(time_point, error_log_file):
    ip_login_error_count_table = {}

    login_error_list_during_interval = [ int_ip2str(x.ut_addr) for x in utmp(error_log_file) if x.ut_time > time_point ]
    for ip_addr in login_error_list_during_interval:
        if ip_addr in ip_login_error_count_table:
            ip_login_error_count_table[ip_addr] = ip_login_error_count_table[ip_addr] + 1
        else:
            ip_login_error_count_table[ip_addr] = 1 

    return ip_login_error_count_table

# 生成当天总的错误IP地址和错误登录次数列表
def Get_error_login_list_for_the_day(dump_file_dir, dump_file, ip_login_error_count_table):
    if os.path.isfile(os.path.join(dump_file_dir, dump_file)): 
        with open(os.path.join(dump_file_dir, dump_file), 'r') as f:
            old_error_login_list = json.load(f)
    else:
        old_error_login_list = {}
    for i in ip_login_error_count_table:
        if i in old_error_login_list:
            old_error_login_list[i] = old_error_login_list[i] + ip_login_error_count_table[i]
        else:
            old_error_login_list[i] = ip_login_error_count_table[i]
    return old_error_login_list

def Dump_error_log_list_to_file(all_error_list_for_the_day, dump_file_dir, dump_file_name):
    with open(os.path.join(dump_file_dir, dump_file_name), 'w') as f:
        json.dump(all_error_list_for_the_day, f)

def Add_rule_in_iptables(ipaddress):
    os.popen('/usr/sbin/iptables -I INPUT -s %s/32 -p tcp --dport 22 -j DROP' % ipaddress)

def Del_rule_in_iptables(ipaddress):
    os.popen('/usr/sbin/iptables -D INPUT -s %s/32 -p tcp --dport 22 -j DROP' % ipaddress)

def Get_iptables_rule_info():
    return commands.getoutput('/usr/sbin/iptables-save')

def monitor(time_point, error_log_file, dump_file_dir, today):
    ip_login_error_count_table = Get_ip_login_error_count_table(time_point, error_log_file)
    error_login_list_for_the_day = Get_error_login_list_for_the_day(dump_file_dir, today, ip_login_error_count_table)
    iptables_rule_string = Get_iptables_rule_info()

    for i in error_login_list_for_the_day:
        if error_login_list_for_the_day[i] > bad_logins:
            if i not in iptables_rule_string:
                Add_rule_in_iptables(i)

    Dump_error_log_list_to_file(error_login_list_for_the_day, dump_file_dir, today)

def delete_address(ipaddress, today, dump_file_dir):
    if os.path.isfile(os.path.join(dump_file_dir, today)):
        with open(os.path.join(dump_file_dir, today), 'r') as f:
            error_login_list_for_the_day = json.load(f)
        error_login_list_for_the_day[ipaddress] = 0
        with open(os.path.join(dump_file_dir, today), 'w') as f:
            json.dump(error_login_list_for_the_day, f)
    Del_rule_in_iptables(ipaddress)

def Option_parser():
    parser = OptionParser(usage="usage:%prog [options] arg1", add_help_option=False)
    parser.add_option("-h",
                  "--help",
                  action = 'help',
                  help = "脚本使用帮助"
                )
    parser.add_option("-w", "--work",
                action = "store",
                dest = "work",
                default = None,
                help="使用方法(monitor,add,del)"
                )
    parser.add_option("-i", "--ip",
                action = "store",
                type = 'string',
                dest = "ip",
                default = None,
                help = "当方法为monitor时，不需要该参数"
                )
    (options, _) = parser.parse_args()
    
    work_list = ("monitor", "add", "del")
    if options.work == None and options.work not in work_list:
        parser.print_help()
        print "\n使用错误，work参数传入错误，允许值范围 %s" % str(work_list)
        sys.exit(1)
    elif options.work == "monitor":
        return options
    elif options.work != 'monitor' and options.ip == None:
        print "使用错误，add 和 del 需要传入ip参数"
        sys.exit(1)
    elif not re.match(r'^\d{1,3}(\.\d{1,3}){3}$', options.ip):
        print "ip 地址输入错误"
        sys.exit(1)
    return options

if __name__ == '__main__':
    if os.getuid() != 0:
        raise EnvironmentError('Please run as root!')
        sys.exit(1)
    error_log_file = '/var/log/btmp'
    # 日志文件
    #Intervals = 1
    Intervals = 0.1
    # 时间间隔，单位小时
    Intervals_sec = Intervals * 60 * 60
    # 时间间隔 单位秒
    time_point = time.time() - Intervals_sec
    # 时间间隔点时间戳
    dump_file_dir = '/var/log/error_login'
    # 用来保存错误登录信息和脚本需要存储文件的目录
    bad_logins = 5
    # 错误登录次数
    today = time.strftime("%Y-%m-%d", time.localtime())
    # xxxx-xx-xx(年月日)用来存储当天的错误登录信息
    to_work = Option_parser()
    if to_work.work == 'add':
        Add_rule_in_iptables(to_work.ip)
    elif to_work.work == 'del':
        delete_address(to_work.ip, today, dump_file_dir)
    elif to_work.work == 'monitor':
        Make_log_dir(dump_file_dir)
        monitor(time_point, error_log_file, dump_file_dir, today)
    else:
        sys.exit(1)
