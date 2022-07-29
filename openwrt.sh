#!/bin/bash
#set -x
#set -u

version="3.0"
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

calculating_time_start() {
	startTime=`date +%Y%m%d-%H:%M:%S`
	startTime_s=`date +%s`
}

calculating_time_end() {
	endTime=`date +%Y%m%d-%H:%M:%S`
	endTime_s=`date +%s`
	sumTime=$[ $endTime_s - $startTime_s ]

	echo -e "$yellow开始时间:$green $startTime ---> $yellow结束时间:$green $endTime $white"
	echo -e "耗时:"

	#以下代码ｃｏｐｙ　https://blog.csdn.net/weixin_33478575/article/details/116683248
	local T=$sumTime

	local D=$((T/60/60/24))

	local H=$((T/60/60%24))

	local M=$((T/60%60))

	local S=$((T%60))

	(( $D > 0 )) && printf '%d 天 ' $D

	(( $H > 0 )) && printf '%d 小时 ' $H

	(( $M > 0 )) && printf '%d 分钟 ' $M

	(( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '

	printf '%d 秒\n' $S

	echo ""

}

prompt() {
	echo -e "$green  脚本问题反馈：https://github.com/openwrtcompileshell/OpenwrtCompileScript/issues或者加群反馈(群在github有)$white"
	echo  -e " $yellow温馨提示，最近的编译依赖有变动，如果你最近一直编译失败，建议使用脚本5.其他选项 --- 1.只搭建编译环境功能 $white"
}

source_make_clean() {
	clear
	echo "--------------------------------------------------------"
	echo -e "$green++是否执行make clean清理固件++$white"
	echo ""
	echo "  1.执行make clean"
	echo ""
	echo "  2.不执行make clean"
	echo ""
	echo -e "$yellow  温馨提醒make clean会清理掉之前编译的固件，为了编译成功 $white"
	echo -e "$yellow率建议执行make clean，虽然编译时间会比较久$white"
	echo "--------------------------------------------------------"
	read  -p "请输入你的参数(回车默认：make clean)：" mk_c
	if [[ -z "$mk_c" ]];then
		clear && echo -e "$green开始执行make clean $white"
		make clean
	else
		case "$mk_c" in
		1)
		clear && echo -e "$green开始执行make clean $white"
		make clean
		;;
		2)
		clear && echo -e "$green不执行make clean $white"
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		 clear && source_make_clean
		;;
	esac
	fi

}

rely_on() {
	sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
	bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
	git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
	libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
	mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pip libpython3-dev qemu-utils \
	rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev

	#sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync bison g++ gcc help2man htop ncurses-term ocaml-nox sharutils yui-compressor make cmake
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
		echo "$file" > $HOME/$OW/$SF/tmp/you_file
	else
		mkdir -p $HOME/$OW/$SF/tmp	
	fi
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
		echo -ne "\r"
	done
}

#选项9.更新update_script
update_script() {
	clear
	cd $HOME/$OW/$SF/$OCS
	if [[ "$action1" == "" ]]; then
		git fetch --all
		git reset --hard origin/master
		if [[ $? -eq 0 ]]; then
			echo -e "$green>> 脚本源码更新成功回车进入编译菜单$white"
			read a
			bash $openwrt
		else
			echo -e "$red>> 脚本源码更新失败，重新执行代码$white"
			update_script
		fi
	else
		git fetch --all
		git reset --hard origin/master
		if [[ $? -eq 0 ]]; then
			echo -e "$green>> 脚本源码更新成功$white"
		else
			echo -e "$red>> 脚本源码更新失败，重新执行代码$white"
			update_script
		fi
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
		ls_file_luci
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
	dl_download
	if [[ $? -eq 0 ]]; then
		echo ""
		echo -e ">>$green dl已经单独下载完成$white"
	else
		clear	
		echo -e "$red dl没有下载成功,重新执行下载代码 $white" && Time
		dl_other
	fi
	 
}

update_lean_package() {
	ls_file_luci
	source_make_clean
	rm -rf package/lean
	source_openwrt_Setting
	echo "插件下载完成"
	Time
	display_git_log_luci
	update_feeds
	source_config
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
	cd $HOME/$OW/$you_file/lede
	rm -rf ./tmp
	display_git_log_luci
	update_feeds
	source_config
}


download_package_luci() {
	cd $HOME/$OW/$you_file/lede/package/Extra-plugin
	clear
	echo "	      -------------------------------------"
	echo "	      	    【 5.4额外的插件 】"
	echo ""
	echo " 		  1. luci-theme-argon"
	echo ""
	echo "		  2. luci-app-oaf （测试中）"
	echo ""
	echo "		  3. cups 共享打印机"
	echo ""
	echo "		  4. luci-app-netkeeper（闪讯插件）"
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
		3)
		cd $HOME/$OW/$you_file/lede/
		if [[ `cat feeds.conf.default | grep "cups" | wc -l` -eq 0 ]]; then
			echo "src-git cups https://github.com/TheMMcOfficial/lede-cups.git" >> feeds.conf.default
		fi
		./scripts/feeds update cups
		./scripts/feeds install cups
		;;
		4)
		cd $HOME/$OW/$you_file/lede/
		if [[ `cat feeds.conf.default | grep "netkeeper" | wc -l` -eq 0 ]]; then
			echo "src-git netkeeper https://github.com/sjz123321/feed-netkeeper.git" >> feeds.conf.default
		fi
		./scripts/feeds update netkeeper
		./scripts/feeds install netkeeper
		;;
		99)
		download_package_customize
		;;
		0)
		other
		;;
		*)
	clear && echo  "请输入正确的数字 [1-4,99,0]" && Time
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
	cd $HOME/$OW/$you_file/lede/package/Extra-plugin
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
		cd $HOME/$OW/$you_file/lede
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
		cd $HOME/$OW/$you_file/lede/package/Extra-plugin
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
	if [[ -e $HOME/$OW/$you_file ]]; then
			cd $HOME/$OW/$you_file/lede
			echo -e  "危险操作注意：$red所有编译过的文件全部删除,openwrt源代码保存，回车继续$white  $green Ctrl+c取消$white" && read a
			echo -e ">>$green开始删除$file文件 $white" && Time
			echo ""
	 	 else
			clear && echo "-----文件名错误，请重新输入-----" && Time
			source_RestoreFactory
		fi
	make distclean
	ln -s $HOME/$OW/$SF/dl  $HOME/$OW/$you_file/lede/dl
	echo -e ">>$green $file文件删除完成 $white"
	echo -e "  所有编译过的文件全部删除完成，回车可以开始编译 不需要编译Ctrl+c取消,如依旧编译失败，请重新下载源代码" && read a
	source_if
	display_git_log_luci	
}

#选项2.二次编译 与 源码更新合并
source_secondary_compilation() {
		ls_file_luci
		if [[ -e $HOME/$OW/$you_file ]]; then
			cd && cd $HOME/$OW/$you_file/lede
	 	 else
			clear && echo "-----文件名错误，请重新输入-----" && Time
			source_secondary_compilation
		fi
		echo "开始清理之前的文件"
		source_make_clean && rm -rf ./tmp && Time
		if [[ `grep -o "PandoraBox" .config | wc -l` == "2" ]]; then
				echo "检测到PandoraBox源码，开始更新"				
				rm -rf package/lean && rm -rf ./feeds
				source_lean_package
				source_Soft_link			
				update_feeds
	 	 else
			source_if
			display_git_log_luci
		fi
}

#显示git log 提交记录
display_git_log() {
	git log -3 --graph --all --branches --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(bold green)(%ai)%C(reset) %C(white)%s%C(reset) %C(yellow) - %an%C(reset)%C(auto) %d%C(reset)'
#参考xueguang668
}

display_git_log_if() {
		git_branch=$(git branch -v | grep -o 落后 )
		if [[ "$git_branch" == "落后" ]]; then
			echo -e  "$yellow自动检测：$white $red本地源码已经落后远端，建议更新$white"
		else
			echo -e  "$yellow自动检测：$white $green本地源码与远端一样$white"
		fi
}

display_git_log_luci() {
	clear
		echo "稍等一下，正在取回分支，用于比较现在源码，不会更新请放心，速度看你网络"
		git fetch
		if [[ $? -eq 0 ]]; then
			echo ""
		else
			echo -e "$red>> 取回分支没有成功，重新执行代码$white" && Time
			display_git_log_luci
		fi
		clear
		echo "----------------------------------------"
		echo -e "   $green显示远端仓库最近三条更新内容$white                  "
		echo "----------------------------------------"
		echo ""
		display_git_log
		echo ""
		echo -e "$yellow你所在的文件夹：$white $green $file $white"
		display_git_log_if
		echo -e "$yellow你现在所用的分支版本：$white`git branch -v`"
		echo ""
		read -p "是否需要更新源码（1.yes 2.no 3.退到/进到某个版本）：" update_source
		case "$update_source" in
			1)
			rm -rf ./feeds && source_update && rm -rf ./tmp	&& source_openwrt && update_feeds 
			;;
			2)
			source_openwrt && update_feeds 
			;;
			3)
			git_reset && source_openwrt && update_feeds
			;;
			*)
			clear && echo  "Error请输入正确的数字 [1-2]" && Time
			display_git_log_luci
			;;
		esac
		if [[ "$?" == "0" ]]; then
			source_lean 
			source_lienol
			source_Setting_Public	
			source_config
			make_defconfig
			ecc
		else
			echo -e  "$red >>命令错误或者网络不好，重新执行代码$white" && Time
			display_git_log_luci
		fi
		
}


