#!/bin/bash

version="2.8_test"
OF="Script_File"
fl="Openwrt"
by="ITdesk"
OCS="OpenwrtCompileScript"

#颜色调整参考wen55333
red="\033[31m"
green="\033[32m"
white="\033[0m"


rely_on() {
	sudo apt-get -y install asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache flex \
g++ gawk gcc gcc-multilib gettext git git-core help2man htop lib32gcc1 libc6-dev-i386 libglib2.0-dev libncurses5-dev \
libssl-dev libtool libz-dev libelf-dev make msmtp ncurses-term ocaml-nox p7zip p7zip-full patch qemu-utils sharutils \
subversion texinfo uglifyjs unzip upx xmlto yui-compressor zlib1g-dev make cmake
}

#显示编译文件夹
ls_file() {
	LF=`ls $HOME/$fl | grep -v $0  | grep -v Script_File`
	echo -e "$green$LF$white"
	echo ""
}
ls_file_luci(){
	clear && cd
	echo "***你的openwrt文件夹有以下几个***"
	ls_file
	read -p "请输入你的文件夹（记得区分大小写）：" file
	cd && cd $HOME/$fl/$file/lede
}

#显示config文件夹
ls_my_config() {
	LF=`ls My_config`
	echo -e "$green$LF$white"
	echo ""
}

#显示git log 提交记录
display_git_log() {
	git log -3 --graph --all --branches --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(bold green)(%ai)%C(reset) %C(white)%s%C(reset) %C(yellow) - %an%C(reset)%C(auto) %d%C(reset)'
#参考xueguang668
}

display_git_log_luci() {
	clear
		echo "----------------------------------------"
		echo -e "   $green显示远端仓库最近三条更新内容$white                  "
		echo "----------------------------------------"
		echo ""
				display_git_log
		echo ""
		echo ""
		read -p "是否需要更新源码（1.yes 2.no）：" update_soure
		case "$update_soure" in
			1)
			source_update
			;;
			2)
			echo ""
			;;
			*)
			clear && echo  "Error请输入正确的数字 [1-2]" && Time
			display_git_log_luci
			;;
		esac	
}

#倒数专用
Time() {
	seconds_left=3
	echo ""
	echo "   ${seconds_left}秒以后执行代码"
	echo "   如果不需要执行代码以Ctrl+C 终止即可"
	echo ""
	while [[ ${seconds_left} -gt 0 ]]; do
		echo -n ${seconds_left}
		sleep 1
		seconds_left=$(($seconds_left - 1))
		echo -ne "\r     \r"
	done
}

#选项9.更新update_script
update_script() {
	clear
	cd $HOME/$fl/$OF/$OCS
	CheckUrl_github=`curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null www.github.com`
		if [[ $CheckUrl_github -eq 301 ]]; then
			git fetch --all
			git reset --hard origin/master
			echo "回车进入编译菜单"
			read a
			bash ${openwrt}
		else
			echo "请检查你的网络!!!!" && read a
			Time && main_interface
		fi
}

#选项5.其他选项
other() {
	clear
	echo "	      -------------------------------------"
	echo "	      	    【 其他选项 】"
	echo ""
	echo " 		  5.1 只搭建编译环境，不进行编译"
	echo ""
	echo "		  5.2 单独Download DL库 "
	echo ""
	echo "		  5.3 更新lean软件库 "
	echo ""
	echo "		  5.4 下载额外的插件 "
	echo ""
	echo "		  0. 回到上一级菜单"
	echo ""
	echo ""
	echo "		PS:请先搭建好梯子再进行编译，不然很慢！"
	echo "			     By:ITdesk"
	echo "	      --------------------------------------"
	read -p "请输入数字:" other_num
	case "$other_num" in
		5.1)
		clear
		echo "5.1 只搭建编译环境，不进行编译 " && Time
		update_system
		echo "环境搭建完成，请自行创建文件夹和git"
		;;
		5.2)
		dl_other
		echo "DL更新完成"
		;;
		5.3)
		update_lean_package
		echo "lean软件库更新完成"
		;;
		5.4)
		download_package
		echo "插件下载完成"
		;;
		0)
		main_interface
		;;
		*)
	clear && echo  "请输入正确的数字 [1-4,0]" && Time
	other
	;;
esac
}

dl_other() {
	ls_file_luci
	dl_source
}

update_lean_package() {
	ls_file_luci
	make clean
	rm -rf package/lean
	software_lean
	software_Setting
	Time
	update_feeds
	source_config
	mk_df
}

download_package() {
	ls_file_luci 
	if [[ -e package/Extra-plugin ]]; then
		cd package/Extra-plugin	
	else
		mkdir package/Extra-plugin
	fi
	download_package_luci
	
}

download_package2() {
	cd $HOME/$fl/$file/lede 
	rm -rf ./tmp
	update_feeds
	source_config
	mk_df
}


