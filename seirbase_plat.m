function dydt = seirbase_plat(t,y,pars)
% function dydt = seirbase_plat(t,y,pars)
% 
% Shield model

% Variables
S=y(1);
E=y(2);
I=y(3);
R=y(4);
D=y(5);
dydt=zeros(5,1);

Dday = pars.gamma*I*pars.frac_D;

% Model
dydt(1) = -pars.beta*S*I/(1+(Dday/pars.Dcrit)^(pars.awareness));
dydt(2) = pars.beta*S*I/(1+(Dday/pars.Dcrit)^(pars.awareness))-pars.mu*E;
dydt(3) = pars.mu*E-pars.gamma*I;
dydt(4) = pars.gamma*I*(1-pars.frac_D);
dydt(5) = pars.gamma*I*pars.frac_D;
