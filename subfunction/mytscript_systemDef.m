% mytfunc_systemDef.m
%                                                  2011/01/01 by Masato Miyata
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
    
    roomElementContents = [];
    % 室要素接続
    if isempty(strfind(roomElements{iROOM},','))  % 一要素だけの場合
        roomElementContents{1} = roomElements{iROOM};
    else
        conma = strfind(roomElements{iROOM},',');
        for iSTR = 1:length(conma)+1
            if iSTR == 1
                roomElementContents{iSTR} = roomElements{iROOM}(1:conma(iSTR)-1);
            elseif iSTR == length(conma)+1
                roomElementContents{iSTR} = roomElements{iROOM}(conma(iSTR-1)+1:end);
            else
                roomElementContents{iSTR} = roomElements{iROOM}(conma(iSTR-1)+1:conma(iSTR)-1);
            end
        end
    end
    
    % 室要素の行列番号探索
    roomElementContentsNum = ones(1,length(roomElementContents));
    for iROOMEL = 1:length(roomElementContents)
        for iELEMENTS = 1:length(roomElementName)
            if strcmp(roomElementContents{iROOMEL},roomElementName{iELEMENTS})
                roomElementContentsNum(iROOMEL) = iELEMENTS;
            end
        end
    end
    
    roomArea(iROOM) = 0;
    for iROOMEL = roomElementContentsNum
        roomArea(iROOM)   = roomArea(iROOM) + roomElementArea(iROOMEL);   % 室面積（要素の和）
        
        roomType{iROOM}   = roomElementType{iROOMEL};   % 室用途（全要素同じでなければいけない）
        roomCount(iROOM)   = roomElementCount(iROOMEL);  % 室数（全要素同じでなければいけない）
        roomFloorHeight(iROOM) = roomElementFloorHeight(iROOMEL); % 階高（全要素同じでなければいけない）
        roomHeight(iROOM) = roomElementHeight(iROOMEL); % 室高（全要素同じでなければいけない）
    end
    
    % 建物用途と室用途リストを検索
    roomTime_start_p1_1 = [];
    for iDB = 2:size(perDB_RoomType,1)
        if strcmp(perDB_RoomType(iDB,4),BuildingType) &&...
                strcmp(perDB_RoomType(iDB,5),roomType{iROOM})
            
            % 各室の空調開始・終了時刻
            roomTime_start_p1_1 = str2double(cell2mat(perDB_RoomType(iDB,14))); % パターン1_空調開始時刻(1)
            roomTime_stop_p1_1   = str2double(cell2mat(perDB_RoomType(iDB,15))); % パターン1_空調終了時刻(1)
            roomTime_start_p1_2 = str2double(cell2mat(perDB_RoomType(iDB,16))); % パターン1_空調開始時刻(2)
            roomTime_stop_p1_2   = str2double(cell2mat(perDB_RoomType(iDB,17))); % パターン1_空調終了時刻(2)
            roomTime_start_p2_1 = str2double(cell2mat(perDB_RoomType(iDB,18))); % パターン2_空調開始時刻(1)
            roomTime_stop_p2_1   = str2double(cell2mat(perDB_RoomType(iDB,19))); % パターン2_空調終了時刻(1)
            roomTime_start_p2_2 = str2double(cell2mat(perDB_RoomType(iDB,20))); % パターン2_空調開始時刻(2)
            roomTime_stop_p2_2   = str2double(cell2mat(perDB_RoomType(iDB,21))); % パターン2_空調終了時刻(2)
            
            % カレンダー番号
            if strcmp(cell2mat(perDB_RoomType(iDB,7)),'A')
                roomClarendarNum(iROOM) = 1;
            elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'B')
                roomClarendarNum(iROOM) = 2;
            elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'C')
                roomClarendarNum(iROOM) = 3;
            elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'D')
                roomClarendarNum(iROOM) = 4;
            elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'E')
                roomClarendarNum(iROOM) = 5;
            elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'F')
                roomClarendarNum(iROOM) = 6;
            else
                
                % 旧データベース対応
                if strcmp(cell2mat(perDB_RoomType(iDB,7)),'1')
                    roomClarendarNum(iROOM) = 1;
                elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'2')
                    roomClarendarNum(iROOM) = 2;
                elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'3')
                    roomClarendarNum(iROOM) = 3;
                elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'4')
                    roomClarendarNum(iROOM) = 4;
                elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'5')
                    roomClarendarNum(iROOM) = 5;
                elseif strcmp(cell2mat(perDB_RoomType(iDB,7)),'6')
                    roomClarendarNum(iROOM) = 6;
                else
                    
                    perDB_RoomType(iDB,7)
                    error('カレンダーナンバーが不正です')
                    
                end
            end
            
            % 外気導入量 [m3/h/m2]
            roomVoa_m3hm2(iROOM) = str2double(cell2mat(perDB_RoomType(iDB,13)));
        end
    end
    if isempty(roomTime_start_p1_1)
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
        elseif strcmp(perDB_calendar{1+dd,roomClarendarNum(iROOM)+2},'2')  % 運転パターン２
            roomTime_start(dd,iROOM) = roomTime_start_p2;
            roomTime_stop(dd,iROOM)   = roomTime_stop_p2;
        elseif strcmp(perDB_calendar{1+dd,roomClarendarNum(iROOM)+2},'3')  % 運転パターン３
            roomTime_start(dd,iROOM) = 0;
            roomTime_stop(dd,iROOM)   = 0;
        end
    end
    
    % 外気取り入れ量 [m3/h] → [kg/s]  <室数をかける>
    roomVoa(iROOM) = roomVoa_m3hm2(iROOM).*1.293./3600.*roomArea(iROOM).*roomCount(iROOM);
    