git_reset() {
	clear
		echo "----------------------------------------"
		echo -e "   $green Git reset 回退到某个版本$white      "
		echo "----------------------------------------"
		echo -e "$green >>例子$white"
		echo -e "  git reset --hard HEAD^         $green回退到上个版本$white"
		echo -e "  git reset --hard HEAD~3        $green回退到前3次提交之前，以此类推$white"
		echo -e "  git reset --hard (commit_id)   $green退到/进到 指定commit的sha码(不会的百度)$white"
		echo ""
		echo -e "$yellow你所在的文件夹：$white $green $file $white"
		echo -e "$yellow你现在所用的分支版本：$white`git branch -v`"
		echo ""
		read -p "请输入你的命令（手动敲别偷懒）：" git_reset_read
		$git_reset_read
		rm -rf ./feeds &&  rm -rf ./tmp
		if [[ "$?" == "0" ]]; then
			clear
			echo ""
			echo -e  "$green >>命令执行完成$white"
			echo -e "$yellow你现在所用的分支版本：$white`git branch -v`" && Time
		else
			echo -e  "$red >>命令错误或者网络不好，重新执行代码$white" && Time
			git_reset
		fi
}

source_config() {
	clear
		 echo "----------------------------------------------------------------------"
		 echo -e "$green选择编译方式$white"
		 echo ""
		 echo "     1.以全新的config进行编译 (适合编译新机型)"
		 echo "     2.继续上次的编译（不对配置做任何操作）"
		 echo ""
		 echo -e "$yellow PS:如果源码进行过重大更新，建议直接选择1.以全新config进行编译，以减少报错$white"
		 echo "----------------------------------------------------------------------"
	read -p "请输入你的决定："  config
		case "$config" in
			1)
			rm -rf .config && rm -rf ./tmp
			;;
			2)
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
	source_branch=$(cat "$HOME/$OW/$SF/tmp/source_branch")
	clear
	if [[ "$source_branch" == "" ]]; then
		git fetch --all
		git reset --hard origin/master
	else
		git fetch --all
		git reset --hard origin/$source_branch
		if [[ $? -eq 0 ]]; then
			echo ""
		else
			echo -e "$red>> 源码更新失败，重新执行代码$white" && Time
			source_update_No_git_pull
		fi
	fi
}

source_update_git_pull() {
	git pull
	if [[ $? -eq 0 ]]; then
		echo ""
	else
		echo -e "$red>> 源码更新失败，重新执行代码$white" && Time
		source_update_git_pull
	fi
}

#选项1.开始搭建编译环境与主菜单

#判断代码
description_if(){
   	cd
	clear
	echo "开始检测系统"
	curl_if=$(dpkg -l | grep -o "curl" |sed -n '1p' | wc -l)
	if [[ "$curl_if" == "0" ]]; then
		clear && echo "安装一下脚本用的依赖（注：不是openwrt的依赖而是脚本本身）"
		sudo apt update
		sudo apt install curl -y
	else
		clear && echo -e  "$green已经安装curl$white"
	fi

:<<'COMMENT'
	#解决golang下载慢的问题,来源：https://goproxy.cn/
	if [[ ! "$GO111MODULE" == "no" ]]; thendescription_if
		echo "export GO111MODULE=on" | sudo tee -a /etc/profile
		echo "export GOPROXY=https://goproxy.cn" | sudo tee -a /etc/profile
		source /etc/profile
	fi
COMMENT
	
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
		echo "$yellow请注意云编译已经放弃维护很久了description_if，不保证你能编译成功,太耗时耗力，你如果不信邪你可以回车继续$white"
		read a
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

:<<'COMMENT'
	#win10
	check_win10_system=$(cat /proc/version |grep -o Microsoft@Microsoft.com)
	check_win10_system01=$(cat /proc/version |grep -o microsoft-standard)
	if [[ "$check_win10_system" == "Microsoft@Microsoft.com" ]]; then
		win10
	elif [[ "$check_win10_system01" == "microsoft-standard" ]]; then
		win10
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
COMMENT

	clear
	echo ""
	echo -e "$red图形界面编译已停止维护，请参考底下命令行进行编译$white"

}

win10() {
		export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
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
					sudo apt-get update
					sudo apt-get install git-core build-essential libssl-dev libncurses5-dev unzip
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
	if [[ $? -eq 0 ]]; then
		echo ""
	else
		echo -e "$red>> 取回分支没有成功，重新执行代码$white" && Time
		self_test
	fi
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
	echo -e "$green  脚本问题反馈：https://github.com/openwrtcompileshell/OpenwrtCompileScript/issues或者加群反馈(群在github有)$white"
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
		99)
		cd $HOME/$OW/lean/lede/
		n1_builder
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
	clear
	echo -e "$green>> 是否要更新系统，首次搭建选择是，其余选否(1.是  2.否)$white"
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
	clear && echo -e "$green >>准备更新系统 $white"	&& Time
	sudo apt-get update
	clear
	javahome=`echo "$JAVA_HOME" | grep gitpod | wc -l`
	if [[ "$javahome" == "1" ]]; then
		clear
		echo -e "$green >>检测到你是gitpod云编译主机，不需要安装依赖，直接创建文件夹即可 $white" && Time
		create_file
	else
		echo -e "$green >>准备安装依赖 $white" && Time
		rely_on
		if [[ $? -eq 0 ]]; then
			echo -e "$green >>安装完成 $white" && Time
		else
			clear
			echo -e "$red 依赖没有更新或安装成功，重新执行代码 $white" && Time
			update_system
		fi
	fi
}

create_file() {
	clear
	echo "----------------------------------------"
	echo -e "		   $green开始创建文件夹$white"
	echo "----------------------------------------"
	echo ""
	read -p "请输入你要创建的文件夹名(不要中文):" you_file

	if [[ -z "$you_file" ]];then
		echo -e "$red请不要输入空值!!!$white"
		Time
		create_file
	elif [[ -e $HOME/$OW/$you_file ]]; then
		clear
		echo -e "$green你输入的$yellow$you_file$green文件夹在$yellow$HOME/$OW$green已存在，请重新输入文件夹名$white" && Time
		create_file
	 else
		echo "开始创建文件夹"
			mkdir $HOME/$OW/$you_file
			cd $HOME/$OW/$you_file  && clear
			echo "$you_file" > $HOME/$OW/$SF/tmp/you_file
			#source_download_select
			source_download_openwrt
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
		echo -e "	$green准备下载openwrt代码$white"
		#echo -e "	$green默认下载:${yellow}Lean_master_source$white"
		echo "  -----------------------------------------"
		echo ""
		echo -e "	1.Lean_master_source　$yellow(* 推荐,我个人用的比较多)$white"
		echo ""
		echo " 	2.immortalwrt_openwrt-18.06-k5.4"
		echo ""
		read  -p "请输入你要下载的源代码:" Download_source_openwrt
			case "$Download_source_openwrt" in
				1)
				git clone https://github.com/coolsnowwolf/lede.git lede
				echo "lean" > $HOME/$OW/$SF/tmp/source_type
				;;
				2)
				git clone -b openwrt-18.06-k5.4 --single-branch  https://github.com/immortalwrt/immortalwrt lede
				echo "immortalwrt" > $HOME/$OW/$SF/tmp/source_type
				;;
				*)
				clear && echo  "请输入正确的数字（1-2）" && Time
				source_download_openwrt
				 ;;
			esac

