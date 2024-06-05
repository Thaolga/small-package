#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clash
PKG_VERSION:=_meta

PKG_RELEASE:=1.85

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Clash is a cross-platform proxy software
	URL:=https://github.com/MetaCubeX/mihomo
endef


define Package/$(PKG_NAME)/description
Clash is a cross-platform proxy software
endef

CLASH_BIN:=clash

ifeq ($(ARCH),x86_64)
	PKG_ARCH_CLASH:=amd64
endif
ifeq ($(ARCH),mipsel)
	PKG_ARCH_CLASH:=mipsle
endif
ifeq ($(ARCH),mips)
	PKG_ARCH_CLASH:=mips
endif
ifeq ($(ARCH),i386)
	PKG_ARCH_CLASH:=x86
endif
ifeq ($(ARCH),arm)
	PKG_ARCH_CLASH:=arm
	ifneq ($(BOARD),bcm53xx)
		CLASH_BIN:=clash_armv7
  endif
  ifeq ($(BOARD),kirkwood)
		CLASH_BIN:=clash
  endif
endif
ifeq ($(ARCH),aarch64)
	PKG_ARCH_CLASH:=arm64
endif

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/openclash/core
	$(INSTALL_BIN) ./files/$(PKG_ARCH_CLASH)/$(CLASH_BIN) $(1)/etc/openclash/core/clash_meta
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
