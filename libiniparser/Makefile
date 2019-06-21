include $(TOPDIR)/rules.mk

PKG_NAME:=libiniparser
PKG_RELEASE:=4.1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/ndevilla/iniparser.git
PKG_SOURCE_DATE:=2019-06-10
PKG_SOURCE_VERSION:=f858275f7f307eecba84c2f5429483f9f28007f8

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/$(PKG_NAME)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=$(PKG_NAME)
endef

define Package/$(PKG_NAME)/description
 libiniparser
endef

define Build/Configure
	 mkdir -p $(PKG_BUILD_DIR)
	 $(CP) ./src/* $(PKG_BUILD_DIR)
	 [ -d $(PKG_BUILD_DIR)/src ] && $(CP) $(PKG_BUILD_DIR)/src/* $(PKG_BUILD_DIR)/ || echo
	 [ -f $(PKG_BUILD_DIR)/Makefile ] && rm $(PKG_BUILD_DIR)/Makefile || echo
	 [ -f $(PKG_BUILD_DIR)/CMakeCache.txt ] && rm $(PKG_BUILD_DIR)/CMakeCache.txt || echo
	 [ -f $(PKG_BUILD_DIR)/*.o ] && rm $(PKG_BUILD_DIR)/*.o || echo
	$(call Build/Configure/Default)
endef

define Build/InstallDev
	echo "===================================="
	echo "===================================="
	echo "===================================="
	echo "===================================="
	echo "===================================="
	echo
	echo $(1)
	echo 
	echo $(2)
	echo
	echo "===================================="
	echo 
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libiniparser.so* $(1)/usr/lib/
endef

define Package/libiniparser/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libiniparser.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