download_package_luci() {
	clear
	echo "	      -------------------------------------"
	echo "	      	    【 5.4额外的插件 】"
	echo ""
	echo " 		  1. luci-theme-argon"
	echo ""
	echo "		  2. luci-app-oaf （测试中）"
	echo ""
	echo "		  99. 自定义下载插件 "
	echo ""
	echo "		  0. 回到上一级菜单"
	echo ""
	echo "		PS:如果你有什么好玩的插件，可以提交给我"
	echo "	      --------------------------------------"
	read -p "请输入数字:" download_num
	case "$download_num" in
		1)
		git clone https://github.com/jerrykuku/luci-theme-argon.git
		;;
		2)
		git clone https://github.com/destan19/OpenAppFilter.git
		;;
		99)
		download_package_customize
		;;
		0)
		other
		;;
		*)
	clear && echo  "请输入正确的数字 [1-2,99,0]" && Time
	download_package_luci
	;;
esac
download_package_customize_Decide
}

download_package_customize() {	
	cd $HOME/$fl/$file/lede/package/Extra-plugin
	clear
	echo "--------------------------------------------------------------------------------"
	echo "自定义下载插件"
	echo ""
	echo -e " $green例子：git clone https://github.com/destan19/OpenAppFilter.git   (此插件用于过滤应用)$white"
 	echo "--------------------------------------------------------------------------------"
	echo ""
	read -p "请输入你要下载的插件地址："  download_url
	$download_url
	if [[ $? -eq 0 ]]; then
		cd $HOME/$fl/$file/lede
	else
		clear	
		echo -e "没有下载成功或者插件已经存在，请检查$red package/Extra-plugin $white里面是否已经存在" && Time
		download_package_customize
	fi
	download_package_customize_Decide
	
}

download_package_customize_Decide() {
	clear
	echo "----------------------------------------"
	echo "是否需要继续下载插件"
	echo " 1.继续下载插件"
	echo " 2.不需要了"
	echo "----------------------------------------"
	read -p "请输入你的决定：" Decide
	case "$Decide" in
		1)
		cd $HOME/$fl/$file/lede/package/Extra-plugin
		download_package_luci
		;;
		2)
		download_package2
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		 clear && download_package_customize_Decide
		;;
	esac
}


#选项4.恢复编译环境
source_RestoreFactory() {
	ls_file_luci 
	echo ""
	if [[ -e $HOME/$fl/$file ]]; then
			cd && cd $HOME/$fl/$file/lede
			echo "所有编译过的文件全部删除,openwrt源代码保存，回车继续 Ctrl+c取消" && read a
	 	 else
			clear && echo "-----文件名错误，请重新输入-----" && Time
			source_secondary_compilation
		fi
	make distclean
	ln -s $HOME/$fl/$OF/dl  $HOME/$fl/$file/lede/dl
	clear && echo ""
	echo "所有编译过的文件全部删除完成，如依旧编译失败，请重新下载源代码，回车可以开始编译 不需要编译Ctrl+c取消" && read a
	update_feeds
	source_config
	make menuconfig
	Save_My_Config_luci
	mk_menu
}

#选项2.二次编译 与 源码更新合并
source_secondary_compilation() {
		ls_file_luci
		if [[ -e $HOME/$fl/$file ]]; then
			cd && cd $HOME/$fl/$file/lede
	 	 else
			clear && echo "-----文件名错误，请重新输入-----" && Time
			source_secondary_compilation
		fi
		echo "开始清理之前的文件"
		make clean && rm -rf ./tmp && Time
		display_git_log_luci
		update_feeds
		source_config
		mk_df
}

source_config() {
	clear
		 echo "----------------------------------------"
		 echo "是否要加载你之前保存的配置"
		 echo "     1.是（加载之前保存的配置）"
		 echo "     2.否（以全新的config进行编译）"
		 echo "     3.继续上次的编译（不对配置做任何操作）"
		 echo "----------------------------------------- "
	read -p "请输入你的决定："  config
		case "$config" in
			1)
			transfer_my_config
			;;
			2)
			source_Secondary_compilation_deleteConfig
			;;
			3)
			echo ""
			;;
			*)
			clear && echo  "Error请输入正确的数字 [1-2]" && Time
			source_config
			;;
		esac
}

source_Secondary_compilation_deleteConfig() {
	rm -rf .config
}

Save_My_Config_luci() {
	clear && echo "------------------------------------------------"
		 echo "是否要保存你的配置，以备下次使用(1.是  2.否 )"
		 echo "注：同一名字的文件会覆盖"
		 echo "------------------------------------------------"
	read -p "请输入你的决定："  save
		case "$save" in
			1)
			save_my_config_yes
			;;
			2)
			;;
			*)
			clear && echo  "请输入正确的数字 [1-2]" && Time
			Save_My_Config_luci
			;;
		esac
}

