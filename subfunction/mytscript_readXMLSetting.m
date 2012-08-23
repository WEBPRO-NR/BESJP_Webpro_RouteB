% mytfunc_readXMLSetting.m
%                                                  2011/04/16 by Masato Miyata
%------------------------------------------------------------------------------
% 省エネ基準ルートB：設定ファイル（XMLファイル）を読み込む。
%------------------------------------------------------------------------------

% XMLファイル読込み
INPUT = xml_read(INPUTFILENAME);

% Modelの属性
climateAREA  = INPUT.ATTRIBUTE.Region;     % 地域区分
BuildingArea = INPUT.ATTRIBUTE.TotalArea;  % 延床面積 [m2]

%----------------------------------
% 空調ゾーンのパラメータ
numOfRoooms    = length(INPUT.AirConditioningSystem.AirConditioningZone);

roomID          = cell(1,numOfRoooms);
roomFloor       = cell(1,numOfRoooms);
roomName        = cell(1,numOfRoooms);
EnvelopeRef     = cell(1,numOfRoooms);
roomAHU_Qroom   = cell(1,numOfRoooms);
roomAHU_Qoa     = cell(1,numOfRoooms);
buildingType    = cell(1,numOfRoooms);
roomType        = cell(1,numOfRoooms);
roomArea        = zeros(1,numOfRoooms);
roomFloorHeight = zeros(1,numOfRoooms);
roomHeight      = zeros(1,numOfRoooms);

for iZONE = 1:numOfRoooms
    
    roomID{iZONE}       = INPUT.AirConditioningSystem.AirConditioningZone(iZONE).ATTRIBUTE.ID;        % 空調室ID
    roomFloor{iZONE}    = INPUT.AirConditioningSystem.AirConditioningZone(iZONE).ATTRIBUTE.ACZoneFloor; % 階
    roomName{iZONE}     = INPUT.AirConditioningSystem.AirConditioningZone(iZONE).ATTRIBUTE.ACZoneName;  % 名称
    
    EnvelopeRef{iZONE}  = INPUT.AirConditioningSystem.AirConditioningZone(iZONE).ATTRIBUTE.ID;  % 外皮ID
    
    % 建物用途、室用途、階高、天井高
    buildingType{iZONE} = INPUT.AirConditioningSystem.AirConditioningZone(iZONE).RoomRef(1).ATTRIBUTE.BuildingType;
    roomType{iZONE}     = INPUT.AirConditioningSystem.AirConditioningZone(iZONE).RoomRef(1).ATTRIBUTE.RoomType;
    roomFloorHeight(iZONE)  = mytfunc_null2value(INPUT.AirConditioningSystem.AirConditioningZone(iZONE).RoomRef(1).ATTRIBUTE.FloorHeight,NaN);
    roomHeight(iZONE)   = mytfunc_null2value(INPUT.AirConditioningSystem.AirConditioningZone(iZONE).RoomRef(1).ATTRIBUTE.RoomHeight,NaN);
    
    % ゾーンの床面積合計値
    tmpRoomArea = 0;
    for iROOM = 1:length(INPUT.AirConditioningSystem.AirConditioningZone(iZONE).RoomRef)
        tmpRoomArea = tmpRoomArea + mytfunc_null2value(INPUT.AirConditioningSystem.AirConditioningZone(iZONE).RoomRef(iROOM).ATTRIBUTE.RoomArea,NaN);
    end
    roomArea(iZONE) = tmpRoomArea;
    
    % 空調機ID
    for iAHU = 1:2
        if strcmp(INPUT.AirConditioningSystem.AirConditioningZone(iZONE).AirHandlingUnitRef(iAHU).ATTRIBUTE.Load,'Room')
            % 室負荷を処理する空調機ID
            roomAHU_Qroom{iZONE} = INPUT.AirConditioningSystem.AirConditioningZone(iZONE).AirHandlingUnitRef(iAHU).ATTRIBUTE.ID;
        elseif strcmp(INPUT.AirConditioningSystem.AirConditioningZone(iZONE).AirHandlingUnitRef(iAHU).ATTRIBUTE.Load,'OutsideAir')
            % 外気負荷を処理する空調機ID
            roomAHU_Qoa{iZONE} = INPUT.AirConditioningSystem.AirConditioningZone(iZONE).AirHandlingUnitRef(iAHU).ATTRIBUTE.ID;
        end
    end
    