:<<'COMMENT'
		echo ""
		echo ""
		echo "	1.Lean_lede-17.01_source(我很久没对这个进行测试了)"
		echo ""
		echo " 	2.Lean_master_source"
		echo ""
		echo " 	3.Lienol(dev-19.07)_source(我很久没对这个进行测试了)"
		echo ""
		echo "	4.openwrt17.1(stable version)_source(我很久没对这个进行测试了)"
		echo ""
		echo "	5.openwrt18.6(stable version)_source(我很久没对这个进行测试了)"
		echo ""
		echo "	6.openwrt19.7(stable version)_source(我很久没对这个进行测试了)"
		echo ""
		echo "	7.openwrt(Trunk)_source(我很久没对这个进行测试了)"
		echo ""
		echo "	0.exit"
		echo ""
		echo "我现在经常用lean的源码，并且我已很长时间没有维护这个互动界面了，你可以bash \$openwrt help查看命令用法"
		echo "  ----------------------------------------"
		read  -p "请输入你要下载的源代码:" Download_source_openwrt
			case "$Download_source_openwrt" in
				1)
				git clone -b lede-17.01 https://github.com/coolsnowwolf/openwrt.git lede
				;;
				2)
				git clone https://github.com/coolsnowwolf/lede.git lede
				;;
				3)
				git clone https://github.com/Lienol/openwrt.git lede
				;;
				4)
				git clone -b lede-17.01 https://github.com/openwrt/openwrt.git lede
				;;
				5)
				git clone -b openwrt-18.06 https://github.com/openwrt/openwrt.git lede
				;;
				6)
				git clone -b openwrt-19.07 https://github.com/openwrt/openwrt.git lede
				;;
				7)
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
COMMENT
			echo -e "$green你的源码已经为你下载到了$yellow$HOME/$OW/$you_file$white"
			Time
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
				ln -s $HOME/$OW/$SF/dl  $HOME/$OW/$you_file/lede/dl
				wget --no-check-certificate https://raw.githubusercontent.com/coolsnowwolf/lede/master/feeds.conf.default -O $HOME/$OW/$you_file/lede/feeds.conf.default
				source_lean_package
				cd $HOME/$OW/$you_file/lede
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
		if [[ -e $HOME/$OW/$you_file/lede ]]; then
			cd $HOME/$OW/$you_file/lede
			source_download_ok
			ecc
		else
			echo ""
			echo "源码下载失败，请检查你的网络，回车重新选择下载" && read a && Time
			cd $HOME/$OW/$you_file
			source_download_select
		fi
}

source_download_ok() {
			#source_if
			source_Soft_link
			update_feeds
			#source_openwrt
			source_lean
			#source_lienol
			source_Setting_Public
			make_defconfig
}

source_if() {
		#检测源码属于那个版本
		source_git_branch=$(git branch | sed 's/* //g')
		if [[ `git remote -v | grep -o https://github.com/openwrt/openwrt.git | wc -l` == "2" ]]; then
			echo "openwrt" > $HOME/$OW/$SF/tmp/source_type
			if [[ $source_git_branch == "lede-17.01" ]]; then
				echo "lede-17.01" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "openwrt-18.06" ]]; then
				echo "openwrt-18.06" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "openwrt-19.07" ]]; then
				echo "openwrt-19.07" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "master" ]]; then
				echo "master" > $HOME/$OW/$SF/tmp/source_branch
			fi
		elif [[ `git remote -v | grep -o https://github.com/coolsnowwolf/openwrt.git | wc -l` == "2" ]]; then
			echo "lean" > $HOME/$OW/$SF/tmp/source_type
			echo "lede-17.01" > $HOME/$OW/$SF/tmp/source_branch

		elif [[ `git remote -v | grep -o https://github.com/coolsnowwolf/lede.git | wc -l` == "2" ]]; then
			echo "lean" > $HOME/$OW/$SF/tmp/source_type
			if [[ $source_git_branch == "master" ]]; then
				echo "master" > $HOME/$OW/$SF/tmp/source_branch
			elif [[ $source_git_branch == "lede-17.01" ]]; then
				echo "lede-17.01" > $HOME/$OW/$SF/tmp/source_branch
			fi

		elif [[ `git remote -v | grep -o https://github.com/Lienol/openwrt.git | wc -l` == "2" ]]; then
			echo "lienol" > $HOME/$OW/$SF/tmp/source_type
			if [[ $source_git_branch == "my-19.07-full" ]]; then
				echo "my-19.07-full" > $HOME/$OW/$SF/tmp/source_branch
			fi

		else
			echo -e  "检查到你的源码是：$red未知源码$white"
			echo -e  "是否继续运行脚本！！！运行请回车，不运行请终止脚本"
			echo "unknown" > $HOME/$OW/$SF/tmp/source_type
			read a
		fi 
}


source_Soft_link() {
		#1
		if [[ -e $HOME/$OW/$SF/description ]]; then
			echo ""
		else
			description >> $HOME/$OW/$SF/description
		fi

		#2
		if [[ -e $HOME/$OW/$you_file/lede/dl ]]; then
			echo ""
		else
			ln -s  $HOME/$OW/$SF/dl $HOME/$OW/$you_file/lede/dl
		fi

		#3
		if [[ -e $HOME/$OW/$you_file/lede/My_config ]]; then
			echo ""
		else
			ln -s  $HOME/$OW/$SF/My_config $HOME/$OW/$you_file/lede/My_config
		fi

		#4
		if [[ -e $HOME/$OW/$you_file/lede/openwrt.sh ]]; then
			echo ""
		else
			ln -s  $HOME/$OW/$SF/$OCS/openwrt.sh $HOME/$OW/$you_file/lede/openwrt.sh
		fi

}


source_openwrt() {
		clear
		source_type=`cat "$HOME/$OW/$SF/tmp/source_type"`
		if [[ `echo "$source_type" | grep openwrt | wc -l` == "1" ]]; then
			rm -rf package/lean 
			source_openwrt_Setting
		elif [[ `echo "$source_type" | grep lean | wc -l` == "1" ]]; then
			echo ""
		fi
			
}

source_openwrt_Setting() {
		source_type=`cat "$HOME/$OW/$SF/tmp/source_type"`
		if [[ "$source_type" == "openwrt-18.06" ]]; then
			source_openwrt_Setting_18
		fi
		#下载lean插件
		source_lean_package
		echo -e ">>$green openwrt官方源码开始配置优化$white"
		Time
		itdesk_default_packages="block-mount coremark kmod-nf-nathelper kmod-nf-nathelper-extra kmod-ipt-raw wget libustream-openssl ca-certificates default-settings luci luci-app-ddns luci-app-upnp luci-app-autoreboot luci-app-webadmin luci-app-serverchan luci-app-diskman luci-app-passwall luci-app-fileassistant luci-app-jd-dailybonus luci-app-wrtbwmon luci-app-filetransfer luci-app-vsftpd luci-app-ssr-plus luci-app-unblockmusic luci-app-arpbind luci-app-vlmcsd luci-app-wol luci-app-ramfree luci-app-sfe luci-app-nlbwmon luci-app-accesscontrol  luci-app-frpc luci-app-ttyd luci-app-netdata  ddns-scripts_aliyun ddns-scripts_dnspod #tr_ok "
		lean_packages_nas="DEFAULT_PACKAGES.nas:=fdisk lsblk mdadm automount autosamba"	

		#修改target.mk
		if [[ `grep -o "#tr_ok" include/target.mk | wc -l ` == "1" ]]; then
			echo ""
		else
			#(DEFAULT_PACKAGES)
			if [[ "$(grep -o "urngd" include/target.mk_back )" == "urngd" ]]; then
				#19.7 and master (PACKAGES)
				sed -i "s/urandom-seed urngd/urandom-seed urngd $itdesk_default_packages/g"  include/target.mk
			else
				#17.1 and 18.6 (PACKAGES)
				sed -i "s/uclient-fetch logd/uclient-fetch logd $itdesk_default_packages/g"  include/target.mk
			fi

			#17.1-master (PACKAGES.nas)
			#sed -i "s/DEFAULT_PACKAGES.nas:=block-mount fdisk lsblk mdadm/$lean_packages_nas/g" include/target.mk	
		fi	
		
		#x86_makefile
		x86_makefile="partx-utils mkf2fs fdisk e2fsprogs wpad kmod-usb-hid kmod-mmc-spi kmod-sdhci kmod-ath5k kmod-ath9k kmod-ath9k-htc kmod-ath10k kmod-rt2800-usb kmod-e1000e kmod-igb kmod-igbvf kmod-ixgbe kmod-pcnet32 kmod-tulip kmod-vmxnet3 kmod-i40e kmod-i40evf kmod-r8125 kmod-8139cp kmod-8139too kmod-fs-f2fs kmod-sound-hda-core kmod-sound-hda-codec-realtek kmod-sound-hda-codec-via kmod-sound-via82xx kmod-sound-hda-intel kmod-sound-hda-codec-hdmi kmod-sound-i8x0 kmod-usb-audio kmod-usb-net kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 kmod-r8168 kmod-mlx4-core kmod-mlx5-core kmod-drm-amdgpu ath10k-firmware-qca988x ath10k-firmware-qca9888 ath10k-firmware-qca9984 brcmfmac-firmware-43602a1-pcie htop lm-sensors  automount autosamba luci-app-aria2 luci-app-frps luci-app-hd-idle luci-app-dockerman iperf iperf3 luci-app-ddns luci-app-sqm  ca-certificates #autocore"
		FEATURES="squashfs vdi vmdk pcmcia fpu boot-part rootfs-part ext4 targz"
		if [[ `grep -o "$x86_makefile" target/linux/x86/Makefile ` == "$x86_makefile" ]]; then
			echo -e "$green x86_makefile配置已经修改，不做其他操作$white"
		else
			sed -i "s/partx-utils mkf2fs e2fsprogs/$x86_makefile/g" target/linux/x86/Makefile
		fi	
			
		#enable KERNEL_MIPS_FPU_EMULATOR
		sed -i 's/default y if TARGET_pistachio/default y/g' config/Config-kernel.in
			
		#应用fullconenat
		#rm -rf package/network/config/firewall
		#svn checkout https://github.com/coolsnowwolf/lede/trunk/package/network/config/firewall package/network/config/firewall

		#docekr-ce
		if [[ -e package/other-plugins/docker-ce ]]; then
			rm -rf package/other-plugins/docker-ce
			svn checkout https://github.com/coolsnowwolf/packages/trunk/utils/docker-ce  $HOME/$OW/$you_file/lede/package/other-plugins/docker-ce
			cd $HOME/$OW/$you_file/lede/
		else
			svn checkout https://github.com/coolsnowwolf/packages/trunk/utils/docker-ce  $HOME/$OW/$you_file/lede/package/other-plugins/docker-ce
		fi

		#添加库
		echo "src-git helloworld https://github.com/fw876/helloworld" >> feeds.conf.default && update_feeds
		

		#活动连接数
		sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

		#删除lean_frp
		#rm -rf package/lean/frp
		#rm -rf package/lean/luci-app-frpc		
				
		#取消官方源码强制https
		sed -i '09s/\(.\{1\}\)/\#/' package/network/services/uhttpd/files/uhttpd.config
		sed -i '10s/\(.\{1\}\)/\#/' package/network/services/uhttpd/files/uhttpd.config
		sed -i 's/option redirect_https\s1/option redirect_https   0/g' package/network/services/uhttpd/files/uhttpd.config
		sed -i '46s/\(.\{1\}\)/\#/' package/network/services/uhttpd/files/uhttpd.init
		sed -i '47s/\(.\{1\}\)/\#/' package/network/services/uhttpd/files/uhttpd.init
		sed -i '53s/\(.\{1\}\)/\#/' package/network/services/uhttpd/files/uhttpd.init
		
		#upx ucl 
		if [[ $(grep -o "upx" tools/Makefile | wc -l)  == "1" ]]; then
			echo ""
		else
			sed -i '31a\tools-y += ucl upx' tools/Makefile
			svn checkout https://github.com/coolsnowwolf/lede/trunk/tools/upx  $HOME/$OW/$you_file/lede/tools/upx
			svn checkout https://github.com/coolsnowwolf/lede/trunk/tools/ucl  $HOME/$OW/$you_file/lede/tools/ucl
			
		fi 
		echo "" > $HOME/$OW/$SF/tmp/source_branch
		other_plugins
		echo -e ">>$green openwrt官方源码配置优化完成$white"
}

