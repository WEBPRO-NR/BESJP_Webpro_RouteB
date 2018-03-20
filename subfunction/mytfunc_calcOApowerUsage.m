% mytscript_calcOApowerUsage.m
%                                             by Masato Miyata
%---------------------------------------------------------------
% OA機器の消費電力より「その他一次エネルギー消費量 MJ/m2」を計算する（室単位）。
%---------------------------------------------------------------
% Eothers_perArea : その他一次エネルギー消費量原単位 [MJ/m2]
% Eothers_MWh_hourly_perArea : その他消費電力原単位 [MWh/m2]
%---------------------------------------------------------------
function [Eothers_perArea,Eothers_MWh_hourly_perArea,Schedule_AC_hour, Schedule_LT_hour,Schedule_OA_hour] = ...
    mytfunc_calcOApowerUsage(BldgType,RoomType,perDB_RoomType,perDB_calendar,perDB_RoomOpeCondition)

% % テスト用
% clear
% clc
% BldgType = 'Office';
% RoomType = '事務室';
% mytscript_readDBfiles;     % CSVファイル読み込み

check = 0;

% 室用途検索
for iDB = 1:length(perDB_RoomType)
    
    if strcmp(BldgType,perDB_RoomType(iDB,2)) && strcmp(RoomType,perDB_RoomType(iDB,5))
        
        check = 1;
        RoomTypeKey  = perDB_RoomType(iDB,1);  % 室用途キー
        RoomTypeBLDG = perDB_RoomType(iDB,2);  % 建物用途名称
        RoomTypeNAME = perDB_RoomType(iDB,5);  % 室用途名称
        RoomTypeCLNDPTN = perDB_RoomType(iDB,7);  % カレンダー
        RoomTypeOA   = str2double(perDB_RoomType(iDB,11)); % OA機器発熱量 [W/m2]
        
    end
end

if check == 0
    error('建物用途・室用途が不正です')
end


% カレンダーパターン
RoomTypeCLND = zeros(365,length(RoomTypeNAME));
for iROOM = 1:length(RoomTypeCLNDPTN)
    if strcmp(RoomTypeCLNDPTN(iROOM),'A')
        RoomTypeCLND(:,iROOM) = str2double(perDB_calendar(2:end,3));
    elseif strcmp(RoomTypeCLNDPTN(iROOM),'B')
        RoomTypeCLND(:,iROOM) = str2double(perDB_calendar(2:end,4));
    elseif strcmp(RoomTypeCLNDPTN(iROOM),'C')
        RoomTypeCLND(:,iROOM) = str2double(perDB_calendar(2:end,5));
    elseif strcmp(RoomTypeCLNDPTN(iROOM),'D')
        RoomTypeCLND(:,iROOM) = str2double(perDB_calendar(2:end,6));
    elseif strcmp(RoomTypeCLNDPTN(iROOM),'E')
        RoomTypeCLND(:,iROOM) = str2double(perDB_calendar(2:end,7));
    elseif strcmp(RoomTypeCLNDPTN(iROOM),'F')
        RoomTypeCLND(:,iROOM) = str2double(perDB_calendar(2:end,8));
    else
        error('カレンダーパターンが不正です')
    end
end


% スケジュール検索
% perDB_RoomOpeCondition には空調室しかないにことに注意
RoomTypeOAtime = zeros(length(RoomTypeNAME),3);

RoomTypeOAtime_hour = zeros(length(RoomTypeNAME),3,24);
RoomTypeACtime_hour = zeros(length(RoomTypeNAME),3,24);
RoomTypeLTtime_hour = zeros(length(RoomTypeNAME),3,24);

