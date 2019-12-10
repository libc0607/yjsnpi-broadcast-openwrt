include $(TOPDIR)/rules.mk

PKG_NAME:=wbc-packages-mtk
PKG_RELEASE:=YJSNPIv0.1
PKG_SOURCE_DATE:=2019-08-14

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_SOURCE_DATE)

include $(INCLUDE_DIR)/package.mk

define Package/wbc-packages-mtk
  SECTION:=net
  CATEGORY:=Network
  TITLE:=wbc-packages-mtk
  DEPENDS:=+coreutils +coreutils-stty +socat +usbutils +setsbus +eth-uart \
  +ntfs-3g +block-mount +mount-utils \
  +kmod-usb2 +kmod-usb-ohci +kmod-usb-storage-extras \
  +kmod-fs-vfat +kmod-fs-autofs4 +kmod-fs-ext4 \
  +kmod-nls-cp437 +kmod-nls-utf8 +kmod-nls-iso8859-1 \
  +kmod-usb-net +kmod-usb-net-rndis \
  +kmod-usb-serial +kmod-usb-serial-ch341 +kmod-usb-serial-ftdi \
  +kmod-ath9k +kmod-ath9k-htc +kmod-rtl8187 +kmod-rtl8812au-ct \
  +kmod-rt2800-pci +kmod-rt2800-usb +kmod-rt2500-usb +kmod-rt2500-pci \
  +kmod-rt2400-pci +kmod-ath5k \
  +kmod-mmc +kmod-sdhci +kmod-sdhci-mt7620
endef

define Package/wbc-packages-mtk/description
  ezwifibroadcast base packages on openwrt
endef

define Package/wbc-packages-mtk/install
endef

$(eval $(call BuildPackage,wbc-packages-mtk))
