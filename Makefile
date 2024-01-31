
OUT_DIR := build/
TOPTARGETS := clean all
FILES := $(wildcard git-days/*.tex sheet/*.tex)

define compile_latex_with_jobname_and_env
	cd $(4) && $(3) latexmk --shell-escape -synctex=1 -interaction=nonstopmode -file-line-error -lualatex -jobname=$(2) "$(1)"
endef

define build_latex_with_jobname_and_env
	$(eval DIR := $(dir $(1)))
	$(eval FILE := $(notdir $(1)))
	@echo -e "\e[1;32mCompiling \"$(FILE)\" in \"$(DIR)\" with jobname \"$(2)\"$<\e[0m"
	@$(call compile_latex_with_jobname_and_env,$(FILE),$(2),$(3),$(DIR))
	@echo -e "\e[1;32mSuccessfully compiled \"$(FILE)\" in \"$(DIR)\" with jobname \"$(2)\"$<\e[0m"
	@mkdir -p $(OUT_DIR)
	@cp $(DIR)/$(2).pdf $(OUT_DIR)/
endef

all:
	$(MAKE) compile

$(FILES:.tex=.tex.regular):
	$(eval FILE := $(patsubst %.tex.regular,%.tex,$@))
	$(call build_latex_with_jobname_and_env,$(FILE),$(notdir $(patsubst %.tex,%,$(FILE))),)

$(FILES:.tex=.tex.darkmode):
	$(eval FILE := $(patsubst %.tex.darkmode,%.tex,$@))
	$(call build_latex_with_jobname_and_env,$(FILE),$(notdir $(patsubst %.tex,%-darkmode,$(FILE))),DARK_MODE=1)

compile: $(FILES:.tex=.tex.regular) $(FILES:.tex=.tex.darkmode)
	@echo -e "\e[1;42mAll Done. PDFs can be found in $(OUT_DIR)\e[0m"

clean:
	@echo -e "\e[1;34mCleaning up leftover build files...$<\e[0m"
	@latexmk -C -f git-days
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/options.cfg' -exec rm -rf {} \;
	@find . -ignore_readdir_race -maxdepth 1 -not \( -path "*/.git/*" -prune \) -wholename '**/*.pdf' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.aux' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.fdb_latexmk' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.fls' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.len' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.listing' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.log' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.out' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.synctex.gz' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.toc' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.nav' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.snm' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.vrb' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.bbl' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.blg' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.idx' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.ilg' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.ind' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.pyg' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/*.bak[0-9]*' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/_minted-*' -exec rm -rf {} \;
	@find . -ignore_readdir_race -not \( -path "*/.git/*" -prune \) -wholename '**/svg-inkscape' -exec rm -rf {} \;
	@echo -e "\e[1;44mDone cleaning up leftover build files.$<\e[0m"

cleanBuild:
	@echo -e "\e[1;34mCleaning up build directory...$<\e[0m"
	@rm -rf $(OUT_DIR)
	@echo -e "\e[1;44mDone cleaning up build directory.$<\e[0m"

cleanAll: clean cleanBuild