for iROOM = 1:length(RoomTypeNAME)
    
    for iDB = 2:size(perDB_RoomOpeCondition,1)
        
        % 機器発熱密度比率の抽出
        if strcmp(RoomTypeKey(iROOM),perDB_RoomOpeCondition(iDB,1)) && ...
                strcmp(perDB_RoomOpeCondition(iDB,4),'4')  % 「4」は 機器発熱密度比率
            
            if strcmp(perDB_RoomOpeCondition(iDB,5),'1')
                RoomTypeOAtime(iROOM,1) = sum(str2double(perDB_RoomOpeCondition(iDB,8:31)));
                RoomTypeOAtime_hour(iROOM,1,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            elseif strcmp(perDB_RoomOpeCondition(iDB,5),'2')
                RoomTypeOAtime(iROOM,2) = sum(str2double(perDB_RoomOpeCondition(iDB,8:31)));
                RoomTypeOAtime_hour(iROOM,2,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            elseif strcmp(perDB_RoomOpeCondition(iDB,5),'3')
                RoomTypeOAtime(iROOM,3) = sum(str2double(perDB_RoomOpeCondition(iDB,8:31)));
                RoomTypeOAtime_hour(iROOM,3,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            end
            
        end
        
        % 空調時間の抽出
        if strcmp(RoomTypeKey(iROOM),perDB_RoomOpeCondition(iDB,1)) && ...
                strcmp(perDB_RoomOpeCondition(iDB,4),'1')  % 「1」は 室同時使用率
            
            if strcmp(perDB_RoomOpeCondition(iDB,5),'1')
                RoomTypeACtime_hour(iROOM,1,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            elseif strcmp(perDB_RoomOpeCondition(iDB,5),'2')
                RoomTypeACtime_hour(iROOM,2,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            elseif strcmp(perDB_RoomOpeCondition(iDB,5),'3')
                RoomTypeACtime_hour(iROOM,3,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            end
            
        end

        % 照明点灯時間の抽出
        if strcmp(RoomTypeKey(iROOM),perDB_RoomOpeCondition(iDB,1)) && ...
                strcmp(perDB_RoomOpeCondition(iDB,4),'2')  % 「2」は 照明発熱密度比率
            
            if strcmp(perDB_RoomOpeCondition(iDB,5),'1')
                RoomTypeLTtime_hour(iROOM,1,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            elseif strcmp(perDB_RoomOpeCondition(iDB,5),'2')
                RoomTypeLTtime_hour(iROOM,2,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            elseif strcmp(perDB_RoomOpeCondition(iDB,5),'3')
                RoomTypeLTtime_hour(iROOM,3,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            end
            
        end
        
    end
end

% 発熱量年積算値の計算
RoomOAComsumption = zeros(length(RoomTypeNAME),1);
RoomOA_MWh_hour   = zeros(8760,length(RoomTypeNAME));

Schedule_AC_hour = zeros(8760, length(RoomTypeNAME));  % 空調スケジュール
Schedule_LT_hour = zeros(8760, length(RoomTypeNAME));  % 照明発熱スケジュール
Schedule_OA_hour = zeros(8760, length(RoomTypeNAME));  % 機器発熱スケジュール

for iROOM = 1:length(RoomTypeNAME)
    if isnan(RoomTypeOA(iROOM)) == 0
        
        % チェック
        if RoomTypeOA(iROOM) > 0 && RoomTypeOAtime(iROOM,1) == 0 || ...
                RoomTypeOA(iROOM) == 0 && RoomTypeOAtime(iROOM,1) > 0
            RoomTypeBLDG(iROOM)
            RoomTypeNAME(iROOM)
            RoomTypeOA(iROOM)
            RoomTypeOAtime(iROOM,1)
            error('係数が一致しません')
        end
        
        for dd = 1:365
            
            % 発熱量 [W/m2] * 日運転時間 [h] →　[MJ/m2年]
            RoomOAComsumption(iROOM) = RoomOAComsumption(iROOM) + ...
                RoomTypeOA(iROOM).*RoomTypeOAtime(iROOM,RoomTypeCLND(dd,iROOM))./1000000.*3600;
            
            % コジェネ計算用 消費電力量を時刻別に算出。
            for hh = 1:24
                nn = 24*(dd-1)+hh;
                
                % 発熱量 [W/m2] * 日運転時間 [h] →　[MWh/m2年]
                RoomOA_MWh_hour(nn,iROOM) = RoomTypeOA(iROOM).*RoomTypeOAtime_hour(iROOM,RoomTypeCLND(dd,iROOM),hh)./1000000;
                
                if RoomTypeACtime_hour(iROOM,RoomTypeCLND(dd,iROOM),hh) > 0
                    Schedule_AC_hour(nn,iROOM) = 1;
                else
                    Schedule_AC_hour(nn,iROOM) = 0;
                end
                Schedule_LT_hour(nn,iROOM) = RoomTypeLTtime_hour(iROOM,RoomTypeCLND(dd,iROOM),hh);
                Schedule_OA_hour(nn,iROOM) = RoomTypeOAtime_hour(iROOM,RoomTypeCLND(dd,iROOM),hh);
                
            end
            
            
        end
    end
end

% 一次エネ換算 MJ/m2
Eothers_perArea = round(RoomOAComsumption .* 9760/3600);
Eothers_MWh_hourly_perArea = RoomOA_MWh_hour;

% 共同住宅については０にする。
if strcmp(RoomTypeBLDG,'ApartmentHouse')
    Eothers_perArea = 0;
end


