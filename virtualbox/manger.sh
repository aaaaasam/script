#/usr/bin/env bash

# vboxmanager #

vbox_command='/usr/bin/VBoxManage'
basefolder="/home/sam/VirtualBox\ VMs/"

# 位置参数解析
function parameter_analysis() {
	for i in `echo "${@}"`; do 
		if [[ "${i}" =~ "--" ]]; then
			v_name=`echo "${i}" | sed 's/--\(.*\)=.*/\1/'`
			variable=`echo "${i}" | sed 's/--.*=\(.*\)/\1/'`
			eval "${v_name}=${variable}"
		fi
	done
}

# 查看支持的系统类型
function show_ostype() {
    if [[ $# == 1 ]]; then
        eval "${vbox_command} list ostypes | grep ^ID | awk '{print \$2}'"
    else
        eval "${vbox_command} list ostypes | grep ^ID | grep -i ${2} | awk '{print \$2}'"
    fi
}

# 查看虚拟机列表
function show_vms() {
    if [[ $# == 1 ]]; then
        eval "${vbox_command} list vms"
    else
        eval "${vbox_command} list ${2}"
    fi
}


#创建虚拟机
function create_vms() {
	parameter_analysis $@
	if [ -z "${name}" ] || [ -z "${ostype}" ]; then 
		eval "f_help create_vms"
	else
		eval "${vbox_command} createvm --name ${name} --ostype ${ostype} --basefolder ${basefolder} --register"
	fi
}

#配置虚拟机
function setting_vms() {
	parameter_analysis $@
	if [ -z "${name}" ] || [ -z "${cpu}" ] || [ -z "${memory}" ] || [ -z "${vram}" ]; then 
		eval "f_help setting_vms"
	else
		eval "${vbox_command} modifyvm ${name} --cpus ${cpu} --memory ${memory} --vram ${vram}"
	fi
}

# 配置虚拟机网络
function setting_vms_network() {
	parameter_analysis $@
	if [ -z "${name}" ] || [ -z "${network_interface}" ]; then 
		eval "f_help setting_vms_network"
	else
		eval "VBoxManage modifyvm ${name} --nic1 bridged --bridgeadapter1 ${network_interface}"
	fi
}

# 创建磁盘
function create_vms_disk() {
	parameter_analysis $@
	if [ -z "${name}" ] || [ -z "${disk_size}" ] || [ -z "${disk_format}" ]; then 
		eval "f_help create_vms_disk"
	else
		eval "VBoxManage createmedium disk --filename ${basefolder}/${name}/${name}\.vdi --size ${disk_size} --format ${disk_format} --variant Standard"
		eval "VBoxManage storagectl ${name} --name 'SATA Controller' --add sata --bootable on"
		eval "VBoxManage storageattach ${name} --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium ${basefolder}/${name}/${name}\.vdi"
	fi
}

# 添加镜像
function add_install_media() {
	parameter_analysis $@
	if [ -z "${name}" ] || [ -z "${system_image}" ]; then 
		eval "f_help add_install_media"
	else
		eval "VBoxManage storagectl ${name} --name 'IDE Controller' --add ide"
		eval "VBoxManage storageattach ${name} --storagectl 'IDE Controller' --port 0  --device 0 --type dvddrive --medium ${system_image}"
	fi
}

# 管理虚拟机的VRDE配置
function manager_vrde() {
	parameter_analysis $@
	if [ -z "${name}" ] || [ -z "${status}" ]; then 
		eval "f_help manager_vrde"
	else
		eval "VBoxManage controlvm ${name} vrde ${status}"
	fi
}

# 开启虚拟机
function start() {
	parameter_analysis $@
	if [ -z "${name}" ]; then 
		eval "f_help start"
	else
		eval "VBoxManage startvm ${name} --type headless"
	fi
}

# 关闭虚拟机
function stop() {
	parameter_analysis $@
	if [ -z "${name}" ]; then 
		eval "f_help stop"
	else
		eval "VBoxManage controlvm ${name} poweroff"
	fi
}

# 快照管理
function snapshot() {
	parameter_analysis $@
	if [ -z "${name}" ] || [ -z "${to_do}" ]; then 
		eval "f_help snapshot"
	elif [[ "${to_do}" == "list" ]]; then
		eval "VBoxManage snapshot ${name} list"
	elif [ ! -z "${snapname}" ]; then
		case "${to_do}" in
			create)
			eval "VBoxManage snapshot ${name} take ${snapname}"
			;;
			delete)
			eval "VBoxManage snapshot ${name} delete ${snapname}"
			;;
			load)
			eval "VBoxManage snapshot ${name} restore ${snapname}"
			;;
			*)
			eval "f_help snapshot"
			;;
		esac
	else
		eval "f_help snapshot"
	fi
}

