# build and install perl scripts into ~/bin

DIR = $(HOME)/bin
FILESsh := $(wildcard *sh)
FILES := $(FILESsh:.sh=)

ENV:=$(shell which env)
PERL = $(ENV) perl

help:
	@echo make 'help|all'
	@echo FILES=$(FILES)
	@echo ENV=$(ENV)
	@echo PERL=$(PERL)
	@echo DIR=$(DIR)
	@#ls -la $(DIR)/ || echo $(DIR) does not exist yet >&2

all:	$(FILES)

%:	%.sh
	@$(PERL) -c $< || exit 0; \
	echo "#!$(PERL)" > $@; \
	echo 'use warnings;' >> $@; \
	cat $< | sed -e "s|@@script@@|$@|g" >> $@; \
	diff $@ $(DIR)/$@ && rm $@ || ( mv $@ $(DIR); chmod +x $(DIR)/$@; )