source_openwrt_Setting_18() {
	clear
	echo -e ">>$green针对18.6版本开始配置优化$white"
	Time

	#修改x86启动等待时间成0秒(by:左右）
	sed -i 's/default "5"/default "0"/g' $HOME/$OW/$you_file/lede/config/Config-images.in

	#去掉IPV6(by:左右）
	sed -i 's/+IPV6:luci-proto-ipv6 //g' $HOME/$OW/$you_file/lede/feeds/luci/collections/luci/Makefile

	#修改exfat支持(by:左右）
	sed -i 's/+kmod-nls-base @BUILD_PATENTED/+kmod-nls-base/g' $HOME/$OW/$you_file/lede/feeds/packages/kernel/exfat-nofuse/Makefile

	#修改KB成MB(by:左右）
	sed -i 's/1024) + " <%:k/1048576) + " <%:M/g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
	sed -i 's/(info.memory/Math.floor(info.memory/g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
	sed -i 's/(Math.floor/Math.floor(/g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
	sed -i 's/(info.swap/Math.floor(info.swap/g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm	

	echo -e ">>$green针对18.6版本配置优化完成$white"
}

source_lean() {
	source_type=`git remote show origin | grep "coolsnowwolf" | wc -l`
	if [[ "$source_type" == "2" ]]; then
		clear
		echo -e ">>$green针对lean版本开始配置优化$white" && Time
		
		#添加库
		echo "src-git helloworld https://github.com/fw876/helloworld" >> feeds.conf.default
		update_feeds

		#target.mk
		target_mk="automount autosamba luci-app-filetransfer luci-app-ssr-plus luci-app-sfe luci-app-accesscontrol luci-app-serverchan luci-app-diskman luci-app-fileassistant  luci-app-wrtbwmon luci-app-frpc  luci-app-arpbind luci-app-wol luci-app-unblockmusic  luci-app-dockerman luci-app-ikoolproxy lm-sensors #tr_ok"
		if [[ `grep -o "#tr_ok" include/target.mk | wc -l ` == "1" ]]; then
			echo ""
		else
			sed -i "s/luci-app-autoreboot/luci-app-autoreboot  $target_mk/g" include/target.mk

		fi	
		
		#x86_makefile
		x86_makefile="luci-app-aria2 luci-app-baidupcs-web luci-app-frps luci-app-hd-idle iperf iperf3 luci-app-ddns jd_openwrt_script luci-app-openvpn-server luci-app-upnp luci-app-turboacc luci-app-v2ray-server ipv6helper luci-app-go-aliyundrive-webdav"
		if [[ `grep -o "$x86_makefile" target/linux/x86/Makefile ` == "$x86_makefile" ]]; then
			echo -e "$green x86_makefile配置已经修改，不做其他操作$white"
		else
			sed -i "s/luci-app-unblockmusic luci-app-zerotier luci-app-xlnetacc/$x86_makefile/g" target/linux/x86/Makefile
			sed -i "s/luci-app-ipsec-vpnd luci-proto-bonding//g" target/linux/x86/Makefile
			sed -i "s/luci-app-qbittorrent//g" target/linux/x86/Makefile
			sed -i "s/luci-app-uugamebooster//g" target/linux/x86/Makefile
			sed -i "s/luci-app-adbyby-plus//g" target/linux/x86/Makefile
			sed -i "s/luci-app-wireguard//g" target/linux/x86/Makefile
		fi

		#修改X86默认固件大小
		if [[ `grep -o "default 160" config/Config-images.in | wc -l` == "1" ]]; then
			sed -i 's\default 160\default 1024\g' config/Config-images.in
			#传统模式
			grub_position=$(cat config/Config-images.in | grep -n "Build GRUB images" | awk  '{print $1}' | sed "s/://")
			del_num=$(($grub_position + 4))
			add_num=$(($grub_position + 3))
			sed -i "$del_num d" config/Config-images.in
			sed -i "$add_num a\default y" config/Config-images.in
		else
			echo ""
		fi

		#默认对x86首页下手，其他的你们安全了
		x86indexif=$(grep -o "Local Weather" package/lean/autocore/files/x86/index.htm)
		if [[ "$x86indexif" == "Local Weather" ]]; then
			echo "已经替换X86首页文件"
		else
			rm -rf package/lean/autocore/files/x86/index.htm
			cp $HOME/$OW/$SF/$OCS/Warehouse/index_Weather/x86_index.htm package/lean/autocore/files/x86/index.htm
		fi
	
		base_zh_po_if=$(grep -o "#天气预报" feeds/luci/modules/luci-base/po/zh-cn/base.po)
		if [[ "$base_zh_po_if" == "#天气预报" ]]; then
			echo "已添加天气预报翻译"
		else
			sed -i '$a \#天气预报\nmsgid "Weather"\nmsgstr "天气"\n\nmsgid "Local Weather"\nmsgstr "本地天气"\n ' feeds/luci/modules/luci-base/po/zh-cn/base.po
		fi

		#首页显示编译时间
		Compile_time_if=$(grep -o "#首页显示编译时间" feeds/luci/modules/luci-base/po/zh-cn/base.po)
		if [[ "$Compile_time_if" == "#首页显示编译时间" ]]; then
			echo "已添加首页显示编译时间"
		else
			sed -i '$a \#首页显示编译时间\nmsgid "Compile_time"\nmsgstr "固件编译时间"\n' feeds/luci/modules/luci-base/po/zh-cn/base.po
			sed -i '$d' package/lean/default-settings/files/zzz-default-settings
			sed -i '$d' package/lean/default-settings/files/zzz-default-settings
			echo "echo \"`date "+%Y-%m-%d %H:%M"` (commit:`git log -1 --format=format:'%C(bold white)%h%C(reset)'`)\" >> /etc/Compile_time" >> package/lean/default-settings/files/zzz-default-settings
			echo "exit 0" >> package/lean/default-settings/files/zzz-default-settings
		fi

:<<'COMMENT'
		#修改x86内核
		if [[ `grep -o "KERNEL_PATCHVER:=5.4" target/linux/x86/Makefile | wc -l` == "1" ]]; then
			sed -i 's\KERNEL_PATCHVER:=5.4\KERNEL_PATCHVER:=4.19\g' target/linux/x86/Makefile
			sed -i 's\KERNEL_TESTING_PATCHVER:=5.4\KERNEL_TESTING_PATCHVER:=4.19\g' target/linux/x86/Makefile
		else
			echo ""
		fi
COMMENT
		#ipq806x_makefile
		ipq806x_makefile="kmod-ath10k-ct wpad-openssl jd_openwrt_script"
		#ipq806x_makefile="kmod-ath10k-ct wpad-openssl kmod-qca-nss-drv kmod-qca-nss-drv-qdisc kmod-qca-nss-ecm-standard kmod-qca-nss-gmac kmod-nss-ifb iptables-mod-physdev kmod-ipt-physdev kmod-qca-nss-drv-pppoe MAC80211_NSS_SUPPORT  luci-app-cpufreq jd_openwrt_script"
		if [[ `grep -o "$ipq806x_makefile" target/linux/ipq806x/Makefile ` == "$ipq806x_makefile" ]]; then
			echo -e "$green ipq806x_makefile配置已经修改，不做其他操作$white"
		else
			sed -i "s/kmod-ath10k-ct wpad-openssl/$ipq806x_makefile/g" target/linux/ipq806x/Makefile
		fi


		#N1_makefile
		N1_makefile="mkf2fs e2fsprogs brcmfmac-firmware-43430-sdio brcmfmac-firmware-43455-sdio brcmfmac-firmware-usb wireless-regdb kmod-b44 kmod-brcmfmac kmod-brcmutil kmod-cfg80211 fdisk blkid lsblk losetup uuidgen  tar  gawk getopt  bash perl perlbase-utf8 acl attr chattr debugfs dosfstools dumpe2fs e2freefrag e4crypt exfat-fsck exfat-mkfs f2fs-tools filefrag fstrim fuse-utils hfsfsck lsattr mkhfs ncdu nfs-utils nfs-utils-libs ntfs-3g ntfs-3g-utils resize2fs squashfs-tools-mksquashfs squashfs-tools-unsquashfs swap-utils tune2fs xfs-admin xfs-fsck xfs-growfs xfs-mkfs ddns-scripts_aliyun jd_openwrt_script luci-app-aria2 luci-app-frps luci-app-hd-idle luci-app-openvpn-server luci-app-transmission luci-app-upnp"
		if [[ `grep -o "$N1_makefile" target/linux/armvirt/Makefile ` == "$N1_makefile" ]]; then
			echo -e "$green N1_makefile配置已经修改，不做其他操作$white"
		else
			sed -i "s/mkf2fs e2fsprogs/$N1_makefile/g" target/linux/armvirt/Makefile
			sed -i "s/default y if TARGET_sunxi/default y if TARGET_sunxi\n default y if TARGET_armvirt/g" package/kernel/mac80211/broadcom.mk

		fi

		#rockchip_makefile
		rockchip_makefile="luci-app-vsftpd ipv6helper autocore-arm jd_openwrt_script luci-app-aria2 luci-app-frps luci-app-hd-idle luci-app-openvpn-server luci-app-ssrserver-python luci-app-transmission luci-app-zerotier wget"
		if [[ `grep -o "$rockchip_makefile" target/linux/rockchip/Makefile ` == "$rockchip_makefile" ]]; then
			echo -e "$green rockchip_makefile配置已经修改，不做其他操作$white"
		else
			sed -i "s/luci-app-zerotier/$rockchip_makefile/g" target/linux/rockchip/Makefile

		fi

		#修改网易云启用node.js
		sed -i "s/default n/default y/g" feeds/luci/applications/luci-app-unblockmusic/Makefile

		#将diskman选项启用
		sed -i "s/default n/default y/g" feeds/luci/applications/luci-app-diskman/Makefile

		#下载插件
		other_plugins

		#删除这个，解决报错问题
		rm -rf dl/go-mod-cache && rm -rf ./tmp

		update_feeds
		#node.js
		node_if=$(grep "https://github.com/nxhack/openwrt-node-packages.git" feeds.conf.default | wc -l)
		if [[  "$node_if" == "0" ]];then
			echo "src-git node https://github.com/nxhack/openwrt-node-packages.git" >>feeds.conf.default
			./scripts/feeds update node
			rm ./package/feeds/packages/node
			rm ./package/feeds/packages/node-*
			./scripts/feeds install -a -p node
		fi
		echo -e ">>$green lean版本配置优化完成$white"

	fi
:<<'COMMENT'
		#替换lean首页文件，添加天气代码(by:冷淡)
		indexif=$(grep -o "Local Weather" feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm)
		if [[ "$indexif" == "Local Weather" ]]; then
			echo "已经替换首页文件"
		else
			rm -rf feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
			cp $HOME/$OW/$SF/$OCS/Warehouse/index_Weather/index.htm feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
		fi

		#增加首页温度显示
		temperature_if=$(grep -o "@TARGET_x86" package/lean/autocore/Makefile | wc -l)
		if [[ "$temperature_if" == "1" ]]; then
			rm -rf package/lean/autocore/files/autocore
			sed -i "s/@TARGET_x86/@(i386||x86_64||arm||mipsel||mips||aarch64)/g"  package/lean/autocore/Makefile
			cp $HOME/$OW/$SF/$OCS/Warehouse/index_temperature/autocore  package/lean/autocore/files/autocore
			cp $HOME/$OW/$SF/$OCS/Warehouse/index_temperature/temperature package/lean/autocore/files/sbin/temperature
		else
			echo "temperature添加完成"
		fi

		#默认选上其他参数
		if [[ -e package/other-plugins/luci-app-passwall ]]; then
			sed -i '54d' package/other-plugins/luci-app-passwall/Makefile
			sed -i '53a\default y if i386||x86_64||arm||aarch64' package/other-plugins/luci-app-passwall/Makefile
			sed -i "54s/^/        /" package/other-plugins/luci-app-passwall/Makefile

			sed -i '66d' package/other-plugins/luci-app-passwall/Makefile
			sed -i '65a\default y if i386||x86_64||arm||aarch64' package/other-plugins/luci-app-passwall/Makefile
			sed -i "66s/^/        /" package/other-plugins/luci-app-passwall/Makefile

			sed -i '74d' package/other-plugins/luci-app-passwall/Makefile
			sed -i '73a\default y if i386||x86_64||arm||aarch64' package/other-plugins/luci-app-passwall/Makefile
			sed -i "74s/^/        /" package/other-plugins/luci-app-passwall/Makefile
		fi
COMMENT
}


