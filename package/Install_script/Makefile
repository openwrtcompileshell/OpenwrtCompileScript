#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=Install_script
PKG_VERSION:=1
PKG_RELEASE:=8
#PKG_FLAGS:=nonshared

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/Install_script
  TITLE:=x86/x64 Install Script.
  MAINTAINER:=ITdesk
  DEPENDS:=+git +git-http +node +node-npm
endef

define Package/Install_script/description
Script Used
	https://github.com/ITdesk01/JD_Script
	https://github.com/ITdesk01/Checkjs
	https://github.com/ITdesk01/AUCloudflareIP

Dependent requirements
	node >=10
	node-npm >=10

Please meet the above dependencies, otherwise you may not be able to use the script normally

endef

define Build/Compile
endef

define Package/Install_script/conffies
	/usr/share/Install_script/config
endef

define Package/Install_script/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/Install_script $(1)/etc/init.d/Install_script
endef

$(eval $(call BuildPackage,Install_script))
