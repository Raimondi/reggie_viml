# This should make my life easier.
# Almost everthing depends on perl.

# The name of the plugin is the same of the containing dir.
plugin_name        = $(shell basename "$$PWD")
# Location of help file, many things depend on this.
help_file          = doc/$(plugin_name).txt
# All other files.
autoload_script    = autoload/$(plugin_name).vim
ftplugins          = $(wildcard ftplugin/**/*.vim)
# Get version from the documentation.
current_version    = $(shell perl -ne 'if (/\*\sCurrent\sRelease:/) {s/^\s+(\d+\.\S+)\s.*$$/\1/;print;exit}' $(help_file))
# Set the file name + version to be used in release files.
name_plus_version  = $(plugin_name)-$(current_version)
# Where is Vim.
vim_exec           = vim
# Group all files.
all_files          = $(autoload_script) $(help_file) $(ftplugins)
# Let's get them ready to be used by Vim's append().
all_quoted         = $(shell for i in $(all_files); do var=$$var"\"$$i\", ";done;echo $${var%,})
# Temp file that will prevent the version target to be run if not needed.
version_file       = version.txt
# Command to open URLs.
open_url = open

# vim.org values.
#----------------
# The version comments.
VO_comment_file    = comments.txt
# Script's vim.org ID.
VO_scriptID        = 3026
# Script URL.
VO_scriptURL       = http://www.vim.org/scripts/script.php?script_id=$(VO_scriptID)
# Vim's minimum version where the script will run.
VO_min_vim_version = $(shell perl -ne 'if (/^\*$(plugin_name).txt\*\s+For Vim version/) {s/^.*For Vim version (\d+\.\S+)\s.*$$/\1/;print;exit}' $(help_file))
# Cookies file.
VO_cookie_jar      = cookies.txt

# github.com values.
#-------------------
# Get github's username from the git repo.
GH_username        = $(strip $(shell git config --global github.user))
# Now the downloads page URL.
GH_project_URL     = https://github.com/$(shell git remote show origin | perl -ne 'if (/github/) {s%^.*github\.com:(.*)\.git.*$$%$$1/downloads%;print;exit;}')
GH_temp_file       = github

# Phony targets.
.PHONY: clean all vimball zip release version echo deploy_vimorg deploy_github
all: vimball README zip gzip
vimball: $(plugin_name).vba
zip: $(plugin_name).zip
gzip: $(plugin_name).gz
release: $(version_file) all
version: $(version_file)
deploy_vimorg: $(VO_cookie_jar)
deploy_github: $(GH_temp_file)
clean:
	@echo clean
	rm -f *.vba **/*.orig *.~* .VimballRecord *.zip *.gz $(version_file) $(VO_comment_file) $(PASSWDFILE) $(VO_cookie_jar) $(GH_temp_file)

# Undo version.
undo:
	@for i in **/*.orig; do mv -f "$$i" "$${i%.*}"; echo mv -f "$$i" "$${i%.*}"; done

# Real targets.
# Update version everywhere.
$(version_file): $(all_files)
	@echo Version: $(current_version); \
	perl -i.orig -pne 'if (/^"\sVersion:/) {s/(\d+\.\S+)/$(current_version)/}' $(ftplugins) $(autoload_script); \
	perl -i.orig -pne 'if (/^v\d+\.\S+$$/) {s/(v\d+\.\S+)/v$(current_version)/}' $(help_file); \
	echo Date: `date '+%G %B %d'`; \
	perl -i.orig -MPOSIX -pne 'if (/^"\sModified:/) {$$now_string = strftime "%F", localtime; s/(\d+-\d+-\d+)/$$now_string/}' $(ftplugins) $(autoload_script); \
	perl -i.orig -MPOSIX -pne 'if (/^\s+$(current_version)\s+\d+-\d+-\d+\s+\*/) {$$now_string = strftime "%F", localtime; s/(\d+-\d+-\d+)/$$now_string/}' $(help_file); \
	perl -i.orig -MPOSIX -pne 'if (/^\*$(plugin_name)\.txt\*.*/) {$$now_string = strftime "%G %B %d", localtime; s/(\d{4} [a-zA-Z]+ \d{2})/$$now_string/}' $(help_file); \
	echo $(current_version) > $(version_file)