# 创建一个新的虚拟机
function create_new_vms() {
	# cpu=1
	# 	cpu 数量
	# memory=1024
	# 	内存大小(mb)
	# vram=128
	# 	显存大小(mb)
	# name=test
	# 	虚拟机名字
	# ostype=Ubuntu_64
	# 	虚拟机的系统类型（Virtualbox集成）
	# basefolder=/home/sam/virtualbox
	# 	虚拟机配置文件存放目录
	# network_interface=enp2s0
	# 	需要桥接的网卡名称
	# disk_size=20480
	# 	磁盘大小(mb)
	# disk_format=vdi
	#	磁盘格式
	# system_image=system_image/ubuntu-16.04.5-server-amd64.iso
	#	需要安装的操作系统镜像
	# status=on
	# 	vrde开关(开启或关闭远程桌面)

	parameter_analysis $@
	if [ -z "${cpu}" ] || \
	   [ -z "${memory}" ] || \
	   [ -z "${vram}" ] || \
	   [ -z "${name}" ] || \
	   [ -z "${ostype}" ] || \
	   [ -z "${basefolder}" ] || \
	   [ -z "${network_interface}" ] || \
	   [ -z "${disk_size}" ] || \
	   [ -z "${disk_format}" ] || \
	   [ -z "${system_image}" ] || \
	   [ -z "${status}" ] ; then 
		eval "f_help create_new_vms"
	else
		create_vms
    	setting_vms
    	setting_vms_network
    	create_vms_disk
    	add_install_media
    	manager_vrde
    	start
    fi
}

#程序帮助
function f_help() {
    echo -e "\a 程序帮助:"
    if [ -z $1 ]; then
    	help_list=(
    		"show_ostype"
    		"show_vms"
    		"create_vms"
    		"setting_vms"
    		"setting_vms_network"
    		"create_vms_disk"
    		"add_install_media"
    		"manager_vrde"
    		"start"
    		"stop"
    		"snapshot"
    		"create_new_vms"
    		)
    	for i in "${help_list[@]}"; do 
    		eval "help_${i}"
    	done
    else
    	eval "help_${1}"
    fi
}

# 查看支持的系统类型帮助
function help_show_ostype() {
	echo -e "\t command show_ostype:\t\t打印支持的系统类型列表"
	echo -e "\t\t <type>:\t\t搜索相对应关键字的系统类型" 
}

# 查看虚拟机列表帮助
function help_show_vms() {
	echo -e "\t command show_vms:\t\t打印虚拟机列表"
	echo -e "\t command show_vms runningvms:\t打印正在运行的虚拟机"
}

# 查看创建虚拟机帮助
function help_create_vms() {
    echo -e "\t command create_vms:"
	echo -e "\t\t --name=<str>:\t\t虚拟机的名字"
    echo -e "\t\t --ostype=<str>:\t虚拟机的系统类型"
    echo -e "\t\t --basefolder=<str>:\t虚拟机的存储目录(默认:${basefolder})"
}

# 查看虚拟机配置帮助
function help_setting_vms() {
	echo -e "\t command setting_vms:"
	echo -e "\t\t --name=<str>:\t\t虚拟机的名字"
	echo -e "\t\t --cpu=<int>:\t\tcpu核数"
	echo -e "\t\t --memory=<int>:\t内存大小(单位：Mb)"
	echo -e "\t\t --vram=<int>:\t\t显存大小(单位：Mb)"
}

# 虚拟机网络连接方式设置（固定为桥接模式）
function help_setting_vms_network() {
	echo -e "\t command setting_vms_network:"
	echo -e "\t\t --name=<str>:\t\t虚拟机的名字"
	echo -e "\t\t --network_interface=<str>:\t宿主机网卡名称"
	echo -e "\t\t (注：固定虚拟机的网卡模式为桥接模式)"
}