source_lean_package() {
	echo ""
	echo -e ">>$green开始下载lean的软件库$white"
	svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean  $HOME/$OW/$you_file/lede/package/lean
	if [[ $? -eq 0 ]]; then
		echo -e ">>$green下载lean的软件库完成$white"
	else
		clear
		echo "下载lean插件没有成功，重新执行代码" && Time
		source_lean_package
	fi
}

source_lienol() {
	source_type=`cat "$HOME/$OW/$SF/tmp/source_type"`
	if [[ "$source_type" == "lienol" ]]; then
		clear
		echo -e ">>$green针对lienol版本开始配置优化$white" && Time

		if [[ -e $HOME/$OW/$you_file/lede/package/lean/luci-app-ttyd ]]; then
			echo ""
		else
			svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ttyd $HOME/$OW/$you_file/lede/package/lean/luci-app-ttyd
		fi

		./scripts/feeds install -a

		#lienol_target.mk
		sed -i "s/luci-app-ddns/luci-app-sqm /g" include/target.mk
		sed -i "s/luci-theme-bootstrap-mod/ /g" include/target.mk
		sed -i "s/luci-app-pptp-vpnserver-manyusers luci-app-pppoe-server luci-app-pppoe-relay/luci-app-autoreboot luci-app-frpc luci-app-ttyd luci-app-arpbind /g" include/target.mk
		sed -i "s/ip6tables/ /g" include/target.mk
		sed -i "s/odhcpd-ipv6only odhcp6c/ /g" include/target.mk

		#x86禁用gzip压缩
		sed -i "s/depends on TARGET_IMAGES_PAD || TARGET_ROOTFS_EXT4FS || TARGET_x86/depends on TARGET_IMAGES_PAD || TARGET_ROOTFS_EXT4FS #|| TARGET_x86/g" config/Config-images.in

		#lienol_x86_makefile
		x86_makefile="luci-app-unblockmusic luci-app-transmission luci-app-aria2 luci-app-baidupcs-web  "
		if [[ `grep -o "$x86_makefile" target/linux/x86/Makefile ` == "$x86_makefile" ]]; then
			echo -e "$green x86_makefile配置已经修改，不做其他操作$white"
		else
			sed -i "s/luci-app-v2ray-server luci-app-trojan-server/$x86_makefile/g" target/linux/x86/Makefile
		fi

		#lienol_ipq806_makefile
		ipq806_makefile="uboot-envtools automount autosamba  luci-app-aria2 luci-app-baidupcs-web luci-app-unblockmusic luci-app-wifischedule fdisk e2fsprogs"
		if [[ `grep -o "$ipq806_makefile" target/linux/ipq806x/Makefile  ` == "$ipq806_makefile" ]]; then
			echo -e "$green 配置已经修改，不做其他操作$white"
		else
			sed -i "s/uboot-envtools/$ipq806_makefile/g" target/linux/ipq806x/Makefile
		fi

		echo -e ">>$green lean版本配置优化完成$white"
:<<'COMMENT'
		#默认选上tj
		trojanif=$(grep -o "#tjdefault n" feeds/lienol/lienol/luci-app-passwall/Makefile | wc -l)
		if [[ "$trojanif" == "1" ]]; then
			echo "Trojan设置完成"
		else
			sed -i '45s/\(.\{1\}\)/\#tj/' feeds/lienol/lienol/luci-app-passwall/Makefile
			sed -i '45a\default y' feeds/lienol/lienol/luci-app-passwall/Makefile
			sed -i "45s/^/        /" feeds/lienol/lienol/luci-app-passwall/Makefile
			sed -i "46s/^/        /" feeds/lienol/lienol/luci-app-passwall/Makefile
		fi

		#更改passwall国内的dns
		passwall_dns=$(grep -o "option up_china_dns '114.114.114.114'" feeds/lienol/lienol/luci-app-passwall/root/etc/config/passwall | wc -l)
		if [[ "$passwall_dns" == "1" ]]; then
			sed -i "s/option up_china_dns '114.114.114.114'/option up_china_dns '223.5.5.5'/g" feeds/lienol/lienol/luci-app-passwall/root/etc/config/passwall
		fi

		#更改passwall的dns模式
		dns_mode=$(grep -o "option dns_mode 'pdnsd'" feeds/lienol/lienol/luci-app-passwall/root/etc/config/passwall | wc -l)
		if [[ "$dns_mode" == "1" ]]; then
			sed -i "s/option dns_mode 'pdnsd'/option dns_mode 'chinadns-ng'/g" feeds/lienol/lienol/luci-app-passwall/root/etc/config/passwall
		fi
COMMENT
	fi
}