end

%----------------------------------
% 外壁と窓

% WCON.csv の生成
confW = {};
WallType = {};

for iWALL = 1:length(INPUT.AirConditioningSystem.WallConfigure)
    
    % 壁名称
    confW{iWALL,1} = INPUT.AirConditioningSystem.WallConfigure(iWALL).ATTRIBUTE.Name;
    % 壁ID
    confW{iWALL,2} = INPUT.AirConditioningSystem.WallConfigure(iWALL).ATTRIBUTE.ID;
    % 外壁タイプ
    WallType{iWALL,1} = INPUT.AirConditioningSystem.WallConfigure(iWALL).ATTRIBUTE.WallType;
    
    for iELE = 1:length(INPUT.AirConditioningSystem.WallConfigure(iWALL).MaterialRef)
        
        LayerNum = INPUT.AirConditioningSystem.WallConfigure(iWALL).MaterialRef(iELE).ATTRIBUTE.Layer;
        
        % 材料番号
        confW{iWALL,2+2*(LayerNum-1)+1} = int2str(INPUT.AirConditioningSystem.WallConfigure(iWALL).MaterialRef(iELE).ATTRIBUTE.MaterialNumber);
        % 厚み
        if INPUT.AirConditioningSystem.WallConfigure(iWALL).MaterialRef(iELE).ATTRIBUTE.WallThickness < 1000
            confW{iWALL,2+2*(LayerNum-1)+2} = int2str(INPUT.AirConditioningSystem.WallConfigure(iWALL).MaterialRef(iELE).ATTRIBUTE.WallThickness);
        else
            error('壁の厚さが不正です')
        end
    end
end

% WIND.csv の生成
confG = {};

for iWIND = 1:length(INPUT.AirConditioningSystem.WindowConfigure)
    
    % 名称
    confG{2*iWIND-1,1} = strcat(INPUT.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.ID,'_0');
    confG{2*iWIND,1}   = strcat(INPUT.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.ID,'_1');
    % 窓種類
    confG{2*iWIND-1,2} = INPUT.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.WindowTypeClass;
    confG{2*iWIND,2}   = INPUT.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.WindowTypeClass;
    % 窓番号
    confG{2*iWIND-1,3} = int2str(INPUT.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.WindowTypeNumber);
    confG{2*iWIND,3}   = int2str(INPUT.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.WindowTypeNumber);
    % ブラインド
    confG{2*iWIND-1,4} = '0'; % ブラインドなし
    confG{2*iWIND,4}   = '1';   % 明色ブラインドあり
    
end

% WCON,WIND.csv の出力
for iFILE=1:2
    if iFILE == 1
        tmp = confG;
        filename = './database/WIND.csv';
        header = {'名称','窓種','品種番号','ブラインド'};
    else
        tmp = confW;
        filename = './database/WCON.csv';
        header = {'名称','WCON名','第1層材番','第1層厚','第2層材番','第2層厚','第3層材番',...
            '第3層厚','第4層材番','第4層厚','第5層材番','第5層厚','第6層材番','第6層厚',...
            '第7層材番','第7層厚','第8層材番','第8層厚','第9層材番','第9層厚','第10層材番',...
            '第10層厚','第11層材番','第11層厚'};
    end
    
    fid = fopen(filename,'wt'); % 書き込み用にファイルオープン
    
    % ヘッダーの書き出し
    fprintf(fid, '%s,', header{1:end-1});
    fprintf(fid, '%s\n', header{end});
    
    [rows,cols] = size(tmp);
    for j = 1:rows
        for k = 1:cols
            if k < cols
                fprintf(fid, '%s,', tmp{j,k}); % 文字列の書き出し
            else
                fprintf(fid, '%s\n', tmp{j,k}); % 行末の文字列は、改行を含めて出力
            end
        end
    end
    
    y = fclose(fid);
    
end


%----------------------------------
% 外皮
numOfENVs = length(INPUT.AirConditioningSystem.Envelope);

