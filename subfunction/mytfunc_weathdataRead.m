% mytfunc_weathdataRead.m
%                                                                                by Masato Miyata 2011/10/15
%-----------------------------------------------------------------------------------------------------------
% 気象データを読み込んで温度，湿度，エンタルピーを求め，
% 日平均・昼平均・夜平均・時系列　の　4種類　の気象データを作成する．
%-----------------------------------------------------------------------------------------------------------
% 入力
%   filename：気象データファイル名
% 出力
%   OAdataAll：日平均の気象データ（365×温度・湿度・熱量）
%   OAdataDay：昼平均の気象データ（365×温度・湿度・熱量）
%   OAdataNgt：夜平均の気象データ（365×温度・湿度・熱量）
%   OAdataHourly：時刻別気象データ（8760×温度・湿度・熱量）
%-----------------------------------------------------------------------------------------------------------

function [OAdataAll,OAdataDay,OAdataNgt,OAdataHourly] = mytfunc_weathdataRead(filename)

% 気象データ読み込み（newHASPが吐き出したファイルを読み込む）
weathDataALL = csvread(filename,1,1);

% 時刻別データの整理
OAdataHourly(:,1) = weathDataALL(:,6);       % 外気温度の時刻別データ [℃]
OAdataHourly(:,2) = weathDataALL(:,7)./1000; % 外気湿度の時刻別データ [kg/kgDA]
for hh=1:8760
    % エンタルピーの時刻別データ [kJ/kgDA]
    OAdataHourly(hh,3) = mytfunc_enthalpy(OAdataHourly(hh,1),OAdataHourly(hh,2));
end


% 日平均化
for type=1:3
    
    OAdataD = zeros(365,3);
    for dd = 1:365
        if type == 1 % 日平均
            OAdataD(dd,1) = mean(OAdataHourly(24*(dd-1)+1:24*(dd-1)+24,1)); % 温度
            OAdataD(dd,2) = mean(OAdataHourly(24*(dd-1)+1:24*(dd-1)+24,2)); % 湿度
            OAdataD(dd,3) = mean(OAdataHourly(24*(dd-1)+1:24*(dd-1)+24,3)); % 熱量
        elseif type == 2 % 昼平均
            OAdataD(dd,1) = mean(OAdataHourly(24*(dd-1)+7:24*(dd-1)+18,1)); % 温度
            OAdataD(dd,2) = mean(OAdataHourly(24*(dd-1)+7:24*(dd-1)+18,2)); % 湿度
            OAdataD(dd,3) = mean(OAdataHourly(24*(dd-1)+7:24*(dd-1)+18,3)); % 熱量
        elseif type == 3 % 夜間平均
            OAdataD(dd,1) = mean(OAdataHourly([24*(dd-1)+1:24*(dd-1)+6,24*(dd-1)+19:24*(dd-1)+24],1)); % 温度
            OAdataD(dd,2) = mean(OAdataHourly([24*(dd-1)+1:24*(dd-1)+6,24*(dd-1)+19:24*(dd-1)+24],2)); % 湿度
            OAdataD(dd,3) = mean(OAdataHourly([24*(dd-1)+1:24*(dd-1)+6,24*(dd-1)+19:24*(dd-1)+24],3)); % 熱量
        end
    end
    
    if type == 1
        OAdataAll = OAdataD; % 日平均
    elseif type == 2
        OAdataDay = OAdataD; % 昼平均
    elseif type == 3
        OAdataNgt = OAdataD; % 夜平均
    end
end


end

