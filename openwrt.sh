#!/bin/bash

version="2.7"
OF="Script_File"
fl="Openwrt"
by="ITdesk"
OCS="OpenwrtCompileScript"
rely_on="sudo apt-get -y install asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache flex g++ gawk gcc gcc-multilib gettext git git-core help2man htop lib32gcc1 libc6-dev-i386 libglib2.0-dev libncurses5-dev libssl-dev libtool libz-dev libelf-dev make msmtp ncurses-term ocaml-nox p7zip p7zip-full patch qemu-utils sharutils subversion texinfo uglifyjs unzip upx xmlto yui-compressor zlib1g-dev"

#显示编译文件夹
Ls_File(){
	 LF=`ls $HOME/$fl | grep -v $0  | grep -v Script_File`
	 echo -e "\e[49;32;1m $LF \e[0m"
	 echo ""
}

#显示config文件夹
Ls_My_config(){
	 LF=`ls My_config`
	 echo -e "\e[49;32;1m $LF \e[0m"
	 echo ""
}

#倒数专用
Time(){
	 seconds_left=3
		echo " "
   		echo "   ${seconds_left}秒以后执行代码"
		echo "   如果不需要执行代码以Ctrl+C 终止即可"
		echo " "
   		while [ $seconds_left -gt 0 ];do
     		echo -n  $seconds_left
      		sleep 1
      		seconds_left=$(($seconds_left - 1))
     	 	echo -ne "\r     \r" 
   	 done

}


#选项9.更新update_script
update_script(){
	clear
	cd $HOME/$fl/$OF/$OCS
	CheckUrl_github=`curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null www.github.com`
		if [ $CheckUrl_github -eq 301 ]; then 
			git fetch --all
			git reset --hard origin/master
			echo "回车进入编译菜单"
			read a 
			Main_interface
		else
			echo "请检查你的网络!!!!" && read a
			Time && Main_interface
			
		fi 	
}


#选项6.其他选项
other(){
	clear
	echo "	      -------------------------------------"
	echo "	      	    【 其他选项 】"
	echo ""
	echo " 		  1.只搭建编译环境，不进行编译"
	echo ""
	echo "		  2.单独Download DL库 "
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
		update_system
		echo "环境搭建完成，请自行创建文件夹和git"
		;;
		2)
		DL_other
		echo "DL更新完成"
		;;
		0)
		Main_interface
		;;
		*)
	clear && echo  "请输入正确的数字 [1-2,0]" && Time
	other
	;;
esac
}
DL_other(){
	clear && cd
	echo "***你的openwrt文件夹有以下几个***"
		 Ls_File
	read -p "请选择你要输入你要更新的文件夹：" DL_file
	cd && cd $HOME/$fl/DL_file/lede 
	DL_source
		
}


#选项4.恢复编译环境
source_RestoreFactory(){
	clear
	echo "------------------------------"
	echo "你的openwrt文件夹有以下几个"
	echo "------------------------------"
		Ls_File
	
	echo ""
	read  -p "请输入你的根目录openwrt文件夹名（用于还原dl文件夹）:" openwrt
	if [ -e $HOME/$fl/$openwrt ]; then
			cd && cd $HOME/$fl/$openwrt/lede
			echo "所有编译过的文件全部删除,openwrt源代码保存，回车继续 Ctrl+c取消" && read a  
	 	 else
			clear && echo "-----文件名错误，请重新输入-----" && Time
			source_Secondary_compilation
		fi
	make distclean 
	ln -s $HOME/$fl/$OF/dl  $HOME/$fl/$openwrt/lede/dl
	./scripts/feeds update -a && ./scripts/feeds install -a
	clear && echo ""
	echo "所有编译过的文件全部删除完成，如依旧编译失败，请重新下载源代码，回车可以开始编译 不需要编译Ctrl+c取消" && read a 
	./scripts/feeds update -a && ./scripts/feeds install -a
	make menuconfig 
	Save_My_Config_luci
	mk_time

}