save_my_config_yes() {
	read -p "请输入你的配置名："  mange_config
	cp .config My_config/$mange_config
	echo "******配置保存完成回车进行编译*******" && read a
}

transfer_my_config() {
	clear
	echo "你的配置文件如下："
	echo ""
		ls_my_config
	echo ""
	read -p "请输入你要调用的配置名（记得区分大小写）："  transfer
	if [[ -e `pwd`/My_config/$transfer ]]; then
		Time && clear
		echo "正在调用"
		rm -rf .config
		cp My_config/$transfer  .config
		echo "配置加载完成" && Time

	else
		clear && echo "调用错误" && Time
		transfer_my_config
	fi
}

#选项 3.源码更新 与 二次编译合并
source_update() {
	clear
	echo "------------------------------------------------------------------"
	echo -e "$green***准备开始更新openwrt源代码与软件***$white"
	echo ""
	echo "有没有改动过源代码，因为改动过源代码可能会导致git pull失效无法更新"
	echo "1.是   2.否 "
	echo "	"
	echo "------------------------------------------------------------------"
	read -p "请输入你的决定："  git_source
		case "$git_source" in
			1)
			source_update_No_git_pull
			;;
			2)
			source_update_git_pull
			;;
			*)
			clear && echo  "Error请输入正确的数字 [1-2]" && Time
			source_update
			;;
		esac
	if [[ "$?" == "0" ]]; then
		echo -e  "$green源码更新完成$white"
	else
		echo -e  "$red源码更新失败，重新执行代码$white" && Time
		source_update
	fi
}

source_update_No_git_pull() {
	git fetch --all
	git reset --hard origin/master
}

source_update_git_pull() {
	git pull
}

#选项1.开始搭建编译环境与主菜单
#判断代码
description_if() {
	cd
	clear
	echo "开始检测系统"
	openwrt_script_path=$(cat /etc/profile | grep -o openwrt.sh)

	if [[ "${openwrt_script_path}" = "openwrt.sh" ]]; then
		echo "系统变量存在"
	else
		echo "export openwrt=$HOME/Openwrt/Script_File/OpenwrtCompileScript/openwrt.sh" | sudo tee -a /etc/profile
		source /etc/profile
		clear
		echo "-----------------------------------------------------------------------"
		echo ""
		echo -e "$green添加openwrt变量成功,重启系统以后无论在那个目录输入 bash \$openwrt 都可以运行脚本$white"
		echo ""
		echo "-----------------------------------------------------------------------"
	fi

	#添加一下脚本路径
	openwrt_shfile_path=$(cat /etc/profile | grep -o shfile)
	if [[ "${openwrt_shfile_path}" = "shfile" ]]; then
		echo "系统变量存在"
	else
		echo "export shfile=$HOME/Openwrt/Script_File/OpenwrtCompileScript" | sudo tee -a /etc/profile
		source /etc/profile
		clear
		echo "-----------------------------------------------------------------------"
		echo ""
		echo -e "$green添加openwrt变量成功,重启系统以后无论在那个目录输入 cd \$shfile 都可以进到脚本目录$white"
		echo ""
		echo "-----------------------------------------------------------------------"
	fi

	if [[ ! -d {$HOME/$fl/$OF/$OSC} ]]; then
		echo "开始创建主文件夹"
		mkdir -p $HOME/$fl/$OF/dl
		mkdir -p $HOME/$fl/$OF/My_config
		mkdir  $HOME/$fl/$OF/pl
		cp -r `pwd`/$OCS $HOME/$fl/$OF/
	fi

	if [[ -e /etc/apt/sources.list.back ]]; then
		clear && echo -e "$green源码已替换$white"
	else
		check_system=$(cat /proc/version |grep -o Microsoft@Microsoft.com)
	fi
	clear

	if [[ "$check_system" == "Microsoft@Microsoft.com" ]]; then
		clear
		echo "-----------------------------------------------------------------"
		echo "+++检测到win10子系统+++"
		echo ""
		echo "  win10子系统已知问题"
		echo "     1.IO很慢，编译很慢，不怕耗时间随意"
		echo "     2.win10对大小写不敏感，你需要百度如何开启win10子系统大小写敏感"
		echo "     3.需要替换子系统的linux源（脚本可以帮你搞定）"
		echo "-----------------------------------------------------------------"
		echo ""
		read -p "是否替换软件源然后进行编译（1.yes，2.no）："  win10_select
			case "$win10_select" in
			1)
				clear
				echo -e "$green开始替换软件源$white" && Time
				sudo cp  /etc/apt/sources.list /etc/apt/sources.list.back
				sudo rm -rf /etc/apt/sources.list
				sudo cp $HOME/$fl/$OF/$OCS/ubuntu18.4_sources.list /etc/apt/sources.list
				;;
			2)
				 clear
				 echo "不做任何操作，即将进入主菜单" && Time
				 ;;
			*)
				 clear && echo  "Error请输入正确的数字 [1-2]" && Time
				 description_if
				 ;;
			esac
	else
		echo "不是win10系统" && clear
	fi

	curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null  www.baidu.com
	if [[ "$?" == "0" ]]; then
		clear && echo -e  "$green已经安装curl$white"
	else
		clear && echo "安装一下脚本用的依赖（注：不是openwrt的依赖而是脚本本身）"
		sudo apt update
		sudo apt install curl -y
		sudo rm -rf $HOME/${OCS}
		cd ${HOME}/${fl}
	fi

	if [[ -e $HOME/$fl/$OF/description ]]; then
		self_test
		main_interface
	else
		clear
		description
		echo ""
		read -p "请输入密码:" ps
			if [[ $ps = $by ]]; then
				description >> $HOME/$fl/$OF/description && clear && self_test && main_interface
			else
				clear && echo "+++++密码错误++++++" && Time && description_if
			fi
	fi
}

