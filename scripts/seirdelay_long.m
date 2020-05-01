function dydt = seirdelay_long(t,y,pars)
% function dydt = seirdelay_long(t,y,pars)
% 
% Shield model

% Variables
S=y(1);
E=y(2);
I=y(3);
R=y(4);
H=y(5);
D=y(6);
dydt=zeros(6,1);

Dday = pars.gamma_H*H;

% Model
dydt(1) = -pars.beta*S*I/(1+(Dday/pars.Dcrit)^pars.awareness+(D/pars.Dtot_crit)^(pars.awareness));
dydt(2) = pars.beta*S*I/(1+(Dday/pars.Dcrit)^pars.awareness+(D/pars.Dtot_crit)^(pars.awareness))-pars.mu*E;
dydt(3) = pars.mu*E-pars.gamma*I;
dydt(4) = pars.gamma*I*(1-pars.frac_D);
dydt(5) = pars.gamma*I*pars.frac_D-pars.gamma_H*H;
dydt(6) = pars.gamma_H*H;
