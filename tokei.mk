ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += tokei
TOKEI_VERSION := 12.0.4
DEB_TOKEI_V   ?= $(TOKEI_VERSION)

tokei-setup: setup
	-[ ! -f "$(BUILD_SOURCE)/tokei-$(TOKEI_VERSION).tar.gz" ] && wget -q -nc -O$(BUILD_SOURCE)/tokei-$(TOKEI_VERSION).tar.gz https://github.com/XAMPPRocky/tokei/archive/v$(TOKEI_VERSION).tar.gz
	$(call EXTRACT_TAR,tokei-$(TOKEI_VERSION).tar.gz,tokei-$(TOKEI_VERSION),tokei)

ifneq ($(wildcard $(BUILD_WORK)/tokei/.build_complete),)
tokei:
	@echo "Using previously built tokei."
else
tokei: tokei-setup
	cd $(BUILD_WORK)/tokei && SDKROOT="$(TARGET_SYSROOT)" cargo \
		build \
		--release \
		--target=$(RUST_TARGET) \
		--features all

#	touch $(BUILD_WORK)/tokei/.build_complete
endif

tokei-package: tokei-stage
	# tokei.mk Package Structure
	rm -rf $(BUILD_DIST)/tokei
	
	# tokei.mk Prep tokei
	cp -a $(BUILD_STAGE)/tokei $(BUILD_DIST)
	
	# tokei.mk Sign
	$(call SIGN,tokei,general.xml)
	
	# tokei.mk Make .debs
	$(call PACK,tokei,DEB_TOKEI_V)
	
	# tokei.mk Build cleanup
	rm -rf $(BUILD_DIST)/tokei

.PHONY: tokei tokei-package
