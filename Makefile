include Makefile.config

#---------------------------------------
# Directories
#---------------------------------------

PREFIX = $(INTERPROC_PREFIX)

# For the WEB version
OCAMLHTML_INSTALL = $(HOME)/pkg/ocamlhtml/$(ARCH)

#
LCFLAGS = \
-L$(GMP_PREFIX)/lib \
-L$(MPFR_PREFIX)/lib \
-L$(MLGMPIDL_PREFIX)/lib \
-L$(APRON_PREFIX)/lib \
-L$(CAML_PREFIX)/lib/ocaml \
-L$(CAMLIDL_PREFIX)/lib/ocaml \
-L$(FIXPOINT_PREFIX)/lib


OCAMLLDFLAGS = \
-g -noautolink unix.cma bigarray.cma camllib.cma fixpoint.cma gmp.cma apron.cma box.cma oct.cma polka.cma ppl.cma polkaGrid.cma -cc "g++" -ccopt "-L$(CAML_PREFIX)/lib/ocaml -L$(CAMLIDL_PREFIX)/lib/ocaml -L$(APRON_PREFIX)/lib -L$(GMP_PREFIX)/lib -L$(MPFR_PREFIX)/lib -L$(MLGMPIDL_PREFIX)/lib -L$(PPL_PREFIX)/lib" -cclib "-lpolkaGrid_caml -lap_pkgrid -lap_ppl_caml -lap_ppl -lppl -lgmpxx -lpolka_caml -lpolka -loct_caml -loctMPQ -lbox_caml -lbox -lapron_caml -lapron -lgmp_caml -lmpfr -lgmp -lunix -lbigarray -lcamlidl"

OCAMLOPTLDFLAGS = \
-g -noautolink unix.cmxa bigarray.cmxa camllib.cmxa fixpoint.cmxa gmp.cmxa apron.cmxa box.cmxa oct.cmxa polka.cmxa ppl.cmxa polkaGrid.cmxa \
-cc "g++" -ccopt "-L$(CAML_PREFIX)/lib/ocaml -L$(CAMLIDL_PREFIX)/lib/ocaml -L$(APRON_PREFIX)/lib -L$(GMP_PREFIX)/lib -L$(MPFR_PREFIX)/lib -L$(MLGMPIDL_PREFIX)/lib -L$(PPL_PREFIX)/lib" -cclib "-lpolkaGrid_caml -lap_pkgrid -lap_ppl_caml -lap_ppl -lppl -lgmpxx -lpolka_caml -lpolka -loct_caml -loctMPQ -lbox_caml -lbox -lapron_caml -lapron -lgmp_caml -lmpfr -lgmp -lunix -lbigarray -lcamlidl"

OCAMLOPTLDFLAGSf = \
-g -noautolink unix.cmxa bigarray.cmxa camllib.cmxa fixpoint.cmxa gmp.cmxa apron.cmxa box.cmxa oct.cmxa polka.cmxa ppl.cmxa polkaGrid.cmxa \
-cc "g++" -ccopt "-L$(CAML_PREFIX)/lib/ocaml -L$(CAMLIDL_PREFIX)/lib/ocaml -L$(APRON_PREFIX)/lib -L$(GMP_PREFIX)/lib -L$(MPFR_PREFIX)/lib -L$(MLGMPIDL_PREFIX)/lib -L$(PPL_PREFIX)/lib" -cclib "-lpolkaGrid_caml -lap_pkgrid -lap_ppl_caml -lap_ppl -lppl -lgmpxx -lpolka_caml -lpolka -loct_caml -loctD -lbox_caml -lboxD -lapron_caml -lapron -lgmp_caml -lmpfr -lgmp -lunix -lbigarray -lcamlidl"

OCAMLINC = \
-I $(OCAMLHTML_INSTALL)/lib \
-I $(CAMLLIB_PREFIX)/lib \
-I $(APRON_PREFIX)/lib \
-I $(MLGMPIDL_PREFIX)/lib \
-I $(CAML_PREFIX)/lib/ocaml \
-I $(CAMLIDL_PREFIX)/lib/ocaml


MLMODULES = spl_syn pSpl_syn spl_yacc spl_lex boolexpr equation syn2equation solving option frontend
MLSRC =  $(MLMODULES:%=%.ml) $(MLMODULES:%=%.mli)

INT = $(MLMODULES:%=%.cmi)
OBJ = $(MLMODULES:%=%.cmo)
OBJx = $(MLMODULES:%=%.cmx)


#---------------------------------------
# Rules
#---------------------------------------

# Global rules
all: interproc interproc.opt interprocf.opt

interproc: $(OBJ) interproc.cmo interprocrun
	$(OCAMLC) -g -o $@ -use-runtime ./interprocrun $(OCAMLFLAGS) $(OCAMLINC) \
	bigarray.cma unix.cma camllib.cma fixpoint.cma gmp.cma		\
	apron.cma polka.cma box.cma ppl.cma polkaGrid.cma fixpoint.cma $(OBJ) interproc.cmo

interprocrun:
	$(OCAMLC) -g -o $@ -make-runtime $(OCAMLINC) $(OCAMLLDFLAGS)

interproc.opt: $(OBJx) interproc.cmx
	$(OCAMLOPT) -o $@ -verbose $(OCAMLINC) $(OCAMLOPTLDFLAGS) \
	fixpoint.cmxa $(OBJx) interproc.cmx

interprocf.opt: $(OBJx) interproc.cmx
	$(OCAMLOPT) -o $@ -verbose $(OCAMLINC) $(OCAMLOPTLDFLAGSf) \
	fixpoint.cmxa $(OBJx) interproc.cmx

install:
	$(INSTALLd) $(PREFIX)/bin
	for i in interproc interprocrun interproc.opt interprocf.opt; do \
		$(INSTALL) $$i $(PREFIX)/bin; \
	done

distclean: clean
	for i in interproc interprocrun interproc.opt interprocf.opt; do \
		/bin/rm -f $(PREFIX)/bin/$$i; \
	done

interprocweb.cgi: $(OBJx) interprocweb.cmx 
	$(OCAMLOPT) -o $@ -verbose $(OCAMLINC) $(OCAMLOPTLDFLAGS) \
	fixpoint.cmxa html.cmxa $(OBJx) interprocweb.cmx 

mostlyclean: clean
	$(RM) -r *.pdf html Makefile.depend

clean:
	$(RM) *.[aoc] *.cm[ioxa] *.annot spl_lex.ml spl_yacc.ml spl_yacc.mli interproc interprocrun interproc.opt interprocf.opt interprocweb interprocweb.cgi *~ *.idx *.ilg *.ind *.log *.toc *.dvi *.out *.aux *.bbl *.blg *.makeimage *.html *.png *.ps ocamldoc.* *.output

dist: Makefile Makefile.config.model COPYING README $(MLSRC) interproc.ml interproc.mli interprocweb.ml interprocweb.mli manual.tex manual.bib interproc.tex mypanels.hlx examples manual.pdf 
	(cd ..; tar zcvf $(HOME)/interproc.tgz $(^:%=interproc/%))

#---------------------------------------
# TEX and HTML rules
#---------------------------------------

.PHONY: html interproc.dvi manual.dvi

manual.pdf: manual.dvi
	$(DVIPDF) manual.dvi

manual.dvi:
	$(LATEX) manual
	bibtex manual
	$(LATEX) manual
	$(LATEX) manual

interproc.pdf: interproc.dvi
	$(DVIPDF) interproc.dvi

interproc.dvi: $(MLINT) $(MLSRC)
	$(OCAMLDOC) $(OCAMLINC) \
	-latextitle 1,chapter -latextitle 2,section -latextitle 3,subsection -latextitle 4,subsubsection -latextitle 5,paragraph -latextitle 6,subparagraph -noheader -notrailer -latex -o ocamldoc.tex $(MLMODULES:%=%.mli) interproc.mli
	$(LATEX) interproc
	$(LATEX) interproc
	$(LATEX) interproc

html: $(MLINT) $(MLSRC)
	mkdir -p html
	$(OCAMLDOC) $(OCAMLINC) -html -d html -colorize-code $(MLMODULES:%=%.mli)

homepage: html interproc.pdf manual.pdf
	hyperlatex manual	
	cp -r html interproc.pdf manual.pdf $(HOME)/web/bjeannet-forge/interproc
	cp manual*.html $(HOME)/web/bjeannet-forge/interproc

#--------------------------------------------------------------
# IMPLICIT RULES AND DEPENDENCIES
#--------------------------------------------------------------

.SUFFIXES: .ml .mli .cmi .cmo .cmx

#-----------------------------------
# CAML
#-----------------------------------

%.ml: %.mll
	$(OCAMLLEX) $^

%.ml %.mli: %.mly
	$(OCAMLYACC) $^

%.cmi: %.mli
	$(OCAMLC) -g $(OCAMLFLAGS) $(OCAMLINC) -c $<

%.cmo: %.ml
	$(OCAMLC) -g $(OCAMLFLAGS) $(OCAMLINC) -c $<

%.cmx: %.ml
	$(OCAMLOPT) $(OCAMLOPTFLAGS) $(OCAMLINC) -c $<

Makefile.depend: spl_yacc.ml spl_yacc.mli spl_lex.ml
	$(OCAMLDEP) $(MLSRC) interproc.ml interproc.mli interprocweb.ml interprocweb.mli >Makefile.depend

-include Makefile.depend