# 创建磁盘帮助
function help_create_vms_disk () {
	echo -e "\t command create_vms_disk:"
	echo -e "\t\t --name=<str>:\t\t虚拟机的名字"
	echo -e "\t\t --disk_size=<int>:\t磁盘大小（Mb）"
	echo -e "\t\t --disk_format=<str>:\t磁盘格式（VDI|VMDK|VHD）"
}

# 添加镜像帮助
function help_add_install_media() {
    echo -e "\t command add_install_media:"
    echo -e "\t\t --name=<str>:\t\t虚拟机的名字"
   	echo -e "\t\t --system_image=<str>:\t系统镜像路径"
}

# 管理VRDE
function help_manager_vrde() {
    echo -e "\t command manager_vrde:"
	echo -e "\t\t --name=<str>:\t\t虚拟机的名字"
    echo -e "\t\t --status=<on|off>:\t开启或关闭vrde"
}

# 开启虚拟机帮助
function help_start() {
	echo -e "\t command start:"
	echo -e "\t\t --name=<str>:\t\t虚拟机的名字"
}

# 关闭虚拟机帮助
function help_stop() {
	echo -e "\t command stop:"
	echo -e "\t\t --name=<str>:\t\t虚拟机的名字"
}

# 快照管理帮助
function help_snapshot() {
	echo -e "\t command snapshot:"
	echo -e "\t\t --name=<str>:\t\t虚拟机的名字"
    echo -e "\t\t --to_do=<str>:"
    echo -e "\t\t\t carete:\t创建快照"
    echo -e "\t\t\t delete:\t删除快照"
    echo -e "\t\t\t load:\t\t加载快照"
    echo -e "\t\t\t list:\t\t快照列表"
    echo -e "\t\t --snapname=<str>:\t快照名称"
}

# 创建新的虚拟机帮助
function help_create_new_vms() {
	echo -e "\t command create_new_vms:"
	echo -e "\t\t --name=<str>:\t\t虚拟机的名字"
	echo -e "\t\t --memory=<int>:\t内存大小(单位：Mb)"
	echo -e "\t\t --vram=<int>:\t\t显存大小(单位：Mb)"
	echo -e "\t\t --ostype=<str>:\t虚拟机的系统类型"
    echo -e "\t\t --basefolder=<str>:\t虚拟机的存储目录(默认:${basefolder})"
    echo -e "\t\t --cpu=<int>:\t\tcpu核数"
	echo -e "\t\t --network_interface=<str>:\t宿主机网卡名称"
	echo -e "\t\t --disk_size=<int>:\t磁盘大小（Mb）"
	echo -e "\t\t --disk_format=<str>:\t磁盘格式（VDI|VMDK|VHD）"
   	echo -e "\t\t --system_image=<str>:\t系统镜像路径"
   	echo -e "\t\t --status=<on|off>:\t开启或关闭vrde"
}


function main() {
    case "${1}" in
        show_ostype)
            show_ostype $@
            ;;
        create_vms)
			create_vms $@
			;;
		setting_vms)
			setting_vms $@
			;;
		show_vms)
			show_vms $@
			;;
		setting_vms_network)
			setting_vms_network $@
			;;
		create_vms_disk)
			create_vms_disk $@
			;;
		add_install_media)
			add_install_media $@
			;;
		manager_vrde)
			manager_vrde $@
			;;
		start)
			start $@
			;;
		stop)
			stop $@
			;;
		create_new_vms)
			create_new_vms $@
			;;
		snapshot)
			snapshot $@
			;;
		help)
			f_help $2
			;;
        *)
            f_help
            ;;
    esac
}

main $@


#bash vm.sh create_new_vms --name=ubuntu_test_1 --memory=1024 --vram=128 --ostype=Ubuntu_64 --basefolder=/home/sam/virtualbox --cpu=1 --network_interface=enp2s0 --disk_size=20480 --disk_format=vdi --system_image=system_image/ubuntu-16.04.5-server-amd64.iso --status=on



# vm snapshot --name=ubuntu_test_1 --to_do=delete --snapname=default
