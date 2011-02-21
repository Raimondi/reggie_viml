PLUGIN=$(shell basename "$$PWD")
AUTOL=autoload/$(PLUGIN).vim
DOC=$(wildcard doc/*.txt)
FTPLUGINVIM=ftplugin/vim/$(PLUGIN).vim
FTPLUGINRUBY=ftplugin/ruby/$(PLUGIN).vim
VERSION=$(shell perl -ne 'if (/\*\sCurrent\sRelease:/) {s/^\s+(\d+\.\S+)\s.*$$/\1/;print}' $(DOC))
VIMFOLDER=~/.vim/
VIM=/usr/bin/vim
ALL=$(AUTOL) $(DOC) $(FTPLUGINVIM) $(FTPLUGINRUBY)

.PHONY: clean all vimball zip release echo

#.ONESHELL:

all: vimball README zip gzip

vimball: $(PLUGIN).vba

zip: $(PLUGIN).zip

gzip: $(PLUGIN).gz

clean:
	@echo clean
	rm -f *.vba **/*.orig *.~* .VimballRecord *.zip *.gz version

undo:
	for i in **/*.orig; do mv -f "$$i" "$${i%.*}"; done

README: $(DOC)
	@echo README
	ln -f $(DOC) README

$(PLUGIN).vba $(PLUGIN).zip version: $(ALL)
	@if [ "$@" == "$(PLUGIN).vba" ]; then \
		echo Creating $(PLUGIN).vba; \
		rm -f $(PLUGIN)-$(VERSION).vba; \
		$(VIM) -N -u NONE -c 'ru! plugin/vimballPlugin.vim' -c ':call append("0", [ "$(AUTOL)", "$(DOC)", "$(FTPLUGINRUBY)", "$(FTPLUGINVIM)"])' -c '$$d' -c ":%MkVimball $(PLUGIN)-$(VERSION)  ." -c':q!'; \
		ln -f $(PLUGIN)-$(VERSION).vba $(PLUGIN).vba; \
	elif [ "$@" == "$(PLUGIN).zip" ]; then \
		echo Creating $(PLUGIN).zip; \
		rm -f *.zip; \
		zip -r $(PLUGIN).zip doc ftplugin autoload; \
		zip $(PLUGIN).zip -d \*.sw\? || echo 1; \
		zip $(PLUGIN).zip -d \*.un\? || echo 1; \
		zip $(PLUGIN).zip -d \*.orig || echo 1; \
		zip $(PLUGIN).zip -d \*tags  || echo 1; \
		ln -f $(PLUGIN).zip $(PLUGIN)-$(VERSION).zip; \
	elif [ "$@" == "version" ]; then \
		echo Version: $(VERSION); \
		perl -i.orig -pne 'if (/^"\sVersion:/) {s/(\d+\.\S+)/$(VERSION)/}' $(FTPLUGINRUBY) $(FTPLUGINVIM) $(AUTOL); \
		perl -i.orig -pne 'if (/^v\d+\.\S+$$/) {s/(v\d+\.\S+)/v$(VERSION)/}' $(DOC); \
		echo Date: `date '+%G %B %d'`; \
		perl -i.orig -MPOSIX -pne 'if (/^"\sModified:/) {$$now_string = strftime "%F", localtime; s/(\d+-\d+-\d+)/$$now_string/}' $(FTPLUGINRUBY) $(FTPLUGINVIM) $(AUTOL); \
		perl -i.orig -MPOSIX -pne 'if (/^\s+$(VERSION)\s+\d+-\d+-\d+\s+\*/) {$$now_string = strftime "%F", localtime; s/(\d+-\d+-\d+)/$$now_string/}' $(DOC); \
		perl -i.orig -MPOSIX -pne 'if (/^\*$(PLUGIN)\.txt\*.*/) {$$now_string = strftime "%G %B %d", localtime; s/(\d{4} [a-zA-Z]+ \d{2})/$$now_string/}' $(DOC); \
		echo $(VERSION) > version; \
	fi

$(PLUGIN).gz: $(PLUGIN).vba
	@echo vimball
	gzip -fc $(PLUGIN).vba > $(PLUGIN).gz

release: version all

echo:
