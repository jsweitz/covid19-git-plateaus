## This is plateaus

current: target
-include target.mk

# -include makestuff/perl.def

vim_session:
	bash -cl "vmt"

######################################################################

Ignore += deaths

Sources += $(wildcard *.tex)

covidplateaus.pdf: covidplateaus.tex covidplateaus.abs.tex covidplateaus.acknowledge.tex covidplateaus.appendix.tex covidplateaus.author.tex covidplateaus.biblio.tex covidplateaus.settings.tex covidplateaus.sign.tex covidplateaus.title.tex covidplateaus.body.tex

outputs/covidplateaus.pdf: covidplateaus.pdf
	$(copy)
	git add $@

## Temporarily suppress .sign.tex
outputs/preprint.pdf: covidplateaus.pdf
	$(copy)
	git add $@

######################################################################

## Diffs

## Does not work because of Weitz Balkanization ☹
## covidplateaus.ld.pdf: covidplateaus.tex
covidplateaus.ld.tex: covidplateaus.tex.4cdd8fc05.oldfile

######################################################################

### Makestuff

Sources += Makefile .gitignore

## Sources += content.mk
## include content.mk

Ignore += makestuff
msrepo = https://github.com/dushoff

## Want to chain and make makestuff if it doesn't exist
## Compress this ¶ to choose default makestuff route
Makefile: makestuff/Makefile
makestuff/Makefile:
	git clone $(msrepo)/makestuff
	ls makestuff/Makefile

-include makestuff/os.mk

## -include makestuff/makeR.mk
-include makestuff/texdeps.mk

-include makestuff/git.mk
-include makestuff/visual.mk