end

% 空調面積
roomAreaTotal = sum(roomArea .* roomCount);

%----------------------------------
% 空調機のパラメータ

for iAHU = 1:numOfAHUs
    
    % ファン消費電力 [kW]
    ahuEfan(iAHU) = ahuEfsa(iAHU) + ahuEfra(iAHU) + ahuEfoa(iAHU);
    
    % 接続室
    tmpQroomSet = {};
    tmpQoaSet   = {};
    tmpVoa      = 0;
    for iROOM = 1:length(roomName)
        if strcmp(ahuName(iAHU),roomAHU_Qroom(iROOM))
            tmpQroomSet = [tmpQroomSet,roomName(iROOM)];  % 室負荷処理用
        end
        if strcmp(ahuName(iAHU),roomAHU_Qoa(iROOM))
            tmpQoaSet = [tmpQoaSet,roomName(iROOM)];      % 外気負荷処理用
            tmpVoa    = tmpVoa + roomVoa(iROOM);          % 外気取入量 [kg/s]
        end
    end
    ahuQroomSet{iAHU,:} = tmpQroomSet;  % 室負荷処理対象
    ahuQoaSet{iAHU,:}   = tmpQoaSet;    % 外気負荷処理対象
    ahuQallSet{iAHU,:}  = [ahuQroomSet{iAHU,:},ahuQoaSet{iAHU,:}];
    ahuVoa(iAHU)        = tmpVoa;
    
    % AHUtype
    switch ahuType{iAHU}
        case 'AHU'
            ahuTypeNum(iAHU) = 1;
        case 'FCU'
            ahuTypeNum(iAHU) = 2;
        case 'UNIT'
            ahuTypeNum(iAHU) = 3;
        otherwise
            error('XMLファイルが不正です')
    end
    
    % VAV制御
    switch ahuFlowControl{iAHU}
        case 'CAV'
            ahuFanVAV(iAHU) = 0;
            ahuFanVAVmin(iAHU) = 1;
        case 'VAV'
            ahuFanVAV(iAHU) = 1;
            if ahuMinDamperOpening(iAHU) >= 0 && ahuMinDamperOpening(iAHU) <= 1
                ahuFanVAVmin(iAHU) = ahuMinDamperOpening(iAHU);  % VAV最小風量比 [-]
            else
                error('VAV最小開度の設定が不正です')
            end
        otherwise
            error('XMLファイルが不正です')
    end
    
    % 外気カット
    switch ahuOACutCtrl{iAHU}
        case 'False'
            ahuOAcut(iAHU) = 0;
        case 'True'
            ahuOAcut(iAHU) = 1;
        otherwise
            error('XMLファイルが不正です')
    end
    
    % 外気冷房
    switch ahuFreeCoolingCtrl{iAHU}
        case 'False'
            ahuOAcool(iAHU) = 0;
        case 'True'
            ahuOAcool(iAHU) = 1;
        otherwise
            error('XMLファイルが不正です')
    end
    
    % 全熱交換器
    switch ahuHeatExchangeCtrl{iAHU}
        case 'False'
            ahuaex(iAHU)    = 0;
            ahuaexeff(iAHU) = 0;
            ahuaexE(iAHU)   = 0;
            AEXbypass(iAHU) = 0;
            ahuaexV(iAHU)      = 0;
        case 'True'
            ahuaex(iAHU) = 1;
            if ahuHeatExchangeEff(iAHU) >= 0 && ahuHeatExchangeEff(iAHU) <= 1
                ahuaexeff(iAHU) = ahuHeatExchangeEff(iAHU);   % 全熱交換機効率
            else
                error('全熱交換効率の設定が不正です。')
            end
            ahuaexE(iAHU)   = ahuHeatExchangePower(iAHU); % 全熱交換機の動力
            
            % 課題
            AEXbypass(iAHU) = 1;
            ahuaexV(iAHU)      = 10000;
            
        otherwise
            error('XMLファイルが不正です')
    end
    
    
    % ビルマル対応（仮想二次ポンプを自動追加）
    if isnan(ahuPump_cooling{iAHU}) == 1 % 冷水ポンプ
        
        % 仮想ポンプ(冷)を追加（熱源名称＋VirtualPump）
        ahuPump_cooling{iAHU} = strcat(ahuRef_cooling{iAHU},'C_VirtualPump');
        
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
            pumpCount(iPUMP)    = 0;                     % ポンプ台数
            pumpFlow(iPUMP)     = 0;                     % ポンプ流量
            pumpPower(iPUMP)    = 0;                     % ポンプ定格電力
            pumpFlowCtrl{iPUMP} = 'CWV';                 % ポンプ流量制御
            pumpQuantityCtrl{iPUMP} = 'False';            % 台数制御
        end
    end
    
    if isnan(ahuPump_heating{iAHU}) ==1 % 温水ポンプ
        
        % 仮想ポンプ(冷)を追加（熱源名称＋VirtualPump）
        ahuPump_heating{iAHU} = strcat(ahuRef_heating{iAHU},'H_VirtualPump');
        
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
            pumpCount(iPUMP)    = 0;                     % ポンプ台数
            pumpFlow(iPUMP)     = 0;                     % ポンプ流量
            pumpPower(iPUMP)    = 0;                     % ポンプ定格電力
            pumpFlowCtrl{iPUMP} = 'CWV';                 % ポンプ流量制御
            pumpQuantityCtrl{iPUMP} = 'False';            % 台数制御
        end
    end
    