envelopeID    = cell(1,numOfENVs);
numOfWalls    = zeros(1,numOfENVs);

for iENV = 1:numOfENVs
    
    envelopeID{iENV} = INPUT.AirConditioningSystem.Envelope(iENV).ATTRIBUTE.ACZoneID;
    numOfWalls(iENV) = length(INPUT.AirConditioningSystem.Envelope(iENV).Wall);
    
    for iWALL = 1:numOfWalls(iENV)
        WallConfigure{iENV,iWALL} = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WallConfigure;  % 外壁種類
        WallArea(iENV,iWALL)      = mytfunc_null2value(INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WallArea,0);  % 外皮面積 [m2]
        WindowArea(iENV,iWALL)    = mytfunc_null2value(INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WindowArea,0); % 窓面積 [m2]
        Direction{iENV,iWALL}     = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.Direction;      % 方位
        Blind{iENV,iWALL}         = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.Blind;          % ブラインド
        
        Eaves_Cooling{iENV,iWALL}  = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.Eaves_Cooling;  % 日よけ効果係数（冷房）
        Eaves_Heating{iENV,iWALL}  = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.Eaves_Heating;  % 日よけ効果係数（暖房）
        
        % 外壁タイプNum
        check = 0;
        for iDB = 1:length(confW{iWALL,1})
            if strcmp(confW{iDB,1},WallConfigure{iENV,iWALL})
                WallTypeTemp = WallType{iDB,1};
                check = 1;
                break
            end
        end
        if check == 0
            error('外壁タイプが見つかりません')
        end
        
        if strcmp(WallTypeTemp,'Air')
            WallTypeNum(iENV,iWALL) = 1;
        elseif strcmp(WallTypeTemp,'Ground')
            WallTypeNum(iENV,iWALL) = 2;
        elseif strcmp(WallTypeTemp,'Internal')
            WallTypeNum(iENV,iWALL) = 3;
        end
        
        % 窓種類(ブラインド番号を付ける)
        switch Blind{iENV,iWALL}
            case {'True'}
                WindowType{iENV,iWALL} = strcat(INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WindowType,'_1');
            case {'False'}
                WindowType{iENV,iWALL} = strcat(INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WindowType,'_0');
        end
        
        % EXPS(= 方位＋庇　newHASP用)
        if strcmp(Eaves_Cooling{iENV,iWALL},'Null')
            EXPSdata{iENV,iWALL} = strcat(Direction{iENV,iWALL});
        else
            EXPSdata{iENV,iWALL} = strcat(Direction{iENV,iWALL},Eaves_Cooling{iENV,iWALL});
        end
        
    end
end


%----------------------------------
% 空調機のパラメータ
numOfAHUsTemp = length(INPUT.AirConditioningSystem.AirHandlingUnit);

ahueleID    = cell(1,numOfAHUsTemp);
ahueleName  = cell(1,numOfAHUsTemp);
ahueleType  = cell(1,numOfAHUsTemp);
ahueleCount = zeros(1,numOfAHUsTemp);
ahueleQcmax = zeros(1,numOfAHUsTemp);
ahueleQhmax = zeros(1,numOfAHUsTemp);
ahueleVsa   = zeros(1,numOfAHUsTemp);
ahueleEfsa  = zeros(1,numOfAHUsTemp);
ahueleEfra  = zeros(1,numOfAHUsTemp);
ahueleEfoa  = zeros(1,numOfAHUsTemp);
ahueleEfex  = zeros(1,numOfAHUsTemp);
ahueleFlowControl        = cell(1,numOfAHUsTemp);
ahueleMinDamperOpening   = zeros(1,numOfAHUsTemp);
ahueleOACutCtrl          = cell(1,numOfAHUsTemp);
ahueleFreeCoolingCtrl    = cell(1,numOfAHUsTemp);
ahueleHeatExchangeCtrl   = cell(1,numOfAHUsTemp);
ahueleHeatExchangeEff    = zeros(1,numOfAHUsTemp);
ahueleHeatExchangePower  = zeros(1,numOfAHUsTemp);
ahueleHeatExchangeVolume = zeros(1,numOfAHUsTemp);
ahueleHeatExchangeBypass = cell(1,numOfAHUsTemp);
ahueleRef_cooling  = cell(1,numOfAHUsTemp);
ahueleRef_heating  = cell(1,numOfAHUsTemp);
ahuelePump_cooling = cell(1,numOfAHUsTemp);
ahuelePump_heating = cell(1,numOfAHUsTemp);

