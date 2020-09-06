clf
% automatically create postscript whenever
% figure is drawn
tmpfilename = 'figseir_phase2';
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
%set(gcf,'Position',[   454   489   861   466]);
set(gcf,'Position', [679 362 641 458]);



% main data goes here
pars.beta=0.5;
pars.mu=1/2;
pars.gamma=1/6;
pars.frac_D=0.01;
pars.R0=pars.beta/pars.gamma;
pars.N = 10^7;
pars.Dcrit = 0.5*10^-5;
pars.Dtot_crit_range = [1000 2000 5000 200000000]/pars.N;
pars.awareness = 1;
pars.gamma_H=1/21;
pars.p_metric=0.1;
y0 = [pars.N-1 1 0 0 0 0]/pars.N;

opts=odeset('RelTol',1e-8,'MaxStep',0.5);

for i=1:length(pars.Dtot_crit_range),
  pars.Dtot_crit=pars.Dtot_crit_range(i);
  [t,y]=ode45(@seirdelay_long,[0:0.1:400],y0,opts,pars);
  S=y(:,1);
  E=y(:,2);
  I=y(:,3);
  R=y(:,4);
  H=y(:,5);
  D=y(:,6);
  Dday = pars.gamma_H*H;
  % Base
  Iday = pars.beta*S.*I./(1+(D/pars.Dtot_crit).^(pars.awareness));
  % Switch
  %Iday= pars.beta*S.*I.*(Dday<pars.Dcrit);
  
  % Near peak
  [Dmax tday]=max(Dday);
  t_left=find(Dday>pars.p_metric*Dmax,1);
  Dleft=Dday(t_left);
  t_right=tday+(tday-t_left);
  Dright=Dday(t_right);

  behavior = 1./(1+(Dday/pars.Dcrit).^pars.awareness+(D/pars.Dtot_crit).^(pars.awareness));
  tmph=plot(behavior(t_left:t_right),Dday(t_left:t_right)*pars.N,'k-');
  set(tmph,'linewidth',3,'color',[0.0 0.0 0.0]+[0.15 0.15 0.15]*(5-i));
  hold on
  xend(i).b=behavior(t_right)*pars.N;
  xend(i).d=Dday(t_right)*pars.N;
end

% Same thing but full series
for i=1:length(pars.Dtot_crit_range),
  pars.Dtot_crit=pars.Dtot_crit_range(i);
  [t,y]=ode45(@seirdelay_long,[0:0.1:400],y0,opts,pars);
  S=y(:,1);
  E=y(:,2);
  I=y(:,3);
  R=y(:,4);
  H=y(:,5);
  D=y(:,6);
  Dday = pars.gamma_H*H;
  % Base
  Iday = pars.beta*S.*I./(1+(D/pars.Dtot_crit).^(pars.awareness));
  % Switch
  %Iday= pars.beta*S.*I.*(Dday<pars.Dcrit);
  
  behavior = 1./(1+(Dday/pars.Dcrit).^pars.awareness+(D/pars.Dtot_crit).^(pars.awareness));
  tmph=plot(behavior,Dday*pars.N,'k-');
  set(tmph,'linewidth',3,'color',[0.0 0.0 0.0]+[0.15 0.15 0.15]*(5-i));
  hold on
end
%for i=1:length(pars.Dtot_crit_range),
%  tmph=plot(xend(i).b,xend(i).d,'ko');
%  set(tmph,'markersize',12,'markerfacecolor',[0.5 0.5 0.5]);
%end
%tmph=semilogy(t,ones(size(t))*pars.N*pars.Dcrit*(pars.R0-1)^(1/pars.awareness),'k--');
%set(tmph,'linewidth',3);
%ylim([1 150]);
%set(gca,'ytick',[0:25:125]);
%set(gca,'xtick',[0:50:400]);
xlabel('Relative behavior','fontsize',20,'verticalalignment','top','interpreter','latex');
ylabel({'Deaths/day';'given $N=10,000,000$'},'fontsize',20,'verticalalignment','bottom','interpreter','latex');
%title('(B) Awareness, $k=2$','fontsize',20,'interpreter','latex');
set(gca,'fontsize',20);
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
 xlim([0 1]);

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
tmplh = legend('$ND_{c}=1,000$ deaths' ,'$ND_{c}=2,000$ deaths','$ND_{c}=5,000$ deaths','No long-term awareness');
set(tmplh,'interpreter','latex','fontsize',16,'location','NorthEast');
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

% Create arrow
annotation(gcf,'arrow',[0.425897035881435 0.444617784711388],...
    [0.752275109170303 0.689956331877729],'LineWidth',3);

% Create arrow
annotation(gcf,'arrow',[0.648985959438378 0.606864274570983],...
    [0.35589519650655 0.390829694323144],'LineWidth',3);

% Create textbox
annotation(gcf,'textbox',...
    [0.215288611544462 0.811135371179039 0.0764430577223089 0.0665938864628821],...
    'String',{'(B)'},...
    'FontWeight','bold',...
    'FontSize',18,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

% Create arrow
annotation(gcf,'arrow',[0.625585023400937 0.583463338533542],...
    [0.271925764192139 0.307860262008733],...
    'Color',[0.450980392156863 0.450980392156863 0.450980392156863],...
    'LineWidth',3);

% Create arrow
annotation(gcf,'arrow',[0.617784711388456 0.58034321372855],...
    [0.255458515283842 0.288209606986899],'Color',[0.6 0.6 0.6],'LineWidth',3);

% Create arrow
annotation(gcf,'arrow',[0.628705148205929 0.589703588143527],...
    [0.291576419213973 0.32532751091703],...
    'Color',[0.149019607843137 0.149019607843137 0.149019607843137],...
    'LineWidth',3);

% Create arrow
annotation(gcf,'arrow',[0.29173166926677 0.291731669266771],...
    [0.485899563318778 0.417030567685589],'Color',[0.6 0.6 0.6],'LineWidth',3);

% Create arrow
annotation(gcf,'arrow',[0.355694227769111 0.360374414976599],...
    [0.474982532751091 0.408296943231441],...
    'Color',[0.450980392156863 0.450980392156863 0.450980392156863],...
    'LineWidth',3);

% Create arrow
annotation(gcf,'arrow',[0.411856474258971 0.422776911076443],...
    [0.472799126637554 0.412663755458515],...
    'Color',[0.149019607843137 0.149019607843137 0.149019607843137],...
    'LineWidth',3);


% Create textbox
annotation(gcf,'textbox',...
    [0.215288611544462 0.811135371179039 0.0764430577223089 0.0665938864628821],...
    'String',{'(B)'},...
    'FontWeight','bold',...
    'FontSize',18,...
    'EdgeColor',[1 1 1]);


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