#选项3.二次编译
source_Secondary_compilation(){
	clear
	echo "-----------------------------"
	echo " 你需要编译那个openwrt库"
	echo "-----------------------------"
		 Ls_File
	read -p "请输入你要编译的库名（记得区分大小写）："  Library
		if [ -e $HOME/$fl/$Library ]; then
			cd && cd $HOME/$fl/$Library/lede
	 	 else
			clear && echo "-----文件名错误，请重新输入-----" && Time
			source_Secondary_compilation
		fi
		clear && echo "开始清理之前的文件" 
		make clean && rm -rf ./tmp && Time
		source_config
		make menuconfig 
		Save_My_Config_luci
		mk_time

		
}

source_config(){
	clear
		 echo "----------------------------------------"
		 echo "是否要加载你之前保存的配置(1.是  2.否)"
		 echo "     1.是（加载配置）"
		 echo "     2.否（以全新的config进行编译）"
		 echo "----------------------------------------- "
	read -p "请输入你的决定："  config
		case "$config" in
			1)
			transfer_My_config
			;;
			2)
			source_Secondary_compilation_deleteConfig
			;;
			*)
			clear && echo  "Error请输入正确的数字 [1-2]" && Time
			source_config
			;;
		esac
}

source_Secondary_compilation_deleteConfig(){
	rm -rf .config	
}

Save_My_Config_luci(){
	clear && echo "------------------------------------------------"
		 echo "是否要保存你的配置，以备下次使用(1.是  2.否 )"
		 echo "注：同一名字的文件会覆盖"
		 echo "------------------------------------------------"
	read -p "请输入你的决定："  save
		case "$save" in
			1)
			Save_My_Config_Yes
			;;
			2)
			;;
			*)
			clear && echo  "请输入正确的数字 [1-2]" && Time
			Save_My_Config_luci
			;;
		esac

}

Save_My_Config_Yes(){
	read -p "请输入你的配置名："  mange_config
	cp .config My_config/$mange_config
	echo "******配置保存完成回车进行编译*******" && read a
	
}

transfer_My_config(){
	clear
	echo "你的配置文件如下："
	echo ""
		Ls_My_config
	echo ""
	read -p "请输入你要调用的配置名（记得区分大小写）："  transfer
	if [ -e `pwd`/My_config/$transfer ]; then
		Time && clear 
		echo "正在调用"
		cp My_config/$transfer  .config
		echo "配置加载完成" && Time
		
	else
		clear && echo "调用错误" && Time
		transfer_My_config
	fi
	
	
}


#选项2.源码更新
source_update(){
	clear 
	echo "--------------------------------"
	echo " 准备开始更新openwrt源代码与软件"
	echo "--------------------------------"
	echo "***你的openwrt文件夹有以下几个***"
		Ls_File
	read -p "请选择你要输入你要更新的文件夹：" You_file
	if [ -e $HOME/$fl/$You_file ]; then
			cd && cd $HOME/$fl/$You_file/lede
			clear && echo "开始清理之前的编译文件"
			make clean
	 	 else
			clear && echo "-----文件名错误，请重新输入-----" && Time
			source_update
		fi
	
	clear && echo "有没有改动过源代码，因为改动过源代码可能会导致git pull失效无法更新"
	echo "		1.是 "
	echo "		2.否"
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
	Update_feeds
        clear && echo "更新完成回车进行编译  Ctrl+c取消,不进行编译" && read a && Time
	source_config
	Save_My_Config_luci
	mk_time

	
} 
source_update_No_git_pull(){
	git fetch --all
	git reset --hard origin/master
}

source_update_git_pull(){
	git pull	
}


#选项1.开始搭建编译环境与主菜单
#主菜单
Main_interface(){
	clear
	echo "	      	    -------------------------------------"
	echo "	      	  【 Openwrt Compile Script Ver $version版 】"
	echo ""
	echo " 		  	1.开始搭建编译环境"
	echo ""
	echo "		  	2.更新源代码"
	echo ""
	echo "			3.二次编译固件"
	echo ""
	echo "			4.恢复编译环境"
	echo ""
	echo "			6.其他选项"	
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
		source_update
		;;
		3)
		source_Secondary_compilation
		;;
		4)
		source_RestoreFactory
		;;
		6)
		other
		;;
		9)
		update_script
		;;
		0)
		exit
		;;
		*)
	clear && echo  "请输入正确的数字 [1-4,6,0]" && Time
	Main_interface
	;;
esac
}


