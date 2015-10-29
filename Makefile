TMP ?= $(abspath tmp)

version := 0.9.1
installer_version := 1
configure_flags := 

.SECONDEXPANSION :

.PHONY : all
all : httperf-$(version).pkg


.PHONY : clean
clean :
	-rm -f httperf-$(version).pkg
	-rm -rf $(TMP)


##### dist ##########
dist_sources := $(shell find dist -type f \! -name .DS_Store)

$(TMP)/install/usr/local/bin/httperf : $(TMP)/build/httperf | $(TMP)/install
	cd $(TMP)/build && $(MAKE) DESTDIR=$(TMP)/install install

$(TMP)/build/httperf : $(TMP)/build/config.status $(dist_sources)
	cd $(TMP)/build && $(MAKE)

$(TMP)/build/config.status : dist/configure | $(TMP)/build
	cd $(TMP)/build && sh $(abspath $<) $(configure_flags)

$(TMP)/build \
$(TMP)/install :
	mkdir -p $@


##### pkg ##########

$(TMP)/httperf-$(version).pkg : \
        $(TMP)/install/usr/local/bin/httperf \
        $(TMP)/install/etc/paths.d/httperf.path
	pkgbuild \
        --root $(TMP)/install \
        --identifier com.ablepear.httperf \
        --ownership recommended \
        --version $(version) \
        $@

$(TMP)/install/etc/paths.d/httperf.path : httperf.path | $(TMP)/install/etc/paths.d
	cp $< $@

$(TMP)/install/etc/paths.d :
	mkdir -p $@


##### product ##########

httperf-$(version).pkg : \
        $(TMP)/httperf-$(version).pkg \
        $(TMP)/distribution.xml \
        $(TMP)/resources/background.png \
        $(TMP)/resources/license.html \
        $(TMP)/resources/welcome.html
	productbuild \
        --distribution $(TMP)/distribution.xml \
        --resources $(TMP)/resources \
        --package-path $(TMP) \
        --version $(installer_version) \
        --sign 'Able Pear Software Incorporated' \
        $@

$(TMP)/distribution.xml \
$(TMP)/resources/welcome.html : $(TMP)/% : % | $$(dir $$@)
	sed -e s/{{version}}/$(version)/g $< > $@

$(TMP)/resources/background.png \
$(TMP)/resources/license.html : $(TMP)/% : % | $(TMP)/resources
	cp $< $@

$(TMP) \
$(TMP)/resources :
	mkdir -p $@
