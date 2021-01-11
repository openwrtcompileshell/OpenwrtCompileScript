#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=installscript
PKG_VERSION:=1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/installscript-x86
  TITLE:=x86/x64 Install script.
  MAINTAINER:=ITdesk
  DEPENDS:=@TARGET_x86
  VARIANT:=x86
endef

define Package/installscript-x86/description
  Install JD_Script Checkjs AUCloudflareIP Script.
endef

define Build/Compile
endef

define Package/installscript-x86/postinst
	#!/bin/sh
	npm install -g crypto-js got http-server tough-cookie download request tunnel
	exit 0
endef 

define Package/installscript-x86/install
	$(INSTALL_DIR) $(1)/usr/share
	$(CP) ./files/* $(1)/usr/share
endef

$(eval $(call BuildPackage,installscript-x86))