for iAHU = 1:numOfAHUsTemp
    
    ahueleID{iAHU}    = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.Name;    % 空調機ID
    ahueleType{iAHU}  = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.Type;  % 空調機タイプ
    
    ahueleCount(iAHU) = mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.Count,1);  % 台数
    
    ahueleQcmax(iAHU) = ahueleCount(iAHU) .* mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.CoolingCapacity,0);  % 定格冷房能力
    ahueleQhmax(iAHU) = ahueleCount(iAHU) .* mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.HeatingCapacity,0);  % 定格暖房能力
    ahueleVsa(iAHU)   = ahueleCount(iAHU) .* mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.SupplyAirVolume,0);  % 給気風量
    ahueleEfsa(iAHU)  = ahueleCount(iAHU) .* mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.SupplyFanPower,0);   % 給気ファン消費電力
    ahueleEfra(iAHU)  = ahueleCount(iAHU) .* mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.ReturnFanPower,0);   % 還気ファン消費電力
    ahueleEfoa(iAHU)  = ahueleCount(iAHU) .* mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.OutsideAirFanPower,0);   % 外気ファン消費電力
    ahueleEfex(iAHU)  = ahueleCount(iAHU) .* mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.ExitFanPower,0);     % 排気ファン消費電力
    
    ahueleFlowControl{iAHU}        = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.FlowControl;            % 風量制御
    ahueleMinDamperOpening(iAHU)   = mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.MinDamperOpening,1);       % VAV最小開度
    ahueleOACutCtrl{iAHU}          = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.OutsideAirCutControl;   % 外気カット制御
    ahueleFreeCoolingCtrl{iAHU}    = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.FreeCoolingControl;     % 外気冷房制御
    
    ahueleHeatExchangeCtrl{iAHU}   = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.HeatExchanger;          % 全熱交換機制御
    ahueleHeatExchangeBypass{iAHU} = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.HeatExchangerBypass;    % 全熱交バイパス有無
    
    ahueleHeatExchangeEff(iAHU)    = mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.HeatExchangerEfficiency,0);  % 全熱交効率
    ahueleHeatExchangePower(iAHU)  = ahueleCount(iAHU) .* mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.HeatExchangerPower,0);     % 全熱交動力
    ahueleHeatExchangeVolume(iAHU) = ahueleCount(iAHU) .* mytfunc_null2value(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.HeatExchangerVolume,0);    % 全熱交風量
    
    ahueleRef_cooling{iAHU}  = strcat(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).HeatSourceSetRef.ATTRIBUTE.CoolingID,'_C');  % 熱源接続（冷房）
    ahueleRef_heating{iAHU}  = strcat(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).HeatSourceSetRef.ATTRIBUTE.HeatingID,'_H');  % 熱源接続（暖房）
    ahuelePump_cooling{iAHU} = strcat(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).SecondaryPumpRef.ATTRIBUTE.CoolingID,'_C');  % ポンプ接続（冷房）
    ahuelePump_heating{iAHU} = strcat(INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).SecondaryPumpRef.ATTRIBUTE.HeatingID,'_H');  % ポンプ接続（暖房）
    
end


