#!/bin/bash
set -u

version="2.9"
SF="Script_File"
OW="Openwrt"
by="ITdesk"
OCS="OpenwrtCompileScript"
cpu_cores=`cat /proc/cpuinfo | grep processor | wc -l`	

#颜色调整参考wen55333
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"

#ITdesk
itdesk_default_packages="DEFAULT_PACKAGES:=base-files libc libgcc busybox dropbear mtd uci opkg netifd fstools uclient-fetch logd block-mount coremark kmod-nf-nathelper kmod-nf-nathelper-extra kmod-ipt-raw wget  ca-certificates default-settings luci luci-app-adbyby-plus luci-app-autoreboot luci-app-arpbind luci-app-filetransfer luci-app-vsftpd  luci-app-ssr-plus  luci-app-vlmcsd luci-app-wifischedule luci-app-wol luci-app-ramfree luci-app-sfe luci-app-flowoffload luci-app-frpc luci-app-nlbwmon luci-app-accesscontrol  luci-app-ttyd luci-app-unblockmusic luci-app-watchcat "
		

rely_on() {
	sudo apt-get -y install asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache flex \
g++ gawk gcc gcc-multilib gettext git git-core help2man htop lib32gcc1 libc6-dev-i386 libglib2.0-dev libncurses5-dev \
libssl-dev libtool libz-dev libelf-dev make msmtp ncurses-term ocaml-nox p7zip p7zip-full patch qemu-utils sharutils \
subversion texinfo uglifyjs unzip upx xmlto yui-compressor zlib1g-dev make cmake
}

#显示编译文件夹
ls_file() {
	LF=`ls $HOME/$OW | grep -v $0  | grep -v Script_File`
	echo -e "$green$LF$white"
	echo ""
}
ls_file_luci(){
	clear && cd
	echo "***你的openwrt文件夹有以下几个***"
	ls_file
	read -p "请输入你的文件夹（记得区分大小写）：" file
	if [[ -e $HOME/$OW/$SF/tmp ]]; then
		echo ""
	else
		mkdir -p $HOME/$OW/$SF/tmp	
	fi
	
	echo "$file" > $HOME/$OW/$SF/tmp/you_file
	cd && cd $HOME/$OW/$file/lede
}

#显示config文件夹
ls_my_config() {
	LF=`ls My_config`
	echo -e "$green$LF$white"
	echo ""
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
	cd $HOME/$OW/$SF/$OCS
	CheckUrl_github=`curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null www.github.com`
		if [[ $CheckUrl_github -eq 301 ]]; then
			git fetch --all
			git reset --hard origin/master
			echo "回车进入编译菜单"
			read a
			bash ${openwrt}
		else
			echo "请检查你的网络，回车重新选择" && read a
			Time && main_interface
		fi
}

#选项5.其他选项
other() {
	clear
	echo "	      -------------------------------------"
	echo "	      	    【 5.其他选项 】"
	echo ""
	echo " 		  1 只搭建编译环境，不进行编译"
	echo ""
	echo "		  2 单独Download DL库 "
	echo ""
	echo "		  3 更新lean软件库 "
	echo ""
	echo "		  4 下载额外的插件 "
	echo ""
	echo "		  0. 回到上一级菜单"
	echo ""
	echo ""
	echo "		PS:请先搭建好梯子再进行编译，不然很慢！"
	echo "			     By:ITdesk"
	echo "	      --------------------------------------"
	read -p "请输入数字:" other_num
	case "$other_num" in
		1)
		clear
		echo "5.1 只搭建编译环境，不进行编译 " && Time
		update_system
		echo "环境搭建完成，请自行创建文件夹和git"
		;;
		2)
		dl_other
		;;
		3)
		update_lean_package
		;;
		4)
		download_package		
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
}

update_lean_package() {
	ls_file_luci
	make clean
	rm -rf package/lean
	source_openwrt_Setting
	echo "插件下载完成"
	Time
	display_git_log_luci
	update_feeds
	source_config
	make_defconfig
}

download_package() {
	ls_file_luci 
	if [[ -e package/Extra-plugin ]]; then
		echo ""	
	else
		mkdir package/Extra-plugin
	fi
	download_package_luci
	
}

download_package2() {
	cd $HOME/$OW/$file/lede 
	rm -rf ./tmp
	display_git_log_luci
	update_feeds
	source_config
	make_defconfig
}


