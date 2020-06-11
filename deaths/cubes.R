library(dplyr)

curr <- (curr
	%>% mutate(
		ld = log(deaths)
	)
)

plot(curr$day, curr$ld)

mod <- lm(ld~poly(day, 3, raw=TRUE), data=curr)
plot(mod)
plot(predict(mod))

cf <- coef(mod)
names(cf) <- NULL
print(cf)

findPeak <- function(cf){
	c <- cf[2]
	β <- cf[3]
a <- 3*cf[4]
D <- β^2-a*c
if (D<0) return(NA)
δ = sqrt(D)
return(-c(β+δ, β-δ)/a)
}

findPeak(cf)
