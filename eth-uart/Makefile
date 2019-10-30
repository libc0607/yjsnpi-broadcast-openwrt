include $(TOPDIR)/rules.mk

PKG_NAME:=eth-uart
PKG_RELEASE:=1

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/eth-uart
  CATEGORY:=Network
  TITLE:=eth-uart
  DEPENDS:=kmod-eth-uart libiniparser
endef

define Package/eth-uart/description
 eth-uart userspace program
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

define Package/eth-uart/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eth-uart $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,eth-uart))