self_test() {
	clear
	CheckUrl_google=$(curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null   www.google.com)

	if [[ "$CheckUrl_google" -eq "200" ]]; then
		Check_google=`echo -e "$green网络正常$white"`
	else
		Check_google=`echo -e "$red网络较差$white"`
	fi

	CheckUrl_baidu=$(curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null  www.baidu.com)
	if [[ "$CheckUrl_baidu" -eq "200" ]]; then
		Check_baidu=`echo -e "$green百度正常$white"`
	else
		Check_baidu=`echo -e "$red百度无法打开，请修复这个错误$white"`
	fi

	Root_detection=`id -u`	# 学渣代码改良版
	if [[ "$Root_detection" -eq "0" ]]; then
		Root_run=`echo -e "$red请勿以root运行,请修复这个错误$white"`
	else
		Root_run=`echo -e "$green非root运行$white"`
	fi
	echo "	      	    -------------------------------------------"
	echo "	      	  	【  Script Self-Test Program  】"
	echo ""
	echo " 			检测是否root运行:  $Root_run  "
	echo ""
	echo "		  	检测与DL网络情况： $Check_google "
	echo "  "
	echo "		  	检测百度是否正常： $Check_baidu "
	echo "  "
	echo "	      	    -------------------------------------------"
	echo ""
	echo "  请自行决定是否修复红字的错误，以保证编译顺利，你也可以直接回车进入菜单，但有可能会出现编译失败！！！如果都是绿色正常可以忽略此段话"
	read a
}

description() {
		echo "	      +++++++++++++++++++++++++++++++++++++++"
		echo "	    ++欢迎使用Openwrt-Compile-Script Ver $version ++"
		echo "	      +++++++++++++++++++++++++++++++++++++++"
		echo ""
		echo -e "  创建脚本的初衷是因($red I $white)为openwrt编译的时候有些东西太繁琐了，为了简化掉一些操作，使编译更加简单就有了此脚本($red T $white)的诞生，后面觉得好玩就分享给了大家一起玩耍，你需要清楚此脚本仅用于学习，有一定危险性，请勿进行商用，如果商用导致损失或者其他问题，均由使用者自行承担!!!"
		echo ""
		echo "下面简单给大家描述脚本的作用"
		echo -e "	1.协助你更快的搭建编译环境，小白($red d $white)建议学习一下再用会比较好"
		echo -e  "	2.统一管理你的编译源，全部($red e $white)存放在Openwrt这个文件里面"
		echo "	3.你只要启动脚本就可以控制你的源，进行二次编译或者更新"
		echo ""
		echo -e "缺陷1：小白($red s $white)不太适合，因为他们不了解过程"
		echo -e "缺陷2：不能自定义openwrt代码或者修改，此脚本适合做重复的事情($red k $white)"
		echo ""
		echo "注：请自行将你系统的软件源更换为国内的服务器，不会请百度"
		echo ""
		echo ""
		echo "请阅读完上面的前言，（）红字里面的就是密码，此界面只会出现一次，后面就不会了"
}

#主菜单
main_interface() {
	clear
	echo "	      	    -------------------------------------"
	echo "	      	  【 Openwrt Compile Script Ver ${version}版 】"
	echo ""
	echo " 		  	1.搭建编译环境"
	echo ""
	echo "		  	2.二次编译固件"
	echo ""
	echo "			4.恢复编译环境"
	echo ""
	echo "			5.其他选项"
	echo ""
	echo "			9.更新脚本"
	echo ""
	echo "		  	0. EXIT"
	echo ""
	echo ""
	echo "		    PS:请先搭建好梯子再进行编译，不然很慢！"
	echo "			     By:ITdesk"
	echo "	     	  --------------------------------------"
	read -p "请输入数字:" num
	case "$num" in
		1)
		system_install
		;;
		2)
		source_secondary_compilation
		;;
		4)
		source_RestoreFactory
		;;
		5)
		other
		;;
		9)
		update_script
		;;
		0)
		exit
		;;
		*)
	clear && echo  "请输入正确的数字 [1-5,9,0]" && Time
	main_interface
	;;
