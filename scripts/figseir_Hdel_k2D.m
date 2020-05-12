clf;
% automatically create postscript whenever
% figure is drawn
tmpfilename = 'figseir_Hdel_k2D';
tmpfilebwname = sprintf('%s_noname_bw',tmpfilename);
tmpfilenoname = sprintf('%s_noname',tmpfilename);

tmpprintname = fixunderbar(tmpfilename);
% for use with xfig and pstex
tmpxfigfilename = sprintf('x%s',tmpfilename);

set(gcf,'DefaultLineMarkerSize',10);
% set(gcf,'DefaultLineMarkerEdgeColor','k');
% set(gcf,'DefaultLineMarkerFaceColor','w');
set(gcf,'DefaultAxesLineWidth',2);

set(gcf,'PaperPositionMode','auto');
tmppos= [0.2 0.2 0.7 0.7];
tmpa = axes('position',tmppos);
% set(gca,'Position',[680 132 630 688]);
set(gcf,'Position', [679 362 641 458]);


% main data goes here
pars.beta=0.5;
pars.mu=1/2;
pars.gamma=1/6;
pars.frac_D=0.01;
pars.R0=pars.beta/pars.gamma;
pars.Dcrit = 0.5*10^-5;
pars.awareness = 2;
pars.N = 10^7;
pars.gamma_H_range=1./[7:7:28];
y0 = [pars.N-1 1 0 0 0 0]/pars.N;

opts=odeset('RelTol',1e-8,'MaxStep',0.5);

for i=1:length(pars.gamma_H_range),
  pars.gamma_H=pars.gamma_H_range(i);
  [t,y]=ode45(@seirdelay_plat,[0:1:200],y0,opts,pars);
  S=y(:,1);
  E=y(:,2);
  I=y(:,3);
  R=y(:,4);
  H=y(:,5);
  D=y(:,6);
  Dday = pars.gamma_H*H;
  % Base
  Iday = pars.beta*S.*I./(1+(Dday/pars.Dcrit).^(pars.awareness));
  % Switch
  %Iday= pars.beta*S.*I.*(Dday<pars.Dcrit);

  tmph=plot(t,Dday*pars.N,'k-');
  set(tmph,'linewidth',3,'color',[0.0 0.0 0.0]+[0.15 0.15 0.15]*(5-i));
  hold on
end
tmph=plot(t,ones(size(t))*pars.Dcrit*pars.N*(pars.R0-1)^(1/pars.awareness),'k--');
set(tmph,'linewidth',3);
%tmph=semilogy(t,ones(size(t))*(1-1/pars.R0),'k--');
%set(tmph,'linewidth',3);
ylim([0 180]);
xlabel('Time, days','fontsize',20,'verticalalignment','top','interpreter','latex');
ylabel({'Deaths/day';'out of 10,000,000'},'fontsize',20,'verticalalignment','bottom','interpreter','latex');
%title('(D) Awareness, $k=2$','fontsize',20,'interpreter','latex');
set(gca,'fontsize',20);
%set(gca,'yaxislocation','right');
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
tmplh = legend('$T_H=7$ days','$T_H=14$ days','$T_H=21$ days','$T_H=28$ days');
set(tmplh,'interpreter','latex','fontsize',16,'location','NorthWest');
% remove box
% set(tmplh,'visible','off')
legend('boxoff');

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
