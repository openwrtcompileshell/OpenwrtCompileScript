#!/bin/bash
version=$(echo "2.6")
OF=$(echo "Script_File")
fl=$(echo "Openwrt")
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

	Update_feeds

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
		sudo mkdir  $HOME/$fl/$OF
		sudo mkdir  $HOME/$fl/$OF/dl 
		sudo mkdir  $HOME/$fl/$OF/My_config
		sudo mkdir  $HOME/$fl/$OF/pl
		sudo cp `pwd`/$version $HOME/$fl/$version
		sudo chmod 777 $HOME/$fl/$OF
		sudo chmod 777 $HOME/$fl/$OF/dl
		sudo chmod 777 $HOME/$fl/$OF/pl
		sudo chmod 777 $HOME/$fl/$OF/My_config
		sudo chmod 777 $HOME/$fl/$version
		ln -s  $HOME/$fl/$OF/dl $HOME/$fl/$file/lede/dl
		ln -s  $HOME/$fl/$OF/My_config $HOME/$fl/$file/lede/My_config
		ln -s  $HOME/$fl/$version $HOME/$fl/$file/lede/$version
		cd $HOME/$fl/$file/lede
		DL_source

	clear
	echo "    --------------------------------------------"
	echo ""
	echo "		【××编译环境搭建成功××】"
	echo ""
	echo "	  1.请回车进入编译菜单，第一次回车较慢稍等"
	echo "	  2.进去编译菜单选择你要的功能完成以后Save"
	echo "	  3.菜单Exit以后会自动开始编译"
	echo ""
	echo ""
	echo "   ----------------------------------------------"
	read a
	make menuconfig 
	Save_My_Config_luci
 	make V=99
}

create_file(){
	 if [ -e $HOME/$fl ]; then
		echo "主文件夹已创建，继续创建其他文件夹"		
	 else
		cd  $HOME
		echo "开始创建主文件夹"
			sudo mkdir $fl && sudo chmod 777 $fl
			cd $fl 
	 fi
	
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

update_system(){
	clear
	echo "检测是否以Root运行,openwrt不能用root来编译！！！！！！" && Time
	Root_detection
	clear && echo "准备更新系统"	&& Time
	sudo apt-get update
	clear
	echo "准备安装依赖" && Time
	sudo apt-get install gcc g++ build-essential asciidoc  binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch flex bison make autoconf texinfo unzip sharutils subversion ncurses-term zlib1g-dev ccache upx lib32gcc1 libc6-dev-i386 uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev libglib2.0-dev xmlto qemu-utils automake libtool  -y
	clear && echo "安装完成" && Time
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
			
}	

DL_other(){
	clear && cd
	echo "***你的openwrt文件夹有以下几个***"
		 ls $HOME/$fl | grep -v $version  |grep -v Script_File
	read -p "请选择你要输入你要更新的文件夹：" DL_file
	cd && cd $HOME/$fl/DL_file/lede 
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
			wget https://raw.githubusercontent.com/openwrt/openwrt/openwrt-18.06/scripts/download.pl -O $HOME/$fl/$OF/pl/download_1806.pl
			
			
		fi
	if [ -e $HOME/$fl/$OF/pl/download_1150.pl ]; then
			echo "文件已存在"
	 	 else
			wget https://raw.githubusercontent.com/LGA1150/openwrt/exp/scripts/download.pl -O $HOME/$fl/$OF/pl/download_1150.pl
				
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
		echo "------------------------------------------"	&& Time	
			make download V=s 
		DL_error
			
}
DL_error(){
			echo "----------------------------------------"
			echo "请检查有没有error出现，如果有请重新下载"
			echo " 1.有"
			echo " 2.没有"
			echo "----------------------------------------"
			read -p "请输入你的决定："  DL_dw
			case "$DL_dw" in
				1)
				DL_download
				;;
				2)
				;;
				*)
				clear && echo  "Error请输入正确的数字 [1-2]" && Time
				Dl_error
				;;
			esac
}	
Update_feeds(){
	clear
	echo "---------------------------"
	echo "      更新Feeds代码"
	echo "---------------------------"
				
		./scripts/feeds update -a && ./scripts/feeds install -a
}
DNS_Host(){
	clear 
	echo "××××××替换HOST文件×××××××"
	echo ""
	echo "    1.替换HOST文件"
	echo "    2.恢复HOST文件"
	read -p "请输入你的决定："  HOST
		case "$HOST" in
			1)
			DNS_Host_replace
			;;
			2)
			DNS_Host_restore
			;;
			*)
			clear &&  echo  "请输入正确的数字 [1-2]" && Time
			DNS_Host
			;;
		esac
		
}
DNS_Host_replace(){
	
	if [ -e /etc/hosts.back ]; then
		echo "-----已存在-----"
	 else
		sudo mv /etc/hosts /etc/hosts.back
		
	fi
	
		touch ./hosts && echo "
		127.0.0.1 localhost
		162.159.209.51 www.right.com.cn
		192.30.253.112 github.com 
		192.30.253.119 gist.github.com 
		151.101.100.133 assets-cdn.github.com 
		151.101.100.133 raw.githubusercontent.com 
		151.101.100.133 gist.githubusercontent.com 
		151.101.100.133 cloud.githubusercontent.com 
		151.101.100.133 camo.githubusercontent.com 
		151.101.100.133 avatars0.githubusercontent.com 
		151.101.100.133 avatars1.githubusercontent.com 
		151.101.100.133 avatars2.githubusercontent.com 
		151.101.100.133 avatars3.githubusercontent.com 
		151.101.100.133 avatars4.githubusercontent.com 
		151.101.100.133 avatars5.githubusercontent.com 
		151.101.100.133 avatars6.githubusercontent.com 
		151.101.100.133 avatars7.githubusercontent.com 
		151.101.100.133 avatars8.githubusercontent.com

		# The following lines are desirable for IPv6 capable hosts
		::1     ip6-localhost ip6-loopback
		fe00::0 ip6-localnet
		ff00::0 ip6-mcastprefix
		ff02::1 ip6-allnodes
		ff02::2 ip6-allrouters	
		">>./hosts
		sudo mv ./hosts /etc/hosts 
		sudo /etc/init.d/networking restart 
		echo "替换完成如果使用的过程中发现有任何问题，请还原之前的HOST文件"
	
	
}