esac
}

system_install() {
	clear && echo "是否要更新系统，首次搭建选择是，其余选否(1.是  2.否)"
	read -p "请输入你的决定："  system
		case "$system" in
			1)
			update_system
			create_file
			;;
			2)
			create_file
			;;
			*)
			clear && echo  "请输入正确的数字 [1-2]" && Time
			system_install
			;;
		esac
}

update_system() {
	clear
	clear && echo "准备更新系统"	&& Time
	sudo apt-get update
	clear
	echo "准备安装依赖" && Time
	rely_on
	if [[ $? -eq 0 ]]; then
		echo "安装完成" && Time
	else
		clear	
		echo "依赖没有更新或安装成功，重新执行代码" && Time
		rely_on
	fi
}

create_file() {
	clear
	echo ""
	echo "----------------------------------------"
	echo "		   开始创建文件夹"
	echo "----------------------------------------"
	echo ""
	read -p "请输入你要创建的文件夹名:" file

	if [[ -e $HOME/$fl/$file ]]; then
		clear && echo "文件夹已存在，请重新输入文件夹名" && Time
		create_file

	 else
		echo "开始创建文件夹"
			mkdir $HOME/$fl/$file
			cd $HOME/$fl/$file  && clear
			source_download_select
	 fi
}

source_download_select() {
		clear
		echo "  -----------------------------------------"
		echo ""
  		echo "	选择你要编译的类型"
		echo ""
		echo "	1.Openwrt"
		echo ""
		echo " 	2.Pandorabox_SDK"
		echo ""
		echo "  ----------------------------------------"
		read  -p "请输入你要编译的类型:" Download_select
			case "$Download_select" in
				1)
				source_download_openwrt
				;;
				2)
				source_download_pandorabox_sdk
				;;
				0)
				exit
				;;
				*)
				clear && echo  "请输入正确的数字（1-2，0）" && Time
				source_download_select
				 ;;
			esac
}

source_download_openwrt() {
		clear
		echo "  -----------------------------------------"
		echo ""
  		echo "	准备下载openwrt代码"
		echo ""
		echo "	1.Lean_R8(stable version)_source"
		echo ""
		echo " 	2.Lean_R9(Trunk)_source"
		echo ""
		echo "	3.openwrt17.1(stable version)_source"
		echo ""
		echo "	4.openwrt18.6(stable version)_source"
		echo ""
		echo "	5.openwrt19.7(stable version)_source"
		echo ""
		echo "	6.openwrt(Trunk)_source"
		echo ""
		echo "	0.exit"
		echo ""
		echo ""
		echo "  ----------------------------------------"
		read  -p "请输入你要下载的源代码:" Download_source_openwrt
			case "$Download_source_openwrt" in
				1)
				git clone https://github.com/coolsnowwolf/openwrt.git lede
				;;
				2)
				git clone https://github.com/coolsnowwolf/lede.git lede
				;;
				3)
				git clone -b lede-17.01 https://github.com/openwrt/openwrt.git lede
				;;
				4)
				git clone -b openwrt-18.06 https://github.com/openwrt/openwrt.git lede
				;;
				5)
				git clone -b openwrt-19.07 https://github.com/openwrt/openwrt.git lede
				;;
				6)
				git clone  https://github.com/openwrt/openwrt.git lede
				;;
				0)
				exit
				;;
				*)
				clear && echo  "请输入正确的数字（1-6，0）" && Time
				source_download_openwrt
				 ;;
			esac
			source_if
}

