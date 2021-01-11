#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=installscript
PKG_VERSION:=1
PKG_RELEASE:=3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/installscript
  TITLE:=x86/x64 Install JD_Script Checkjs AUCloudflareIP Script.
  MAINTAINER:=ITdesk
  DEPENDS:=+git +git-http +node +node-npm
endef

define Package/installscript/description
	Install JD_Script Checkjs AUCloudflareIP Script.
endef

define Build/Compile
endef

define Package/installscript/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/installscript-settings-settings $(1)/etc/uci-defaults/99-installscript-settings
endef

$(eval $(call BuildPackage,installscript))