DNS_Host_restore(){
	sudo rm -rf /etc/hosts
	sudo mv /etc/hosts.back /etc/hosts
	sudo /etc/init.d/networking restart 
	echo "还原完成"
}

source_update(){
	clear 
	echo "--------------------------------"
	echo " 准备开始更新openwrt源代码与软件"
	echo "--------------------------------"
	echo "***你的openwrt文件夹有以下几个***"
		 ls $HOME/$fl | grep -v $version  |grep -v Script_File
	read -p "请选择你要输入你要更新的文件夹：" You_file
	if [ -e $HOME/$fl/$You_file ]; then
			cd && cd $HOME/$fl/$You_file/lede
	 	 else
			clear && echo "-----文件名错误，请重新输入-----" && Time
			source_update
		fi
	
	clear && echo "有没有改动过源代码，因为改动过源代码可能会导致git pull失效无法更新(默认：否  )"
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
	make menuconfig 
	Save_My_Config_luci
	make V=99
	
} 

source_update_git_pull(){
	git pull	
}

source_update_No_git_pull(){
	git fetch --all
	git reset --hard origin/master
}

source_Secondary_compilation(){
	clear
	echo "-----------------------------"
	echo " 你需要编译那个openwrt库"
	echo "-----------------------------"
		 ls $HOME/$fl | grep -v $version  |grep -v Script_File
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
		make V=99
		 
		
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

source_RestoreFactory(){
	clear
	echo "------------------------------"
	echo "你的openwrt文件夹有以下几个"
	echo "------------------------------"
		 ls $HOME/$fl | grep -v $version  |grep -v Script_File
	
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
	clear && echo ""
	echo "所有编译过的文件全部删除完成，如依旧编译失败，请重新下载源代码，回车可以开始编译 不需要编译Ctrl+c取消" && read a 
	make menuconfig 
	Save_My_Config_luci
	make V=99
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
	echo "配置保存完成回车进行编译" && read a
	
}

transfer_My_config(){
	clear
	echo "你的配置文件如下："
	echo ""
		ls My_config
	echo ""
	read -p "请输入你要调用的配置名（记得区分大小写）："  transfer
	if [ -e `pwd`/My_config/$transfer ]; then
		clear && Time
		echo "正在调用"
		cp My_config/$transfer  .config
		echo "配置加载完成回车进行编译" && read a
		make menuconfig
	else
		clear && echo "调用错误" && Time
		transfer_My_config
	fi
	
	
}

Root_detection(){	
	if [$(id -u) == "0"]; then 
		echo "Error:You must run this without root"
		exit			
	else
		clear && echo " 你非root用户开始准备安装系统"  && Time
	fi 	
		
		
	#此模块代码由郑学渣提供	
}

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
		sh openwrt.sh	
		;;
		*)
	clear && echo  "请输入正确的数字 [1-2,0]" && Time
	other
	;;
esac
}


	clear
	echo "	      -------------------------------------"
	echo "	      	    【 ××Openwrt编译辅助脚本$version版×× 】"
	echo ""
	echo " 		  	1.开始搭建编译环境"
	echo ""
	echo "		  	2.更新源代码"
	echo ""
	echo "			3.二次编译固件"
	echo ""
	echo "			4.恢复编译环境"
	echo ""
	echo "			5.替换DNS HOST(加快下载与打开GitHub)"
	echo ""
	echo "			6.其他选项"	
	echo ""
	echo "		  	0. EXIT"
	echo ""
	echo ""
	echo "		PS:请先搭建好梯子再进行编译，不然很慢！"
	echo "			     By:ITdesk"
	echo "	      --------------------------------------"
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
		5)
		DNS_Host
		;;
		6)
		other
		;;
		0)
		exit;;
		*)
	clear && echo  "请输入正确的数字 [1-5,0]" && Time
	sh openwrt.sh
	;;
esac