other_plugins() {

		#other-plugins
		if [[ -e package/other-plugins ]]; then
			echo ""
		else
			mkdir package/other-plugins
		fi

		
		#下载一下微信推送插件
		if [[ -e package/other-plugins/luci-app-serverchan ]]; then
			cd  package/other-plugins/luci-app-serverchan
			source_update_No_git_pull
			cd $HOME/$OW/$you_file/lede/
		else
			git clone https://github.com/tty228/luci-app-serverchan.git package/other-plugins/luci-app-serverchan
		fi

		#采用lisaac的luci-app-dockerman
		if [[ -e package/lean/luci-app-dockerman ]]; then
			rm -rf package/lean/luci-app-dockerman
		fi

		if [[ -e package/other-plugins/luci-app-dockerman ]]; then
			cd  package/other-plugins/luci-app-dockerman
			source_update_No_git_pull
			sed -i "s/+ttyd//g" applications/luci-app-dockerman/Makefile
			cd $HOME/$OW/$you_file/lede/
		else
			git clone https://github.com/lisaac/luci-app-dockerman.git package/other-plugins/luci-app-dockerman
			sed -i "s/+ttyd//g" package/other-plugins/luci-app-dockerman/applications/luci-app-dockerman/Makefile
		fi

		#下载lienol的fileassistant
		if [[ -e package/other-plugins/luci-app-fileassistant ]]; then
			rm -rf   package/other-plugins/luci-app-fileassistant
			svn checkout https://github.com/Lienol/openwrt-package/trunk/luci-app-fileassistant package/other-plugins/luci-app-fileassistant
		else
			svn checkout https://github.com/Lienol/openwrt-package/trunk/luci-app-fileassistant package/other-plugins/luci-app-fileassistant
		fi

		#adguardhome插件
		if [[ -e package/other-plugins/luci-app-adguardhome ]]; then
			cd  package/other-plugins/luci-app-adguardhome && source_update_No_git_pull
			cd $HOME/$OW/$you_file/lede/
		else
			git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/other-plugins/luci-app-adguardhome
		fi

		#godproxy插件
		if [[ -e package/other-plugins/luci-app-godproxy ]]; then
			cd  package/other-plugins/luci-app-godproxy
			git fetch --all
			git reset --hard origin/main
			cd $HOME/$OW/$you_file/lede/
		else
			git clone https://github.com/project-lede/luci-app-godproxy.git package/other-plugins/luci-app-godproxy
		fi

		 #错误访问登录限制（来自恩山401626436）
		if [[ -e package/other-plugins/luci-app-banlogon ]]; then
			rm -rf  package/other-plugins/luci-app-banlogon
			cp -r $HOME/$OW/$SF/$OCS/package/luci-app-banlogon  package/other-plugins/luci-app-banlogon
		else
			cp -r $HOME/$OW/$SF/$OCS/package/luci-app-banlogon  package/other-plugins/luci-app-banlogon
		fi

		#安装脚本
		if [[ -e package/other-plugins/jd_openwrt_script ]]; then
			cd  package/other-plugins/jd_openwrt_script
			git fetch --all
			git reset --hard origin/main
			cd $HOME/$OW/$you_file/lede/
		else
			git clone https://github.com/ITdesk01/jd_openwrt_script.git package/other-plugins/jd_openwrt_script
		fi

:<<'COMMENT'
		#下载jd插件
		if [[ -e package/other-plugins/luci-app-jd-dailybonus ]]; then
			cd  package/other-plugins/node-request && source_update_No_git_pull
			cd $HOME/$OW/$you_file/lede/
			cd  package/other-plugins/luci-app-jd-dailybonus && source_update_No_git_pull
			cd $HOME/$OW/$you_file/lede/
		else
			git clone https://github.com/jerrykuku/node-request.git package/other-plugins/node-request
			git clone https://github.com/jerrykuku/luci-app-jd-dailybonus.git package/other-plugins/luci-app-jd-dailybonus
		fi

		#Hello word插件
		if [[ -e package/other-plugins/luci-app-passwall ]]; then
			rm -rf package/other-plugins/luci-app-passwall
			rm -rf package/other-plugins/chinadns-ng
			rm -rf package/other-plugins/tcping
			rm -rf package/other-plugins/trojan-go
			rm -rf package/other-plugins/trojan-plus
			rm -rf package/other-plugins/brook
			rm -rf package/other-plugins/ssocks
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/lienol/luci-app-passwall package/other-plugins/luci-app-passwall
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/chinadns-ng package/other-plugins/chinadns-ng
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/tcping package/other-plugins/tcping
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/trojan-go package/other-plugins/trojan-go
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/trojan-plus package/other-plugins/trojan-plus
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/brook package/other-plugins/brook
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/ssocks package/other-plugins/ssocks
		else
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/lienol/luci-app-passwall package/other-plugins/luci-app-passwall
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/chinadns-ng package/other-plugins/chinadns-ng
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/tcping package/other-plugins/tcping
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/trojan-go package/other-plugins/trojan-go
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/trojan-plus package/other-plugins/trojan-plus
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/brook package/other-plugins/brook
			svn checkout https://github.com/xiaorouji/openwrt-package/trunk/package/ssocks package/other-plugins/ssocks
		fi
COMMENT
}

#Public配置
source_Setting_Public() {
	clear
	echo -e ">>$green Public配置$white" 
	#隐藏首页显示用户名(by:kokang)
	sed -i 's/name="luci_username" value="<%=duser%>"/name="luci_username"/g' feeds/luci/modules/luci-base/luasrc/view/sysauth.htm
		
	#移动光标至第一格(by:kokang)
	sed -i "s/'luci_password'/'luci_username'/g" feeds/luci/modules/luci-base/luasrc/view/sysauth.htm

	#修改固件生成名字,增加当天日期(by:左右）
	sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=[$(shell date +%Y%m%d)]-$(VERSION_DIST_SANITIZED)/g' include/image.mk


	#frpc替换为27版本
	source_type=`cat "$HOME/$OW/$SF/tmp/source_type"`
	if [[ `echo "$source_type" | grep openwrt | wc -l` == "1" ]]; then
		sed -i "s/PKG_VERSION:=0.34.1/PKG_VERSION:=0.27.0/g" feeds/packages/net/frp/Makefile
	elif [[ `echo "$source_type" | grep lean | wc -l` == "1" ]]; then
		sed -i "s/PKG_VERSION:=0.34.1/PKG_VERSION:=0.27.0/g" package/lean/frp/Makefile
		sed -i "s/PKG_HASH:=a47f952cc491a1d5d6f838306f221d6a8635db7cf626453df72fe6531613d560/PKG_HASH:=5d2efd5d924c7a7f84a9f2838de6ab9b7d5ca070ab243edd404a5ca80237607c/g" package/lean/frp/Makefile
	else
		echo ""
	fi

	sed -i "s/*\/\$time \* /0 *\/2 /g" package/lean/luci-app-frpc/root/etc/init.d/frp

	echo -e ">>$green Public配置完成$white"	
}

