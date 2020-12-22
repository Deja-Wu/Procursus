ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += ruby
RUBY_VERSION := 2.7.2
DEB_RUBY_V   ?= $(RUBY_VERSION)

ruby-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://cache.ruby-lang.org/pub/ruby/2.7/ruby-$(RUBY_VERSION).tar.xz
	$(call EXTRACT_TAR,ruby-$(RUBY_VERSION).tar.xz,ruby-$(RUBY_VERSION),ruby)
	$(call DO_PATCH,ruby,ruby,-p1)

ifneq ($(wildcard $(BUILD_WORK)/ruby/.build_complete),)
ruby:
	@echo "Using previously built ruby."
else
ruby: ruby-setup openssl readline libgmp10 libffi
	cd $(BUILD_WORK)/ruby && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--enable-shared \
		MJIT_CC=/usr/bin/clang
	+$(MAKE) -C $(BUILD_WORK)/ruby
	+$(MAKE) -C $(BUILD_WORK)/ruby install \
		DESTDIR=$(BUILD_STAGE)/ruby
	touch $(BUILD_WORK)/ruby/.build_complete
endif

ruby-package: ruby-stage
	# ruby.mk Package Structure
	rm -rf $(BUILD_DIST)/ruby
	mkdir -p $(BUILD_DIST)/ruby
	
	# ruby.mk Prep ruby
	cp -a $(BUILD_STAGE)/ruby $(BUILD_DIST)
	
	# ruby.mk Sign
	$(call SIGN,ruby,general.xml)
	
	# ruby.mk Make .debs
	$(call PACK,ruby,DEB_RUBY_V)
	
	# ruby.mk Build cleanup
	rm -rf $(BUILD_DIST)/ruby

.PHONY: ruby ruby-package