# This just hard links the help file to README.
README: $(help_file)
	@echo README
	ln -f $(help_file) README

# Create VimBall archive.
$(plugin_name).vba: $(all_files)
	@echo Creating "$(plugin_name).vba"; \
	rm -f $(plugin_name).vba; \
	echo $(vim_exec) -N -u NONE -c 'ru! plugin/vimballPlugin.vim' -c ':call append("0", [ $(all_quoted) ])' -c '$$d' -c ":%MkVimball $(plugin_name)  ." -c':q!'; \
	$(vim_exec) -N -u NONE -c 'ru! plugin/vimballPlugin.vim' -c ':call append("0", [ $(all_quoted) ])' -c '$$d' -c ":%MkVimball $(plugin_name)  ." -c':q!'; \
	ln -f $(plugin_name).vba $(name_plus_version).vba

# Create zip archive.
$(plugin_name).zip: $(all_files)
	@echo Creating "$(plugin_name).zip"
	@rm -f *.zip
	@zip -r $(plugin_name).zip doc ftplugin autoload
	@-zip $(plugin_name).zip -d \*.sw\?
	@-zip $(plugin_name).zip -d \*.un\?
	@-zip $(plugin_name).zip -d \*.orig
	@-zip $(plugin_name).zip -d \*tags
	@ln -f $(plugin_name).zip $(name_plus_version).zip

# Gzip VimBall archive.
$(plugin_name).gz: $(plugin_name).vba
	@echo Creating "$(plugin_name).gz"
	gzip -fc $(plugin_name).vba > $(plugin_name).gz

# Update vimorg's version comments.
$(VO_comment_file): $(help_file)
	$(vim_exec) -c 'set tw=9999' -c 'read $(help_file)' -c 'write $(VO_comment_file)' -c '1,/\* Current Release.*\n\s*/d' -c '/^|-\+|$$/,$$d' -c '%s/^\s*//' -c 'normal! gggqG' -c "silent! %s/'/\\'/g"

# Upload new version to vim.org.
# Depends on cURL.
$(VO_cookie_jar): $(VO_comment_file) release
	@touch $(VO_cookie_jar)
	@echo logging in to vim.org...; read -sp "Enter username for vim.org: " userName; read -sp "Enter pasword for user '$(USER)': " pass; curl -b $(VO_cookie_jar) --cookie-jar $(VO_cookie_jar) --user-agent Mozilla/4.0 -e 'http://www.vim.org/login.php' -d "authenticate=true" -d "referrer=" -d "userName=$$userName" -d "password=$$pass" 'http://www.vim.org/login.php' > /dev/null
	@echo Uploading...; curl --referer '$(VO_scriptURL)' --cookie $(VO_cookie_jar) --user-agent Mozilla/4.0 -F 'MAX_FILE_SIZE=10485760' -F 'vim_version=$(VO_min_vim_version)' -F 'script_version=$(current_version)' -F 'script_file=@$(plugin_name).vba' -F 'version_comment=$(shell cat $(VO_comment_file))' -F 'script_id=$(VO_scriptID)' -F 'add_script=upload' 'http://www.vim.org/scripts/add_script_version.php?script_id=$(VO_scriptID)' >/dev/null
	@printf 'Opening $(VO_scriptURL)...'; sleep 2; $(open_url) '$(VO_scriptURL)';printf " done.\n"

# Upload new version to GitHub downloads page.
# Depends on https://github.com/github/upload
$(GH_temp_file): release
	@read -p "Upload '$(name_plus_version).zip' to GitHub: (y/N) " yn; if [ "$$yn" == "y" ];then printf "Uploading '$(name_plus_version).zip' to GitHub..."; github-upload $(name_plus_version).zip 2>/dev/null || printf ""; printf " done.\n" ; echo Opening '$(GH_project_URL)'; $(open_url) $(GH_project_URL); touch $(GH_temp_file); fi

# Test stuff here.
echo:
	@perl -ne 'if (/^\*$(plugin_name).txt\*\s+For Vim version/) {s/^.*For Vim version (\d+\.\S+)\s.*$$/\1/;print;exit}' $(help_file)
