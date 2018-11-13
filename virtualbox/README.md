### 简述


>  动机很单纯，就是想搭建个实验环境，但是没有显示器，于是乎就研究了基于字符终端的Virtualbox控制命令VBoxManage，然后觉得这个写得太复杂了，想简化一下，融入自己的理解，于是乎就有了这个...


### 帮助

```text
   程序帮助:
	 command show_ostype:		打印支持的系统类型列表
		 <type>:		搜索相对应关键字的系统类型
	 command show_vms:		打印虚拟机列表
	 command show_vms runningvms:	打印正在运行的虚拟机
	 command create_vms:
		 --name=<str>:		虚拟机的名字
		 --ostype=<str>:	虚拟机的系统类型
		 --basefolder=<str>:	虚拟机的存储目录(默认:/home/sam/VirtualBox\ VMs/)
	 command setting_vms:
		 --name=<str>:		虚拟机的名字
		 --cpu=<int>:		cpu核数
		 --memory=<int>:	内存大小(单位：Mb)
		 --vram=<int>:		显存大小(单位：Mb)
	 command setting_vms_network:
		 --name=<str>:		虚拟机的名字
		 --network_interface=<str>:	宿主机网卡名称
		 (注：固定虚拟机的网卡模式为桥接模式)
	 command create_vms_disk:
		 --name=<str>:		虚拟机的名字
		 --disk_size=<int>:	磁盘大小（Mb）
		 --disk_format=<str>:	磁盘格式（VDI|VMDK|VHD）
	 command add_install_media:
		 --name=<str>:		虚拟机的名字
		 --system_image=<str>:	系统镜像路径
	 command manager_vrde:
		 --name=<str>:		虚拟机的名字
		 --status=<on|off>:	开启或关闭vrde
	 command start:
		 --name=<str>:		虚拟机的名字
	 command stop:
		 --name=<str>:		虚拟机的名字
	 command snapshot:
		 --name=<str>:		虚拟机的名字
		 --to_do=<str>:
			 carete:	创建快照
			 delete:	删除快照
			 load:		加载快照
			 list:		快照列表
		 --snapname=<str>:	快照名称
	 command create_new_vms:
		 --name=<str>:		虚拟机的名字
		 --memory=<int>:	内存大小(单位：Mb)
		 --vram=<int>:		显存大小(单位：Mb)
		 --ostype=<str>:	虚拟机的系统类型
		 --basefolder=<str>:	虚拟机的存储目录(默认:/home/sam/VirtualBox\ VMs/)
		 --cpu=<int>:		cpu核数
		 --network_interface=<str>:	宿主机网卡名称
		 --disk_size=<int>:	磁盘大小（Mb）
		 --disk_format=<str>:	磁盘格式（VDI|VMDK|VHD）
		 --system_image=<str>:	系统镜像路径
		 --status=<on|off>:	开启或关闭vrde
```

### 使用

```
cp <scriptname> /usr/local/bin/<command_name>
chmod +x /usr/local/bin/<command_name>
```

