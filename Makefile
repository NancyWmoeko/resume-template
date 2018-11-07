TYPE ?= moderncv
PHONE ?= 13*~****~**60
EMAIL ?= me@annhe.net
HOMEPAGE ?= www.annhe.net
GITHUB ?= annProg
PHOTO ?= static/photo.png
YAML ?= sample.yml
BUILD = build
PREVIEW = preview
WORK ?= work
REPO ?= annprog/resume-template
TAG ?= latest
PWD := $(shell pwd)
ONLINECV ?=
SED_I = sed -i -r

ARCH := $(shell uname -s)

ifeq ($(ARCH), Linux)
	FONT ?= WenQuanYi Micro Hei
	QUOTE?=$(shell ./converters/quote.py $(YAML))
else
	FONT ?= SimSun
	QUOTE?=$(shell ./converters/quote.py $(YAML) |iconv -f gbk -t utf-8)
endif


# moderncv 相关变量
ifeq ($(TYPE), moderncv)
	TPL ?= templates/moderncv.tpl
	STYLE ?= classic
	COLOR ?= blue
	ALL_STYLE = casual classic oldstyle banking fancy
	ALL_COLOR = blue orange green red purple grey black
endif

# limecv 相关变量
ifeq ($(TYPE), limecv)
	TPL ?= templates/limecv.tpl
	STYLE = none
	COLOR = none
endif

# 如果以下值未设置，设置为默认值
STYLE ?= banking
COLOR ?= orange
TPL ?= templates/moderncv.tpl

all: all-moderncv limecv clean

pdf:
	test -d $(BUILD) || mkdir -p $(BUILD)
	./converters/converter.py "$(TYPE)" "$(YAML)" "$(STYLE)" > $(BUILD)/$(TYPE)-$(STYLE).md
	$(shell enca -L zh_CN -x UTF-8 $(BUILD)/$(TYPE)-$(STYLE).md)
	pandoc $(BUILD)/$(TYPE)-$(STYLE).md -o $(BUILD)/$(TYPE)-$(STYLE)-$(COLOR).tex \
	--template=$(TPL) \
	-V photo=$(PHOTO) \
    -V onlinecv="$(ONLINECV)" \
	-V mobile=$(PHONE) \
	-V email=$(EMAIL) \
	-V homepage=$(HOMEPAGE) \
	-V github=$(GITHUB) \
	-V color=$(COLOR) \
	-V font="$(FONT)" \
	-V quote="$(QUOTE)" \
	-V style=$(STYLE)
	cp -f $(PHOTO) $(BUILD)/photo.png
	# pandoc不能正确处理latex命令选项
	cd $(BUILD) && \
	$(SED_I) 's|\{\[\}|\[|g' $(TYPE)-$(STYLE)-$(COLOR).tex && \
	$(SED_I) 's|\{\]\}|\]|g' $(TYPE)-$(STYLE)-$(COLOR).tex && \
	xelatex $(TYPE)-$(STYLE)-$(COLOR).tex
	
moderncv: 
	$(MAKE) TYPE=moderncv pdf
	
# limecv需要编译2遍
limecv:
	$(MAKE) TYPE=limecv pdf
	$(MAKE) TYPE=limecv pdf
	
sub-moderncv-%:
	$(MAKE) STYLE=$* moderncv
	
all-moderncv: $(addprefix sub-moderncv-,$(ALL_STYLE))

sub-moderncv-color-%:
	$(MAKE) COLOR=$* moderncv
	
color-moderncv: $(addprefix sub-moderncv-color-,$(ALL_COLOR))

docker:
	docker build -t $(REPO):$(TAG) .

run-docker-common:
	test -d $(BUILD) || mkdir -p $(BUILD)
	test -d $(WORK) || mkdir -p $(WORK)
	docker run -it --rm -v /usr/share/fonts:/usr/share/fonts/fonts -v $(PWD)/$(BUILD):/home/resume/$(BUILD) -v $(PWD)/$(WORK):/home/resume/$(WORK) $(REPO):$(TAG) /init.sh $(TYPE) $(STYLE) $(PHONE) $(EMAIL) $(HOMEPAGE) $(GITHUB) $(COLOR) $(PHOTO) $(YAML) $(WORK) "$(FONT)" "$(QUOTE)" $(TPL) "$(ONLINECV)"

run-docker-limecv:
	$(MAKE) TYPE=limecv run-docker-common

run-docker-moderncv:
	$(MAKE) TYPE=moderncv run-docker-common

run-docker:
	$(MAKE) run-docker-limecv
	$(MAKE) run-docker-moderncv

enter-docker:
	docker run -it --rm -v $(PWD)/$(BUILD):/home/resume/$(BUILD) -v $(PWD)/$(WORK):/home/resume/$(WORK) -v /usr/share/fonts:/usr/share/fonts/fonts $(REPO):$(TAG)
	
preview:
	test -d $(PREVIEW) || mkdir -p $(PREVIEW)
	for pdf in `ls $(BUILD)/*.pdf`; \
	do \
		n=`echo $$pdf|cut -f2 -d'/' |cut -f1 -d'.'`; \
		pdftocairo -png $$pdf $(PREVIEW)/$$n; \
	done

preview-md:
	echo -e '# Preview\n' > $(PREVIEW)/README.md
	for id in `ls $(PREVIEW)/*.png`;do \
		name=`echo $$id |cut -f2 -d'/'`; \
		echo -e "### $$name \n![]($$name)\n\n" >> $(PREVIEW)/README.md; \
	done
	
clean:
	cd $(BUILD) && rm -f *.out *.aux *.log *.tex *.md