source_download_pandorabox_sdk() {
	clear
		echo "  ----------------------------------------"
		echo ""
  		echo "	准备下载Pandorabox_SDK代码"
		echo ""
		echo "	1.PandoraBox-SDK-ralink-mt7621"
		echo ""
		echo "	0.exit"
		echo ""
		echo ""
		echo "  注：此源码只是SDK用于编译Pandorabox的插件"
		echo "  并不是Pandorabox的源码.不懂百度"
		#echo "PS：为什么不顺便放Openwrt的SDK呢，因为他的平台太多了，工程量巨大，先不考虑"
		echo "  ----------------------------------------"
		read  -p "请输入你要下载的源代码:" Download_source_pandorabox_sdk
			case "$Download_source_pandorabox_sdk" in
				1)
				wget --no-check-certificate http://downloads.pangubox.com:6380/sdk_for_pear/PandoraBox-SDK-ralink-mt7621_gcc-5.5.0_uClibc-1.0.x.Linux-x86_64.tar.xz  
				tar -xvJf PandoraBox-SDK-ralink-mt7621_gcc-5.5.0_uClibc-1.0.x.Linux-x86_64.tar.xz
				mv PandoraBox-SDK-ralink-mt7621_gcc-5.5.0_uClibc-1.0.x.Linux-x86_64 lede
				rm -rf PandoraBox-SDK-ralink-mt7621_gcc-5.5.0_uClibc-1.0.x.Linux-x86_64.tar.xz 
				rm -rf lede/dl
				wget --no-check-certificate https://raw.githubusercontent.com/coolsnowwolf/lede/master/feeds.conf.default -O $HOME/$fl/$file/lede/feeds.conf.default
				svn checkout https://github.com/coolsnowwolf/lede/trunk/package/base-files $HOME/$fl/$file/lede/package/base-files
				svn checkout https://github.com/coolsnowwolf/lede/trunk/package/boot $HOME/$fl/$file/lede/package/boot	
				svn checkout https://github.com/coolsnowwolf/lede/trunk/package/devel $HOME/$fl/$file/lede/package/devel
				svn checkout https://github.com/coolsnowwolf/lede/trunk/package/kernel $HOME/$fl/$file/lede/package/kernel
				svn checkout https://github.com/coolsnowwolf/lede/trunk/package/libs $HOME/$fl/$file/lede/package/libs
				svn checkout https://github.com/coolsnowwolf/lede/trunk/package/system $HOME/$fl/$file/lede/package/system
				cd $HOME/$fl/$file/lede				
				software_lean
				software_Setting
				update_feeds
				mk_df
				;;
				0)
				exit
				;;
				*)
				clear && echo  "请输入正确的数字（1，0）" && Time
				source_download_pandorabox_sdk
				 ;;
			esac
			source_if
			
	
}

source_if() {
		clear
		if [[ -e $HOME/$fl/$file/lede ]]; then
			cd lede
			software_luci
			cd $HOME/$fl/$file/lede
			update_feeds
			mk_df
		else
			echo ""
			echo "源码下载失败，请检查你的网络，回车重新选择下载" && read a && Time
			cd $HOME/$fl/$file
			source_download_select
		fi
}

software_luci() {
	if [[ -e $HOME/$fl/$file/lede/package/lean ]]; then
		 echo ""
	else
		echo "----------------------------------------------------"
  		echo "检测到你是openwrt官方源码，是否加入lean插件"
		echo " 1.添加插件(测试功能会有问题)"
		echo " 2.不添加插件"
		echo "----------------------------------------------------"
		read  -p "请输入你的选择:" software_luci_select
			case "$software_luci_select" in
				1)
				software_Setting
				;;
				2)
				echo ""
				;;
				*)
				clear && echo  "请输入正确的数字（1-2）" && Time
				software_luci_select
				 ;;
			esac					
	fi	
}
software_lean() {
	echo "开始下载lean的软件库"
			svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean  $HOME/$fl/$file/lede/package/lean
}

software_Setting() {
		#已知ok的插件有55r，frpc，其他有些用不到没有测试
		#已知不行的插件有samb，qt
		software_lean
		echo "开始配置优化"
			#初始配置
			cp $HOME/$fl/$file/lede/include/target.mk  $HOME/$fl/$file/lede/include/target.mk_back
			sed -i "s/base-files libc libgcc busybox dropbear mtd uci opkg netifd fstools uclient-fetch logd urandom-seed urngd/base-files libc libgcc busybox dropbear mtd uci opkg netifd fstools uclient-fetch logd block-mount coremark lm-sensors\
kmod-nf-nathelper kmod-nf-nathelper-extra kmod-ipt-raw wget libustream-openssl ca-certificates \
default-settings luci luci-app-ddns luci-app-sqm luci-app-upnp luci-app-adbyby-plus luci-app-autoreboot \
luci-app-filetransfer luci-app-vsftpd ddns-scripts_aliyun luci-app-ssr-plus \
luci-app-pptp-server luci-app-arpbind luci-app-vlmcsd luci-app-wifischedule luci-app-wol luci-app-ramfree \
luci-app-sfe luci-app-flowoffload luci-app-nlbwmon luci-app-usb-printer luci-app-accesscontrol luci-app-zerotier luci-app-xlnetacc/g"  $HOME/$fl/$file/lede/include/target.mk
			sed -i 's/block-mount fdisk lsblk mdadm/fdisk lsblk mdadm automount autosamba luci-app-usb-printer /g' $HOME/$fl/$file/lede/include/target.mk
			
			sed -i 's/dnsmasq iptables ip6tables ppp ppp-mod-pppoe firewall odhcpd-ipv6only odhcp6c kmod-ipt-offload/dnsmasq-full iptables ppp ppp-mod-pppoe firewall kmod-ipt-offload kmod-tcp-bbr/g' $HOME/$fl/$file/lede/include/target.mk
			
			#enable KERNEL_MIPS_FPU_EMULATOR
			sed -i 's/default y if TARGET_pistachio/default y/g' $HOME/$fl/$file/lede/config/Config-kernel.in
			
			#应用fullconenat
			cd $HOME/$fl/$file/lede
			rm -rf package/network/config/firewall
			svn checkout https://github.com/coolsnowwolf/lede/trunk/package/network/config/firewall $HOME/$fl/$file/lede/package/network/config/firewall

			#活动连接数
			sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

			#热爱党和国家
			#sed -i '69i\echo 0xDEADBEEF > /etc/config/google_fu_mode' package/lean/default-settings/files/zzz-default-settings

			#修改点东西55r
			sed -i 's/local ipkg = require("luci.model.ipkg")/-- local ipkg = require("luci.model.ipkg")--/g' package/lean/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/server.lua
			sed -i 's/local ipkg = require("luci.model.ipkg")/-- local ipkg = require("luci.model.ipkg")--/g' package/lean/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/client-config.lua

			#修改frp
			sed -i 's/local e=require("luci.model.ipkg")/-- local e=require("luci.model.ipkg")--/g' package/lean/luci-app-frpc/luasrc/model/cbi/frp/frp.lua

			#解决qt问题(未完成)
			if [[ -e $HOME/$fl/$OF/dl/qt-everywhere-opensource-src-5.8.0.tar.xz ]]; then
				echo ""
			else
				wget --no-check-certificate http://mirrors.ustc.edu.cn/qtproject/archive/qt/5.8/5.8.0/single/qt-everywhere-opensource-src-5.8.0.tar.xz -O $HOME/$fl/$OF/dl/qt-everywhere-opensource-src-5.8.0.tar.xz
				chmod 777 $HOME/$fl/$file/lede/scripts/download.pl
			fi

			update_feeds
			
			#修改一下luci 添加频率和温度
			rm -rf feeds/packages/utils/lm-sensors
			rm -rf feeds/luci/modules/luci-mod-status/luasrc/view/admin_status/index/10-system.htm	
			cp -r $HOME/$fl/$OF/$OCS/lean/lm-sensors	feeds/packages/utils/lm-sensors
			cp $HOME/$fl/$OF/$OCS/lean/10-system.htm feeds/luci/modules/luci-mod-status/luasrc/view/admin_status/index/10-system.htm

}