download_package_luci() {
	cd $HOME/$OW/$file/lede/package/Extra-plugin
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
if [[ $? -eq 0 ]]; then
		download_package_customize_Decide
	else
		clear	
		echo -e "没有下载成功或者插件已经存在，请检查$red package/Extra-plugin $white里面是否已经存在" && Time
		download_package_customize
	fi
}

download_package_customize() {	
	cd $HOME/$OW/$file/lede/package/Extra-plugin
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
		cd $HOME/$OW/$file/lede
	else
		clear	
		echo -e "没有下载成功或者插件已经存在，请检查$red package/Extra-plugin $white里面是否已经存在" && Time
		download_package_customize
	fi
	download_package_customize_Decide
	
}

download_package_customize_Decide() {
	echo "----------------------------------------"
	echo -e "$green是否需要继续下载插件$white"
	echo " 1.继续下载插件"
	echo " 2.不需要了"
	echo "----------------------------------------"
	read -p "请输入你的决定：" Decide
	case "$Decide" in
		1)
		cd $HOME/$OW/$file/lede/package/Extra-plugin
		download_package_luci
		;;
		2)
		download_package2
		;;
		*)
		clear && echo -e"$red Error请输入正确的数字 [1-2]$white" && Time
		 clear && download_package_customize_Decide
		;;
	esac
}


#选项4.恢复编译环境
source_RestoreFactory() {
	ls_file_luci 
	echo ""
	if [[ -e $HOME/$OW/$file ]]; then
			cd $HOME/$OW/$file/lede
			echo -e  "危险操作注意：$red所有编译过的文件全部删除,openwrt源代码保存，回车继续$white  $green Ctrl+c取消$white" && read a
			echo -e ">>$green开始删除$file文件 $white" && Time
			echo ""
	 	 else
			clear && echo "-----文件名错误，请重新输入-----" && Time
			source_RestoreFactory
		fi
	make distclean
	ln -s $HOME/$OW/$SF/dl  $HOME/$OW/$file/lede/dl
	echo -e ">>$green $file文件删除完成 $white"
	echo -e "  所有编译过的文件全部删除完成，回车可以开始编译 不需要编译Ctrl+c取消,如依旧编译失败，请重新下载源代码" && read a
	
	display_git_log_luci
	source_config
	make_defconfig
}

#选项2.二次编译 与 源码更新合并
source_secondary_compilation() {
		ls_file_luci
		if [[ -e $HOME/$OW/$file ]]; then
			cd && cd $HOME/$OW/$file/lede
	 	 else
			clear && echo "-----文件名错误，请重新输入-----" && Time
			source_secondary_compilation
		fi
		echo "开始清理之前的文件"
		make clean && rm -rf ./tmp && Time
		if [[ `grep -o "PandoraBox" .config | wc -l` == "2" ]]; then
				echo "检测到PandoraBox源码，开始更新"				
				rm -rf package/lean && rm -rf ./feeds
				source_lean_package
				source_Soft_link			
				update_feeds
	 	 else
			display_git_log_luci
		fi
		source_config
		make_defconfig
}

#显示git log 提交记录
display_git_log() {
	git log -3 --graph --all --branches --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(bold green)(%ai)%C(reset) %C(white)%s%C(reset) %C(yellow) - %an%C(reset)%C(auto) %d%C(reset)'
#参考xueguang668
}

display_git_log_if() {
		git_branch=$(git branch -v | grep -o 落后 )
		if [[ "$git_branch" == "落后" ]]; then
			echo -e  "自动检测：$red本地源码已经落后远端，建议更新$white"
		else
			echo -e  "自动检测：$green本地源码与远端一样$white"
			
		fi
}

display_git_log_luci() {
	clear
		echo "稍等一下，正在取回分支，用于比较现在源码，不会更新请放心，速度看你网络"
		git fetch
		if [[ $? -eq 0 ]]; then
			echo ""
		else
			echo "取回分支没有成功，重新执行代码" && Time
			display_git_log_luci
		fi
		clear
		echo "----------------------------------------"
		echo -e "   $green显示远端仓库最近三条更新内容$white                  "
		echo "----------------------------------------"
		echo ""
		display_git_log
		echo ""
		echo ""
		echo -e "$yellow你现在所用的分支：$white`git branch -v`"
		echo ""
		display_git_log_if
		echo ""
		read -p "是否需要更新源码（1.yes 2.no）：" update_source
		case "$update_source" in
			1)
			source_update
			rm -rf ./feeds && rm -rf ./tmp
			Source_judgment
			;;
			2)
			source_if
			source_config
			ecc
			exit 
			;;
			100)
			source_update
			rm -rf ./feeds && rm -rf ./tmp	
			Source_judgment
			source_lean
			;;
			*)
			clear && echo  "Error请输入正确的数字 [1-2]" && Time
			display_git_log_luci
			;;
		esac	
}


