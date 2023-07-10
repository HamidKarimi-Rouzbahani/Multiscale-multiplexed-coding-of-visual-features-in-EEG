%% Plotting
clc;
clear all;
close all;
Taus=[6 22 50];
cl=cool;
indx_cols=round(linspace(1,size(cl,1),10));
cols=cl(indx_cols([2 6 9]),:);
t=0:1:150;
c=0;
for Tau=Taus
    c=c+1;
    x=exp(-t./Tau);
    plot(t,x,'linewidth',2,'color',cols(c,:))
    hold on;
end
xlabel('Time delay (ms)')
ylabel('Autocorrelation')
grid on
box off
legend({'6 ms','22 ms','50 ms'},'location','northeast')
set(gca,'TickDir','out','XMinorTick','on','Fontsize',16)

%% A random signal
rng(1)
data=randn(1,150);
ref_time=70;
% Taus=[1 3 5 7 9 11 13 19 25 37]*2;
Taus=[50 22 6];
cl=cool;
indx_cols=round(linspace(1,size(cl,1),10));
cols=cl(indx_cols([9 6 2]),:);
subplot(211)
plot(data,'linewidth',1.5,'color','k')
hold on;
c=0;
for i=Taus
    c=c+1;
    wind=floor(Taus(c)/2);
    bias=[[max(data)-min(data)]*[0.03]*c];
    s(c)=rectangle('Position',[ref_time-wind min(data)-bias 2*wind max(data)-min(data)+2*bias],'EdgeColor',cols(c,:),'LineWidth',2);
    hold on;
end
plot([ref_time ref_time],[-3 3],'color','k','linestyle','--')
ylim([-3 3])
xlabel('Time (ms)')
ylabel('Amplitude (a.u.)')
grid on
box off
% legend([s(1) s(2) s(3)],{'6 ms','22 ms','50 ms'});
set(gca,'TickDir','out','XMinorTick','on','Fontsize',16)