update_feeds() {
	clear
	echo "---------------------------"
	echo "      更新Feeds代码"
	echo "---------------------------"
	./scripts/feeds update -a && ./scripts/feeds install -a
	if [[ $? -eq 0 ]]; then
		echo ""
	else
		clear	
		echo "Feeds没有更新或安装成功，重新执行代码" && Time
		update_feeds
	fi
}

mk_df() {
	clear
	echo "---------------------------"
	echo ""
	echo ""
	echo "       测试编译环境"
	echo ""
	echo ""
	echo "--------------------------"
		make defconfig
 		cd
		description >> $HOME/$fl/$OF/description
		ln -s  $HOME/$fl/$OF/dl $HOME/$fl/$file/lede/dl
		ln -s  $HOME/$fl/$OF/My_config $HOME/$fl/$file/lede/My_config
		ln -s  $HOME/$fl/$OF/$OCS/openwrt.sh $HOME/$fl/$file/lede/openwrt.sh
		cd $HOME/$fl/$file/lede
		dl_detection
		dl_source
}

dl_detection() {
	if [[ -e $HOME/$fl/$OF/pl/download_1150.pl ]]; then
		echo ""
	else
		wget --no-check-certificate https://raw.githubusercontent.com/LGA1150/openwrt/exp/scripts/download.pl -O $HOME/$fl/$OF/pl/download_1150.pl
		chmod 777 $HOME/$fl/$file/lede/scripts/download.pl
	fi
	
}

dl_source() {
		clear && echo "选择DL服务器"
		echo "----------------------------------------"
		echo " 1.国内DL服务器，下载更快"
		echo ""
		echo " 2.官方的DL服务器（需要梯子，不然容易报错）"
		echo ""
		echo "----------------------------------------"
		read -p "请输入你的决定："  DL_so
			case "$DL_so" in
				1)
				domestic_dl
				dl_download
				;;
				2)
				official_dl
				dl_download
				;;
				*)
				clear && echo  "Error请输入正确的数字 [1-2]" && Time
				dl_source
				;;
			esac
}

domestic_dl() {
		if [[ -e $HOME/$fl/$file/lede/scripts/download_back.pl ]]; then
			echo ""
		else
			cp $HOME/$fl/$file/lede/scripts/download.pl $HOME/$fl/$file/lede/scripts/download_back.pl
			rm -rf $HOME/$fl/$file/lede/scripts/download.pl
			cp $HOME/$fl/$OF/pl/download_1150.pl $HOME/$fl/$file/lede/scripts/download.pl
		fi
}

official_dl() {
		if [[ -e $HOME/$fl/$file/lede/scripts/download_back.pl ]]; then
			rm -rf $HOME/$fl/$file/lede/scripts/download.pl
			mv $HOME/$fl/$file/lede/scripts/download_back.pl $HOME/$fl/$file/lede/scripts/download.pl
		else
			echo ""
		fi

}