system_install(){
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



update_system(){
	clear
	clear && echo "准备更新系统"	&& Time
	sudo apt-get update
	clear
	echo "准备安装依赖" && Time
	$rely_on && $rely_on #这里执行两次是因为发现win10这个坑爹货会安装不全，所以再执行一次
	echo "安装完成" && Time
}


create_file(){
	clear
	echo ""
	echo "----------------------------------------"
	echo "		   开始创建文件夹"
	echo "----------------------------------------"
	echo ""
	read -p "请输入你要创建的文件夹名:" file
	 
	if [ -e $HOME/$fl/$file ]; then
		clear && echo "文件夹已存在，请重新输入文件夹名" && Time
		create_file
		
	 else
		echo "开始创建文件夹"
			mkdir $HOME/$fl/$file
 			chmod 777 $HOME/$fl/$file
			cd $HOME/$fl/$file  && clear 
			source_Download
	 fi
 	
}


source_Download(){
		clear
		echo "  -----------------------------------------"
		echo ""
  		echo "	准备下载openwrt代码"
		echo ""
		echo "	1.openwrt17.1(stable version)_source"
		echo ""
		echo "	2.openwrt18.6(Trunk)_source"
		echo ""
		echo "	3.Lean_R8(stable version)_source"
		echo ""
		echo " 	4.Lean_R9(Trunk)_source"
		echo ""
		echo "	0.exit"
		echo ""
		echo ""
		echo "  ----------------------------------------"
		read  -p "请输入你要下载的源代码:" Download_source
			case "$Download_source" in
				1)
				git clone -b lede-17.01 https://github.com/openwrt/openwrt.git lede
				cd lede
				;;
				2)
				git clone  https://github.com/openwrt/openwrt.git lede
				cd lede
				;;
				3)
				git clone https://github.com/coolsnowwolf/openwrt.git lede
				cd lede
				;;
				4)
				git clone https://github.com/coolsnowwolf/lede.git lede
				cd lede
				;;
				0)
				exit;;
				*)
				clear && echo  "请输入正确的数字（1-4，0）" && Time
				source_Download
				 ;;
			esac
			source_if
			
}	

source_if(){
		clear
		if [ -e $HOME/$fl/$file/lede ]; then
			cd lede
			software
		else
			echo ""
			echo "源码下载失败，请检查你的网络，回车重新选择下载" && read a && Time
			cd $HOME/$fl/$file
			source_Download
		fi
}


software(){
	cd 
	if [ -e $HOME/$fl/$file/lede/package/lean ]; then
		clear && echo "" && Time
	else
		svn checkout https://github.com/coolsnowwolf/lede/trunk/package/lean  $HOME/$fl/$file/lede/package/lean
		
	fi
	cd $HOME/$fl/$file/lede
	Update_feeds
	mk_df
		
}


Update_feeds(){
	clear
	echo "---------------------------"
	echo "      更新Feeds代码"
	echo "---------------------------"
				
		./scripts/feeds update -a && ./scripts/feeds install -a
		
		
}


mk_df(){
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
		ln -s  $HOME/$fl/$OF/$OCS/$0 $HOME/$fl/$file/lede/$0
		cd $HOME/$fl/$file/lede
		DL_source
}


DL_source(){
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
				DL_Detection
				cp $HOME/$fl/$OF/pl/download_1150.pl $HOME/$fl/$file/lede/scripts/download.pl
				chmod 777 $HOME/$fl/$file/lede/scripts/download.pl
				DL_download
				;;
				2)
				DL_Detection
				cp $HOME/$fl/$OF/pl/download_1806.pl $HOME/$fl/$file/lede/scripts/download.pl
				chmod 777 $HOME/$fl/$file/lede/scripts/download.pl
				DL_download
				;;
				*)
				clear && echo  "Error请输入正确的数字 [1-2]" && Time
				DL_source
				;;
			esac
		
}

