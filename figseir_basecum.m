clf;
% automatically create postscript whenever
% figure is drawn
tmpfilename = 'figseir_basecum';
tmpfilebwname = sprintf('%s_noname_bw',tmpfilename);
tmpfilenoname = sprintf('%s_noname',tmpfilename);

tmpprintname = fixunderbar(tmpfilename);
% for use with xfig and pstex
tmpxfigfilename = sprintf('x%s',tmpfilename);

set(gcf,'DefaultLineMarkerSize',10);
% set(gcf,'DefaultLineMarkerEdgeColor','k');
% set(gcf,'DefaultLineMarkerFaceColor','w');
set(gcf,'DefaultAxesLineWidth',2);

tmppos= [0.2 0.2 0.7 0.7];
tmpa = axes('position',tmppos);
set(gcf,'PaperPositionMode','auto');

% main data goes here
pars.beta=0.5;
pars.mu=1/2;
pars.gamma=1/6;
pars.frac_D=0.01;
pars.R0=pars.beta/pars.gamma;
pars.Dcrit = 0.5*10^-5;
pars.awareness = 2;
pars.N = 10^7;
y0 = [pars.N-1 1 0 0 0]/pars.N;

opts=odeset('RelTol',1e-8,'MaxStep',0.5);

[t,y]=ode45(@seirbase_plat,[0:1:400],y0,opts,pars);
%[t,y]=ode45(@seirbase_switch,[0:1:400],y0,opts,pars);
S=y(:,1);
E=y(:,2);
I=y(:,3);
R=y(:,4);
D=y(:,5);
tmph=semilogy(t,S,'b-');
set(tmph,'linewidth',3,'color','b');
hold on
tmph=semilogy(t,I,'r--');
set(tmph,'linewidth',3,'color','r');
tmph=semilogy(t,R,'g:');
set(tmph,'linewidth',3,'color','g');
tmph=semilogy(t,D,'ko');
set(tmph,'linewidth',3,'color','k','markerfacecolor',[0.25 0.25 0.25]);
xlabel('Time, days','fontsize',20,'verticalalignment','top','interpreter','latex');
ylabel({'Individuals';'out of 10,000,000'},'fontsize',20,'verticalalignment','bottom','interpreter','latex');
set(gca,'fontsize',20);
title({'SEIR Model with Death-Awareness Based Social Distancing';'The Emergence of Peaks followed by Plateaus'}','fontsize',20,'interpreter','latex');
ylim([10^-7 1.1]);

% loglog(,, '');
%
%
% Some helpful plot commands
% tmph=plot(x,y,'ko');
% set(tmph,'markersize',10,'markerfacecolor,'k');
% tmph=plot(x,y,'k-');
% set(tmph,'linewidth',2);

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
