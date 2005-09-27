NAME=sems
LIBNAME=sems.so

# version number
VERSION = 0
PATCHLEVEL = 9
SUBLEVEL =   9
EXTRAVERSION = _unstable

RELEASE=$(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)

PLUGIN_DIR=plug-in
SRCS=$(filter-out $(NAME).cpp traceloader.cpp, $(wildcard *.cpp))
HDRS=$(SRCS:.cpp=.h)
OBJS=$(SRCS:.cpp=.o)
DEPS=$(SRCS:.cpp=.d) $(NAME).d traceloader.d
AUDIO_FILES=$(notdir $(wildcard wav/*.wav))

include Makefile.defs

.PHONY: all
all:
	-@$(MAKE) deps    && \
	  $(MAKE) $(NAME) && \
	  $(MAKE) traceloader && \
	  $(MAKE) modules


.PHONY: clean
clean:
	rm -f $(OBJS) $(DEPS) $(NAME)
	rm -f lib/apps/*.so lib/audio/*.so
	$(MAKE) -C $(PLUGIN_DIR) clean

.PHONY: modules
modules:
	$(MAKE) -C $(PLUGIN_DIR) $(MAKECMDGOALS)

.PHONY: deps
deps: $(DEPS)

.PHONY: doc
doc:
	rm -Rf doxygen_output; rm -rf docs/doxygen_output ; \
	doxygen doxygen_proj ; mv doxygen_output docs

# implicit rules
%.o : %.cpp %.d
	g++ -c -o $@ $< $(CPP_FLAGS)

%.d : %.cpp %.h Makefile
	g++ -MM $< $(CPP_FLAGS) > $@

md5.o: md5.c md5.d
	$(CC) $(cflags) -c $< -o $@

md5.d: md5.c md5.h Makefile
	$(CC) -MM $< $(cflags) > $@

# explicit rules
#$(LIBNAME): $(OBJS)
#	g++ -o $(LIBNAME) $(OBJS) $(LIB_LD_FLAGS)

$(NAME): $(NAME).o $(OBJS) md5.o
	g++ -o $(NAME) $(NAME).o $(OBJS) md5.o $(LD_FLAGS)

traceloader: traceloader.o  $(OBJS)
	g++ -o $@ traceloader.o $(OBJS) md5.o $(LD_FLAGS)

install: all mk-install-dirs install-cfg install-bin install-modules \
	install-audio install-doc

mk-install-dirs: $(cfg-prefix)/$(cfg-dir) $(bin-prefix)/$(bin-dir) \
			$(modules-prefix)/$(modules-dir)audio \
			$(modules-prefix)/$(modules-dir)apps \
			$(audio-prefix)/$(audio-dir) \
			$(doc-prefix)/$(doc-dir)

$(cfg-prefix)/$(cfg-dir): 
		mkdir -p $(cfg-prefix)/$(cfg-dir)

$(bin-prefix)/$(bin-dir):
		mkdir -p $(bin-prefix)/$(bin-dir)

$(modules-prefix)/$(modules-dir)audio:
		mkdir -p $(modules-prefix)/$(modules-dir)audio

$(modules-prefix)/$(modules-dir)apps:
		mkdir -p $(modules-prefix)/$(modules-dir)apps

$(audio-prefix)/$(audio-dir):
		mkdir -p $(audio-prefix)/$(audio-dir)

$(doc-prefix)/$(doc-dir):
		mkdir -p $(doc-prefix)/$(doc-dir)

# note: on solaris 8 sed: ? or \(...\)* (a.s.o) do not work
install-cfg: $(cfg-prefix)/$(cfg-dir)
		sed -e "s#/usr/.*lib/sems/audio/#$(audio-target)#g" \
			-e "s#/usr/.*lib/sems/plug-in/#$(modules-target)#g" \
			-e "s#/usr/.*etc/sems#$(cfg-target)#g" \
			< sems.conf.sample > $(cfg-prefix)/$(cfg-dir)sems.conf.default
		chmod 644 $(cfg-prefix)/$(cfg-dir)sems.conf.default
		if [ ! -f $(cfg-prefix)/$(cfg-dir)sems.conf ]; then \
			mv -f $(cfg-prefix)/$(cfg-dir)sems.conf.default \
				$(cfg-prefix)/$(cfg-dir)sems.conf; \
		fi

install-bin: $(bin-prefix)/$(bin-dir)
		$(INSTALL-TOUCH) $(bin-prefix)/$(bin-dir)$(NAME)
		$(INSTALL-BIN) $(NAME) $(bin-prefix)/$(bin-dir)

install-modules: $(PLUGIN_DIR) $(modules-prefix)/$(modules-dir)audio \
		 $(modules-prefix)/$(modules-dir)apps
	$(MAKE) -C $(PLUGIN_DIR) install

install-audio: $(audio-prefix)/$(audio-dir)
	-@for f in $(AUDIO_FILES) ; do \
		if [ -n "wav/$$f" ]; then \
			$(INSTALL-TOUCH) $(audio-prefix)/$(audio-dir)$$f; \
			$(INSTALL-AUDIO) wav/$$f $(audio-prefix)/$(audio-dir)$$f; \
		fi ; \
	done

install-doc: $(doc-prefix)/$(doc-dir)
	$(INSTALL-TOUCH) $(doc-prefix)/$(doc-dir)README
	$(INSTALL-DOC) README $(doc-prefix)/$(doc-dir)

dist: tar

tar: 
	$(TAR) -C .. \
		--exclude=$(notdir $(CURDIR))/ivr \
		--exclude=$(notdir $(CURDIR))/tmp \
		--exclude=CVS* \
		--exclude=.\#* \
		--exclude=*.[do] \
		--exclude=*.la \
		--exclude=*.lo \
		--exclude=*.so \
		--exclude=*.il \
		--exclude=$(notdir $(CURDIR))/sems \
		--exclude=*.gz \
		--exclude=*.bz2 \
		--exclude=*.tar \
		-cf - $(notdir $(CURDIR)) | \
			(mkdir -p tmp/_tar1; mkdir -p tmp/_tar2 ; \
			    cd tmp/_tar1; $(TAR) -xf - ) && \
			    mv tmp/_tar1/$(notdir $(CURDIR)) \
			       tmp/_tar2/"$(NAME)-$(RELEASE)" && \
			    (cd tmp/_tar2 && $(TAR) \
			                    -zcf ../../"$(NAME)-$(RELEASE)".tar.gz \
			                               "$(NAME)-$(RELEASE)" ) ; \
			    rm -rf tmp/_tar1; rm -rf tmp/_tar2


ifeq '$(NAME)' '$(MAKECMDGOALS)'
include $(DEPS)
endif