DL_Detection(){
	if [ -e $HOME/$fl/$OF/pl/download_1806.pl ]; then
			echo "文件已存在"
	 	 else
			wget --no-check-certificate https://raw.githubusercontent.com/openwrt/openwrt/openwrt-18.06/scripts/download.pl -O $HOME/$fl/$OF/pl/download_1806.pl
			
			
		fi
	if [ -e $HOME/$fl/$OF/pl/download_1150.pl ]; then
			echo "文件已存在"
	 	 else
			wget --no-check-certificate https://raw.githubusercontent.com/LGA1150/openwrt/exp/scripts/download.pl -O $HOME/$fl/$OF/pl/download_1150.pl
				
		fi
	if [ -e $HOME/$fl/$file/lede/scipts/download_back.pl ]; then
			sudo rm -rf $HOME/$fl/$file/lede/scripts/download.pl
	 	 else
			cd $HOME/$fl/$file/lede/scripts
			mv download.pl download_back.pl
			cd ..
			
		fi
	
		

		
}

DL_download(){
		clear 
		echo "----------------------------------------------" 
		echo "# 开始下载DL，如果出现下载很慢，请检查你的梯子 #"
		echo "------------------------------------------"	
			Time
			make download V=s 
			DL_error
			
}

DL_error(){
			echo "----------------------------------------"
			echo "请检查上面有没有error出现，如果有请重新下载"
			echo " 1.有"
			echo " 2.没有"
			echo "----------------------------------------"
			read -p "请输入你的决定："  DL_dw
			case "$DL_dw" in
				1)
				DL_download
				;;
				2)
				Ecc 
				;;
				*)
				clear && echo  "Error请输入正确的数字 [1-2]" && Time
				Dl_error
				;;
			esac
}	


Ecc(){
	clear
	echo "    -----------------------------------------------"
	echo ""
	echo "		【××编译环境搭建成功××】"
	echo ""
	echo "	  1.请回车进入编译菜单，第一次回车较慢稍等"
	echo "	  2.进去编译菜单选择你要的功能完成以后Save"
	echo "	  3.菜单Exit以后会自动开始编译"
	echo ""
	echo ""
	echo "   -------------------------------------------------"
	read a
	make menuconfig 
	Save_My_Config_luci
	mk_time

}	
	


mk_time(){
	starttime=`date +'%Y-%m-%d %H:%M:%S'`
	clear
	echo  "是否要使用多线程编译"
	echo ""
	echo "  首次编译不建议，具体用几线程看你电脑，不懂百度，有机会编译失败,回车默认运行make V=s,多线程例子：（ make -j4 V=s ）  -j（这个值看你电脑），不要随便乱输，电脑炸了不管"
	echo ""
	read  -p "请输入你的参数(回车默认：make V=s)：" mk_j
		if [ -z "$mk_j" ];then
			clear && echo "开始执行编译" && Time
       			make V=s
		else
			clear
			echo "你数入的线程是：$mk_j"
			echo "准备开始执行编译" && Time
			$mk_j
        	fi 
	endtime=`date +'%Y-%m-%d %H:%M:%S'`
	start_seconds=$(date --date="$starttime" +%s);
	end_seconds=$(date --date="$endtime" +%s);
	echo "本次运行时间： "$((end_seconds-start_seconds))"s"
	#by：BoomLee  ITdesk
}



