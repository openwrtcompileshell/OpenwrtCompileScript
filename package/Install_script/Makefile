#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=Install_script
PKG_VERSION:=1
PKG_RELEASE:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/Install_script
  TITLE:=x86/x64 Install JD_Script Checkjs AUCloudflareIP Script.
  MAINTAINER:=ITdesk
  DEPENDS:=+git +git-http +node +node-npm
endef

define Package/Install_script/description
	Install JD_Script Checkjs AUCloudflareIP Script.
endef

define Build/Compile
endef

define Package/Install_script/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/Install_script-settings $(1)/etc/uci-defaults/99-Install_script-settings
endef

$(eval $(call BuildPackage,Install_script))