dl_download() {
	clear
	echo "----------------------------------------------"
	echo "# 开始下载DL，如果出现下载很慢，请检查你的梯子 #"
	echo "------------------------------------------"
	Time
	make download V=s
	dl_error
	
}

dl_error() {
	echo "----------------------------------------"
	echo "请检查上面有没有error出现，如果有请重新下载"
	echo " 1.有"
	echo " 2.没有"
	echo "----------------------------------------"
	read -p "请输入你的决定：" dl_dw
	case "$dl_dw" in
		1)
		dl_download
		;;
		2)
		ecc
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		 clear && dl_error
		;;
	esac
}

ecc() {
	clear
	echo "    -----------------------------------------------"
	echo ""
	echo "		【××编译环境搭建成功××】"
	echo ""
	echo "	  1.请回车进入编译菜单，第一次回车较慢稍等"
	echo "	  2.进去编译菜单选择你要的功能完成以后Save"
	echo "	  3.菜单Exit以后会自动开始编译"
	echo ""
	echo "          注：如果不需要编译 Ctrl+c退出"
	echo "   -------------------------------------------------"
	read a
	make menuconfig
	if [[ $? -eq 0 ]]; then
		Save_My_Config_luci
		mk_menu
	else
		echo ""
		echo -e "$redError，请查看上面报错，回车重新执行命令$white"
		echo "" && read a
		ecc
	fi
}

mk_menu() {
	clear
	starttime=`date +'%Y-%m-%d %H:%M:%S'`
	echo "----------------------------------------"
	echo "请选择编译固件 OR 编译插件"
	echo " 1.编译固件"
	echo " 2.编译插件"
	echo "----------------------------------------"
	read -p "请输入你的决定：" mk_value
	case "$mk_value" in
		1)
		mk_compile_firmware
		;;
		2)
		mk_Compile_plugin
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		 clear && mk_menu
		;;
	esac
	
	
}

mk_compile_firmware() {
	clear
	echo  "编译固件是否要使用多线程编译"
	echo ""
	echo -e "  首次编译不建议，具体用几线程看你电脑，不懂百度，有机会编译失败,回车默认运行make V=s,$green多线程例子：（ make -j4 V=s ）$white  -j（这个值看你电脑），不要随便乱输，电脑炸了不管，如果你不需要多线程编译那么直接回车即可"
	echo ""
	read  -p "请输入你的参数(回车默认：make V=s)：" mk_f
	if [[ -z "$mk_f" ]];then
		clear && echo "开始执行编译" && Time
		make V=s
	else
		clear
		echo -e "你输入的线程是：$green$mk_f$white"
		echo "准备开始执行编译" && Time
		$mk_f
	fi
	
	endtime=`date +'%Y-%m-%d %H:%M:%S'`
	start_seconds=$(date --date="$starttime" +%s);
	end_seconds=$(date --date="$endtime" +%s);
	echo "本次运行时间： "$((end_seconds-start_seconds))"s"
	#by：BoomLee  ITdesk
}

mk_Compile_plugin() {
	clear
	echo "--------------------------------------------------------"
	echo "编译插件"
	echo ""
	echo -e "$green例子：make package/插件名字/compile V=99$white" 
	echo ""
	echo "PS:Openwrt首次git clone仓库不要用此功能，绝对失败!!!"
	echo "--------------------------------------------------------"
	read  -p "请输入你的参数：" mk_p
		clear
		echo -e "你输入的参数是：$green$mk_p$white"
		echo "准备开始执行编译" && Time
		$mk_p
	echo ""
	echo "" 
	echo "---------------------------------------------------------------------"
	echo ""
	echo -e "  潘多拉编译完成的插件在$green/Openwrt/文件名/lede/bin/packages/你的平台/base$white,如果还是找不到的话，看下有没有报错，善用搜索 "
	echo ""
	echo "回车可以继续编译插件，或者Ctrl + c终止操作"
	echo ""
	echo "---------------------------------------------------------------------"	
	read a
	mk_Continue_compiling_the_plugin
	endtime=`date +'%Y-%m-%d %H:%M:%S'`
	start_seconds=$(date --date="$starttime" +%s);
	end_seconds=$(date --date="$endtime" +%s);
	echo "本次运行时间： "$((end_seconds-start_seconds))"s"
	#by：BoomLee  ITdesk
}

mk_Continue_compiling_the_plugin() {
	clear
	echo "----------------------------------------"
	echo "是否需要继续编译插件"
	echo " 1.继续编译插件"
	echo " 2.不需要了"
	echo "----------------------------------------"
	read -p "请输入你的决定：" mk_value
	case "$mk_value" in
		1)
		mk_Compile_plugin
		;;
		2)
		echo ""
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		 clear && mk_Continue_compiling_the_plugin
		;;
	esac
}

description_if
