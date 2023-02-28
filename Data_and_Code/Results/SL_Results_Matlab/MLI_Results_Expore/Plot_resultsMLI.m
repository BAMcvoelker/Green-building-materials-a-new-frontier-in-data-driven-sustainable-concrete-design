%clear; clc
%% Read Result Data and plot results
%% Vanilla isotropic GPR + Vanilla RF +PCA
VanillaPCA=[];
clear FileN
FileN = dir('Vanilla+PCA/*.csv');
for ii=1:length(FileN)
    clear tempdat
VanillaPCA=vertcat(VanillaPCA,readmatrix(['Vanilla+PCA/',FileN(ii).name]));
end
VanillaPCA(1:17:end,:)=[];VanillaPCA(:,[1,6,7,12,13,22:25])=[];

%% Tuned  GPR + RF 
clear FileN
path='Tuned/';
FileN = dir([path,'*.csv']);

Tuned=[];
for ii=1:length(FileN)
    clear tempdat
    tempdat=readmatrix([path,FileN(ii).name],'Delimiter',',');
       if size(tempdat,1) == 9                                  %kleiner Fix wegen angepassten Ergebniss dateien von Horacio
         tempdat(1,:)=[];
    Tuned=vertcat(Tuned,tempdat);
else 
    Tuned=vertcat(Tuned,tempdat);
end
end
Tuned(:,[5,6,11,12,21:24])=[];


% Random Performance (Calculated using hypergeometric distribution)
DSsz=VanillaPCA(1:8:end,13);
for ii=1:length(DSsz)
RP(ii,1)=RPperf(DSsz(ii),0.95,0.9);
end
% Create Variables with results for each Algorithm
GPRVanilla=[];GPRVanillaPCA=[];GPRtuned=[];
RFVanilla=[];RFVanillaPCA=[];RFTuned=[];
numDS=9;
Col=3;
GPRVanilla = ( [ ...
    VanillaPCA(1:8:numDS*8,Col),VanillaPCA(3:8:numDS*8,Col), ...
    VanillaPCA(5:8:numDS*8,Col),VanillaPCA(7:8:numDS*8,Col) ...
    ]);

GPRVanillaPCA = ( [ ...
    VanillaPCA(numDS*8+1:8:numDS*16,Col),VanillaPCA(numDS*8+3:8:numDS*16,Col), ...
    VanillaPCA(numDS*8+5:8:numDS*16,Col),VanillaPCA(numDS*8+7:8:numDS*16,Col) ...
    ]);

GPRtuned = ([ ...
    Tuned(1:8:numDS*8,Col),Tuned(3:8:numDS*8,Col), ...
    Tuned(5:8:numDS*8,Col),Tuned(7:8:numDS*8,Col) ...
    ]);

RFVanilla=( [ ...
    VanillaPCA(2:8:numDS*8,Col),VanillaPCA(4:8:numDS*8,Col), ...
    VanillaPCA(6:8:numDS*8,Col),VanillaPCA(8:8:numDS*8,Col) ...
    ]);

RFVanillaPCA=( [ ...
    VanillaPCA(numDS*8+2:8:numDS*16,Col),VanillaPCA(numDS*8+4:8:numDS*16,Col), ...
    VanillaPCA(numDS*8+6:8:numDS*16,Col),VanillaPCA(numDS*8+8:8:numDS*16,Col) ...
    ]);

RFTuned= ([ ...
    Tuned(2:8:numDS*8,Col),Tuned(4:8:numDS*8,Col), ...
    Tuned(6:8:numDS*8,Col),Tuned(8:8:numDS*8,Col) ...
    ]);
%% Plot results

clear series error
close all;clc;
figure('Position',[50, 50,  1080, 450],'InvertHardcopy','off',... 
    'Color',[1 1 1]);

series = [mean(GPRVanilla(:,:))',mean(GPRVanillaPCA(:,:))',mean(GPRtuned(:,:))',mean(RFVanilla(:,:))',mean(RFVanillaPCA(:,:))', mean(RFTuned(:,:))'...
];

error = [std(GPRVanilla(:,:))', std(GPRVanillaPCA(:,:))',std(GPRtuned(:,:))',std(RFVanilla(:,:))',std(RFVanillaPCA(:,:))',std(RFTuned(:,:))'...
];
% RP
x = 0.4;       
[data,errhigh,errlow] = errorbarplot(RP);
bar(x,data,0.1,'FaceColor',[1 0 0]);hold on
er = errorbar(x,data,errlow,errhigh);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  hold on

% adjust errorbarplot to group plots 
bar(series,'grouped'); hold on
% Find the number of groups and the number of bars in each group
[ngroups, nbars] = size(series);

% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar
% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, series(:,i), error(:,i), 'k', 'linestyle', 'none');
end

hold on
plot ([2.5,2.5],[0,60],':k'); % dashed line to seprate SO and MO

xticks([0.4,1:100])
xticklabels({'base line','4 init. samples - single objective','20 init. samples - single objective', ...
             '4 init. samples - multi objective','20 init. samples - multi objective'})
ylabel('requ. dev. cycle')
legend ('base line (random draw)','','GPR vanilla', 'GPR vanilla + PCA','GPR grid search', ...
        'RF vanilla','RF vanilla + PCA', 'RF grid search');
axis tight
ylim ([0 60])
hold off

saveas(gcf,['MLI_perf.png'])





