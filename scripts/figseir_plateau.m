clf;
% automatically create postscript whenever
% figure is drawn
tmpfilename = 'figseir_plateau';
tmpfilebwname = sprintf('%s_noname_bw',tmpfilename);
tmpfilenoname = sprintf('%s_noname',tmpfilename);

tmpprintname = fixunderbar(tmpfilename);
% for use with xfig and pstex
tmpxfigfilename = sprintf('x%s',tmpfilename);

tmppos= [0.2 0.2 0.6 0.6];
tmpa1 = axes('position',tmppos);

set(gcf,'DefaultLineMarkerSize',10);
% set(gcf,'DefaultLineMarkerEdgeColor','k');
% set(gcf,'DefaultLineMarkerFaceColor','w');
set(gcf,'DefaultAxesLineWidth',2);

set(gcf,'PaperPositionMode','auto');

% main data goes here
pars.beta=0.6;
pars.mu=1/2;
pars.gamma=1/6;
pars.gamma_H=1/20;
pars.frac_hosp=0.1;
pars.frac_Hdead=0.2;
pars.R0=pars.beta/pars.gamma;
pars.Dcrit = 10^-5;
pars.awareness = 4;
y0 = [0.99999 0.00001 0 0 0 0];

opts=odeset('RelTol',1e-8,'MaxStep',0.1);

[t,y]=ode45(@seir_plateau,[0 400],y0,opts,pars);
S=y(:,1);
E=y(:,2);
I=y(:,3);
H=y(:,4);
R=y(:,5);
D=y(:,6);
Dday = pars.gamma_H*H*pars.frac_Hdead;
Iday = pars.beta*S.*I./(1+Dday/pars.Dcrit).^(pars.awareness);
[tmpa tmph1 tmph2]=plotyy(t,Iday*10^7,t,Dday*10^7);
axes(tmpa(1));
set(gca,'ycolor',[0.2 0.2 0.8]);
set(tmph1,'linewidth',3,'color',[0.2 0.2 0.8]);
xlabel('Time, days','fontsize',20,'verticalalignment','top','interpreter','latex');
ylabel({'Infections/day';'out of 10,000,000'},'fontsize',20,'verticalalignment','bottom','interpreter','latex');
set(gca,'fontsize',20);
%set(gca,'ytick',[0:2000:10000]);
axes(tmpa(2));
set(gca,'ycolor','k');
set(tmph2,'linewidth',3,'color','k');
ylabel({'Deaths/day';'out of 10,000,000'},'fontsize',20,'verticalalignment','top','interpreter','latex');
%set(gca,'ytick',[0:20:100]);
set(gca,'fontsize',20);
% loglog(,, '');
%
%
% Some helpful plot commands
% tmph=plot(x,y,'ko');
% set(tmph,'markersize',10,'markerfacecolor,'k');
% tmph=plot(x,y,'k-');
% set(tmph,'linewidth',2);

set(gca,'fontsize',20);

% for use with layered plots
% set(gca,'box','off')

% adjust limits
% tmpv = axis;
% axis([]);
% ylim([]);
% xlim([]);

% change axis line width (default is 0.5)
% set(tmpa1,'linewidth',2)

% fix up tickmarks
% set(gca,'xtick',[1 100 10^4])
% set(gca,'ytick',[1 100 10^4])

% creation of postscript for papers
% psprint(tmpxfigfilename);

% the following will usually not be printed 
% in good copy for papers
% (except for legend without labels)

% legend
% tmplh = legend('stuff',...);
%tmplh = legend('New infections','New deaths');
%set(tmplh,'interpreter','latex','fontsize',16);
% remove box
% set(tmplh,'visible','off')
%legend('boxoff');

title({'SEIR Model with Death-Awareness Based Social Distancing';'The Emergence of Peaks followed by Plateaus'}','fontsize',20,'interpreter','latex');
% 'horizontalalignment','left');

% for writing over the top
% coordinates are normalized again to (0,1.0)
tmpa2 = axes('Position', tmppos);
set(tmpa2,'visible','off');
% first two points are normalized x, y positions
% text(,,'','Fontsize',14);

% automatic creation of postscript
% without name/date
psprintc(tmpfilenoname);
psprint(tmpfilebwname);

tmpt = pwd;
tmpnamememo = sprintf('[source=%s/%s.ps]',tmpt,tmpprintname);
text(1.05,.05,tmpnamememo,'Fontsize',6,'rotation',90);
datenamer(1.1,.05,90);
% datename(.5,.05);
% datename2(.5,.05); % 2 rows

% automatic creation of postscript
psprintc(tmpfilename);

% set following on if zooming of 
% plots is required
% may need to get legend up as well
%axes(tmpa1)
%axes(tmplh)
clear tmp*
