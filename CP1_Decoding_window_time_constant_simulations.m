% This script performs two simulations:
    % 1: simulation of a time series with indication of different length of
    % decoding window + plotting
    % 2: simulation of three decay functions with different levels of decay
    % constant (Tau) + plotting
    % Figures 1C and 1D

% INPUTS: NA
% OUTPUTS: NA (images)
%% Simulation 1 (Figure 1C)
clc;
clear all;
close all;
rng(1)
data=randn(1,150); % zero-mean unit variance random numbers of length 150
ref_time=70; % Time point in the centre of the three decoding windows
Taus=[50 22 6]; % Different lengths of decoding window
cl=cool; % colour codes
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
set(gca,'TickDir','out','XMinorTick','on','Fontsize',16)

%% Simulation 2 (Figure 1D)
figure
Taus=[6 22 50]; % Tau in exponential decay function
cl=cool; % colour coding
indx_cols=round(linspace(1,size(cl,1),10));
cols=cl(indx_cols([2 6 9]),:);
t=0:1:150; % time points
c=0;
for Tau=Taus
    c=c+1;
    x=exp(-t./Tau); % exponential decay function
    plot(t,x,'linewidth',2,'color',cols(c,:))
    hold on;
end
xlabel('Time delay (ms)')
ylabel('Autocorrelation')
grid on
box off
legend({'6 ms','22 ms','50 ms'},'location','northeast')
set(gca,'TickDir','out','XMinorTick','on','Fontsize',16)

