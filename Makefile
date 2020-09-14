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

######################################################################

### Makestuff

Sources += Makefile

## Sources += content.mk
## include content.mk

Ignore += makestuff
msrepo = https://github.com/dushoff

## Want to chain and make makestuff if it doesn't exist
## Compress this ¶ to choose default makestuff route
Makefile: makestuff/Makefile
makestuff/Makefile:
clonestuff:
	git clone $(msrepo)/makestuff
	ls makestuff/Makefile

-include makestuff/os.mk

## -include makestuff/makeR.mk
-include makestuff/texdeps.mk

-include makestuff/git.mk
-include makestuff/visual.mk
