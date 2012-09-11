% mytscript_calcOAusage.m
%                                             by Masato Miyata
%---------------------------------------------------------------
% 省エネ基準：OA機器の消費電力量を集計する
%---------------------------------------------------------------

clear
clc
tic
addpath('./subfunction/')

% データベースの読み込み
mytscript_readDBfiles;     % CSVファイル読み込み

% 室用途リスト
RoomTypeKey  = cell(size(perDB_RoomType,1)-1,1);
RoomTypeBLDG = cell(size(perDB_RoomType,1)-1,1);
RoomTypeNAME = cell(size(perDB_RoomType,1)-1,1);
RoomTypeCLND = cell(size(perDB_RoomType,1)-1,1);
RoomTypeOA   = zeros(size(perDB_RoomType,1)-1,1);
for iROOM = 2:size(perDB_RoomType,1)
    
    RoomTypeKey(iROOM-1,1)  = perDB_RoomType(iROOM,1);  % 室用途キー
    RoomTypeBLDG(iROOM-1,1) = perDB_RoomType(iROOM,2);  % 建物用途名称
    RoomTypeNAME(iROOM-1,1) = perDB_RoomType(iROOM,5);  % 室用途名称
    
    RoomTypeCLNDPTN(iROOM-1,1) = perDB_RoomType(iROOM,7);  % カレンダー
    RoomTypeOA(iROOM-1,1)   = str2double(perDB_RoomType(iROOM,11)); % OA機器発熱量 [W/m2]
    
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
for iROOM = 1:length(RoomTypeNAME)
    
    for iDB = 2:size(perDB_RoomOpeCondition,1)
        if strcmp(RoomTypeKey(iROOM),perDB_RoomOpeCondition(iDB,1)) && ...
                strcmp(perDB_RoomOpeCondition(iDB,4),'4')
            
            if strcmp(perDB_RoomOpeCondition(iDB,5),'1')
                RoomTypeOAtime(iROOM,1) = sum(str2double(perDB_RoomOpeCondition(iDB,8:31)));
            elseif strcmp(perDB_RoomOpeCondition(iDB,5),'2')
                RoomTypeOAtime(iROOM,2) = sum(str2double(perDB_RoomOpeCondition(iDB,8:31)));
            elseif strcmp(perDB_RoomOpeCondition(iDB,5),'3')
                RoomTypeOAtime(iROOM,3) = sum(str2double(perDB_RoomOpeCondition(iDB,8:31)));
            end
            
        end
    end
end

% 発熱量年積算値の計算
RoomOAComsumption = zeros(length(RoomTypeNAME),1);

for iROOM = 1:length(RoomTypeNAME)
    if isnan(RoomTypeOA(iROOM)) == 0
        
        % チェック
        if RoomTypeOA(iROOM) > 0 && RoomTypeOAtime(iROOM,1) == 0 || ...
                RoomTypeOA(iROOM) == 0 && RoomTypeOAtime(iROOM,1) > 0
            RoomTypeBLDG(iROOM)
            RoomTypeNAME(iROOM)
            RoomTypeOA(iROOM)
            RoomTypeOAtime(iROOM,1)
            error('おかしい')
        end
        
        for dd = 1:365
            
            % 発熱量 [W/m2] * 日運転時間 [h] →　[MJ/m2年]
            RoomOAComsumption(iROOM) = RoomOAComsumption(iROOM) + ...
                RoomTypeOA(iROOM).*RoomTypeOAtime(iROOM,RoomTypeCLND(dd,iROOM))./1000000.*3600;
            
        end
    end
end

rmpath('./subfunction/')
toc