%----------------------------------
% ポンプのパラメータ
if isfield(INPUT.AirConditioningSystem,'SecondaryPumpSet')
    
    numOfPumps       = 2*length(INPUT.AirConditioningSystem.SecondaryPumpSet);  % 冷房用と暖房用の2つ作成
    pumpName         = cell(1,numOfPumps);
    pumpdelT         = zeros(1,numOfPumps);
    pumpMode         = cell(1,numOfPumps);
    
    for iPUMP = 1:numOfPumps/2
        
        % 10台以上あれば警告
        if length(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump) > 10
            disp('二次ポンプが10台以上あります。')
            pumpsetPnum(2*iPUMP-1) = 10; % ポンプの数（最大10）
            pumpsetPnum(2*iPUMP)  = 10; % ポンプの数（最大10）
        else
            pumpsetPnum(2*iPUMP-1) = length(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump); % ポンプの数（最大10）
            pumpsetPnum(2*iPUMP)  = length(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump); % ポンプの数（最大10）
        end
        
        % 冷水ポンプ群
        pumpMode{2*iPUMP-1}         = 'Cooling';        % ポンプ運転モード
        pumpName{2*iPUMP-1}         = strcat(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).ATTRIBUTE.Name,'_C');            % ポンプ群名称
        pumpdelT(2*iPUMP-1)         = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).ATTRIBUTE.deltaTemp_Cooling,5);     % ポンプ設計温度差（冷房）
        pumpQuantityCtrl{2*iPUMP-1} = INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).ATTRIBUTE.QuantityControl; % ポンプ台数制御
        
        % 温水ポンプ群
        pumpMode{2*iPUMP}           = 'Heating';        % ポンプ運転モード
        pumpName{2*iPUMP}           = strcat(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).ATTRIBUTE.Name,'_H');            % ポンプ名称
        pumpdelT(2*iPUMP)           = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).ATTRIBUTE.deltaTemp_Heating,5);     % ポンプ設計温度差（暖房）
        pumpQuantityCtrl{2*iPUMP}   = INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).ATTRIBUTE.QuantityControl; % ポンプ台数制御
        
        % 各ポンプの設定
        for iPUMPSUB = 1:pumpsetPnum(2*iPUMP-1)
            for rr = 1:10
                if INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.Order == rr
                    pumpsubCount  = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.Count,0);           % ポンプ台数
                    pumpFlow(2*iPUMP-1,rr)         = pumpsubCount * mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.RatedFlow,0);       % ポンプ流量
                    pumpPower(2*iPUMP-1,rr)        = pumpsubCount * mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.RatedPower,0);      % ポンプ定格電力
                    pumpFlowCtrl{2*iPUMP-1,rr}     = INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.FlowControl;     % ポンプ流量制御
                    pumpMinValveOpening(2*iPUMP-1,rr)  = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.MinValveOpening,0.3);  % VWV時最小流量
                    
                    pumpsubCount  = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.Count,0);           % ポンプ台数
                    pumpFlow(2*iPUMP,rr)           = pumpsubCount * mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.RatedFlow,0);       % ポンプ流量
                    pumpPower(2*iPUMP,rr)          = pumpsubCount * mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.RatedPower,0);      % ポンプ定格電力
                    pumpFlowCtrl{2*iPUMP,rr}       = INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.FlowControl;     % ポンプ流量制御
                    pumpMinValveOpening(2*iPUMP,rr)    = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPumpSet(iPUMP).SecondaryPump(iPUMPSUB).ATTRIBUTE.MinValveOpening,0.3);  % VWV時最小流量
                end
            end
        end
        
    end
else
    numOfPumps = 0;
end

%----------------------------------
% 熱源のパラメータ

numOfRefs = 2*length(INPUT.AirConditioningSystem.HeatSourceSet);  % numOfRefs: 熱源群の数