end


%----------------------------------
% ポンプのパラメータ

for iPUMP = 1:numOfPumps
    
    Td_PUMP(iPUMP) = 5;
    pumpVWVmin(iPUMP) = 0.3;
    
    % ポンプ運転モード
    switch pumpMode{iPUMP}
        case 'Cooling'
            PUMPtype(iPUMP) = 1;
        case 'Heating'
            PUMPtype(iPUMP) = 2;
        otherwise
            error('XMLファイルが不正です')
    end
    
    % VWV制御
    switch pumpFlowCtrl{iPUMP}
        case 'CWV'
            PUMPvwv(iPUMP) = 0;
        case 'VWV'
            PUMPvwv(iPUMP) = 1;
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
    
    % 接続空調機
    tmpAHUSet = {};
    for iAHU = 1:numOfAHUs
        if PUMPtype(iPUMP) == 1
            if strcmp(pumpName{iPUMP},ahuPump_cooling(iAHU)) % 冷水ポンプ
                tmpAHUSet = [tmpAHUSet,ahuName(iAHU)];
            end
        elseif PUMPtype(iPUMP) == 2
            if strcmp(pumpName{iPUMP},ahuPump_heating(iAHU)) % 温水ポンプ
                tmpAHUSet = [tmpAHUSet,ahuName(iAHU)];
            end
        end
    end
    PUMPahuSet{iPUMP,:} = tmpAHUSet;
    
