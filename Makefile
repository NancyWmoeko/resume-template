TPL ?= templates/moderncv.tpl
STYLE ?= classic
PHONE ?= 13*~****~**60
EMAIL ?= me@annhe.net
HOMEPAGE ?= www.annhe.net
GITHUB ?= annProg
COLOR ?= blue
ALL_STYLE = casual classic oldstyle banking fancy
ALL_COLOR = blue orange green red purple grey black
PHOTO ?= static/photo.png
YAML ?= sample.yml
BUILD = build
WORK ?= work
REPO ?= annprog/resume-template
TAG ?= latest
PWD := $(shell pwd)

ARCH := $(shell uname -s)

ifeq ($(ARCH), Linux)
	FONT := FandolSong
	FONTSET := fandol
else
	FONT := SimSun
	FONTSET := windows
endif

FONT ?= $(FONT)
FONTSET ?= $(FONTSET)

all: all-moderncv clean

moderncv:
	test -d $(BUILD) || mkdir -p $(BUILD)
	./converters/moderncv.py $(YAML) $(STYLE) > $(BUILD)/moderncv-$(STYLE).md
	enca -L zh_CN -x UTF-8 $(BUILD)/moderncv-$(STYLE).md
	pandoc $(BUILD)/moderncv-$(STYLE).md -o $(BUILD)/moderncv-$(STYLE)-$(COLOR).tex \
	--template=$(TPL) \
	-V photo=$(PHOTO) \
	-V mobile=$(PHONE) \
	-V email=$(EMAIL) \
	-V homepage=$(HOMEPAGE) \
	-V github=$(GITHUB) \
	-V color=$(COLOR) \
	-V font=$(FONT) \
	-V fontset=$(FONTSET) \
	-V style=$(STYLE)
	cp -f $(PHOTO) $(BUILD)/photo.png
	cd $(BUILD) && \
	xelatex moderncv-$(STYLE)-$(COLOR).tex
	
sub-moderncv-%:
	$(MAKE) STYLE=$* moderncv
	
all-moderncv: $(addprefix sub-moderncv-,$(ALL_STYLE))

docker:
	docker build -t $(REPO):$(TAG) .

run-docker:
	test -d $(BUILD) || mkdir -p $(BUILD)
	test -d $(WORK) || mkdir -p $(WORK)
	docker run -it --rm -v /usr/share/fonts:/usr/share/fonts/fonts -v $(PWD)/$(BUILD):/home/resume/$(BUILD) -v $(PWD)/$(WORK):/home/resume/$(WORK) $(REPO):$(TAG) /init.sh $(TPL) $(STYLE) $(PHONE) $(EMAIL) $(HOMEPAGE) $(GITHUB) $(COLOR) $(PHOTO) $(YAML) $(WORK)

enter-docker:
	docker run -it --rm -v $(PWD)/$(BUILD):/home/resume/$(BUILD) -v $(PWD)/$(WORK):/home/resume/$(WORK) -v /usr/share/fonts:/usr/share/fonts/fonts $(REPO):$(TAG)
	
clean:
	cd $(BUILD) && rm -f *.out *.aux *.log *.tex *.md