refsetID           = cell(1,numOfRefs);        % refsetID: 熱源群名称
refsetMode         = cell(1,numOfRefs);        % refsetMode: 運転モード（Cooling or Heating)
refsetSupplyMode   = cell(1,numOfRefs);        % refsetSupplyMode: 冷温同時供給の有無
refsetStorage      = cell(1,numOfRefs);        % refsetStorage: 蓄熱制御方式
refsetStorageSize  = zeros(1,numOfRefs);        % refsetStorageSize: 蓄熱槽容量 [MJ]
refsetQuantityCtrl = cell(1,numOfRefs);        % refsetQuantityCtrl: 台数制御の有無
refsetRnum         = zeros(1,numOfRefs);       % refsetRnum: 熱源群に属する熱源機の総台数
refset_Count       = zeros(numOfRefs,10);      % refset_Count: 同種熱源機の台数
refset_Type        = cell(numOfRefs,10);       % refset_Type: 熱源機の機種
refset_Capacity    = zeros(numOfRefs,10);      % refset_Capacity: 熱源機器の定格能力
refset_MainPower   = zeros(numOfRefs,10);      % refset_MainPower: 熱源主機の定格消費エネルギー
refset_SubPower    = zeros(numOfRefs,10);      % refset_SubPower: 熱源補機の定格消費電力
refset_PrimaryPumpPower = zeros(numOfRefs,10); % refset_PrimaryPumpPower: 一次ポンプの定格消費電力
refset_CTCapacity       = zeros(numOfRefs,10); % refset_CTCapacity: 冷却塔定格能力
refset_CTFanPower       = zeros(numOfRefs,10); % refset_CTFanPower: 冷却塔ファンの定格消費電力
refset_CTPumpPower      = zeros(numOfRefs,10); % refset_CTPumpPower: 冷却塔ポンプの定格消費電力
refset_SupplyTemp       = zeros(numOfRefs,10); % refset_SupplyTemp: 送水温度

for iREF = 1:numOfRefs/2
    
    refsetMode{2*iREF-1}         = 'Cooling';             % 運転モード
    refsetMode{2*iREF}           = 'Heating';             % 運転モード
    refsetID{2*iREF-1}           = strcat(INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.Name,'_C');  % 熱源群名称
    refsetID{2*iREF}             = strcat(INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.Name,'_H');  % 熱源群名称
    refsetSupplyMode{2*iREF-1}   = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.CHmode;             % 冷温同時供給の有無
    refsetSupplyMode{2*iREF}     = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.CHmode;             % 冷温同時供給の有無
    refsetQuantityCtrl{2*iREF-1} = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.QuantityConrol;     % 台数制御
    refsetQuantityCtrl{2*iREF}   = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.QuantityConrol;     % 台数制御
    refsetStorage{2*iREF-1}      = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.StorageMode;        % 蓄熱制御
    refsetStorage{2*iREF}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.StorageMode;        % 蓄熱制御
    refsetStorageSize(2*iREF-1)  = mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.StorageSize,0);        % 蓄熱容量 [MJ]
    refsetStorageSize(2*iREF)    = mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.StorageSize,0);        % 蓄熱容量 [MJ]
    
    if length(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource) > 10
        disp('熱源機器が10台以上あります。')
        refsetRnum(2*iREF-1)         = 10;  % 熱源機器の数（最大10）
        refsetRnum(2*iREF)           = 10;  % 熱源機器の数（最大10）
    else
        refsetRnum(2*iREF-1)         = length(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource);  % 熱源機器の数（最大10）
        refsetRnum(2*iREF)           = length(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource);  % 熱源機器の数（最大10）
    end
    
    for iREFSUB = 1:refsetRnum(2*iREF-1)
        
        for rr = 1:10
            % 冷房
            if INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order_Cooling == rr
                refset_Count(2*iREF-1,rr)      ...
                    = mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count_Cooling,0);      % 台数
                refset_Type{2*iREF-1,rr}       ...
                    = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
                refset_Capacity(2*iREF-1,rr)   ...
                    = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity_Cooling,0);   % 定格能力
                refset_MainPower(2*iREF-1,rr)  ...
                    = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower_Cooling,0);  % 定格消費エネルギー
                refset_SubPower(2*iREF-1,rr)   ...
                    = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower_Cooling,0);   % 定格補機電力
                refset_PrimaryPumpPower(2*iREF-1,rr) ...
                    = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower_Cooling,0);  % 一次ポンプ定格電力
                refset_CTCapacity(2*iREF-1,rr) ...
                    = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTCapacity_Cooling,0);  % 冷却塔能力
                refset_CTFanPower(2*iREF-1,rr) ...
                    = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTFanPower_Cooling,0);  % 冷却塔ファン電力
                refset_CTPumpPower(2*iREF-1,rr) ...
                    = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTPumpPower_Cooling,0); % 冷却塔
                refset_SupplyTemp(2*iREF-1,rr) ...
                    = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SupplyWaterTemp_Cooling,0);   % 送水温度（冷房）
            end
        end
        
        % 暖房
        for rr = 1:10
            if INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order_Heating == rr
                refset_Count(2*iREF,rr)       ...
                    = mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count_Heating,0);      % 台数
                refset_Type{2*iREF,rr}        ...
                    = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
                refset_Capacity(2*iREF,rr)    ...
                    = refset_Count(2*iREF,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity_Heating,0);   % 定格能力
                refset_MainPower(2*iREF,rr)   ...
                    = refset_Count(2*iREF,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower_Heating,0);  % 定格消費エネルギー
                refset_SubPower(2*iREF,rr)    ...
                    = refset_Count(2*iREF,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower_Heating,0);   % 定格補機電力
                refset_PrimaryPumpPower(2*iREF,rr) ...
                    = refset_Count(2*iREF,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower_Heating,0);  % 一次ポンプ定格電力
                refset_SupplyTemp(2*iREF,rr)  ...
                    = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SupplyWaterTemp_Heating,0);   % 送水温度（暖房）
            end
        end
    end
        