update_feeds() {
	clear
	echo "---------------------------"
	echo -e "      $green更新Feeds代码$white"
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
	echo -e "       $green测试编译环境$white"
	echo ""
	echo ""
	echo "--------------------------"
		make defconfig
}

dl_download() {
	#检测dl包完整性(by:P3TERX)
	if [[ -e $HOME/$OW/$you_file/lede/dl ]]; then
		cd $HOME/$OW/$you_file/lede/dl
		find . -size -1024c -exec ls -l {} \;
       	 	find . -size -1024c -exec rm -f {} \;
		cd $HOME/$OW/$you_file/lede
	else
		echo ""
	fi
	clear
	echo "----------------------------------------------"
	echo -e "$green# 开始下载DL，如果出现下载很慢，请检查你的梯子 #$white"
	echo ""
	echo -e "$green你的CPU核数为：$cpu_cores $white"
	echo -e "$yellow自动执行make download -j$cpu_cores  V=s加快下载速度$white"
	echo ""
	echo "ps：全速下载可能会导致系统反应慢点，稍等一下就好"	
	echo "----------------------------------------------"
	Time	
	make download -j$cpu_cores V=s
	if [[ $? -eq 0 ]]; then
		echo ""
	else
		dl_error
	fi

}

dl_error() {
	echo "----------------------------------------"
	echo -e " $yellow你的dl下载报错了$white"
	echo " 1.重新下载"
	echo " 2.不理直接编译"
	echo "----------------------------------------"
	read -p "请输入你的决定：" dl_dw
	case "$dl_dw" in
		1)
		dl_download
		;;
		2)
		echo ""
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
	echo -e "		$green【××编译环境搭建成功××】$white"
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
		#Save_My_Config_luci
		#make_firmware_or_plugin
		make_compile_firmware
	else
		echo ""
		echo -e "$redError，请查看上面报错，回车重新执行命令$white"
		echo "" && read a
		ecc
	fi
}

make_firmware_or_plugin() {
	clear
	calculating_time_start
	echo "----------------------------------------"
	echo "请选择编译固件 OR 编译插件"
	echo " 1.编译固件"
	echo " 2.编译插件"
	echo " 3.回退到加载配置选项（可以重新选择你的配置）"
	echo "----------------------------------------"
	read -p "请输入你的决定：" mk_value
	case "$mk_value" in
		1)
		make_compile_firmware
		;;
		2)
		make_Compile_plugin
		;;
		3)
		source_config
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		 clear && make_firmware_or_plugin
		;;
	esac
	
	
}

make_compile_firmware() {
	rm -rf /tmp/compile.log
	calculating_time_start
	clear
	echo "--------------------------------------------------------"
	echo -e "$green++编译固件是否要使用多线程编译++$white"
	echo ""
	echo "  首次编译不建议-j，具体用几线程看你电脑j有机会编译失败,"
	echo "不懂回车默认运行make V=s"
	echo ""
	echo -e "温馨提醒你的cpu核心数为：$green $cpu_cores $white"
	echo -e "可用多线程例子：$yellow make -j$cpu_cores V=s $white(黄色字体这段完整的输进去)"
	echo ""
	echo -e "$red!!!请不要在输入参数这行直接输数字，把命令敲全，不懂就直接回车!!!$white"
	echo "--------------------------------------------------------"
	read  -p "请输入你的参数(回车默认：make V=s)：" mk_f
	if [[ -z $mk_f ]];then
		clear && echo "开始执行编译" && Time
		dl_download
		make V=s >>/tmp/compile.log &
		tail -f /tmp/compile.log &
	else
		dl_download
		clear
		echo -e "你输入的命令是：$green$mk_f$white"
		echo "准备开始执行编译" && Time
		$mk_f >>/tmp/compile.log &
		tail -f /tmp/compile.log &
	fi
	
	if_make
}

if_make() {
	#set -x
	if [[ `cat /tmp/compile.log |grep "make\[1\]: Leaving directory" | wc -l` == "1" ]];then
		kill_tail=$(ps -an | grep tail | grep -v grep | awk '{print $1}')
		kill -9 $kill_tail
		n1_builder
		if_wo
		calculating_time_end
	else
		if [[ `cat /tmp/compile.log |grep "make\: \*\*\* \[world\] Error 2" | wc -l ` == "1" ]]; then
			kill_tail=$(ps -an | grep tail | grep -v grep | awk '{print $1}')
			kill -9 $kill_tail
			echo -e "$red>> 固件编译失败，请查询上面报错代码$white"
			make_continue_to_compile
		else
			sleep 2
			if_make
		fi
	fi

	#by：BoomLee  ITdesk
}

if_wo() {
	if [[ $? -eq 0 ]]; then
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
	else
		echo "---------------------------------------------------"
		echo -e "$red>> 固件编译失败，请查看报错代码$white"
			cat /tmp/compile.log | grep -E "ERROR/|failed"
		echo -e "$yellow >>更多编译过程可以查看　$green/tmp/compile.log$yellow　方便你查看错误发生过程"
		echo ----------------------------------------------------

		make_continue_to_compile
	fi
}

