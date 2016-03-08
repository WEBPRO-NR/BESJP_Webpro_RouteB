% mytfunc_getRoomCondition.m
%--------------------------------------------------------------------------
% 室使用条件データベースから時系列運転時間を作成する。
%--------------------------------------------------------------------------

function [opeMode_V,opeMode_L,opeMode_HW] = ...
    mytfunc_getRoomCondition(perDB_RoomType,perDB_RoomOpeCondition,perDB_calendar,buildingType,roomType)
 
% buildingType = 'Office';
% roomType = '機械室';


check = 0;  % 空調室、非空調室で処理を分ける

opeMode_L = zeros(365,24);
opeMode_V = zeros(365,24);
opeMode_HW = zeros(365,24);


% データベース（perDB_RoomType.csv）の検索
for iDB = 2:size(perDB_RoomType,1)
    if strcmp(perDB_RoomType(iDB,2),buildingType) &&...
            strcmp(perDB_RoomType(iDB,5),roomType)
        
        
        % カレンダー番号
        if strcmp(cell2mat(perDB_RoomType(iDB,7)),'A') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'1')
            roomClarendarNum = 1;
        elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'B') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'2')
            roomClarendarNum = 2;
        elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'C') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'3')
            roomClarendarNum = 3;
        elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'D') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'4')
            roomClarendarNum = 4;
        elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'E') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'5')
            roomClarendarNum = 5;
        elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'F') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'6')
            roomClarendarNum = 6;
        else
            perDB_RoomType(iDB,7)
            error('カレンダーナンバーが不正です')
        end
        
        % WSCパターン
        if strcmp(perDB_RoomType(iDB,8),'WSC1')
            roomWSC = 1;
            check = 1;
        elseif strcmp(perDB_RoomType(iDB,8),'WSC2')
            roomWSC = 2;
            check = 1;
        elseif isempty(perDB_RoomType{iDB,8})  % 非空調室
            roomWSC = 1;
            check = 2;
        else
            perDB_RoomType(iDB,8)
            error('WSCパターンが不正です。')
        end
        
        % 年間空調時間
        timeAC  = str2double(perDB_RoomType(iDB,22));
        % 年間換気時間
        timeV  = str2double(perDB_RoomType(iDB,26));
        % 年間照明時間
        timeL  = str2double(perDB_RoomType(iDB,23));
        % 年間給湯日数
        timeHW = str2double(perDB_RoomType(iDB,32));
        
        % 以下は空調室のみ
        if check == 1
            
            % 各室の空調開始・終了時刻
            roomTime_start_p1_1  = str2double(cell2mat(perDB_RoomType(iDB,14))); % パターン1_空調開始時刻(1)
            roomTime_stop_p1_1   = str2double(cell2mat(perDB_RoomType(iDB,15))); % パターン1_空調終了時刻(1)
            roomTime_start_p1_2  = str2double(cell2mat(perDB_RoomType(iDB,16))); % パターン1_空調開始時刻(2)
            roomTime_stop_p1_2   = str2double(cell2mat(perDB_RoomType(iDB,17))); % パターン1_空調終了時刻(2)
            roomTime_start_p2_1  = str2double(cell2mat(perDB_RoomType(iDB,18))); % パターン2_空調開始時刻(1)
            roomTime_stop_p2_1   = str2double(cell2mat(perDB_RoomType(iDB,19))); % パターン2_空調終了時刻(1)
            roomTime_start_p2_2  = str2double(cell2mat(perDB_RoomType(iDB,20))); % パターン2_空調開始時刻(2)
            roomTime_stop_p2_2   = str2double(cell2mat(perDB_RoomType(iDB,21))); % パターン2_空調終了時刻(2)
            
            % パターン１
            if isnan(roomTime_start_p1_2)
                roomTime_start_p1  = roomTime_start_p1_1;
                roomTime_stop_p1   = roomTime_stop_p1_1;
                roomDayMode = 1; % 使用時間帯（１：昼、２：夜、０：終日）
            else
                roomTime_start_p1  = roomTime_start_p1_2;  % 日をまたぐ場合
                roomTime_stop_p1   = roomTime_stop_p1_1;
                roomDayMode = 2; % 使用時間帯（１：昼、２：夜、０：終日）
            end
            
            if roomTime_start_p1 == 0 && roomTime_stop_p1 == 24
                roomDayMode = 0; % 使用時間帯（１：昼、２：夜、０：終日）
            end
            
            % パターン２
            if isnan(roomTime_start_p2_1)  % NaNであればパターン2は空調OFF
                roomTime_start_p2  = 0;
                roomTime_stop_p2   = 0;
            else
                if isnan(roomTime_start_p2_2)
                    roomTime_start_p2  = roomTime_start_p2_1;
                    roomTime_stop_p2   = roomTime_stop_p2_1;
                else
                    roomTime_start_p2  = roomTime_start_p2_2;  % 日をまたぐ場合
                    roomTime_stop_p2   = roomTime_stop_p2_1;
                end
            end
            
            % 外気導入量 [m3/h/m2]
            roomVoa_m3hm2 = str2double(cell2mat(perDB_RoomType(iDB,13)));
            
            % 機器発熱量 [W/m2]
            roomEnergyOAappUnit = str2double(cell2mat(perDB_RoomType(iDB,11)));
            
            % 照明発熱量 [W/m2]
            roomEnergyLight = str2double(cell2mat(perDB_RoomType(iDB,9)));
            
            % 人体発熱量 [人/m2 * W/人 = W/m2]
            switch cell2mat(perDB_RoomType(iDB,12))
                case '1'
                    roomEnergyPerson = str2double(cell2mat(perDB_RoomType(iDB,10)))*92;
                case '2'
                    roomEnergyPerson = str2double(cell2mat(perDB_RoomType(iDB,10)))*106;
                case '3'
                    roomEnergyPerson = str2double(cell2mat(perDB_RoomType(iDB,10)))*119;
                case '4'
                    roomEnergyPerson = str2double(cell2mat(perDB_RoomType(iDB,10)))*131;
                case '5'
                    roomEnergyPerson = str2double(cell2mat(perDB_RoomType(iDB,10)))*145;
                otherwise
                    perDB_RoomType(iDB,10)
                    error('作業強度指数が不正です。')
            end
            
            % 内部発熱量の時刻変動
            roomKey = perDB_RoomType(iDB,1);  % 検索キー
            
            for iDB2 = 2:size(perDB_RoomOpeCondition,1)
                
                % 室同時使用率
                if strcmp(perDB_RoomOpeCondition(iDB2,1),roomKey) &&...
                        strcmp(perDB_RoomOpeCondition(iDB2,4),'1')
                    if strcmp(perDB_RoomOpeCondition(iDB2,5),'1')
                        roomScheduleACratio(1,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'2')
                        roomScheduleACratio(2,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'3')
                        roomScheduleACratio(3,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    else
                        error('室使用パターンが不正です')
                    end
                end
                
                % 機器発熱密度比率
                if strcmp(perDB_RoomOpeCondition(iDB2,1),roomKey) &&...
                        strcmp(perDB_RoomOpeCondition(iDB2,4),'4')
                    if strcmp(perDB_RoomOpeCondition(iDB2,5),'1')
                        roomScheduleOAapp(1,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'2')
                        roomScheduleOAapp(2,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'3')
                        roomScheduleOAapp(3,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    else
                        error('室使用パターンが不正です')
                    end
                end
                
                % 照明発熱密度比率
                if strcmp(perDB_RoomOpeCondition(iDB2,1),roomKey) &&...
                        strcmp(perDB_RoomOpeCondition(iDB2,4),'2')
                    if strcmp(perDB_RoomOpeCondition(iDB2,5),'1')
                        roomScheduleLight(1,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'2')
                        roomScheduleLight(2,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'3')
                        roomScheduleLight(3,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    else
                        error('室使用パターンが不正です')
                    end
                end
                
                % 人体発熱密度
                if strcmp(perDB_RoomOpeCondition(iDB2,1),roomKey) &&...
                        strcmp(perDB_RoomOpeCondition(iDB2,4),'3')
                    if strcmp(perDB_RoomOpeCondition(iDB2,5),'1')
                        roomSchedulePerson(1,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'2')
                        roomSchedulePerson(2,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'3')
                        roomSchedulePerson(3,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    else
                        error('室使用パターンが不正です')
                    end
                end
                
            end
            
            % 各日の運転時間の割り当て
            for dd=1:365
                if strcmp(perDB_calendar{1+dd,roomClarendarNum+2},'1')  % 運転パターン１
                    roomTime_start(dd) = roomTime_start_p1;
                    roomTime_stop(dd)   = roomTime_stop_p1;
                    roomDailyOpePattern(dd) = 1;
                elseif strcmp(perDB_calendar{1+dd,roomClarendarNum+2},'2')  % 運転パターン２
                    roomTime_start(dd) = roomTime_start_p2;
                    roomTime_stop(dd)   = roomTime_stop_p2;
                    roomDailyOpePattern(dd) = 2;
                    
                elseif strcmp(perDB_calendar{1+dd,roomClarendarNum+2},'3')  % 運転パターン３
                    
                    if roomWSC == 1
                        roomTime_start(dd)  = 0;
                        roomTime_stop(dd)   = 0;
                    elseif roomWSC == 2
                        roomTime_start(dd)  = roomTime_start_p2;
                        roomTime_stop(dd)   = roomTime_stop_p2;
                    end
                    roomDailyOpePattern(dd) = 3;
                    
                end
            end
            
            % 時刻別の割り当て
            
            for dd = 1:365
                
                if strcmp(perDB_calendar{1+dd,roomClarendarNum+2},'1')  % 運転パターン１
                    
                    % 換気
                    if timeV == timeAC
                        opeMode_V(dd,:) = roomScheduleACratio(1,:);
                    elseif timeV == timeL
                        opeMode_V(dd,:) = roomScheduleLight(1,:);
                    elseif timeV == 0
                        opeMode_V(dd,:) = zeros(1,24);
                    else
                        error('換気運転時間が定まりません')
                    end
                    % 照明
                    opeMode_L(dd,:) = roomScheduleLight(1,:);
                    % 給湯
                    opeMode_HW(dd,:) = roomScheduleACratio(1,:);
                    
                elseif strcmp(perDB_calendar{1+dd,roomClarendarNum+2},'2')  % 運転パターン２
                    
                    % 換気
                    if timeV == timeAC
                        opeMode_V(dd,:) = roomScheduleACratio(2,:);
                    elseif timeV == timeL
                        opeMode_V(dd,:) = roomScheduleLight(2,:);
                    elseif timeV == 0
                        opeMode_V(dd,:) = zeros(1,24);
                    else
                        error('換気運転時間が定まりません')
                    end
                    % 照明
                    opeMode_L(dd,:) = roomScheduleLight(2,:);
                    % 給湯
                    opeMode_HW(dd,:) = roomScheduleACratio(2,:);
                    
                elseif strcmp(perDB_calendar{1+dd,roomClarendarNum+2},'3')  % 運転パターン３
                    
                    % 換気
                    if timeV == timeAC
                        opeMode_V(dd,:) = roomScheduleACratio(3,:);
                    elseif timeV == timeL
                        opeMode_V(dd,:) = roomScheduleLight(3,:);
                    elseif timeV == 0
                        opeMode_V(dd,:) = zeros(1,24);
                    else
                        error('換気運転時間が定まりません')
                    end
                    % 照明
                    opeMode_L(dd,:) = roomScheduleLight(3,:);
                    % 給湯
                    opeMode_HW(dd,:) = roomScheduleACratio(3,:);
                    
                end
                
            end
            
            % 調整（小数点以下は使わない）
            for dd = 1:365
                for hh = 1:24
                    if opeMode_V(dd,hh) > 0
                        opeMode_V(dd,hh) = 1;
                    end
                    if opeMode_L(dd,hh) > 0
                        opeMode_L(dd,hh) = 1;
                    end
                    if opeMode_HW(dd,hh) > 0
                        opeMode_HW(dd,hh) = 1;
                    end
                end
            end
            
            % 給湯は均等に割り振る
            for dd = 1:365
                if sum(opeMode_HW(dd,:)) ~= 0
                    tmp = 1/sum(opeMode_HW(dd,:));
                    for hh = 1:24
                        if opeMode_HW(dd,hh) ~= 0
                            opeMode_HW(dd,hh) = tmp;
                        end
                    end
                end
            end
            
        end
        
    end
end

if check == 2 % 非空調室の場合
    opeMode_V = ones(365,24).* (timeV / 8760);
    opeMode_L = ones(365,24).* (timeL / 8760);
end


if check == 0
    error('室用途 %s が見つかりません',strcat(buildingType,':',roomType))
end












