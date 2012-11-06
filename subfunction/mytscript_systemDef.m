% mytfunc_systemDef.m
%                                                  2011/04/25 by Masato Miyata
%------------------------------------------------------------------------------
% 省エネ基準ルートB：XMLファイルの情報を基にデータベースから情報を抜き出す。
%------------------------------------------------------------------------------

% 気象データ
for iDB = 2:size(DB_climateArea,1)
    if strcmp(perDB_climateArea(iDB,2),climateAREA)
        climateDatabase = perDB_climateArea(iDB,6);
    end
end


%----------------------------------
% 空調室のパラメータ
for iROOM = 1:numOfRoooms
    
    % 建物用途と室用途リストを検索
    roomTime_start_p1_1 = [];
    for iDB = 2:size(perDB_RoomType,1)
        if strcmp(perDB_RoomType(iDB,2),buildingType{iROOM}) &&...
                strcmp(perDB_RoomType(iDB,5),roomType{iROOM})
            
            % 各室の空調開始・終了時刻
            roomTime_start_p1_1  = str2double(cell2mat(perDB_RoomType(iDB,14))); % パターン1_空調開始時刻(1)
            roomTime_stop_p1_1   = str2double(cell2mat(perDB_RoomType(iDB,15))); % パターン1_空調終了時刻(1)
            roomTime_start_p1_2  = str2double(cell2mat(perDB_RoomType(iDB,16))); % パターン1_空調開始時刻(2)
            roomTime_stop_p1_2   = str2double(cell2mat(perDB_RoomType(iDB,17))); % パターン1_空調終了時刻(2)
            roomTime_start_p2_1  = str2double(cell2mat(perDB_RoomType(iDB,18))); % パターン2_空調開始時刻(1)
            roomTime_stop_p2_1   = str2double(cell2mat(perDB_RoomType(iDB,19))); % パターン2_空調終了時刻(1)
            roomTime_start_p2_2  = str2double(cell2mat(perDB_RoomType(iDB,20))); % パターン2_空調開始時刻(2)
            roomTime_stop_p2_2   = str2double(cell2mat(perDB_RoomType(iDB,21))); % パターン2_空調終了時刻(2)
            
            % カレンダー番号
            if strcmp(cell2mat(perDB_RoomType(iDB,7)),'A') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'1')
                roomClarendarNum(iROOM) = 1;
            elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'B') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'2')
                roomClarendarNum(iROOM) = 2;
            elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'C') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'3')
                roomClarendarNum(iROOM) = 3;
            elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'D') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'4')
                roomClarendarNum(iROOM) = 4;
            elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'E') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'5')
                roomClarendarNum(iROOM) = 5;
            elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'F') || strcmp(cell2mat(perDB_RoomType(iDB,7)),'6')
                roomClarendarNum(iROOM) = 6;
            else
                perDB_RoomType(iDB,7)
                error('カレンダーナンバーが不正です')
            end
            
            % 外気導入量 [m3/h/m2]
            roomVoa_m3hm2(iROOM) = str2double(cell2mat(perDB_RoomType(iDB,13)));
            
            % 機器発熱量 [W/m2]
            roomEnergyOAappUnit(iROOM) = str2double(cell2mat(perDB_RoomType(iDB,11)));
            
            % 照明
            roomEnergyLight(iROOM) = str2double(cell2mat(perDB_RoomType(iDB,9)));
            % 人体 [人/m2 * W/人 = W/m2]
            switch cell2mat(perDB_RoomType(iDB,12))
                case '1'
                    roomEnergyPerson(iROOM) = str2double(cell2mat(perDB_RoomType(iDB,10)))*92;
                case '2'
                    roomEnergyPerson(iROOM) = str2double(cell2mat(perDB_RoomType(iDB,10)))*106;
                case '3'
                    roomEnergyPerson(iROOM) = str2double(cell2mat(perDB_RoomType(iDB,10)))*119;
                case '4'
                    roomEnergyPerson(iROOM) = str2double(cell2mat(perDB_RoomType(iDB,10)))*131;
                case '5'
                    roomEnergyPerson(iROOM) = str2double(cell2mat(perDB_RoomType(iDB,10)))*145;
                otherwise
                    iROOM
                    perDB_RoomType(iDB,10)
                    error('作業強度指数が不正です。')
            end
            
            % WSCパターン
            if strcmp(perDB_RoomType(iDB,8),'WSC1')
                roomWSC(iROOM) = 1;
            elseif strcmp(perDB_RoomType(iDB,8),'WSC2')
                roomWSC(iROOM) = 2;
            else
                iROOM
                perDB_RoomType(iDB,8)
                error('WSCパターンが不正です。')
            end
            
            % 検索キー
            roomKey{iROOM} = perDB_RoomType(iDB,1);
            
            % 内部発熱量の時刻変動
            for iDB2 = 2:size(perDB_RoomOpeCondition,1)
                
                % 機器発熱密度比率
                if strcmp(perDB_RoomOpeCondition(iDB2,1),roomKey{iROOM}) &&...
                        strcmp(perDB_RoomOpeCondition(iDB2,4),'4')
                    if strcmp(perDB_RoomOpeCondition(iDB2,5),'1')
                        roomScheduleOAapp(iROOM,1,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'2')
                        roomScheduleOAapp(iROOM,2,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'3')
                        roomScheduleOAapp(iROOM,3,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    else
                        error('室使用パターンが不正です')
                    end
                end
                
                % 照明発熱密度比率
                if strcmp(perDB_RoomOpeCondition(iDB2,1),roomKey{iROOM}) &&...
                        strcmp(perDB_RoomOpeCondition(iDB2,4),'2')
                    if strcmp(perDB_RoomOpeCondition(iDB2,5),'1')
                        roomScheduleLight(iROOM,1,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'2')
                        roomScheduleLight(iROOM,2,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'3')
                        roomScheduleLight(iROOM,3,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    else
                        error('室使用パターンが不正です')
                    end
                end
                
                % 人体発熱密度
                if strcmp(perDB_RoomOpeCondition(iDB2,1),roomKey{iROOM}) &&...
                        strcmp(perDB_RoomOpeCondition(iDB2,4),'3')
                    if strcmp(perDB_RoomOpeCondition(iDB2,5),'1')
                        roomSchedulePerson(iROOM,1,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'2')
                        roomSchedulePerson(iROOM,2,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    elseif strcmp(perDB_RoomOpeCondition(iDB2,5),'3')
                        roomSchedulePerson(iROOM,3,:) = str2double(perDB_RoomOpeCondition(iDB2,8:31));
                    else
                        error('室使用パターンが不正です')
                    end
                end
            end
        end
    end
    if isempty(roomTime_start_p1_1)
        buildingType{iROOM}
        roomType{iROOM}
        error('室用途が見つかりません')
    end
    
    % パターン１
    if isnan(roomTime_start_p1_2)
        roomTime_start_p1  = roomTime_start_p1_1;
        roomTime_stop_p1   = roomTime_stop_p1_1;
        roomDayMode(iROOM) = 1; % 使用時間帯（１：昼、２：夜、０：終日）
    else
        roomTime_start_p1  = roomTime_start_p1_2;  % 日をまたぐ場合
        roomTime_stop_p1   = roomTime_stop_p1_1;
        roomDayMode(iROOM) = 2; % 使用時間帯（１：昼、２：夜、０：終日）
    end
    
    if roomTime_start_p1 == 0 && roomTime_stop_p1 == 24
        roomDayMode(iROOM) = 0; % 使用時間帯（１：昼、２：夜、０：終日）
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
    
    % 各日の運転時間の割り当て
    for dd=1:365
        if strcmp(perDB_calendar{1+dd,roomClarendarNum(iROOM)+2},'1')  % 運転パターン１
            roomTime_start(dd,iROOM) = roomTime_start_p1;
            roomTime_stop(dd,iROOM)   = roomTime_stop_p1;
            roomDailyOpePattern(dd,iROOM) = 1;
        elseif strcmp(perDB_calendar{1+dd,roomClarendarNum(iROOM)+2},'2')  % 運転パターン２
            roomTime_start(dd,iROOM) = roomTime_start_p2;
            roomTime_stop(dd,iROOM)   = roomTime_stop_p2;
            roomDailyOpePattern(dd,iROOM) = 2;
        elseif strcmp(perDB_calendar{1+dd,roomClarendarNum(iROOM)+2},'3')  % 運転パターン３
            
            if roomWSC(iROOM) == 1
                roomTime_start(dd,iROOM)  = 0;
                roomTime_stop(dd,iROOM)   = 0;
            elseif roomWSC(iROOM) == 2
                roomTime_start(dd,iROOM)  = roomTime_start_p2;
                roomTime_stop(dd,iROOM)   = roomTime_stop_p2;
            end
            roomDailyOpePattern(dd,iROOM) = 3;
            
        end
    end
    
    % 外気取り入れ量 [m3/h] → [kg/s]
    roomVoa(iROOM) = roomVoa_m3hm2(iROOM).*1.293./3600.*roomArea(iROOM);
    
end

% 空調面積
roomAreaTotal = sum(roomArea);

%----------------------------------
% 空調機のパラメータ
ahuType    = cell(numOfAHUSET,1);
ahuTypeNum = zeros(numOfAHUSET,1);
ahuQcmax   = zeros(numOfAHUSET,1);
ahuQhmax   = zeros(numOfAHUSET,1);
ahuVsa     = zeros(numOfAHUSET,1);
ahuaexE    = zeros(numOfAHUSET,1);
ahuaexV    = zeros(numOfAHUSET,1);

for iAHU = 1:numOfAHUSET
    
    for iAHUele = 1:numOfAHUele(iAHU)
        
        % 空調機タイプが「空調機」のときahuTypeNumを１とする。
        if strcmp(ahueleType{iAHU,iAHUele},'AHU')
            ahuTypeNum(iAHU) = 1;
            ahuType{iAHU}    = '空調機';
        end
        if ahuTypeNum(iAHU) == 0
            ahuType{iAHU}    = '空調機以外';
        end
         
        % ファン消費電力 [kW]
        ahuEfan(iAHU,iAHUele) = ahueleEfsa(iAHU,iAHUele) + ahueleEfra(iAHU,iAHUele) + ...
            ahueleEfoa(iAHU,iAHUele) + ahueleEfex(iAHU,iAHUele);
        
        % 冷房能力、暖房能力、給気風量を足す
        ahuQcmax(iAHU) = ahuQcmax(iAHU) + ahueleQcmax(iAHU,iAHUele);
        ahuQhmax(iAHU) = ahuQhmax(iAHU) + ahueleQhmax(iAHU,iAHUele);
        ahuVsa(iAHU)   = ahuVsa(iAHU)   + ahueleVsa(iAHU,iAHUele);
        
        % 風量制御方式の効果率
        if isempty(ahueleFlowControl{iAHU,iAHUele}) == 0 && ...
                strcmp(ahueleFlowControl(iAHU,iAHUele),'VAV_INV')
            
            % 風量制御方式（出力用）
            ahuFlowControl{iAHU,iAHUele} = '回転数制御';
            % 風量制御方式（0: 定風量、1: 変風量）
            ahuFanVAV(iAHU,iAHUele) = 1;
            
            % エネルギー消費特性 ahuFanVAVfunc
            check = 0;
            for iDB = 2:size(perDB_flowControl,1)
                if strcmp(perDB_flowControl(iDB,2),ahueleFlowControl(iAHU,iAHUele))
                    
                    a4 = str2double(perDB_flowControl(iDB,4));
                    a3 = str2double(perDB_flowControl(iDB,5));
                    a2 = str2double(perDB_flowControl(iDB,6));
                    a1 = str2double(perDB_flowControl(iDB,7));
                    a0 = str2double(perDB_flowControl(iDB,8));
                    
                    ahuFanVAVfunc(iAHU,iAHUele,:) = ...
                        a4 .* aveL.^4 + a3 .* aveL.^3 + a2 .* aveL.^2 + a1 .* aveL + a0;
                    check = 1;
                end
            end
            
            % 最小開度
            if ahueleMinDamperOpening(iAHU,iAHUele) >= 0 && ahueleMinDamperOpening(iAHU,iAHUele) < 1
                ahuFanVAVmin(iAHU,iAHUele) = ahueleMinDamperOpening(iAHU,iAHUele);  % VAV最小風量比 [-]
            elseif ahueleMinDamperOpening(iAHU,iAHUele) == 1
                % 最小開度が1の時はVAVとはみなさない。
                ahuFanVAVfunc(iAHU,:) = ones(1,length(aveL));
                ahuFanVAVmin(iAHU)    = 1;
            else
                error('VAV最小開度の設定が不正です')
            end
            
            if check == 0
                error('VAVのエネルギー消費特性が見つかりません')
            end
            
        else
            
            % 風量制御方式（出力用）
            ahuFlowControl{iAHU,iAHUele}   = '定風量';
            % 風量制御方式（0: 定風量、1: 変風量）
            ahuFanVAV(iAHU,iAHUele)        = 0;
            % エネルギー消費特性
            ahuFanVAVfunc(iAHU,iAHUele,:)  = ones(1,length(aveL));
            % 最小開度
            ahuFanVAVmin(iAHU,iAHUele)     = 1;
            
        end
        
        
        % 外気カット
        if isempty(ahueleOACutCtrl{iAHU,iAHUele}) == 0
            switch ahueleOACutCtrl{iAHU,iAHUele}
                case 'False'
                    ahueleOAcut(iAHU,iAHUele) = 0;
                case 'True'
                    ahueleOAcut(iAHU,iAHUele) = 1;
                otherwise
                    error('XMLファイルが不正です')
            end
        else
            ahueleOAcut(iAHU,iAHUele) = 0;
        end
        
        
        % 外気冷房
        if isempty(ahueleFreeCoolingCtrl{iAHU,iAHUele}) == 0
            switch ahueleFreeCoolingCtrl{iAHU,iAHUele}
                case 'False'
                    ahueleOAcool(iAHU,iAHUele) = 0;
                case 'True'
                    ahueleOAcool(iAHU,iAHUele) = 1;
                otherwise
                    error('XMLファイルが不正です')
            end
        else
            ahueleOAcool(iAHU,iAHUele) = 0;
        end
        
        % 全熱交換器（有無、効率、バイパス有無）
        if isempty(ahueleHeatExchangeCtrl{iAHU,iAHUele}) == 0
            switch ahueleHeatExchangeCtrl{iAHU,iAHUele}
                case {'False','Null'}
                    ahueleaex(iAHU,iAHUele) = 0;
                    ahueleaexeff(iAHU,iAHUele) = 0;
                    ahuelebypass(iAHU,iAHUele) = 0;
                case 'True'
                    ahueleaex(iAHU,iAHUele) = 1;
                    
                    if ahueleHeatExchangeEff(iAHU,iAHUele) >= 0 && ahueleHeatExchangeEff(iAHU,iAHUele) <= 1
                        ahueleaexeff(iAHU,iAHUele) = ahueleHeatExchangeEff(iAHU,iAHUele);
                    else
                        error('全熱交換効率の設定が不正です。')
                    end
                    
                    switch ahueleHeatExchangeBypass{iAHU,iAHUele}
                        case 'False'
                            ahuelebypass(iAHU,iAHUele) = 0;
                        case 'True'
                            ahuelebypass(iAHU,iAHUele) = 1;
                        otherwise
                            error('XMLファイルが不正です')
                    end
                otherwise
                    error('XMLファイルが不正です')
            end
        else
            ahueleaex(iAHU,iAHUele) = 0;
            ahueleaexeff(iAHU,iAHUele) = 0;
            ahuelebypass(iAHU,iAHUele) = 0;
        end
        
        % 全熱交換器（動力、風量）
        ahuaexE(iAHU)   = ...
            ahuaexE(iAHU) + ahueleHeatExchangePower(iAHU,iAHUele);  % 全熱交換機の動力
        ahuaexV(iAHU)   = ...
            ahuaexV(iAHU) + ahueleHeatExchangeVolume(iAHU,iAHUele); % 全熱交換機の風量
        
        
    end
    
    
    % 空調機群として制御が有効であるかどうか(1つでもtrueであればあるとみなす)
    
    % 外気カット
    if sum(ahueleOAcut(iAHU,:)) > 0
        ahuOAcut(iAHU) = 1;
        ahuOACutCtrl{iAHU} = '有';
    else
        ahuOAcut(iAHU) = 0;
        ahuOACutCtrl{iAHU} = '無';
    end
    
    % 外気冷房
    if sum(ahueleOAcool(iAHU,:)) > 0
        ahuOAcool(iAHU) = 1;
        ahuFreeCoolingCtrl{iAHU} = '有';
    else
        ahuOAcool(iAHU) = 0;
        ahuFreeCoolingCtrl{iAHU} = '無';
    end
    
    % 全熱交換器
    if sum(ahueleaex(iAHU,:)) > 0
        ahuaex(iAHU) = 1;
        ahuHeatExchangeCtrl{iAHU} = '有';
        
        % 全熱交換効率（最低のものを採用する）
        ahuaexeff(iAHU) = 0;
        for iAHUele = 1:numOfAHUele(iAHU)
            if ahueleaexeff(iAHU,iAHUele) ~= 0
                if ahuaexeff(iAHU) == 0
                    ahuaexeff(iAHU) = ahueleaexeff(iAHU,iAHUele);
                elseif ahueleaexeff(iAHU,iAHUele) < ahuaexeff(iAHU)
                    ahuaexeff(iAHU) = ahueleaexeff(iAHU,iAHUele);
                end
            end
        end
        
        if sum(ahuelebypass(iAHU,:)) > 0
            AEXbypass(iAHU) = 1;
        else
            AEXbypass(iAHU) = 0;
        end
    else
        ahuaex(iAHU) = 0;
        ahuHeatExchangeCtrl{iAHU} = '無';
        ahuaexeff(iAHU) = 0;
        AEXbypass(iAHU) = 0;
    end
    
    
    % 接続室
    tmpQroomSet = {};
    tmpQoaSet   = {};
    tmpVoa      = 0;
    tmpSahu     = 0;
    for iROOM = 1:length(roomName)
        if strcmp(ahuSetName(iAHU),roomAHU_Qroom(iROOM))
            tmpQroomSet = [tmpQroomSet,roomID(iROOM)];  % 室負荷処理用
        end
        if strcmp(ahuSetName(iAHU),roomAHU_Qoa(iROOM))
            tmpQoaSet = [tmpQoaSet,roomID(iROOM)];      % 外気負荷処理用
            tmpVoa    = tmpVoa + roomVoa(iROOM);          % 外気取入量 [kg/s]
            tmpSahu   = tmpSahu + roomArea(iROOM);
        end
    end
    ahuQroomSet{iAHU,:} = tmpQroomSet;  % 室負荷処理対象室
    ahuQoaSet{iAHU,:}   = tmpQoaSet;    % 外気負荷処理対象室
    ahuQallSet{iAHU,:}  = [ahuQroomSet{iAHU,:},ahuQoaSet{iAHU,:}];
    ahuVoa(iAHU)        = tmpVoa;
    ahuS(iAHU)          = tmpSahu;  % 空調系統ごとの空調対象面積 [m2]
    ahuATF_C(iAHU)      = ahuQcmax(iAHU)/ahuEfan(iAHU); % 冷房時ATF(冷房能力／ファン動力）
    ahuATF_H(iAHU)      = ahuQhmax(iAHU)/ahuEfan(iAHU); % 冷房時ATF(暖房能力／ファン動力）
    ahuFratio(iAHU)     = ahuEfan(iAHU)/ahuS(iAHU)*1000;     % 単位床面積あたりのファン電力 [W/m2]
    
    
    % ビルマル対応（仮想二次ポンプを自動追加）
    if strcmp(ahuPump_cooling{iAHU},'Null_C') % 冷水ポンプ
        
        % 仮想ポンプ(冷)を追加（熱源名称＋VirtualPump）
        ahuPump_cooling{iAHU} = strcat(ahuRef_cooling{iAHU},'_VirtualPump');
        
        % ポンプリストになければ新規追加
        multipumpFlag = 0;
        for iPUMP = 1:numOfPumps
            if strcmp(pumpName{iPUMP},ahuPump_cooling{iAHU})
                multipumpFlag = 1;
                break
            end
        end
        if multipumpFlag == 0
            numOfPumps = numOfPumps + 1;
            iPUMP = numOfPumps;
            pumpName{iPUMP}     = ahuPump_cooling{iAHU}; % ポンプ名称
            pumpMode{iPUMP}     = 'Cooling';             % ポンプ運転モード
            pumpdelT(iPUMP)     = 0;
            pumpQuantityCtrl{iPUMP} = 'False';            % 台数制御
            pumpsetPnum(iPUMP)  = 1;
            
            pumpFlow(iPUMP,1)     = 0;                     % ポンプ流量
            pumpPower(iPUMP,1)    = 0;                     % ポンプ定格電力
            pumpFlowCtrl{iPUMP,1} = 'CWV';                 % ポンプ流量制御
            pumpMinValveOpening(iPUMP,1) = 1;
        end
    end
    
    if strcmp(ahuPump_heating{iAHU},'Null_H') % 温水ポンプ
        
        % 仮想ポンプ(温)を追加（熱源名称＋VirtualPump）
        ahuPump_heating{iAHU} = strcat(ahuRef_heating{iAHU},'_VirtualPump');
        
        % ポンプリストになければ新規追加
        multipumpFlag = 0;
        for iPUMP = 1:numOfPumps
            if strcmp(pumpName{iPUMP},ahuPump_heating{iAHU})
                multipumpFlag = 1;
                break
            end
        end
        if multipumpFlag == 0
            numOfPumps = numOfPumps + 1;
            iPUMP = numOfPumps;
            pumpName{iPUMP}     = ahuPump_heating{iAHU}; % ポンプ名称
            pumpMode{iPUMP}     = 'Heating';             % ポンプ運転モード
            pumpdelT(iPUMP)     = 0;
            pumpQuantityCtrl{iPUMP} = 'False';           % 台数制御
            pumpsetPnum(iPUMP)  = 1;
            
            pumpFlow(iPUMP,1)     = 0;                     % ポンプ流量
            pumpPower(iPUMP,1)    = 0;                     % ポンプ定格電力
            pumpFlowCtrl{iPUMP,1} = 'CWV';                 % ポンプ流量制御
            pumpMinValveOpening(iPUMP,1) = 1;
        end
    end

end


% % 空調機リストの作成
% ahuID = {};
% for iAHU = 1:numOfAHUsTemp
%     if iAHU == 1
%         ahuID = [ahuID; ahueleID(iAHU)];
%     else
%         check = 0;
%         for iDB = 1:length(ahuID)
%             if strcmp(ahuID(iDB),ahueleID(iAHU))
%                 check = 1;
%             end
%         end
%         if check == 0
%             ahuID = [ahuID; ahueleID(iAHU)];
%         end
%     end
% end
% 
% numOfAHUs = length(ahuID);
% ahuName  = cell(1,numOfAHUs);
% ahuType  = cell(1,numOfAHUs);
% ahuQcmax = zeros(1,numOfAHUs);
% ahuQhmax = zeros(1,numOfAHUs);
% ahuVsa   = zeros(1,numOfAHUs);
% ahuEfan  = zeros(1,numOfAHUs);
% ahuFanVAV = zeros(1,numOfAHUs);
% ahuFanVAVmin = ones(1,numOfAHUs);
% ahuOAcut  = zeros(1,numOfAHUs);
% ahuOAcool = zeros(1,numOfAHUs);
% ahuTypeNum = zeros(1,numOfAHUs);
% ahuaexE    = zeros(1,numOfAHUs);
% ahuaexV    = zeros(1,numOfAHUs);
% AEXbypass  = zeros(1,numOfAHUs);
% ahuaexeff  = zeros(1,numOfAHUs);
% ahuaex     = zeros(1,numOfAHUs);
% ahuRef_cooling  = cell(1,numOfAHUs);
% ahuRef_heating  = cell(1,numOfAHUs);
% ahuPump_cooling = cell(1,numOfAHUs);
% ahuPump_heating = cell(1,numOfAHUs);
% ahuFreeCoolingCtrl = cell(1,numOfAHUs);
% ahuHeatExchangeCtrl = cell(1,numOfAHUs);
% ahuOACutCtrl = cell(1,numOfAHUs);
% ahuFlowControl = cell(1,numOfAHUs);
% 
% for iAHU = 1:numOfAHUs
%     
%     % 一致するユニットを探索
%     for iAHUELE = 1:numOfAHUsTemp
%         if strcmp(ahuID(iAHU),ahueleID(iAHUELE))
%             
%             switch ahueleType{iAHUELE}
%                 case {'AHU','FCU','UNIT'}
%                     
%                     % AHUtype
%                     if isempty(ahueleType{iAHUELE}) == 0
%                         switch ahueleType{iAHUELE}
%                             case 'AHU'
%                                 ahuType{iAHU}    = '空調機';
%                                 ahuTypeNum(iAHU) = 1;
%                             case 'FCU'
%                                 ahuType{iAHU}    = 'FCU';
%                                 ahuTypeNum(iAHU) = 2;
%                             case 'UNIT'
%                                 ahuType{iAHU}    = 'UNIT';
%                                 ahuTypeNum(iAHU) = 3;
%                             otherwise
%                                 error('XMLファイルが不正です')
%                         end
%                     end
%                     
%                     % ファン消費電力 [kW]
%                     ahuEfan(iAHU) = ahuEfan(iAHU) + ahueleEfsa(iAHUELE) + ahueleEfra(iAHUELE) + ahueleEfoa(iAHUELE) + ahueleEfex(iAHUELE);
%                     
%                     % 冷房能力、暖房能力、給気風量を足す
%                     ahuQcmax(iAHU) = ahuQcmax(iAHU) + ahueleQcmax(iAHUELE);
%                     ahuQhmax(iAHU) = ahuQhmax(iAHU) + ahueleQhmax(iAHUELE);
%                     ahuVsa(iAHU)   = ahuVsa(iAHU)   + ahueleVsa(iAHUELE);
%                     
%                     % VAV制御
%                     if isempty(ahueleFlowControl{iAHUELE}) == 0
%                         switch ahueleFlowControl{iAHUELE}
%                             case {'CAV','Null'}
%                                 ahuFlowControl{iAHU} = '定風量';
%                                 ahuFanVAV(iAHU)    = 0;
%                                 ahuFanVAVmin(iAHU) = 1;
%                                 AHUvavfac(iAHU,:) = ones(1,length(aveL));
%                                 
%                             otherwise
%                                 ahuFlowControl{iAHU} = '変風量';
%                                 ahuFanVAV(iAHU) = 1;
%                                 
%                                 % 効果係数 AHUvavfac
%                                 check = 0;
%                                 for iDB = 2:size(perDB_flowControl,1)
%                                     if strcmp(perDB_flowControl(iDB,2),ahueleFlowControl(iAHUELE))
%                                         
%                                         a4 = str2double(perDB_flowControl(iDB,4));
%                                         a3 = str2double(perDB_flowControl(iDB,5));
%                                         a2 = str2double(perDB_flowControl(iDB,6));
%                                         a1 = str2double(perDB_flowControl(iDB,7));
%                                         a0 = str2double(perDB_flowControl(iDB,8));
%                                         
%                                         AHUvavfac(iAHU,:) = a4 .* aveL.^4 + a3 .* aveL.^3 + a2 .* aveL.^2 + a1 .* aveL + a0;
%                                         check = 1;
%                                     end
%                                 end
%                                 
%                                 if ahueleMinDamperOpening(iAHUELE) >= 0 && ahueleMinDamperOpening(iAHUELE) < 1
%                                     ahuFanVAVmin(iAHU) = ahueleMinDamperOpening(iAHUELE);  % VAV最小風量比 [-]
%                                 elseif ahueleMinDamperOpening(iAHUELE) == 1
%                                     % 最小開度が1の時はVAVとはみなさない。
%                                     AHUvavfac(iAHU,:) = ones(1,length(aveL));
%                                     ahuFanVAVmin(iAHU) = 1;
%                                 else
%                                     error('VAV最小開度の設定が不正です')
%                                 end
%                                 
%                                 if check == 0
%                                     error('XMLファイルが不正です')
%                                 end
%                         end
%                         
%                     else
%                         ahuFlowControl{iAHU} = '定風量';
%                         ahuFanVAV(iAHU)    = 0;
%                         ahuFanVAVmin(iAHU) = 1;
%                     end
%                     
%                     
%                     % 外気カット
%                     if isempty(ahueleOACutCtrl{iAHUELE}) == 0
%                         switch ahueleOACutCtrl{iAHUELE}
%                             case 'False'
%                                 ahuOACutCtrl{iAHU} = '無';
%                                 ahuOAcut(iAHU) = 0;
%                             case 'True'
%                                 ahuOACutCtrl{iAHU} = '有';
%                                 ahuOAcut(iAHU) = 1;
%                             otherwise
%                                 error('XMLファイルが不正です')
%                         end
%                     else
%                         ahuOACutCtrl{iAHU} = '無';
%                     end
%                     
%                     % 外気冷房
%                     if isempty(ahueleFreeCoolingCtrl{iAHUELE}) == 0
%                         switch ahueleFreeCoolingCtrl{iAHUELE}
%                             case 'False'
%                                 ahuFreeCoolingCtrl{iAHU} = '無';
%                                 ahuOAcool(iAHU) = 0;
%                             case 'True'
%                                 ahuFreeCoolingCtrl{iAHU} = '有';
%                                 ahuOAcool(iAHU) = 1;
%                             otherwise
%                                 error('XMLファイルが不正です')
%                         end
%                     else
%                         ahuFreeCoolingCtrl{iAHU} = '無';
%                     end
%                     
%                     % 全熱交換器
%                     if strcmp(ahueleHeatExchangeCtrl{iAHUELE},'True')
%                         
%                         ahuHeatExchangeCtrl{iAHU} = '有';
%                         ahuaex(iAHU) = 1;
%                         
%                         if ahueleHeatExchangeEff(iAHUELE) >= 0 && ahueleHeatExchangeEff(iAHUELE) <= 1
%                             if ahuaexeff(iAHU) == 0
%                                 ahuaexeff(iAHU) = ahueleHeatExchangeEff(iAHUELE);
%                             else
%                                 % 複数台ある場合の効率は、一番悪いものを使う。
%                                 if ahuaexeff(iAHU) > ahueleHeatExchangeEff(iAHUELE)
%                                     ahuaexeff(iAHU) = ahueleHeatExchangeEff(iAHUELE);
%                                 end
%                             end
%                         else
%                             error('全熱交換効率の設定が不正です。')
%                         end
%                         
%                         if strcmp(ahueleHeatExchangeBypass{iAHUELE},'True')
%                             AEXbypass(iAHU) = 1;
%                         end
%                         
%                         ahuaexE(iAHU)   = ahuaexE(iAHU) + ahueleHeatExchangePower(iAHUELE);  % 全熱交換機の動力
%                         ahuaexV(iAHU)   = ahuaexV(iAHU) + ahueleHeatExchangeVolume(iAHUELE); % 全熱交換機の風量
%                     else
%                         ahuHeatExchangeCtrl{iAHU} = '無';
%                     end
%                     
%                     if isempty(ahueleRef_cooling{iAHU}) == 0
%                         ahuRef_cooling{iAHU}  = ahueleRef_cooling{iAHUELE};
%                     end
%                     if isempty(ahueleRef_heating{iAHU}) == 0
%                         ahuRef_heating{iAHU}  = ahueleRef_heating{iAHUELE};
%                     end
%                     if isempty(ahuelePump_cooling{iAHU}) == 0
%                         ahuPump_cooling{iAHU} = ahuelePump_cooling{iAHUELE};
%                     end
%                     if isempty(ahuelePump_heating{iAHU}) == 0
%                         ahuPump_heating{iAHU} = ahuelePump_heating{iAHUELE};
%                     end
%                     
%                 case {'AEX'}
%                     
%                     % ファン消費電力 [kW]
%                     ahuEfan(iAHU) = ahuEfan(iAHU) + ahueleEfsa(iAHUELE) + ahueleEfra(iAHUELE) + ahueleEfoa(iAHUELE) + ahueleEfex(iAHUELE);
%                     
%                     % 全熱交換器
%                     if strcmp(ahueleHeatExchangeCtrl{iAHUELE},'True')
%                         
%                         ahuaex(iAHU) = 1;
%                         
%                         if ahueleHeatExchangeEff(iAHUELE) >= 0 && ahueleHeatExchangeEff(iAHUELE) <= 1
%                             if ahuaexeff(iAHU) == 0
%                                 ahuaexeff(iAHU) = ahueleHeatExchangeEff(iAHUELE);
%                             else
%                                 % 複数台ある場合の効率は、一番悪いものを使う。
%                                 if ahuaexeff(iAHU) > ahueleHeatExchangeEff(iAHUELE)
%                                     ahuaexeff(iAHU) = ahueleHeatExchangeEff(iAHUELE);
%                                 end
%                             end
%                         else
%                             error('全熱交換効率の設定が不正です。')
%                         end
%                         
%                         if strcmp(ahueleHeatExchangeBypass{iAHUELE},'True')
%                             AEXbypass(iAHU) = 1;
%                         end
%                         
%                         ahuaexE(iAHU)   = ahuaexE(iAHU) + ahueleHeatExchangePower(iAHUELE);  % 全熱交換機の動力
%                         ahuaexV(iAHU)   = ahuaexV(iAHU) + ahueleHeatExchangeVolume(iAHUELE); % 全熱交換機の風量
%                         
%                     end
%             end
%             
%         end
%     end
%     

%     % 接続室
%     tmpQroomSet = {};
%     tmpQoaSet   = {};
%     tmpVoa      = 0;
%     tmpSahu     = 0;
%     for iROOM = 1:length(roomName)
%         if strcmp(ahuID(iAHU),roomAHU_Qroom(iROOM))
%             tmpQroomSet = [tmpQroomSet,roomID(iROOM)];  % 室負荷処理用
%         end
%         if strcmp(ahuID(iAHU),roomAHU_Qoa(iROOM))
%             tmpQoaSet = [tmpQoaSet,roomID(iROOM)];      % 外気負荷処理用
%             tmpVoa    = tmpVoa + roomVoa(iROOM);          % 外気取入量 [kg/s]
%             tmpSahu   = tmpSahu + roomArea(iROOM);
%         end
%     end
%     ahuQroomSet{iAHU,:} = tmpQroomSet;  % 室負荷処理対象
%     ahuQoaSet{iAHU,:}   = tmpQoaSet;    % 外気負荷処理対象
%     ahuQallSet{iAHU,:}  = [ahuQroomSet{iAHU,:},ahuQoaSet{iAHU,:}];
%     ahuVoa(iAHU)        = tmpVoa;
%     ahuS(iAHU)          = tmpSahu;  % 空調系統ごとの空調対象面積 [m2]
%     ahuATF_C(iAHU)      = ahuQcmax(iAHU)/ahuEfan(iAHU); % 冷房時ATF(冷房能力／ファン動力）
%     ahuATF_H(iAHU)      = ahuQhmax(iAHU)/ahuEfan(iAHU); % 冷房時ATF(暖房能力／ファン動力）
%     ahuFratio(iAHU)     = ahuEfan(iAHU)/ahuS(iAHU)*1000;     % 単位床面積あたりのファン電力 [W/m2]
%     
%     
%     % ビルマル対応（仮想二次ポンプを自動追加）
%     if strcmp(ahuPump_cooling{iAHU},'Null_C') % 冷水ポンプ
%         
%         % 仮想ポンプ(冷)を追加（熱源名称＋VirtualPump）
%         ahuPump_cooling{iAHU} = strcat(ahuRef_cooling{iAHU},'_VirtualPump');
%         
%         % ポンプリストになければ新規追加
%         multipumpFlag = 0;
%         for iPUMP = 1:numOfPumps
%             if strcmp(pumpName{iPUMP},ahuPump_cooling{iAHU})
%                 multipumpFlag = 1;
%                 break
%             end
%         end
%         if multipumpFlag == 0
%             numOfPumps = numOfPumps + 1;
%             iPUMP = numOfPumps;
%             pumpName{iPUMP}     = ahuPump_cooling{iAHU}; % ポンプ名称
%             pumpMode{iPUMP}     = 'Cooling';             % ポンプ運転モード
%             pumpdelT(iPUMP)     = 0;
%             pumpQuantityCtrl{iPUMP} = 'False';            % 台数制御
%             pumpsetPnum(iPUMP)  = 1;
%             
%             pumpFlow(iPUMP,1)     = 0;                     % ポンプ流量
%             pumpPower(iPUMP,1)    = 0;                     % ポンプ定格電力
%             pumpFlowCtrl{iPUMP,1} = 'CWV';                 % ポンプ流量制御
%             pumpMinValveOpening(iPUMP,1) = 1;
%         end
%     end
%     
%     if strcmp(ahuPump_heating{iAHU},'Null_H') % 温水ポンプ
%         
%         % 仮想ポンプ(冷)を追加（熱源名称＋VirtualPump）
%         ahuPump_heating{iAHU} = strcat(ahuRef_heating{iAHU},'_VirtualPump');
%         
%         % ポンプリストになければ新規追加
%         multipumpFlag = 0;
%         for iPUMP = 1:numOfPumps
%             if strcmp(pumpName{iPUMP},ahuPump_heating{iAHU})
%                 multipumpFlag = 1;
%                 break
%             end
%         end
%         if multipumpFlag == 0
%             numOfPumps = numOfPumps + 1;
%             iPUMP = numOfPumps;
%             pumpName{iPUMP}     = ahuPump_heating{iAHU}; % ポンプ名称
%             pumpMode{iPUMP}     = 'Heating';             % ポンプ運転モード
%             pumpdelT(iPUMP)     = 0;
%             pumpQuantityCtrl{iPUMP} = 'False';           % 台数制御
%             pumpsetPnum(iPUMP)  = 1;
%             
%             pumpFlow(iPUMP,1)     = 0;                     % ポンプ流量
%             pumpPower(iPUMP,1)    = 0;                     % ポンプ定格電力
%             pumpFlowCtrl{iPUMP,1} = 'CWV';                 % ポンプ流量制御
%             pumpMinValveOpening(iPUMP,1) = 1;
%         end
%     end
%     
% end

%----------------------------------
% ポンプのパラメータ

for iPUMP = 1:numOfPumps
        
    % ポンプ運転モード
    switch pumpMode{iPUMP}
        case 'Cooling'
            PUMPtype(iPUMP) = 1;
        case 'Heating'
            PUMPtype(iPUMP) = 2;
        otherwise
            error('XMLファイルが不正です')
    end
    
    % 台数制御
    switch pumpQuantityCtrl{iPUMP}
        case 'False'
            PUMPnumctr(iPUMP) = 0;
        case 'True'
            PUMPnumctr(iPUMP) = 1;
        otherwise
            error('XMLファイルが不正です')
    end
    
    for iPUMPSUB = 1:pumpsetPnum(iPUMP)
        
        % VWV制御
        switch pumpFlowCtrl{iPUMP,iPUMPSUB}
            case {'CWV', 'Null'}
                PUMPvwv(iPUMP,iPUMPSUB) = 0;
                Pump_VWVcoeffi(iPUMP,iPUMPSUB,1) = 0;  % 4次の係数
                Pump_VWVcoeffi(iPUMP,iPUMPSUB,2) = 0;  % 3次の係数
                Pump_VWVcoeffi(iPUMP,iPUMPSUB,3) = 0;  % 2次の係数
                Pump_VWVcoeffi(iPUMP,iPUMPSUB,4) = 0;  % 1次の係数
                Pump_VWVcoeffi(iPUMP,iPUMPSUB,5) = 1;  % 切片
                
            otherwise
                
                PUMPvwv(iPUMP,iPUMPSUB) = 1;
                
                % 効果係数 Pump_VWVcoeffi
                check = 0;
                for iDB = 2:size(perDB_flowControl,1)
                    if strcmp(perDB_flowControl(iDB,2),pumpFlowCtrl{iPUMP,iPUMPSUB})
                        Pump_VWVcoeffi(iPUMP,iPUMPSUB,1) = str2double(perDB_flowControl(iDB,4));  % 4次の係数
                        Pump_VWVcoeffi(iPUMP,iPUMPSUB,2) = str2double(perDB_flowControl(iDB,5));  % 3次の係数
                        Pump_VWVcoeffi(iPUMP,iPUMPSUB,3) = str2double(perDB_flowControl(iDB,6));  % 2次の係数
                        Pump_VWVcoeffi(iPUMP,iPUMPSUB,4) = str2double(perDB_flowControl(iDB,7));  % 1次の係数
                        Pump_VWVcoeffi(iPUMP,iPUMPSUB,5) = str2double(perDB_flowControl(iDB,8));  % 切片
                        check = 1;
                    end
                end
                
                % VWV時の最小流量
                if pumpMinValveOpening(iPUMP,iPUMPSUB) >= 0 && pumpMinValveOpening(iPUMP,iPUMPSUB) < 1
                    pumpVWVmin(iPUMP,iPUMPSUB) = pumpMinValveOpening(iPUMP,iPUMPSUB);
                elseif pumpMinValveOpening(iPUMP,iPUMPSUB) == 1
                    % 最小開度が1の時はVWVとはみなさない。
                    Pump_VWVcoeffi(iPUMP,iPUMPSUB,1) = 0;  % 4次の係数
                    Pump_VWVcoeffi(iPUMP,iPUMPSUB,2) = 0;  % 3次の係数
                    Pump_VWVcoeffi(iPUMP,iPUMPSUB,3) = 0;  % 2次の係数
                    Pump_VWVcoeffi(iPUMP,iPUMPSUB,4) = 0;  % 1次の係数
                    Pump_VWVcoeffi(iPUMP,iPUMPSUB,5) = 1;  % 切片
                    pumpVWVmin(iPUMP,iPUMPSUB) = 1;
                else
                    error('VWVの最小開度の設定が不正です')
                end
                
                if check == 0
                    error('XMLファイルが不正です')
                end
        end
        
    end
    
    % 接続空調機
    tmpAHUSet = {};
    tmpSpump  = 0;
    for iAHU = 1:numOfAHUSET
        if PUMPtype(iPUMP) == 1
            if strcmp(pumpName{iPUMP},ahuPump_cooling(iAHU)) % 冷水ポンプ
                tmpAHUSet = [tmpAHUSet,ahuSetName(iAHU)];
                tmpSpump  = tmpSpump + ahuS(iAHU);
            end
        elseif PUMPtype(iPUMP) == 2
            if strcmp(pumpName{iPUMP},ahuPump_heating(iAHU)) % 温水ポンプ
                tmpAHUSet = [tmpAHUSet,ahuSetName(iAHU)];
                tmpSpump  = tmpSpump + ahuS(iAHU);
            end
        end
    end
    
    PUMPahuSet{iPUMP,:} = tmpAHUSet;
    pumpS(iPUMP)        = tmpSpump;    % ポンプ系統ごとの空調対象面積
    
end


%----------------------------------
% 熱源のパラメータ

QrefrMax  = zeros(1,numOfRefs);  % 各群の定格最大能力（全台数合計）
REFtype   = zeros(1,numOfRefs);  % 群の運転モード（１：冷房、２：暖房）
TC        = zeros(1,numOfRefs);  % 送水温度 [℃]
REFnumctr = zeros(1,numOfRefs);  % 台数制御の有無（０：なし、１：あり）
REFstrage = zeros(1,numOfRefs);  % 蓄熱制御の有無（０：なし、１：あり）
refS      = zeros(1,numOfRefs);  % 熱源群別の空調面積 [m2]
REFCHmode = zeros(1,numOfRefs);  % 冷暖同時運転の有無（０：なし、１：あり）

xXratioMX = ones(numOfRefs,3,3).*NaN;

for iREF = 1:numOfRefs
    
    % 定格最大能力（全台数合計）
    QrefrMax(iREF) = nansum(refset_Capacity(iREF,:));
    
    % 運転モード
    switch refsetMode{iREF}
        case 'Cooling'
            REFtype(iREF) = 1;
        case 'Heating'
            REFtype(iREF) = 2;
        otherwise
            error('熱源群の運転モード %s は不正です',refsetMode{iREF})
    end
    
    % 冷暖同時運転
    switch refsetSupplyMode{iREF}
        case 'True'
            REFCHmode(iREF) = 1;
        case 'False'
            REFCHmode(iREF) = 0;
        otherwise
            error('XMLファイルが不正です')
    end
    
    % 台数制御
    switch refsetQuantityCtrl{iREF}
        case 'True'
            REFnumctr(iREF) = 1;
        case 'False'
            REFnumctr(iREF) = 0;
        otherwise
            error('XMLファイルが不正です')
    end
    
    % 蓄熱制御
    switch refsetStorage{iREF}
        case 'Charge'
            REFstorage(iREF) = 1;
        case 'Discharge'
            REFstorage(iREF) = -1;
        case {'Null','None'}
            REFstorage(iREF) = 0;
        otherwise
            error('XMLファイルが不正です')
    end
    
    % 接続ポンプ
    tmpPUMPSet = {};
    tmpSref    = 0;
    for iAHU = 1:numOfAHUSET
        if REFtype(iREF) == 1
            if strcmp(refsetID(iREF),ahuRef_cooling(iAHU))
                
                tmpPUMPSet = [tmpPUMPSet,ahuPump_cooling(iAHU)];
                tmpSref    = tmpSref + ahuS(iAHU);
            end
        elseif REFtype(iREF) == 2
            if strcmp(refsetID(iREF),ahuRef_heating(iAHU))
                tmpPUMPSet = [tmpPUMPSet,ahuPump_heating(iAHU)];
                tmpSref    = tmpSref + ahuS(iAHU);
            end
        end
    end
    REFpumpSet{iREF,:} = tmpPUMPSet;
    refS(iREF)         = tmpSref;     % 熱源群別の空調面積 [m2]
    
    
    % 熱源機器別の設定
    for iREFSUB = 1:refsetRnum(iREF)
        
        % 熱源種類
        tmprefset = refset_Type{iREF,iREFSUB};
        
        refmatch = 0; % チェック用
        
        % データベースを検索
        if isempty(tmprefset) == 0
            
            % 該当する箇所をすべて抜き出す
            refParaSetALL = {};
            for iDB = 2:size(perDB_refList,1)
                if strcmp(perDB_refList(iDB,1),tmprefset)
                    refParaSetALL = [refParaSetALL;perDB_refList(iDB,:)];
                end
            end
            
            % データベースファイルに熱源機器の特性がない場合
            if isempty(refParaSetALL)
                error('熱源 %s の特性が見つかりません',tmprefset)
            end
            
            % 燃料種類＋一次エネルギー換算 [kW]
            switch refParaSetALL{1,3}
                case '電力'
                    refInputType(iREF,iREFSUB) = 1;
                    refset_MainPowerELE(iREF,iREFSUB) = (9760/3600)*refset_MainPower(iREF,iREFSUB);
                case 'ガス'
                    refInputType(iREF,iREFSUB) = 2;
                    refset_MainPowerELE(iREF,iREFSUB) = (45000/3600)*refset_MainPower(iREF,iREFSUB);
                case '重油'
                    refInputType(iREF,iREFSUB) = 3;
                    refset_MainPowerELE(iREF,iREFSUB) = (41000/3600)*refset_MainPower(iREF,iREFSUB);
                case '灯油'
                    refInputType(iREF,iREFSUB) = 4;
                    refset_MainPowerELE(iREF,iREFSUB) = (37000/3600)*refset_MainPower(iREF,iREFSUB);
                case '液化石油ガス'
                    refInputType(iREF,iREFSUB) = 5;
                    refset_MainPowerELE(iREF,iREFSUB) = (50000/3600)*refset_MainPower(iREF,iREFSUB);
                case '蒸気'
                    refInputType(iREF,iREFSUB) = 6;
                    % エネルギー消費量＝生成熱量とする。
                    refset_MainPower(iREF,iREFSUB) = refset_Capacity(iREF,iREFSUB);
                    refset_MainPowerELE(iREF,iREFSUB) = (1.36)*refset_MainPower(iREF,iREFSUB);
                case '温水'
                    refInputType(iREF,iREFSUB) = 7;
                    % エネルギー消費量＝生成熱量とする。
                    refset_MainPower(iREF,iREFSUB) = refset_Capacity(iREF,iREFSUB);
                    refset_MainPowerELE(iREF,iREFSUB) = (1.36)*refset_MainPower(iREF,iREFSUB);
                case '冷水'
                    refInputType(iREF,iREFSUB) = 8;
                    % エネルギー消費量＝生成熱量とする。
                    refset_MainPower(iREF,iREFSUB) = refset_Capacity(iREF,iREFSUB);
                    refset_MainPowerELE(iREF,iREFSUB) = (1.36)*refset_MainPower(iREF,iREFSUB);
                otherwise
                    error('熱源 %s の燃料種別が不正です',tmprefset)
            end
            
            % 冷却方式
            switch refParaSetALL{1,4}
                case '水冷'
                    refHeatSourceType(iREF,iREFSUB) = 1;
                case '空冷'
                    refHeatSourceType(iREF,iREFSUB) = 2;
                case '燃焼'
                    refHeatSourceType(iREF,iREFSUB) = 1;
                otherwise
                    error('熱源 %s の冷却方式が不正です',tmprefset)
            end
            
            % 能力比、入力比の変数
            if refHeatSourceType(iREF,iREFSUB) == 1 && REFtype(iREF) == 1   % 水冷／冷房
                xT = TctwC;   % 冷却水温度
            elseif refHeatSourceType(iREF,iREFSUB) == 1 && REFtype(iREF) == 2   % 水冷／暖房
                xT = ToadbH;  % 乾球温度
            elseif refHeatSourceType(iREF,iREFSUB) == 2 && REFtype(iREF) == 1   % 空冷／冷房
                xT = ToadbC;  % 乾球温度
            elseif refHeatSourceType(iREF,iREFSUB) == 2 && REFtype(iREF) == 2   % 空冷／暖房
                xT = ToawbH;  % 湿球温度
            else
                error('モードが不正です')
            end
            
            % 外気温度の軸（マトリックスの縦軸）
            xTALL(iREF,iREFSUB,:) = xT;
            
            
            % 能力比と入力比
            for iPQXW = 1:4
                
                if iPQXW == 1
                    PQname = '能力比';
                    Vname  = 'xQratio';
                elseif iPQXW == 2
                    PQname = '入力比';
                    Vname  = 'xPratio';
                elseif iPQXW == 3
                    PQname = '部分負荷特性';
                elseif iPQXW == 4
                    PQname = '送水温度特性';
                end
                
                % データベースから該当箇所を抜き出し（特性が2つ以上の式で表現されている場合、該当箇所が複数ある）
                paraQ = {};
                for iDB = 1:size(refParaSetALL,1)
                    if strcmp(refParaSetALL(iDB,5),refsetMode{iREF}) && strcmp(refParaSetALL(iDB,6),PQname)
                        paraQ = [paraQ;  refParaSetALL(iDB,:)];
                    end
                end
                
                % 値の抜き出し
                tmpdata   = [];
                tmpdataMX = [];
                if isempty(paraQ) == 0
                    for iDBQ = 1:size(paraQ,1)
                        
                        % 機器特性データベース perDB_refCurve を探査
                        for iLIST = 2:size(perDB_refCurve,1)
                            if strcmp(paraQ(iDBQ,9),perDB_refCurve(iLIST,2))
                                % 最小値、最大値、基整促係数、パラメータ（x4,x3,x2,x1,a）
                                tmpdata = [tmpdata;str2double(paraQ(iDBQ,[7,8,10])),str2double(perDB_refCurve(iLIST,4:8))];
                                
                                if iPQXW == 3
                                    tmpdataMX = [tmpdataMX; str2double(paraQ(iDBQ,12))];  % 当該特性の冷却水温度適用最大値（該当機器のみ）
                                end
                                
                            end
                        end
                    end
                end
                                
                % 係数（基整促係数込み）
                if iPQXW == 1 || iPQXW == 2
                    for i = 1:6
                        eval(['',Vname,'(iREF,iREFSUB,i) = mytfunc_REFparaSET(tmpdata,xT(i));'])
                    end
                    
                elseif iPQXW == 3
                    if isempty(tmpdata) == 0
                        for iX = 1:size(tmpdata,1)
                            RerPerC_x_min(iREF,iREFSUB,iX)    = tmpdata(iX,1);
                            RerPerC_x_max(iREF,iREFSUB,iX)    = tmpdata(iX,2);
                            RerPerC_x_coeffi(iREF,iREFSUB,iX,1)  = tmpdata(iX,4);
                            RerPerC_x_coeffi(iREF,iREFSUB,iX,2)  = tmpdata(iX,5);
                            RerPerC_x_coeffi(iREF,iREFSUB,iX,3)  = tmpdata(iX,6);
                            RerPerC_x_coeffi(iREF,iREFSUB,iX,4)  = tmpdata(iX,7);
                            RerPerC_x_coeffi(iREF,iREFSUB,iX,5)  = tmpdata(iX,8);
                        end
                    else
                        disp('特性が見つからないため、デフォルト特性を適用')
                        RerPerC_x_min(iREF,iREFSUB,1)    = 0;
                        RerPerC_x_max(iREF,iREFSUB,1)    = 0;
                        RerPerC_x_coeffi(iREF,iREFSUB,1,1)  = 0;
                        RerPerC_x_coeffi(iREF,iREFSUB,1,2)  = 0;
                        RerPerC_x_coeffi(iREF,iREFSUB,1,3)  = 0;
                        RerPerC_x_coeffi(iREF,iREFSUB,1,4)  = 0;
                        RerPerC_x_coeffi(iREF,iREFSUB,1,5)  = 1;
                    end
                    if isempty(tmpdataMX) == 0
                        % 当該特性の冷却水温度適用最大値（該当機器のみ）
                        for iMX = 1:length(tmpdataMX)
                            xXratioMX(iREF,iREFSUB,iMX) = tmpdataMX(iMX);
                        end
                    end
                    
                elseif iPQXW == 4
                    if isempty(tmpdata) == 0
                        RerPerC_w_min(iREF,iREFSUB)    = tmpdata(1,1);
                        RerPerC_w_max(iREF,iREFSUB)    = tmpdata(1,2);
                        RerPerC_w_coeffi(iREF,iREFSUB,1)  = tmpdata(1,4);
                        RerPerC_w_coeffi(iREF,iREFSUB,2)  = tmpdata(1,5);
                        RerPerC_w_coeffi(iREF,iREFSUB,3)  = tmpdata(1,6);
                        RerPerC_w_coeffi(iREF,iREFSUB,4)  = tmpdata(1,7);
                        RerPerC_w_coeffi(iREF,iREFSUB,5)  = tmpdata(1,8);
                    else
                        RerPerC_w_min(iREF,iREFSUB)       = 0;
                        RerPerC_w_max(iREF,iREFSUB)       = 0;
                        RerPerC_w_coeffi(iREF,iREFSUB,1)  = 0;
                        RerPerC_w_coeffi(iREF,iREFSUB,2)  = 0;
                        RerPerC_w_coeffi(iREF,iREFSUB,3)  = 0;
                        RerPerC_w_coeffi(iREF,iREFSUB,4)  = 0;
                        RerPerC_w_coeffi(iREF,iREFSUB,5)  = 1;
                    end
                    
                end
                
            end
            
            refmatch = 1; % 処理済みの証拠
            
        end
        
        if isempty(tmprefset)== 0 && refmatch == 0
            error('熱源名称 %s は不正です',tmprefset);
        end
        
    end
    
end


% 各空調機が何管式か(0なら冷暖切替、1なら冷暖同時)
AHUCHmode_C = zeros(numOfAHUSET,1);
AHUCHmode_H = zeros(numOfAHUSET,1);
AHUCHmode   = zeros(numOfAHUSET,1);
for iAHU = 1:numOfAHUSET
    for iDB = 1:numOfRefs
        if strcmp(ahuRef_cooling{iAHU},refsetID{iDB})
            AHUCHmode_C(iAHU) = REFCHmode(iDB);
        end
        if strcmp(ahuRef_heating{iAHU},refsetID{iDB})
            AHUCHmode_H(iAHU) = REFCHmode(iDB);
        end
    end
    
    % 両方とも冷暖同時なら、その空調機は冷暖同時運転可能とする。
    if AHUCHmode_C(iAHU) == 1 && AHUCHmode_H(iAHU) == 1
        AHUCHmode(iAHU) = 1;
    end
end