source_config() {
	clear
		 echo "----------------------------------------------------------------------"
		 echo "是否要加载你之前保存的配置"
		 echo "     1.是（加载之前保存的配置）"
		 echo "     2.否（以全新的config进行编译）"
		 echo "     3.继续上次的编译（不对配置做任何操作）"
		 echo ""
		 echo "PS:如果源码进行过重大更新，建议直接选择2.以全新config进行编译，以减少报错"
		 echo "----------------------------------------------------------------------"
	read -p "请输入你的决定："  config
		case "$config" in
			1)
			transfer_my_config
			;;
			2)
			rm -rf .config && rm -rf ./tmp
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

#源码更新
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
		echo -e  "$green >>源码更新完成$white" && Time
	else
		echo -e  "$red >>源码更新失败，重新执行代码$white" && Time
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
description_if(){
   	cd
	clear
	echo "开始检测系统"
	curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null  www.baidu.com
	if [[ "$?" == "0" ]]; then
		clear && echo -e  "$green已经安装curl$white"
	else
		clear && echo "安装一下脚本用的依赖（注：不是openwrt的依赖而是脚本本身）"
		sudo apt update
		sudo apt install curl -y
	fi
	
	if [[ ! -d "$HOME/$OW/$SF/$OCS" ]]; then
		echo "开始创建主文件夹"
		mkdir -p $HOME/$OW/$SF/dl
		mkdir -p $HOME/$OW/$SF/My_config
		mkdir -p $HOME/$OW/$SF/tmp
	fi

  	#清理一下之前的编译文件
   	rm -rf $HOME/$OW/$SF/tmp/*

	#判断是否云编译
	workspace_home=`echo "$HOME" | grep gitpod | wc -l`
	if [[ "$workspace_home" == "1" ]]; then
        	echo "开始添加云编译系统变量"
		Cloud_env=`gp env | grep -o "shfile" | wc -l `
       		if [[ "$Cloud_env" == "0" ]]; then
           		eval $(gp env -e openwrt=$THEIA_WORKSPACE_ROOT/Openwrt/Script_File/OpenwrtCompileScript/openwrt.sh)
			eval $(gp env -e shfile=$THEIA_WORKSPACE_ROOT/Openwrt/Script_File/OpenwrtCompileScript)
           		echo -e  "系统变量添加完成，老样子启动  bash \$openwrt"
			Time
		fi
		HOME=`echo "$THEIA_WORKSPACE_ROOT"`
   	 else
		#添加系统变量
		openwrt_shfile_path=$(cat /etc/profile | grep -o shfile | wc -l)
		openwrt_script_path=$(cat /etc/profile | grep -o openwrt.sh | wc -l)
		if [[ "$openwrt_shfile_path" == "0" ]]; then
			echo "export shfile=$HOME/Openwrt/Script_File/OpenwrtCompileScript" | sudo tee -a /etc/profile
			echo -e "$green添加openwrt脚本变量成功,以后无论在那个目录输入 cd \$shfile 都可以进到脚本目录$white"
			#clear
		elif [[ "$openwrt_script_path" == "0" ]]; then
			echo "export openwrt=$HOME/Openwrt/Script_File/OpenwrtCompileScript/openwrt.sh" | sudo tee -a /etc/profile
			#clear
			echo "-----------------------------------------------------------------------"
			echo ""
			echo -e "$green添加openwrt变量成功,重启系统以后无论在那个目录输入 bash \$openwrt 都可以运行脚本$white"
			echo ""
			echo ""
			echo -e "                    $green回车重启你的操作系统!!!$white"
			echo "-----------------------------------------------------------------------"
			read a
			Time
			rm -rf `pwd`/$OCS
			reboot	
		else
			echo "系统变量已经添加"
		fi

	fi

	if [[ -e $HOME/$OW/$SF/$OCS ]]; then
		echo "存在"
	else 
		cd $HOME/$OW/$SF/
                git clone https://github.com/openwrtcompileshell/OpenwrtCompileScript.git
		cd 
		rm -rf `pwd`/$OCS
		cd $HOME/$OW/$SF/$OCS
		bash openwrt.sh
	fi

	check_system=$(cat /proc/version |grep -o Microsoft@Microsoft.com)
	if [[ "$check_system" == "Microsoft@Microsoft.com" ]]; then
		if [[ -e /etc/apt/sources.list.back ]]; then
			clear && echo -e "$green源码已替换$white"
		else
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
					sudo cp $HOME/$OW/$SF/$OCS/ubuntu18.4_sources.list /etc/apt/sources.list
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
			
			fi
		else
				echo "不是win10系统" && clear
		fi
	
	clear

	if [[ -e $HOME/$OW/$SF/description ]]; then
		self_test
		main_interface
	else
		clear
		description
		echo ""
		read -p "请输入密码:" ps
			if [[ $ps == $by ]]; then
				description >> $HOME/$OW/$SF/description && clear && self_test && main_interface
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

	
	clear
	echo "稍等一下，正在取回远端脚本源码，用于比较现在脚本源码，速度看你网络"
	cd && cd $HOME/$OW/$SF/$OCS
	git fetch
	clear
	git_branch=$(git branch -v | grep -o 落后 )
	if [[ "$git_branch" == "落后" ]]; then
		Script_status=`echo -e "$red建议更新$white"`
	else
		Script_status=`echo -e "$green最新$white"`		
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
	echo "		  	检测脚本是否最新： $Script_status "
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

	if [[ -e $HOME/$OW/$file ]]; then
		clear && echo "文件夹已存在，请重新输入文件夹名" && Time
		create_file

	 else
		echo "开始创建文件夹"
			mkdir $HOME/$OW/$file
			cd $HOME/$OW/$file  && clear
			echo "$file" > $HOME/$OW/$SF/tmp/you_file
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
			source_download_if
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
				ln -s $HOME/$OW/$SF/dl  $HOME/$OW/$file/lede/dl
				wget --no-check-certificate https://raw.githubusercontent.com/coolsnowwolf/lede/master/feeds.conf.default -O $HOME/$OW/$file/lede/feeds.conf.default
				source_lean_package
				cd $HOME/$OW/$file/lede	
				source_Soft_link			
				update_feeds
				make_defconfig
				;;
				0)
				exit
				;;
				*)
				clear && echo  "请输入正确的数字（1，0）" && Time
				source_download_pandorabox_sdk
				 ;;
			esac
			source_download_if
			
	
}

source_download_if() {
		if [[ -e $HOME/$OW/$file/lede ]]; then
			cd $HOME/$OW/$file/lede
			source_Soft_link
			Source_judgment
			make_defconfig
		else
			echo ""
			echo "源码下载失败，请检查你的网络，回车重新选择下载" && read a && Time
			cd $HOME/$OW/$file
			source_download_select
		fi
}

source_Soft_link() {
		#1
		if [[ -e $HOME/$OW/$file/lede/include/target.mk_back ]]; then
			echo ""
		else
			cp $HOME/$OW/$file/lede/include/target.mk  $HOME/$OW/$file/lede/include/target.mk_back		
		fi
		
		#2
		if [[ -e $HOME/$OW/$SF/description ]]; then
			echo ""
		else
			description >> $HOME/$OW/$SF/description
		fi

		#3		
		if [[ -e $HOME/$OW/$file/lede/dl ]]; then
			echo ""
		else
			ln -s  $HOME/$OW/$SF/dl $HOME/$OW/$file/lede/dl
		fi
	
		#4
		if [[ -e $HOME/$OW/$file/lede/My_config ]]; then
			echo ""
		else
			ln -s  $HOME/$OW/$SF/My_config $HOME/$OW/$file/lede/My_config
		fi

		#5
		if [[ -e $HOME/$OW/$file/lede/openwrt.sh ]]; then
			echo ""
		else
			ln -s  $HOME/$OW/$SF/$OCS/openwrt.sh $HOME/$OW/$file/lede/openwrt.sh
		fi
		
}

Source_judgment() {
	update_feeds
	source_Setting_Public
	source_if
	source_openwrt
}
source_if() {
		#检测源码属于那个版本
		if [[ `git remote -v | grep -o https://github.com/openwrt/openwrt.git | wc -l` == "2" ]]; then
			if [[ "$(git branch | grep -o lede-17.01 )" == "lede-17.01" ]]; then
				echo "openwrt-17.01" > $HOME/$OW/$SF/tmp/source_type
			elif [[ "$(git branch | grep -o openwrt-18.06 )" == "openwrt-18.06" ]]; then
				echo "openwrt-18.06" > $HOME/$OW/$SF/tmp/source_type
			elif [[ "$(git branch | grep -o openwrt-19.07 )" == "openwrt-19.07" ]]; then
				echo "openwrt-19.07" > $HOME/$OW/$SF/tmp/source_type
			elif [[ "$(git branch | grep -o master )" == "master" ]]; then
				echo "openwrt-master" > $HOME/$OW/$SF/tmp/source_type
			else
				echo "openwrt" > $HOME/$OW/$SF/tmp/source_type
			fi
		elif [[ `git remote -v | grep -o https://github.com/coolsnowwolf/lede.git | wc -l` == "2" ]]; then
			echo "lean" > $HOME/$OW/$SF/tmp/source_type
		else
			echo -e  "检查到你的源码是：$red未知源码$white"
			echo "unknown" > $HOME/$OW/$SF/tmp/source_type
			update_feeds
		fi
}



source_openwrt() {
		clear
		source_type=`cat "$HOME/$OW/$SF/tmp/source_type"`
		if [[ `echo "$source_type" | grep openwrt | wc -l` == "1" ]]; then
			echo "----------------------------------------------------"
  			echo -e "检测到你是$green$source_type$white源码，是否加入lean插件"
			echo " 1.添加插件(测试功能会有问题)"
			echo " 2.不添加插件"
			echo "----------------------------------------------------"
			read  -p "请输入你的选择:" Source_judgment_select
				case "$Source_judgment_select" in
					1)
					rm -rf package/lean 
					source_openwrt_Setting
					;;
					2)
					echo ""
					;;
					*)
					clear && echo  "请输入正确的数字（1-2）" && Time
					source_openwrt
					 ;;
			esac
		elif [[ `echo "$source_type" | grep lean | wc -l` == "1" ]]; then
			
			echo ""
		else
			echo ""
		fi
			
}

source_openwrt_Setting() {
		source_type=`cat "$HOME/$OW/$SF/tmp/source_type"`
		if [[ "$source_type" == "openwrt-18.06" ]]; then
			source_openwrt_Setting_18
		else
			echo ""
		fi
		#已知ok的插件有55r，frpc，其他有些用不到没有测试   #已知不行的插件有samb，qt
		source_lean_package
		echo -e ">>$green openwrt官方源码开始配置优化$white"
		Time	
		lean_packages_nas="DEFAULT_PACKAGES.nas:fdisk lsblk mdadm automount autosamba  "	

		lean_packages_router="DEFAULT_PACKAGES.router:=dnsmasq-full iptables ppp ppp-mod-pppoe firewall kmod-ipt-offload kmod-tcp-bbr"	
		
		#(DEFAULT_PACKAGES)
		if [[ "$(grep -o "urngd" include/target.mk_back )" == "urngd" ]]; then
			#19.7 and master (PACKAGES)
			sed -i "s/DEFAULT_PACKAGES:=base-files libc libgcc busybox dropbear mtd uci opkg netifd fstools uclient-fetch logd urandom-seed urngd/$itdesk_default_packages/g"  include/target.mk
		else
			#17.1 and 18.6 (PACKAGES)
			sed -i "s/DEFAULT_PACKAGES:=base-files libc libgcc busybox dropbear mtd uci opkg netifd fstools uclient-fetch logd/$itdesk_default_packages/g"  include/target.mk
		fi

		#17.1-master (PACKAGES.nas)
		sed -i "s/DEFAULT_PACKAGES.nas:=block-mount fdisk lsblk mdadm/$lean_packages_nas/g" include/target.mk
		
		#(PACKAGES.router)
		if [[ "$(grep -o "kmod-ipt-offload" include/target.mk_back )" == "urngd" ]]; then
			#18.6-master (PACKAGES.router)
			sed -i "s/DEFAULT_PACKAGES.router:=dnsmasq iptables ip6tables ppp ppp-mod-pppoe firewall odhcpd-ipv6only odhcp6c kmod-ipt-offload/$lean_packages_router/g" include/target.mk
		else
			#17.1 (PACKAGES.router)
			sed -i "s/DEFAULT_PACKAGES.router:=dnsmasq iptables ip6tables ppp ppp-mod-pppoe firewall odhcpd odhcp6c/$lean_packages_router/g" include/target.mk
		fi		
			
		#enable KERNEL_MIPS_FPU_EMULATOR
		sed -i 's/default y if TARGET_pistachio/default y/g' config/Config-kernel.in
			
		#应用fullconenat
		rm -rf package/network/config/firewall
		svn checkout https://github.com/coolsnowwolf/lede/trunk/package/network/config/firewall package/network/config/firewall

		#活动连接数
		sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

		#修改frp
		sed -i 's/local e=require("luci.model.ipkg")/-- local e=require("luci.model.ipkg")--/g' package/lean/luci-app-frpc/luasrc/model/cbi/frp/frp.lua
				
		#取消官方源码强制https
		sed -i '09s/\(.\{1\}\)/\#/' package/network/services/uhttpd/files/uhttpd.config
		sed -i '10s/\(.\{1\}\)/\#/' package/network/services/uhttpd/files/uhttpd.config
		sed -i 's/option redirect_https\s1/option redirect_https   0/g' package/network/services/uhttpd/files/uhttpd.config
		sed -i '46s/\(.\{1\}\)/\#/' package/network/services/uhttpd/files/uhttpd.init
		sed -i '47s/\(.\{1\}\)/\#/' package/network/services/uhttpd/files/uhttpd.init
		sed -i '53s/\(.\{1\}\)/\#/' package/network/services/uhttpd/files/uhttpd.init

		echo -e ">>$green openwrt官方源码配置优化完成$white"
}

source_openwrt_Setting_18() {
	clear
	echo -e ">>$green针对18.6版本开始配置优化$white"
	Time

	#修改x86启动等待时间成0秒(by:左右）
	sed -i 's/default "5"/default "0"/g' $HOME/$OW/$file/lede/config/Config-images.in

	#去掉IPV6(by:左右）
	sed -i 's/+IPV6:luci-proto-ipv6 //g' $HOME/$OW/$file/lede/feeds/luci/collections/luci/Makefile

	#修改exfat支持(by:左右）
	sed -i 's/+kmod-nls-base @BUILD_PATENTED/+kmod-nls-base/g' $HOME/$OW/$file/lede/feeds/packages/kernel/exfat-nofuse/Makefile

	#修改KB成MB(by:左右）
	sed -i 's/1024) + " <%:k/1048576) + " <%:M/g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
	sed -i 's/(info.memory/Math.floor(info.memory/g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
	sed -i 's/(Math.floor/Math.floor(/g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
	sed -i 's/(info.swap/Math.floor(info.swap/g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm	

	echo -e ">>$green针对18.6版本配置优化完成$white"
}

source_lean() {
	source_type=`cat "$HOME/$OW/$SF/tmp/source_type"`
	if [[ "$source_type" == "lean" ]]; then
		clear
		echo -e ">>$green针对lean版本开始配置优化$white" && Time
		
		#target.mk	
		sed -i "s/default-settings luci luci-app-ddns luci-app-sqm luci-app-upnp luci-app-adbyby-plus luci-app-autoreboot/default-settings luci-app-adbyby-plus luci-app-autoreboot/g" include/target.mk
		sed -i "s/luci-app-pptp-server luci-app-arpbind luci-app-vlmcsd luci-app-wol luci-app-ramfree/luci-app-arpbind luci-app-vlmcsd luci-app-wol luci-app-ramfree/g" include/target.mk
		sed -i "s/luci-app-sfe luci-app-flowoffload luci-app-nlbwmon luci-app-accesscontrol/luci-app-sfe luci-app-flowoffload luci-app-nlbwmon luci-app-accesscontrol luci-app-frpc luci-app-ttyd luci-app-watchcat luci-app-wifischedule/g" include/target.mk
		sed -i "s/autosamba luci-app-usb-printer/ /g" include/target.mk
		
		#x86_makefile
		x86_makefile=" luci-proto-bonding luci-app-unblockmusic luci-app-transmission luci-app-aria2 luci-app-baidupcs-web ddns-scripts_aliyun ca-certificates"
		if [[ `grep -o "$x86_makefile" target/linux/x86/Makefile ` == "$x86_makefile" ]]; then
			echo -e "$green x86_makefile配置已经修改，不做其他操作$white"
		else
			sed -i "s/luci-app-zerotier luci-app-ipsec-vpnd luci-app-pptp-server luci-proto-bonding luci-app-unblockmusic luci-app-qbittorrent luci-app-v2ray-server luci-app-zerotier luci-app-xlnetacc ddns-scripts_aliyun ca-certificates/$x86_makefile/g" target/linux/x86/Makefile	
		fi

		#ipq806_makefile
		ipq806_makefile="automount autosamba v2ray shadowsocks-libev-ss-redir shadowsocksr-libev-server luci-app-aria2 luci-app-baidupcs-web luci-app-unblockmusic fdisk e2fsprogs"
		if [[ `grep -o "$ipq806_makefile" target/linux/ipq806x/Makefile  ` == "$ipq806_makefile" ]]; then
			echo -e "$green 配置已经修改，不做其他操作$white"
		else
			sed -i "s/automount autosamba luci-app-ipsec-vpnd luci-app-xlnetacc v2ray shadowsocks-libev-ss-redir shadowsocksr-libev-server/$ipq806_makefile/g" target/linux/ipq806x/Makefile
		fi

		echo -e ">>$green lean版本配置优化完成$white"	

	fi
}

source_lean_package() {
	echo ""
	echo -e ">>$green开始下载lean的软件库$white"
	svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean  $HOME/$OW/$file/lede/package/lean
	if [[ $? -eq 0 ]]; then
		echo -e ">>$green下载lean的软件库完成$white"
	else
		clear	
		echo "下载lean插件没有成功，重新执行代码" && Time
		source_lean_package
	fi
}

#Public配置
source_Setting_Public() {
	clear
	echo -e ">>$green Public配置$white" 
	Time
	#隐藏首页显示用户名(by:kokang)
	sed -i 's/name="luci_username" value="<%=duser%>"/name="luci_username"/g' feeds/luci/modules/luci-base/luasrc/view/sysauth.htm
		
	#移动光标至第一格(by:kokang)
	sed -i "s/'luci_password'/'luci_username'/g" feeds/luci/modules/luci-base/luasrc/view/sysauth.htm

	#修改固件生成名字,增加当天日期(by:左右）
	sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=[$(shell date +%Y%m%d)]-$(VERSION_DIST_SANITIZED)/g' include/image.mk

	#默认选上v2
	v2if=$(grep -o "#v2default y if x86_64" package/lean/luci-app-ssr-plus/Makefile | wc -l)
	if [[ "$v2if" == "1" ]]; then
		echo "v2设置完成"
	else
		sed -i '23s/\(.\{1\}\)/\#v2/' package/lean/luci-app-ssr-plus/Makefile
		sed -i '23a\default y' package/lean/luci-app-ssr-plus/Makefile
		sed -i "23s/^/        /" package/lean/luci-app-ssr-plus/Makefile
		sed -i "24s/^/        /" package/lean/luci-app-ssr-plus/Makefile
	fi

	trojanif=$(grep -o "#tjdefault y if x86_64" package/lean/luci-app-ssr-plus/Makefile | wc -l)
	if [[ "$trojanif" == "1" ]]; then
		echo "Trojan设置完成"
	else
		sed -i '28s/\(.\{1\}\)/\#tj/' package/lean/luci-app-ssr-plus/Makefile
		sed -i '28a\default y' package/lean/luci-app-ssr-plus/Makefile
		sed -i "28s/^/        /" package/lean/luci-app-ssr-plus/Makefile
		sed -i "29s/^/        /" package/lean/luci-app-ssr-plus/Makefile
	fi

	#frpc替换为27版本
	sed -i "s/PKG_VERSION:=0.30.0/PKG_VERSION:=0.27.0/g" package/lean/frpc/Makefile
		
	#替换lean首页文件，添加天气代码(by:冷淡)
	indexif=$(grep -o "Local Weather" feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm)
	if [[ "$indexif" == "Local Weather" ]]; then
		echo "已经替换首页文件"
	else
		rm -rf feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
		cp $HOME/$OW/$SF/$OCS/Warehouse/index_Weather/index.htm feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
	fi
	
	x86indexif=$(grep -o "Local Weather" package/lean/autocore/files/index.htm)
	if [[ "$x86indexif" == "Local Weather" ]]; then
		echo "已经替换X86首页文件"
	else
		rm -rf package/lean/autocore/files/index.htm
		cp $HOME/$OW/$SF/$OCS/Warehouse/index_Weather/x86_index.htm package/lean/autocore/files/index.htm
	fi
	
	base_zh_po_if=$(grep -o "#天气预报" feeds/luci/modules/luci-base/po/zh-cn/base.po)
	if [[ "$base_zh_po_if" == "#天气预报" ]]; then
		echo "已添加天气预报翻译"
	else
		sed -i '$a \       ' feeds/luci/modules/luci-base/po/zh-cn/base.po
		sed -i '$a #天气预报' feeds/luci/modules/luci-base/po/zh-cn/base.po
		sed -i '$a msgid "Weather"' feeds/luci/modules/luci-base/po/zh-cn/base.po
		sed -i '$a msgstr "天气"' feeds/luci/modules/luci-base/po/zh-cn/base.po
		sed -i '$a \       ' feeds/luci/modules/luci-base/po/zh-cn/base.po
		sed -i '$a msgid "Local Weather"' feeds/luci/modules/luci-base/po/zh-cn/base.po
		sed -i '$a msgstr "本地天气"' feeds/luci/modules/luci-base/po/zh-cn/base.po
	fi

	echo -e ">>$green Public配置完成$white"	
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

make_defconfig() {
	clear
	echo "---------------------------"
	echo ""
	echo ""
	echo "       测试编译环境"
	echo ""
	echo ""
	echo "--------------------------"
		make defconfig
		Time
		ecc
}

dl_download() {
	#检测dl包完整性(by:P3TERX)
	if [[ -e $HOME/$OW/$file/lede/dl ]]; then
		cd $HOME/$OW/$file/lede/dl
		find . -size -1024c -exec ls -l {} \;
       	 	find . -size -1024c -exec rm -f {} \;
		cd $HOME/$OW/$file/lede
	else
		echo ""
	fi
	clear
	echo "----------------------------------------------"
	echo "# 开始下载DL，如果出现下载很慢，请检查你的梯子 #"
	echo ""
	echo -e "$green你的CPU核数为：$cpu_cores $white"
	echo -e "$green自动执行make download -j$cpu_cores  V=s加快下载速度$white"
	echo ""
	echo "ps：全速下载可能会导致系统反应慢点，稍等一下就好"	
	echo "----------------------------------------------"
	Time	
	make download -j$cpu_cores V=s		
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
		make_firmware_or_plugin
	else
		echo ""
		echo -e "$redError，请查看上面报错，回车重新执行命令$white"
		echo "" && read a
		ecc
	fi
}

make_firmware_or_plugin() {
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
		make_compile_firmware
		;;
		2)
		make_Compile_plugin
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		 clear && make_firmware_or_plugin
		;;
	esac
	
	
}

make_compile_firmware() {
	clear
	echo "--------------------------------------------------------"
	echo  "++编译固件是否要使用多线程编译++"
	echo ""
	echo "  首次编译不建议-j，具体用几线程看你电脑j有机会编译失败,"
	echo "不懂回车默认运行make V=s"
	echo ""
	echo -e "多线程例子：$green make -j4 V=s$white"
	echo -e "温馨提醒你的cpu核心数为：$green $cpu_cores $white"
	echo "--------------------------------------------------------"
	read  -p "请输入你的参数(回车默认：make V=s)：" mk_f
	if [[ -z "$mk_f" ]];then
		clear && echo "开始执行编译" && Time
		make V=s
	else
		dl_download
		clear
		echo -e "你输入的线程是：$green$mk_f$white"
		echo "准备开始执行编译" && Time
		$mk_f
	fi
	
	endtime=`date +'%Y-%m-%d %H:%M:%S'`
	start_seconds=$(date --date="$starttime" +%s);
	end_seconds=$(date --date="$endtime" +%s);
	echo "本次运行时间： "$((end_seconds-start_seconds))"s"
   	if_wo
	#by：BoomLee  ITdesk
}

if_wo() {
	#复制编译好的固件过去
        workspace_if=`echo $HOME | grep workspace | wc -l `
    	if [[ "$workspace_if" == "1" ]]; then
		da=`date +%Y%m%d`
		HOME=`echo "$THEIA_WORKSPACE_ROOT"`
       		source_type=`cat $HOME/$OW/$SF/tmp/source_type`
        	you_file=`cat $HOME/$OW/$SF/tmp/you_file`
		if [[ -e $HOME/bin ]]; then
			echo ""
		else
			mkdir -p $HOME/bin
        fi
        	cd && cd $HOME
		\cp -rf $HOME/$OW/$you_file/lede/bin/targets/  $HOME/bin/$da-$source_type
		echo -e "本次编译完成的固件已经copy到$green $HOME/bin/$da-$source_type $white"
        fi
}

make_Compile_plugin() {
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
	make_Continue_compiling_the_plugin
	endtime=`date +'%Y-%m-%d %H:%M:%S'`
	start_seconds=$(date --date="$starttime" +%s);
	end_seconds=$(date --date="$endtime" +%s);
	echo "本次运行时间： "$((end_seconds-start_seconds))"s"
	#by：BoomLee  ITdesk
}

make_Continue_compiling_the_plugin() {
	clear
	echo "----------------------------------------"
	echo "是否需要继续编译插件"
	echo " 1.继续编译插件"
	echo " 2.不需要了"
	echo "----------------------------------------"
	read -p "请输入你的决定：" mk_value
	case "$mk_value" in
		1)
		make_Compile_plugin
		;;
		2)
		echo ""
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		 clear && make_Continue_compiling_the_plugin
		;;
	esac
}

description_if


