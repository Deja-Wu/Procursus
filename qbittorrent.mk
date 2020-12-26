ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS         += qbittorrent
QBITTORRENT_VERSION := 4.3.1
DEB_QBITTORRENT_V   ?= $(QBITTORRENT_VERSION)

qbittorrent-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://downloads.sourceforge.net/project/qbittorrent/qbittorrent/qbittorrent-$(QBITTORRENT_VERSION)/qbittorrent-$(QBITTORRENT_VERSION).tar.xz{,.asc}
	$(call PGP_VERIFY,qbittorrent-$(QBITTORRENT_VERSION).tar.xz,asc)
	$(call EXTRACT_TAR,qbittorrent-$(QBITTORRENT_VERSION).tar.xz,qbittorrent-$(QBITTORRENT_VERSION),qbittorrent)

ifneq ($(wildcard $(BUILD_WORK)/qbittorrent/.build_complete),)
qbittorrent:
	@echo "Using previously built qbittorrent."
else
qbittorrent: qbittorrent-setup libboost
	cd $(BUILD_WORK)/qbittorrent && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--disable-debug \
		--sysconfdir=/etc \
		--disable-dependency-tracking \
		--enable-color \
		--enable-extra \
		--enable-qbittorrentrc \
		--enable-utf8 \
		--enable-multibuffer \
		NCURSESW_LIBS=$(BUILD_BASE)/usr/lib/libncursesw.dylib
	+$(MAKE) -C $(BUILD_WORK)/qbittorrent
	+$(MAKE) -C $(BUILD_WORK)/qbittorrent install \
		DESTDIR=$(BUILD_STAGE)/qbittorrent
	mkdir -p $(BUILD_STAGE)/qbittorrent/etc
	cp -a $(BUILD_WORK)/qbittorrent/doc/sample.qbittorrentrc $(BUILD_STAGE)/qbittorrent/etc/qbittorrentrc
	touch $(BUILD_WORK)/qbittorrent/.build_complete
endif

qbittorrent-package: qbittorrent-stage
	# qbittorrent.mk Package Structure
	rm -rf $(BUILD_DIST)/qbittorrent
	mkdir -p $(BUILD_DIST)/qbittorrent
	
	# qbittorrent.mk Prep qbittorrent
	cp -a $(BUILD_STAGE)/qbittorrent $(BUILD_DIST)
	
	# qbittorrent.mk Sign
	$(call SIGN,qbittorrent,general.xml)
	
	# qbittorrent.mk Make .debs
	$(call PACK,qbittorrent,DEB_QBITTORRENT_V)
	
	# qbittorrent.mk Build cleanup
	rm -rf $(BUILD_DIST)/qbittorrent

.PHONY: qbittorrent qbittorrent-package
