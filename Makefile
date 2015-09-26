.PHONY: all clean install build
all: build test doc

PREFIX ?= /usr/local
NAME=9p-protocol

LWT ?= $(shell if ocamlfind query lwt >/dev/null 2>&1; then echo --enable-lwt; fi)
LWT_UNIX ?= $(shell if ocamlfind query lwt.unix >/dev/null 2>&1; then echo --enable-lwt-unix; fi)
ASYNC ?= $(shell if ocamlfind query async >/dev/null 2>&1; then echo --enable-async; fi)
JS ?= $(shell if ocamlfind query js_of_ocaml >/dev/null 2>&1; then echo --enable-js; fi)

setup.ml: _oasis
	oasis setup

setup.bin: setup.ml
	ocamlopt.opt -o $@ $< 2>/dev/null || ocamlopt -o $@ $< 2>/dev/null || ocamlc -o $@ $<
	rm -f setup.cmx setup.cmi setup.o setup.cmo

setup.data: setup.bin
	./setup.bin -configure $(LWT) $(ASYNC) $(LWT_UNIX) $(JS) $(TESTS) --prefix $(PREFIX)

build: setup.data setup.bin
	./setup.bin -build -classic-display

doc: setup.data setup.bin
	./setup.bin -doc

install: setup.bin
	./setup.bin -install

test: setup.bin build
	./setup.bin -test

reinstall: setup.bin
	ocamlfind remove $(NAME) || true
	./setup.bin -reinstall

clean:
	ocamlbuild -clean
	rm -f setup.data setup.log setup.bin

