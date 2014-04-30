BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/src
OUTPUTDIR=$(BASEDIR)/build

export PATH := /opt/nodejs/bin:$(PATH)

help:
	@echo 'Makefile for a GROT html5 game                                       '
	@echo '                                                                       '
	@echo 'Usage:                                                                 '
	@echo '   make html                        (re)generate the web site          '
	@echo '   make clean                       remove the generated files         '
	@echo '   make watch                       run coffee compiler in watch mode  '
	@echo '                                                                       '

html:
	mkdir -p $(OUTPUTDIR)
	cp $(INPUTDIR)/html/*.html $(OUTPUTDIR)
	mkdir -p $(OUTPUTDIR)/js
	cp $(INPUTDIR)/javascript/*.js $(OUTPUTDIR)/js
	/opt/nodejs/bin/coffee --compile --output $(OUTPUTDIR)/js $(INPUTDIR)/coffeescript

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

watch:
	/opt/nodejs/bin/coffee --compile --watch --output $(OUTPUTDIR)/js $(INPUTDIR)/coffeescript

.PHONY: html help clean watch
