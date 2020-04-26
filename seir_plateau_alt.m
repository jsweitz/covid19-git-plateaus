function dydt = seir_plateau_alt(t,y,pars)
% function dydt = seir_plateau_alt(t,y,pars)
% 
% Shield model

% Variables
S=y(1);
E=y(2);
I=y(3);
H=y(4);
R=y(5);
D=y(6);
dydt=zeros(6,1);

Dday = pars.gamma_H*H*pars.frac_Hdead;

% Model
dydt(1) = -pars.beta*S*I/(1+Dday/pars.Dcrit)^(pars.awareness)*(rem(t*24,24)<8.0);
dydt(2) = pars.beta*S*I/(1+Dday/pars.Dcrit)^(pars.awareness)*(rem(t*24,24)<8.0)-pars.mu*E;
dydt(3) = pars.mu*E-pars.gamma*I;
dydt(4) = pars.gamma*I*pars.frac_hosp-pars.gamma_H*H;
dydt(5) = pars.gamma*I*(1-pars.frac_hosp)+pars.gamma_H*H*(1-pars.frac_Hdead);
dydt(6) = pars.gamma_H*H*pars.frac_Hdead;
