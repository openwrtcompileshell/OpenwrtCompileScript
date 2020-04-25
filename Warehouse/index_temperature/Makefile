#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=autocore
PKG_VERSION:=1
PKG_RELEASE:=31


include $(INCLUDE_DIR)/package.mk

define Package/autocore
  TITLE:=x86/x64 auto core loadbalance script.
  MAINTAINER:=Lean
  DEPENDS:=@(i386||x86_64||arm||mipsel||mips||aarch64) +bc +lm-sensors +ethtool
endef

define Package/autocore/description
A usb autoconfig hotplug script.
endef

define Build/Compile
endef

ifeq ($(ARCH),x86_64)
	SYS_IF=$($(INSTALL_DATA) ./files/index.htm $(1)/etc/index.htm)
endif

ifeq ($(ARCH),i386)
	SYS_IF=$($(INSTALL_DATA) ./files/index.htm $(1)/etc/index.htm)
endif

define Package/autocore/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/autocore $(1)/etc/init.d/autocore
	$(INSTALL_DIR) $(1)/etc
	$(eval $(SYS_IF))
	$(INSTALL_DIR) $(1)/sbin
	$(CP) ./files/sbin/* $(1)/sbin
endef

$(eval $(call BuildPackage,autocore))