description_if(){
	cd 
	clear
	echo "开始检测系统"
	openwrtpath=`cat /etc/profile |grep -o OpenwrtCompileScript `
	if [[ $openwrtpath = $OCS ]]; then 
		echo "变量存在"
	else 
		
		sudo chmod 777 /etc/profile
		echo "export openwrt=$HOME/Openwrt/Script_File/OpenwrtCompileScript/openwrt.sh" >> /etc/profile
		clear
		echo "-----------------------------------------------------------------------"	
		echo ""	
		echo -e "\e[32m添加openwrt变量 ,重启系统以后无论在那个位置输bash $ openwrt都可以调用脚本\e[0m"
		echo ""
		echo "-----------------------------------------------------------------------"	
		
		
	fi
	
	if [ -e $HOME/$fl/$OF/$OSC ]; then 
		clear && echo "\e[32m文件夹存在\e[0m"		
	 else
		echo "开始创建主文件夹"
			sudo mkdir $fl
			sudo chmod 777 $fl

			sudo mkdir  $HOME/$fl/$OF
			sudo chmod 777 $HOME/$fl/$OF

			sudo mkdir  $HOME/$fl/$OF/dl 
			sudo chmod 777 $HOME/$fl/$OF/dl

			sudo mkdir  $HOME/$fl/$OF/My_config
			sudo chmod 777 $HOME/$fl/$OF/My_config

			sudo mkdir  $HOME/$fl/$OF/pl
			sudo chmod 777 $HOME/$fl/$OF/pl

			cp -r `pwd`/$OCS $HOME/$fl/$OF/
			sudo chmod 777 $HOME/$fl/$OF/$OCS
				
			
	fi
		
	if [[ -e /etc/apt/sources.list.back ]]; then
		clear && echo -e "\e[32m源码已替换\e[0m" 
	else
		Checksystem=`cat /proc/version |grep -o Microsoft@Microsoft.com `
				
	fi
	clear
	
	if [[ "$Checksystem" == "Microsoft@Microsoft.com" ]]; then
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
				echo -e "\e[32m开始替换软件源\e[0m" && Time
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
		clear && echo "不是win10" 
	 fi
	 
	 
	 curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null  www.baidu.com
	 if [[ "$?" == "0" ]]; then
	 	clear && echo -e  "\e[32m已经安装curl\e[0m" 
	 else
	 	clear && echo "安装一下脚本用的依赖（注：不是openwrt的依赖而是脚本本身）"
		sudo apt update 
		sudo apt install curl  -y 
		sudo rm -rf $HOME/$OCS			
		cd $HOME/$fl 
	 	
	fi
	
	
	
	if [ -e $HOME/$fl/$OF/description ]; then
		self_test
		Main_interface
	else
		clear
		description
		echo ""
		read -p "请输入密码:" ps
			if [ $ps = $by ]; then
				description >> $HOME/$fl/$OF/description && clear && self_test && Main_interface
			else
				clear && echo "+++++密码错误++++++" && Time &&  description_if
			fi
	fi
	
	
	
	
}


self_test(){
	clear		
	CheckUrl_google=$(curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null   www.google.com)

		if [[ "$CheckUrl_google" -eq "200" ]]; then 
			Check_google=`echo -e "\e[32m网络正常\e[0m"`	
		else
			Check_google=`echo -e "\e[31m网络较差\e[0m"`
			
		fi 
	CheckUrl_baidu=$(curl -I -m 2 -s -w "%{http_code}\n" -o /dev/null  www.baidu.com)
		if [[ "$CheckUrl_baidu" -eq "200" ]]; then 
			Check_baidu=`echo -e "\e[32m百度正常\e[0m"`	
		else
			Check_baidu=`echo -e "\e[31m百度无法打开，请修复这个错误\e[0m"`
			
		fi 
	Root_detection=`id -u`	#学渣代码改良版
		if [[ "$Root_detection" -eq "0" ]]; then  
			Root_run=`echo -e "\e[31m请勿以root运行,请修复这个错误\e[0m"`
		else
			Root_run=`echo -e "\e[32m非root运行\e[0m"`
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

description(){
		echo "	      +++++++++++++++++++++++++++++++++++++++"
		echo "	    ++欢迎使用Openwrt-Compile-Script Ver $version ++"
		echo "	      +++++++++++++++++++++++++++++++++++++++"
		echo ""
		echo "  创建脚本的初衷是因(I)为openwrt编译的时候有些东西太繁琐了，为了简化掉一些操作，使编译更加简单就有了此脚本(T)的诞生，后面觉得好玩就分享给了大家一起玩耍，你需要清楚此脚本仅用于学习，有一定危险性，请勿进行商用，如果商用导致损失或者其他问题，均由使用者自行承担!!!"
		echo ""
		echo "下面简单给大家描述脚本的作用"
		echo "	1.协助你更快的搭建编译环境，小白(d)建议学习一下再用会比较好"
		echo "	2.统一管理你的编译源，全部(e)存放在Openwrt这个文件里面"
		echo "	3.你只要启动脚本就可以控制你的源，进行二次编译或者更新"
		echo ""
		echo "缺陷1：小白(s)不太适合，因为他们不了解过程"
		echo "缺陷2：不能自定义openwrt代码或者修改，此脚本适合做重复的事情(k)"
		echo ""
		echo "注：请自行将你系统的软件源更换为国内的服务器，不会请百度"
		echo ""
		echo ""
		echo "请阅读完上面的前言，（）里面的就是密码，此界面只会出现一次，后面就不会了"
}

description_if 
