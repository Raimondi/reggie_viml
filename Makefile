PLUGIN=$(shell basename "$$PWD")
AUTOL=autoload/$(PLUGIN).vim
DOC=$(wildcard doc/*.txt)
FTPLUGINS=$(wildcard ftplugin/**/*.vim)
VERSION=$(shell perl -ne 'if (/\*\sCurrent\sRelease:/) {s/^\s+(\d+\.\S+)\s.*$$/\1/;print}' $(DOC))
VIM=vim
ALL=$(AUTOL) $(DOC) $(FTPLUGINS)
QALL=$(shell for i in $(ALL); do var=$$var"\"$$i\", ";done;echo $${var%,})

.PHONY: clean all vimball zip release echo
all: vimball README zip gzip
vimball: $(PLUGIN).vba
zip: $(PLUGIN).zip
gzip: $(PLUGIN).gz

clean:
	@echo clean
	rm -f *.vba **/*.orig *.~* .VimballRecord *.zip *.gz version

undo:
	@for i in **/*.orig; do mv -f "$$i" "$${i%.*}"; echo mv -f "$$i" "$${i%.*}"; done

README: $(DOC)
	@echo README
	ln -f $(DOC) README

$(PLUGIN).vba $(PLUGIN).zip version: $(ALL)
	@if [ "$@" == "$(PLUGIN).vba" ]; then \
		echo Creating "$(PLUGIN).vba"; \
		rm -f $(PLUGIN)-$(VERSION).vba; \
		echo $(VIM) -N -u NONE -c 'ru! plugin/vimballPlugin.vim' -c ':call append("0", [ $(QALL) ])' -c '$$d' -c ":%MkVimball $(PLUGIN)-$(VERSION)  ." -c':q!'; \
		$(VIM) -N -u NONE -c 'ru! plugin/vimballPlugin.vim' -c ':call append("0", [ $(QALL) ])' -c '$$d' -c ":%MkVimball $(PLUGIN)-$(VERSION)  ." -c':q!'; \
		ln -f $(PLUGIN)-$(VERSION).vba $(PLUGIN).vba; \
	elif [ "$@" == "$(PLUGIN).zip" ]; then \
		echo Creating "$(PLUGIN).zip"; \
		rm -f *.zip; \
		zip -r $(PLUGIN).zip doc ftplugin autoload; \
		zip $(PLUGIN).zip -d \*.sw\? || echo 1; \
		zip $(PLUGIN).zip -d \*.un\? || echo 1; \
		zip $(PLUGIN).zip -d \*.orig || echo 1; \
		zip $(PLUGIN).zip -d \*tags  || echo 1; \
		ln -f $(PLUGIN).zip $(PLUGIN)-$(VERSION).zip; \
	elif [ "$@" == "version" ]; then \
		echo Version: $(VERSION); \
		perl -i.orig -pne 'if (/^"\sVersion:/) {s/(\d+\.\S+)/$(VERSION)/}' $(FTPLUGINS) $(AUTOL); \
		perl -i.orig -pne 'if (/^v\d+\.\S+$$/) {s/(v\d+\.\S+)/v$(VERSION)/}' $(DOC); \
		echo Date: `date '+%G %B %d'`; \
		perl -i.orig -MPOSIX -pne 'if (/^"\sModified:/) {$$now_string = strftime "%F", localtime; s/(\d+-\d+-\d+)/$$now_string/}' $(FTPLUGINS) $(AUTOL); \
		perl -i.orig -MPOSIX -pne 'if (/^\s+$(VERSION)\s+\d+-\d+-\d+\s+\*/) {$$now_string = strftime "%F", localtime; s/(\d+-\d+-\d+)/$$now_string/}' $(DOC); \
		perl -i.orig -MPOSIX -pne 'if (/^\*$(PLUGIN)\.txt\*.*/) {$$now_string = strftime "%G %B %d", localtime; s/(\d{4} [a-zA-Z]+ \d{2})/$$now_string/}' $(DOC); \
		echo $(VERSION) > version; \
	fi

$(PLUGIN).gz: $(PLUGIN).vba
	@echo Creating "$(PLUGIN).gz"
	gzip -fc $(PLUGIN).vba > $(PLUGIN).gz

release: version all

echo:
	echo $(FTPLUGINS)
