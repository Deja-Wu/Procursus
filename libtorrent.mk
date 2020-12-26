ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS                  += libtorrent-rasterbar
LIBTORRENT-RASTERBAR_VERSION := 2.0.1
DEB_LIBTORRENT-RASTERBAR_V   ?= $(LIBTORRENT-RASTERBAR_VERSION)

libtorrent-rasterbar-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/arvidn/libtorrent/releases/download/v$(LIBTORRENT-RASTERBAR_VERSION)/libtorrent-rasterbar-$(LIBTORRENT-RASTERBAR_VERSION).tar.gz
	$(call EXTRACT_TAR,libtorrent-rasterbar-$(LIBTORRENT-RASTERBAR_VERSION).tar.gz,libtorrent-rasterbar-$(LIBTORRENT-RASTERBAR_VERSION),libtorrent-rasterbar)

ifneq ($(wildcard $(BUILD_WORK)/libtorrent-rasterbar/.build_complete),)
libtorrent-rasterbar:
	@echo "Using previously built libtorrent-rasterbar."
else
libtorrent-rasterbar: libtorrent-rasterbar-setup libboost openssl
	cd $(BUILD_WORK)/libtorrent-rasterbar && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--disable-debug \
		--disable-dependency-tracking \
		--disable-silent-rules \
		--enable-encryption \
		
	+$(MAKE) -C $(BUILD_WORK)/libtorrent-rasterbar
	+$(MAKE) -C $(BUILD_WORK)/libtorrent-rasterbar install \
		DESTDIR=$(BUILD_STAGE)/libtorrent-rasterbar
	mkdir -p $(BUILD_STAGE)/libtorrent-rasterbar/etc
	cp -a $(BUILD_WORK)/libtorrent-rasterbar/doc/sample.libtorrent-rasterbarrc $(BUILD_STAGE)/libtorrent-rasterbar/etc/libtorrent-rasterbarrc
	touch $(BUILD_WORK)/libtorrent-rasterbar/.build_complete
endif

libtorrent-rasterbar-package: libtorrent-rasterbar-stage
	# libtorrent-rasterbar.mk Package Structure
	rm -rf $(BUILD_DIST)/libtorrent-rasterbar
	mkdir -p $(BUILD_DIST)/libtorrent-rasterbar
	
	# libtorrent-rasterbar.mk Prep libtorrent-rasterbar
	cp -a $(BUILD_STAGE)/libtorrent-rasterbar $(BUILD_DIST)
	
	# libtorrent-rasterbar.mk Sign
	$(call SIGN,libtorrent-rasterbar,general.xml)
	
	# libtorrent-rasterbar.mk Make .debs
	$(call PACK,libtorrent-rasterbar,DEB_LIBTORRENT-RASTERBAR_V)
	
	# libtorrent-rasterbar.mk Build cleanup
	rm -rf $(BUILD_DIST)/libtorrent-rasterbar

.PHONY: libtorrent-rasterbar libtorrent-rasterbar-package