end


% 蓄熱ありで「放熱」モードである場合
% 熱源機種に熱交換機(HEX)があるかを検索し、なければ追加。
% さらに運転順位を1つずつずらす。
for iREF = 1:numOfRefs
       
    if strcmp(refsetStorage(iREF),'Discharge')
        
        % 蓄熱容量が空白であった場合は検索して代入
        if refsetStorageSize(iREF) == 0
            for iDB = 1:numOfRefs
                if strcmp(refsetID(iDB),refsetID(iREF)) && strcmp(refsetStorage(iDB),'Charge')
                    refsetStorageSize(iREF) = refsetStorageSize(iDB);
                end
            end
        end
        
        check = 0;
        for iREFSUB = 1:length(refset_Type(iREF,:))
            if strcmp(refset_Type(iREF,iREFSUB),'HEX')
                
                % 熱交換機の大きさをチェック
                tmpCapacity = (storageEff)*refsetStorageSize(iREF)/8*(1000/3600);  % 8時間運転した際のkW
                if refset_Capacity(iREF,iREFSUB) > tmpCapacity
                    refset_Capacity(iREF,iREFSUB) = tmpCapacity;
                end
                check = 1;
            end
        end
        
        % 放熱用装置が無い場合
        if check == 0
            
            refset_Count(iREF,2:11)       = refset_Count(iREF,1:10);
            refset_Type(iREF,2:11)        = refset_Type(iREF,1:10);
            refset_Capacity(iREF,2:11)    = refset_Capacity(iREF,1:10);
            refset_MainPower(iREF,2:11)   = refset_MainPower(iREF,1:10);
            refset_SubPower(iREF,2:11)    = refset_SubPower(iREF,1:10);
            refset_PrimaryPumpPower(iREF,2:11) = refset_PrimaryPumpPower(iREF,1:10);
            refset_CTCapacity(iREF,2:11)  = refset_CTCapacity(iREF,1:10);
            refset_CTFanPower(iREF,2:11)  = refset_CTFanPower(iREF,1:10);
            refset_CTPumpPower(iREF,2:11) = refset_CTPumpPower(iREF,1:10);
            refset_SupplyTemp(iREF,2:11)  = refset_SupplyTemp(iREF,1:10);
            
            % 仮想熱交換機を追加
            refset_Count(iREF,1)       = 1;
            refset_Type{iREF,1}        = 'HEX';
            refset_Capacity(iREF,1)    = (storageEff)*refsetStorageSize(iREF)/8*(1000/3600);  % 8時間運転した際のkW
            refset_MainPower(iREF,1)   = 0;
            refset_SubPower(iREF,1)    = 0;
            refset_PrimaryPumpPower(iREF,1) = 0;
            refset_CTCapacity(iREF,1)  = 0;
            refset_CTFanPower(iREF,1)  = 0;
            refset_CTPumpPower(iREF,1) = 0;
            if strcmp(refsetMode(iREF),'Cooling')
                refset_SupplyTemp(iREF,1)  = 7;
            elseif strcmp(refsetMode(iREF),'Heating')
                refset_SupplyTemp(iREF,1)  = 42;
            end
            
        end
    end
end


