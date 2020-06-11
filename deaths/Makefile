## This is the deaths subdirectory of Weitz plateaus

current: target
-include target.mk

# -include makestuff/perl.def

######################################################################

Sources += $(wildcard *.R)

data.Rout: daily.csv data.R

cubes.Rout: cubes.R

######################################################################

## Daniel

national_deaths_metric.pdf: national_deaths_metric.Rout ;
national_deaths_metric.Rout: national_deaths_metric.R

### Makestuff

Sources += Makefile

## Sources += content.mk
## include content.mk

Ignore += makestuff
msrepo = https://github.com/dushoff

Makefile: makestuff/Makefile
makestuff/Makefile:
	ln -s ../makestuff .
	ls makestuff/Makefile

-include makestuff/os.mk

-include makestuff/wrapR.mk

-include makestuff/git.mk
-include makestuff/visual.mk
-include makestuff/projdir.mk
