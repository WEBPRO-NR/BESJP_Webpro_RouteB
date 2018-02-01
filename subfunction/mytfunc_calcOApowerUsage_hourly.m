% mytscript_calcOApowerUsage.m
%                                             by Masato Miyata
%---------------------------------------------------------------
% 省エネ基準：OA機器の消費電力量を計算する [MJ/m2]
%---------------------------------------------------------------
function y = mytfunc_calcOApowerUsage_hourly(BldgType,RoomType,perDB_RoomType,perDB_calendar)

% % テスト用
% clear
% clc
% BldgType = 'Office';
% RoomType = '事務室';

% データベースの読み込み
mytscript_readDBfiles;     % CSVファイル読み込み

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
RoomTypeOAtime = zeros(length(RoomTypeNAME),3,24);
for iROOM = 1:length(RoomTypeNAME)

    for iDB = 2:size(perDB_RoomOpeCondition,1)
        if strcmp(RoomTypeKey(iROOM),perDB_RoomOpeCondition(iDB,1)) && ...
                strcmp(perDB_RoomOpeCondition(iDB,4),'4')
            
            if strcmp(perDB_RoomOpeCondition(iDB,5),'1')
                RoomTypeOAtime(iROOM,1,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            elseif strcmp(perDB_RoomOpeCondition(iDB,5),'2')
                RoomTypeOAtime(iROOM,2,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            elseif strcmp(perDB_RoomOpeCondition(iDB,5),'3')
                RoomTypeOAtime(iROOM,3,:) = str2double(perDB_RoomOpeCondition(iDB,8:31));
            end
            
        end
    end
end

% 発熱量年積算値の計算
RoomOAComsumption = zeros(8760,length(RoomTypeNAME));

for iROOM = 1:length(RoomTypeNAME)
    if isnan(RoomTypeOA(iROOM)) == 0
        
        % チェック
        if RoomTypeOA(iROOM) > 0 && sum(RoomTypeOAtime(iROOM,1,:)) == 0 || ...
                RoomTypeOA(iROOM) == 0 && sum(RoomTypeOAtime(iROOM,1,:)) > 0
            RoomTypeBLDG(iROOM)
            RoomTypeNAME(iROOM)
            RoomTypeOA(iROOM)
            RoomTypeOAtime(iROOM,1)
            error('おかしい')
        end
        
        for dd = 1:365
            for hh = 1:24
                
                nn = 24*(dd-1)+hh;
                
                % 発熱量 [W/m2] * 日運転時間 [h] →　[MWh/m2年]
                RoomOAComsumption(nn,iROOM) = RoomTypeOA(iROOM).*RoomTypeOAtime(iROOM,RoomTypeCLND(dd,iROOM),hh)./1000000;
            end
        end
    end
end

y = RoomOAComsumption;

% 一次エネ換算 MJ/m2
% y = round(RoomOAComsumption .* 9760/3600);

% 共同住宅については０にする。
% if strcmp(RoomTypeBLDG,'ApartmentHouse')
%     y = 0;
% end


