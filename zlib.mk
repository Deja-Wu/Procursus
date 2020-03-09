ifneq ($(CHECKRA1N_MEMO),1)
$(error Use the main Makefile)
endif

zlib:
	cd $(BUILD_WORK)/zlib && ./configure -C \
		--prefix=/usr
	$(MAKE) -C $(BUILD_WORK)/zlib
	$(FAKEROOT) $(MAKE) -C $(BUILD_WORK)/zlib install

.PHONY: zlib