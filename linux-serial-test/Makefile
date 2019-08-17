include $(TOPDIR)/rules.mk

PKG_NAME:=linux-serial-test
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/cbrake/linux-serial-test.git
PKG_SOURCE_DATE:=2018-09-13
PKG_SOURCE_VERSION:=aed2a6e78160b63295368d70dbdbc19fe3a38225

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/linux-serial-test
  CATEGORY:=Utilities
  TITLE:=linux-serial-test
  DEPENDS:=
endef

define Package/linux-serial-test/description
 linux-serial-test on openwrt
endef

define Build/Configure
	 mkdir -p $(PKG_BUILD_DIR)
	 [ -f $(PKG_BUILD_DIR)/CMakeLists.txt ] && rm $(PKG_BUILD_DIR)/CMakeLists.txt || echo
	 $(CP) ./files/* $(PKG_BUILD_DIR)
	 [ -f $(PKG_BUILD_DIR)/Makefile ] && rm $(PKG_BUILD_DIR)/Makefile || echo
	 [ -f $(PKG_BUILD_DIR)/CMakeCache.txt ] && rm $(PKG_BUILD_DIR)/CMakeCache.txt || echo
	 [ -f $(PKG_BUILD_DIR)/*.o ] && rm $(PKG_BUILD_DIR)/*.o || echo
	$(call Build/Configure/Default)
endef

define Package/linux-serial-test/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/linux-serial-test $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,linux-serial-test))