n1_builder() {
	n1_img="$HOME/$OW/$you_file/lede/bin/targets/armvirt/64/[$(date +%Y%m%d)]-openwrt-armvirt-64-default-rootfs.tar.gz"
	builder_patch="$HOME/$OW/$you_file/lede/N1_builder"
	armbian_img="Armbian_20.10_Aml-s9xxx_buster_5.4.101-flippy-54+o.img"
	cd $HOME/$OW/$you_file/lede
	if [[ -e $n1_img ]]; then
		echo -e "$green >>检测到N1固件，自动制作N1的OpenWRT镜像$white" && Time
		if [[ -e $builder_patch ]]; then
			cd $builder_patch
			git fetch --all
			git reset --hard origin/20210310
		else
			git clone -b 20210310 https://github.com/ITdesk01/N1_and_beikeyun-OpenWRT-Image-Builder.git $builder_patch
		fi

		if [ ! -d $builder_patch/tmp ];then
			mkdir -p $builder_patch/tmp
		else
			sudo rm -rf $builder_patch/tmp/*
		fi

		if [ ! -d $builder_patch/imges ];then
			mkdir -p $builder_patch/imges
		fi

		if [[ -e $builder_patch/imges/$armbian_img ]]; then
			echo -e "$green >>$builder_patch/imges/$armbian_img存在，复制固件$white" && clear

			if [[ ! -e $builder_patch/openwrt-armvirt-64-default-rootfs.tar.gz ]]; then
				echo -e "$green>> 开始复制openwrt固件 $white"
				rm -rf $builder_patch/openwrt-armvirt-64-default-rootfs.tar.gz
				cp $n1_img $builder_patch/openwrt-armvirt-64-default-rootfs.tar.gz
			fi

			cd $builder_patch
			echo -e "$green>> 准备开始制作n1固件，请输入管理员密码 $white"
			sudo bash mk_s905d_n1.sh
			if [[ $? -eq 0 ]]; then
				echo ""
				echo -e "$green >>N1镜像制作完成,你的固件在：$builder_patch/tmp$white"
			else
				echo -e "$red >>N1固件制作失败，重新执行代码 $white" && Time
				n1_builder
			fi

		else
			clear
			echo -e "$yellow >>检查到没有$armbian_img,请将你的armbian镜像放到：$builder_patch/imges $white"
			echo -e "$green >>存放完成以后，回车继续制作N1固件$white"
			read a
			n1_builder
		fi

	else
		echo ""
	fi
}


make_Compile_plugin() {
	clear
	echo "--------------------------------------------------------"
	echo "编译插件"
	echo ""
	echo -e "$yellow例子：make package/插件名字/compile V=99$white" 
	echo ""
	echo "PS:Openwrt首次git clone仓库不要用此功能，绝对失败!!!"
	echo "--------------------------------------------------------"
	read  -p "请输入你的参数：" mk_p
		clear
		echo -e "你输入的参数是：$green$mk_p$white"
		echo "准备开始执行编译" && Time
		$mk_p
	
	if [[ $? -eq 0 ]]; then
		echo ""
		echo ""
		echo "---------------------------------------------------------------------"
		echo ""
		echo -e "  潘多拉编译完成的插件在$yellow/Openwrt/文件名/lede/bin/packages/你的平台/base$white,如果还是找不到的话，看下有没有报错，善用搜索 "
		echo ""
		echo "回车可以继续编译插件，或者Ctrl + c终止操作"
		echo ""
		echo "---------------------------------------------------------------------"
			read a
			make_Continue_compiling_the_plugin
			calculating_time_end
		else
			echo -e "$red>> 固件编译失败，请查询上面报错代码$white"
			make_continue_to_compile
		fi
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
		exit
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		 clear && make_Continue_compiling_the_plugin
		;;
	esac
}

make_continue_to_compile() {
	echo "---------------------------------------------------------------------"
	echo -e "你的编译出错了是否要继续编译"
	echo ""
	echo -e "$green 1.是（默认执行make clean && make V=s,以方便查出具体报错问题）$white"
	echo ""
	echo -e "$red 2.否 （直接退出脚本）$white"
	echo ""
	echo -e "$yellow温馨提醒，编译失败一般有以下几种可能$white"
	echo "1. 网络（需要科学上网）"
	echo "2. Dl库没有下载完整（跟网络很大关系）"
	echo "3. -j 多线程编译"
	echo "4. 内存太少，在－ｊ的时候容易报错"
	echo "5. 空间不足（至少４０Ｇ空间）"
	echo "---------------------------------------------------------------------"
	read  -p "请输入你的决定:" continue_to_compile
		case "$continue_to_compile" in
		1)
		cd $HOME/$OW/$you_file/lede
		make clean && make V=s
		#make_firmware_or_plugin
		;;
		2)
		exit
		;;
		*)
		clear && echo  "Error请输入正确的数字 [1-2]" && Time
		clear && make_continue_to_compile
		;;
	esac
}

#单独的命令模块
make_j() {
	make_compile_firmware
	#dl_download
	#calculating_time_start
	#make -j$(nproc) V=s
	#calculating_time_end
	#n1_builder
}

new_source_make() {
	system_install
}

clean_make() {
	clear &&echo -e "$green>>执行make clean$white"
	make clean
	noclean_make
}

noclean_make() {
	clear && echo -e "$green>>不执行make clean$white"
	source_config && make menuconfig && make_j
}

update_clean_make() {
	clear
	cd $HOME/$OW/$you_file/lede
	file_patch="$HOME/$OW/$you_file/lede"
	echo -e "$green>>文件夹:$yellow$file_patch$green 执行make clean$white" && sleep 3
		make clean && rm -rf .config && rm -rf ./tmp/ && rm -rf ./feeds
	echo -e "$green>>文件夹:$yellow$file_patch$green 执行git pull$white" && sleep 3
		source_update_No_git_pull
	echo -e "$green>>文件夹:$yellow$file_patch$green 执行常用设置$white"　&& sleep 3
		source_download_ok
	echo -e "$green>>文件夹:$yellow$file_patch$green 执行make menuconfig $white"　&& sleep 3
		make menuconfig
	echo -e "$green>>文件夹:$yellow$file_patch$green 执行make download 和make -j $white"　&& sleep 3
		make_j

	if [[ $? -eq 0 ]]; then
		echo ""
	else
		echo -e "$red>>文件夹:$action1 编译失败了，请检查上面的报错，然后重新进行编译 $white"
		echo ""
		echo -e "$green 可以采用以下命令重新进行编译"
		echo -e "$green bash \$openwrt $action1 make_j "
	fi
}

update_clean_make_kernel() {
	update_clean_make
	make kernel_menuconfig
	make_j
}

update_script_rely() {
	update_script
	rely_on
	if [[ $? -eq 0 ]]; then
		echo -e "$green >>依赖安装完成 $white" && Time
	else
		clear
		echo -e "$red 依赖没有更新或安装成功，重新执行代码 $white" && Time
		update_script_rely
	fi
}

actions_openwrt() {
	HOME=$(pwd)
	file=lean
	if [[ ! -d "$HOME/$OW/$SF/$OCS" ]]; then
		echo -e "开始创建主文件夹"
		mkdir -p $HOME/$OW/$SF/dl
		mkdir -p $HOME/$OW/$SF/My_config
		mkdir -p $HOME/$OW/$SF/tmp
	fi

	echo "开始创建编译文件夹"
	mkdir $HOME/$OW/$you_file
	git clone  https://github.com/coolsnowwolf/lede.git $HOME/$OW/$you_file/lede
	cd $HOME/$OW/$you_file/lede
	source_download_ok
	make_j
}

file_help() {
	echo "---------------------------------------------------------------------"
	echo "	【 Openwrt Compile Script编译脚本 Ver ${version}版 】"
	echo "	 By:ITdesk"
	echo "---------------------------------------------------------------------"
	echo ""
	echo -e "$green用法: bash \$openwrt [文件夹] [命令] $white"
	echo -e "$green脚本创建文件夹目录结构：$HOME/$OW/$yellow你起的文件夹名$green/lede $white"
	echo ""
	echo -e "$yellow首次编译建议：$white"
	echo -e "$green   new_source_make $white   脚本新建一个文件夹下载你需要的源码并进行编译 "
	echo ""
	echo -e "$yellow二次编译建议：$white"
	#echo -e "$green   make_j $white            执行make download 和make -j V=s "
	echo -e "$green   noclean_make $white      不执行make clean清理一下源码然后再进行编译"
	echo -e "$green   clean_make $white        执行make clean清理一下源码然后再进行编译"
	echo -e "$green   update_clean_make $white 执行make clean 并同步最新的源码 再进行编译"
	#echo -e "$green   update_clean_make_kernel $white 编译完成以后执行make kernel_menuconfig($red危险操作$white)"
	echo -e "$green   update_script $white     将脚本同步到最新"
	echo -e "$green   update_script_rely $white将脚本和源码依赖同步到最新"
	#echo -e "$green   help $white 查看帮助"
	echo ""
	echo -e "$yellow例子： $white "
	echo -e "$yellow  1.新建一个文件夹下载你需要的源码并进行编译(适合首次编译) $white "
	echo -e "$green   bash \$openwrt new_source_make $white  "
	echo ""
	echo -e "$yellow  2.不执行clean,执行make download 和make -j V=s(适合二次编译) $white  "
	echo -e "$green   bash \$openwrt $yellow你起的文件夹名$green  noclean_make $white "
	echo ""
	echo -e "$yellow  3.清理编译文件，再重新编译(适合二次编译) $white  "
	echo -e "$green   bash \$openwrt $yellow你起的文件夹名$green  clean_make $white   "
	echo ""
	echo -e "$yellow  4.同步最新的源码清理编译文件再编译(适合二次编译) $white"
	echo -e "$green   bash \$openwrt $yellow你起的文件夹名$green  update_clean_make $white "
	echo ""
	echo -e "$green   bash \$openwrt help $white  查看帮助  "
	echo -e "$green   bash \$openwrt update_script $white  将脚本同步到最新  "
	echo ""
	echo "---------------------------------------------------------------------"

}

action1_if() {
		if [[ -e $HOME/$OW/$action1 ]]; then
			action2_if
		else
			echo ""
			echo -e "$red>>文件夹不存在，使用方法参考以下！！！$white"
			file_help
		fi
}

action2_if() {
	if [[ -z $action2 ]]; then
		echo ""
		echo -e "$red>>命令参数不能为空！$white"
		file_help
	else
		you_file=$action1
		cd $HOME/$OW/$you_file/lede
		rm -rf $HOME/$OW/$SF/tmp/*
		case "$action2" in
			make_j|new_source_make|clean_make|noclean_make|update_clean_make|update_clean_make_kernel|update_script_rely|n1_builder)
			$action2
			action3_if
			;;
			*)
			echo ""
			echo -e "$red 命令不存在，使用方法参考以下！！！$white"
			file_help
			;;
		esac
	fi
}

action3_if() {
	if [[ -z $action3 ]]; then
		echo ""
	else
		you_file=$action1
		cd $HOME/$OW/$you_file/lede
		rm -rf $HOME/$OW/$SF/tmp/*
		case "$action3" in
			make_j|new_source_make|clean_make|noclean_make|update_clean_make|update_clean_make_kernel|update_script_rely|n1_builder)
			$action3
			;;
			*)
			echo ""
			echo -e "$red 命令不存在，使用方法参考以下！！！$white"
			file_help
			;;
		esac
	fi
}


if [[ $(users) == "root" ]];then
	echo -e "${red}请勿使用root进行编译！！！${white}"
	exit 0
fi

git_branch=$(git fetch --all | git branch -v | grep -o "落后")
if [[  "$git_branch" == "落后" ]]; then
	echo -e "$green>>更新脚本到最新$white"　&& sleep 3
	update_script
else
	echo -e "$green脚本已经最新$white"
fi

#copy  by:Toyo  modify:ITdesk
action1="$1"
action2="$2"
action3="$3"
if [[ -z $action1 ]]; then
	description_if
	file_help
else
	case "$action1" in
		help)
		file_help
		;;
		update_script)
		update_script
		;;
		new_source_make)
		new_source_make
		;;
		actions_openwrt)
		actions_openwrt
		;;
		*)
		action1_if
		;;
	esac
fi

