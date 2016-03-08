function y = ECS_routeB_GroundModel_run(INPUTFILENAME,varargin)

% コンパイル時には消す
% clear
% clc
% addpath('./groundModel/')
% addpath('./subfunction/')
% 
% % 地盤への投入熱量が記されたファイル名
% INPUTFILENAME = 'calcREShourly_QforGound_GSHPmodel_1dai_20160204T225312.csv';
% % 熱交換杭の本数[本] [本]
% numPole = 106;
% % 1本あたりの流量 [m3/s/本]
% VwforGround = 0.00032;
% % 計算年数 [年]
% yearIta = 3;

tic

numPole     = str2double(varargin(1));
VwforGround = str2double(varargin(2));
yearIta     = str2double(varargin(3));


% 地盤への投入熱量 [W]
HeatforGround = xlsread(INPUTFILENAME);

Gdata = [];
TimeNum = 0;
for YY = 1:yearIta
    
    for hh = 1:8760
        if abs(HeatforGround(hh,1)) == 0
            Gdata = [Gdata; TimeNum, 0, 0];
        else
            Gdata = [Gdata; TimeNum, VwforGround, HeatforGround(hh,1)/numPole];
        end
        TimeNum = TimeNum + 3600;
    end
    
end

fid = fopen('well_cond_MATLAB','w+');
fprintf(fid,'%s\r\n','# well cond		');
fclose(fid);
dlmwrite('well_cond_MATLAB',Gdata,'delimiter','\t','-append')

movefile('well_cond_MATLAB','./groundModel/')


% 地盤モデル（GSHP.exe）実行
cd('./groundModel/')
y = system('go.bat');

% 結果の格納
% 外気温データの読み込み
climateALL = dlmread('Okayama','',1,0);

% 計算結果ファイルの読み込み
resultALL = dlmread('well0001_hist');

% 3年目の出口水温
Twdata = resultALL(8760*2+1:8760*3,3);

% 外気温と出口水温、流量、１本あたりの負荷[W]の関係
RESdata = [climateALL(:,4),Twdata(:,1),Gdata(1:8760,2:3)];

cd('../')


%% データ分析

% 動いていない箇所は NaN とする。
for i = 1:length(RESdata)
    if RESdata(i,3) == 0
        RESdata(i,1) = NaN;
        RESdata(i,2) = NaN;
    end
end

% 各日の平均
RESdata_Ave = zeros(365,4);
for dd = 1:365
    RESdata_Ave(dd,:) = nanmean(RESdata(24*(dd-1)+1:24*dd,:),1);
end

tmpCdata = [];
tmpHdata = [];
for i = 1:length(RESdata_Ave)
    if RESdata_Ave(i,4) < 0
        tmpHdata = [tmpHdata; RESdata_Ave(i,:)];
    elseif RESdata_Ave(i,4) > 0
        tmpCdata = [tmpCdata; RESdata_Ave(i,:)];
    end
end



paraC = polyfit(tmpCdata(:,1),tmpCdata(:,2),1);
paraH = polyfit(tmpHdata(:,1),tmpHdata(:,2),1);

xC = [0:0.5:40];
yC = polyval(paraC,xC);
xH = [-10:0.5:20];
yH = polyval(paraH,xH);


figure
subplot(2,1,1)
plot(tmpCdata(:,1),tmpCdata(:,2),'bx')
hold on
plot(xC,yC,'k-')
xlabel('外気温度[℃]')
ylabel('地盤からの還水温度[℃]')
legend('冷房時')
grid on
subplot(2,1,2)
plot(tmpHdata(:,1),tmpHdata(:,2),'rx')
hold on
plot(xH,yH,'k-')
xlabel('外気温度[℃]')
ylabel('地盤からの還水温度[℃]')
legend('暖房時')
grid on

y = [paraC;paraH];

save calcRES_paraGround.txt y -ascii

toc