end


%----------------------------------
% 熱源のパラメータ

for iREF = 1:numOfRefs
    
    % 定格最大能力（全台数合計）
    QrefrMax(iREF) = nansum(refset_Capacity(iREF,:));
    
    % 運転モード
    switch refsetMode{iREF}
        case 'Cooling'
            REFtype(iREF) = 1;
            TC(iREF) = 7; % 送水温度 [℃]
        case 'Heating'
            REFtype(iREF) = 2;
            TC(iREF) = 40; % 送水温度 [℃]
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
        case 'True'
            REFstrage(iREF) = 1;
        case 'False'
            REFstrage(iREF) = 0;
        otherwise
            error('XMLファイルが不正です')
    end
    
    % 接続ポンプ
    tmpPUMPSet = {};
    for iAHU = 1:numOfAHUs
        if REFtype(iREF) == 1
            if strcmp(refsetID(iREF),ahuRef_cooling(iAHU))
                tmpPUMPSet = [tmpPUMPSet,ahuPump_cooling(iAHU)];
            end
        elseif REFtype(iREF) == 2
            if strcmp(refsetID(iREF),ahuRef_heating(iAHU))
                tmpPUMPSet = [tmpPUMPSet,ahuPump_heating(iAHU)];
            end
        end
    end
    REFpumpSet{iREF,:} = tmpPUMPSet;
    
    % 熱源特性
    for iREFSUB = 1:refsetRnum(iREF)
        
        % 熱源種類
        tmprefset = refset_Type{iREF,iREFSUB};
        
        refmatch = 0;
        if isempty(tmprefset) == 0
            for iDB = 2:size(perDB_refList,1)
                if strcmp(perDB_refList(iDB,1),tmprefset)
                    % 燃料種類＋一次エネルギー換算
                    switch perDB_refList{iDB,3}
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
                        case '地冷：蒸気'
                            refInputType(iREF,iREFSUB) = 6;
                            refset_MainPowerELE(iREF,iREFSUB) = (1.36)*refset_MainPower(iREF,iREFSUB);
                        case '地冷：温水'
                            refInputType(iREF,iREFSUB) = 7;
                            refset_MainPowerELE(iREF,iREFSUB) = (1.36)*refset_MainPower(iREF,iREFSUB);
                        case '地冷：冷水'
                            refInputType(iREF,iREFSUB) = 8;
                            refset_MainPowerELE(iREF,iREFSUB) = (1.36)*refset_MainPower(iREF,iREFSUB);
                        otherwise
                            error('熱源：燃料種類の設定が不正です')
                    end
                    
                    % 冷却方式
                    switch perDB_refList{iDB,4}
                        case '水冷'
                            refHeatSourceType(iREF,iREFSUB) = 1;
                        case '空冷'
                            refHeatSourceType(iREF,iREFSUB) = 2;
                    end
                                        
                    % 特性曲線
                    tN = '';
                    for i=1:4
                        if i == 1 && REFtype(iREF) == 1
                            tN = 'Cq';  % 能力比特性（冷）
                        elseif i == 1 && REFtype(iREF) == 2
                            tN = 'Hp';  % 能力比特性（温）
                        elseif i == 2 && REFtype(iREF) == 1
                            tN = 'Cp';  % 入力比特性（冷）
                        elseif i == 2 && REFtype(iREF) == 2
                            tN = 'Hq';  % 入力比特性（温）
                        elseif i == 3 && REFtype(iREF) == 1
                            tN = 'Cx';  % 部分負荷特性（冷）
                        elseif i == 3 && REFtype(iREF) == 2
                            tN = 'Hx';  % 部分負荷特性（温）
                        elseif i == 4 && REFtype(iREF) == 1
                            tN = 'Cw';  % 送水温度特性（冷）
                        elseif i == 4 && REFtype(iREF) == 2
                            tN = 'Hw';  % 送水温度特性（温）
                        end

                        % 特性曲線タイプの読み込み
                        if REFtype(iREF) == 1
                            eval(['refPerC_',tN,'{iREF,iREFSUB} = perDB_refList(iDB,4+i);'])
                        elseif REFtype(iREF) == 2
                            eval(['refPerC_',tN,'{iREF,iREFSUB} = perDB_refList(iDB,8+i);'])
                        end
                            
                            
                        % 性能曲線の係数の読み込み
                        eval(['tmpPerC = refPerC_',tN,'{iREF,iREFSUB};'])
                        tmpcoeff = [];
                        for iDB2 = 1:size(perDB_refCurve,1)
                            if strcmp(perDB_refCurve(iDB2,2),tmpPerC)
                                tmpcoeff(1,1) = str2double(perDB_refCurve(iDB2,6));  % 4乗の係数
                                tmpcoeff(1,2) = str2double(perDB_refCurve(iDB2,7));  % 3乗の係数
                                tmpcoeff(1,3) = str2double(perDB_refCurve(iDB2,8));  % 2乗の係数
                                tmpcoeff(1,4) = str2double(perDB_refCurve(iDB2,9));  % 1乗の係数
                                tmpcoeff(1,5) = str2double(perDB_refCurve(iDB2,10)); % 切片
                                tmpcoeff(1,6) = str2double(perDB_refCurve(iDB2,4));  % xの最小値
                                tmpcoeff(1,7) = str2double(perDB_refCurve(iDB2,5));  % xの最大値
                            end
                        end
                        if isempty(tmpcoeff)
                            error('熱源特性が見つかりません')
                        end
                        
                        % 保存
                        if i == 1
                            RerPerC_q_coeffi(iREF,iREFSUB,:) = tmpcoeff(1:5);
                            RerPerC_q_min(iREF,iREFSUB) = tmpcoeff(6);
                            RerPerC_q_max(iREF,iREFSUB) = tmpcoeff(7);
                        elseif i == 2
                            RerPerC_p_coeffi(iREF,iREFSUB,:) = tmpcoeff(1:5);
                            RerPerC_p_min(iREF,iREFSUB) = tmpcoeff(6);
                            RerPerC_p_max(iREF,iREFSUB) = tmpcoeff(7);
                        elseif i == 3
                            RerPerC_x_coeffi(iREF,iREFSUB,:) = tmpcoeff(1:5);
                            RerPerC_x_min(iREF,iREFSUB) = tmpcoeff(6);
                            RerPerC_x_max(iREF,iREFSUB) = tmpcoeff(7);
                        elseif i == 4
                            RerPerC_w_coeffi(iREF,iREFSUB,:) = tmpcoeff(1:5);
                            RerPerC_w_min(iREF,iREFSUB) = tmpcoeff(6);
                            RerPerC_w_max(iREF,iREFSUB) = tmpcoeff(7);
                        end
                        
                    end
                    
                    refmatch = 1; % 処理済みの証拠
                    
                end
            end
        end
        
        % 基整促係数(default 1.2)
        RefTEIGEN(iREF,iREFSUB) = 1.2;
        
        if strcmp(tmprefset,'Rtype10') && REFtype(iREF) == 2
            RefTEIGEN(iREF,iREFSUB) = 1.0;
        elseif strcmp(tmprefset,'Rtype11') && REFtype(iREF) == 2
            RefTEIGEN(iREF,iREFSUB) = 1.0;
        elseif strcmp(tmprefset,'Rtype12') && REFtype(iREF) == 2
            RefTEIGEN(iREF,iREFSUB) = 1.0;
        elseif strcmp(tmprefset,'Rtype13') && REFtype(iREF) == 2
            RefTEIGEN(iREF,iREFSUB) = 1.0;
        elseif strcmp(tmprefset,'Rtype14') && REFtype(iREF) == 2
            RefTEIGEN(iREF,iREFSUB) = 1.0;
        elseif strcmp(tmprefset,'Rtype15') && REFtype(iREF) == 2
            RefTEIGEN(iREF,iREFSUB) = 1.0;
        elseif strcmp(tmprefset,'Rtype16') && REFtype(iREF) == 2
            RefTEIGEN(iREF,iREFSUB) = 1.0;
        elseif strcmp(tmprefset,'Rtype17') && REFtype(iREF) == 2
            RefTEIGEN(iREF,iREFSUB) = 1.0;
        end
        
        if refmatch == 0
            error('熱源名称が不正です');
        end
    end
end


