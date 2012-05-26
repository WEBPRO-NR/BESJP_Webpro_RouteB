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
% 外皮
numOfENVs = length(INPUT.AirConditioningSystem.Envelope);

envelopeID    = cell(1,numOfENVs);
numOfWalls    = zeros(1,numOfENVs);
WallConfigure = cell(1,numOfENVs);
WallArea      = zeros(1,numOfENVs);
WindowType    = cell(1,numOfENVs);
WindowArea    = zeros(1,numOfENVs);
Direction     = cell(1,numOfENVs);
Blind         = cell(1,numOfENVs);
Eaves         = cell(1,numOfENVs);

for iENV = 1:numOfENVs
    envelopeID{iENV} = INPUT.AirConditioningSystem.Envelope(iENV).ATTRIBUTE.ACZoneID;
    numOfWalls(iENV) = length(INPUT.AirConditioningSystem.Envelope(iENV).Wall);
    for iWALL = 1:numOfWalls(iENV)
        WallConfigure{iENV,iWALL} = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WallConfigure;  % 外壁種類
        WallArea(iENV,iWALL)      = mytfunc_null2value(INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WallArea,0);  % 外皮面積 [m2]
        WindowType{iENV,iWALL}    = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WindowType;     % 窓種類
        WindowArea(iENV,iWALL)    = mytfunc_null2value(INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WindowArea,0); % 窓面積 [m2]
        Direction{iENV,iWALL}     = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.Direction;      % 方位
        Blind{iENV,iWALL}         = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.Blind;          % ブラインド
        Eaves{iENV,iWALL}         = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.Eaves;          % 庇
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
    
    ahueleID{iAHU}    = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.ID;    % 空調機ID
%     ahueleName{iAHU}  = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.Name;    % 空調機ID
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
if isfield(INPUT.AirConditioningSystem,'SecondaryPump')
    
    numOfPumps       = 2*length(INPUT.AirConditioningSystem.SecondaryPump);
    pumpName         = cell(1,numOfPumps);
    pumpSystem       = cell(1,numOfPumps);
    pumpMode         = cell(1,numOfPumps);
    pumpCount        = zeros(1,numOfPumps);
    pumpFlow         = zeros(1,numOfPumps);
    pumpPower        = zeros(1,numOfPumps);
    pumpFlowCtrl     = cell(1,numOfPumps);
    pumpQuantityCtrl = cell(1,numOfPumps);
    pumpdelT         = zeros(1,numOfPumps);
    pumpMinValveOpening = zeros(1,numOfPumps);
    
    for iPUMP = 1:numOfPumps/2
                
        % 冷水ポンプ
        pumpMode{2*iPUMP-1}         = 'Cooling';        % ポンプ運転モード
        pumpName{2*iPUMP-1}         = strcat(INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.Name,'_C');            % ポンプ名称
        pumpSystem{2*iPUMP-1}       = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.System;          % ポンプシステム
        pumpCount(2*iPUMP-1)        = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.Count,0);           % ポンプ台数
        pumpFlow(2*iPUMP-1)         = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.RatedFlow,0);       % ポンプ流量
        pumpPower(2*iPUMP-1)        = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.RatedPower,0);      % ポンプ定格電力
        pumpFlowCtrl{2*iPUMP-1}     = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.FlowControl;     % ポンプ流量制御
        pumpQuantityCtrl{2*iPUMP-1} = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.QuantityControl; % ポンプ台数制御
        pumpdelT(2*iPUMP-1)         = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.deltaTemp_Cooling,5);     % ポンプ設計温度差（冷房）
        pumpMinValveOpening(2*iPUMP-1)  = 0.3;
        
        % 温水ポンプ
        pumpMode{2*iPUMP}           = 'Heating';        % ポンプ運転モード
        pumpName{2*iPUMP}           = strcat(INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.Name,'_H');            % ポンプ名称
        pumpSystem{2*iPUMP}         = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.System;          % ポンプシステム
        pumpCount(2*iPUMP)          = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.Count,0);           % ポンプ台数
        pumpFlow(2*iPUMP)           = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.RatedFlow,0);       % ポンプ流量
        pumpPower(2*iPUMP)          = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.RatedPower,0);      % ポンプ定格電力
        pumpFlowCtrl{2*iPUMP}       = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.FlowControl;     % ポンプ流量制御
        pumpQuantityCtrl{2*iPUMP}   = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.QuantityControl; % ポンプ台数制御
        pumpdelT(2*iPUMP)           = mytfunc_null2value(INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.deltaTemp_Heating,5);     % ポンプ設計温度差（暖房）
        pumpMinValveOpening(2*iPUMP) = 0.3;
                
    end
else
    numOfPumps = 0;
end


%----------------------------------
% 熱源のパラメータ

numOfRefs = 2*length(INPUT.AirConditioningSystem.HeatSourceSet);

refsetID           = cell(1,numOfRefs);
refsetMode         = cell(1,numOfRefs);
refsetSupplyMode   = cell(1,numOfRefs);
refsetStorage      = cell(1,numOfRefs);
refsetQuantityCtrl = cell(1,numOfRefs);
refsetRnum         = zeros(1,numOfRefs);
refset_Count       = zeros(numOfRefs,3);
refset_Type        = cell(numOfRefs,3);
refset_Capacity    = zeros(numOfRefs,3);
refset_MainPower   = zeros(numOfRefs,3);
refset_SubPower    = zeros(numOfRefs,3);
refset_PrimaryPumpPower = zeros(numOfRefs,3);
refset_CTCapacity       = zeros(numOfRefs,3);
refset_CTFanPower       = zeros(numOfRefs,3);
refset_CTPumpPower      = zeros(numOfRefs,3);
refsetSupplyTemp   = zeros(1,numOfRefs);

for iREF = 1:numOfRefs/2
    
    refsetMode{2*iREF-1}         = 'Cooling';             % 運転モード
    refsetMode{2*iREF}           = 'Heating';             % 運転モード
    refsetID{2*iREF-1}           = strcat(INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.Name,'_C');  % 熱源群名称
    refsetID{2*iREF}             = strcat(INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.Name,'_H');  % 熱源群名称
    refsetSupplyMode{2*iREF-1}   = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.SupplyMode;  % 冷温同時供給の有無
    refsetSupplyMode{2*iREF}     = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.SupplyMode;  % 冷温同時供給の有無
    refsetStorage{2*iREF-1}      = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.ThermalStorage_Cooling;   % 蓄熱制御
    refsetStorage{2*iREF}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.ThermalStorage_Heating;   % 蓄熱制御
    refsetQuantityCtrl{2*iREF-1} = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.QuantityControl_Cooling;  % 台数制御
    refsetQuantityCtrl{2*iREF}   = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.QuantityControl_Heating;  % 台数制御
    refsetSupplyTemp(2*iREF-1)   = 7;  % 送水温度
    refsetSupplyTemp(2*iREF)     = 42; % 送水温度
    
    
    if length(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource) > 10
        disp('熱源機器が10台以上あります。')
        refsetRnum(2*iREF-1)         = 10;  % 熱源機器の数（最大3）
        refsetRnum(2*iREF)           = 10;  % 熱源機器の数（最大3）
    else
        refsetRnum(2*iREF-1)         = length(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource);  % 熱源機器の数（最大3）
        refsetRnum(2*iREF)           = length(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource);  % 熱源機器の数（最大3）
    end
    
    for iREFSUB = 1:refsetRnum(2*iREF-1)
        
        for rr = 1:10
            % 冷房
            if INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order_Cooling == rr
                refset_Count(2*iREF-1,rr)       = mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count_Cooling,0);      % 台数
                refset_Type{2*iREF-1,rr}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
                refset_Capacity(2*iREF-1,rr)         = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity_Cooling,0);   % 定格能力
                refset_MainPower(2*iREF-1,rr)        = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower_Cooling,0);  % 定格消費エネルギー
                refset_SubPower(2*iREF-1,rr)         = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower_Cooling,0);   % 定格補機電力
                refset_PrimaryPumpPower(2*iREF-1,rr) = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower_Cooling,0);  % 一次ポンプ定格電力
                refset_CTCapacity(2*iREF-1,rr)       = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTCapacity_Cooling,0);  % 冷却塔能力
                refset_CTFanPower(2*iREF-1,rr)       = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTFanPower_Cooling,0);  % 冷却塔ファン電力
                refset_CTPumpPower(2*iREF-1,rr)      = refset_Count(2*iREF-1,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTPumpPower_Cooling,0); % 冷却塔
            end
            %         elseif INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order_Cooling == 2
            %             refset_Count(2*iREF-1,2)       = mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count_Cooling,0);      % 台数
            %             refset_Type{2*iREF-1,2}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
            %             refset_Capacity(2*iREF-1,2)    = refset_Count(2*iREF-1,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity_Cooling,0);   % 定格能力
            %             refset_MainPower(2*iREF-1,2)   = refset_Count(2*iREF-1,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower_Cooling,0);  % 定格消費エネルギー
            %             refset_SubPower(2*iREF-1,2)    = refset_Count(2*iREF-1,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower_Cooling,0);   % 定格補機電力
            %             refset_PrimaryPumpPower(2*iREF-1,2) = refset_Count(2*iREF-1,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower_Cooling,0);  % 一次ポンプ定格電力
            %             refset_CTCapacity(2*iREF-1,2)  = refset_Count(2*iREF-1,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTCapacity_Cooling,0);  % 冷却塔能力
            %             refset_CTFanPower(2*iREF-1,2)  = refset_Count(2*iREF-1,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTFanPower_Cooling,0);  % 冷却塔ファン電力
            %             refset_CTPumpPower(2*iREF-1,2) = refset_Count(2*iREF-1,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTPumpPower_Cooling,0); % 冷却塔
            %
            %         elseif INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order_Cooling == 3
            %             refset_Count(2*iREF-1,3)       = mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count_Cooling,0);      % 台数
            %             refset_Type{2*iREF-1,3}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
            %             refset_Capacity(2*iREF-1,3)    = refset_Count(2*iREF-1,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity_Cooling,0);   % 定格能力
            %             refset_MainPower(2*iREF-1,3)   = refset_Count(2*iREF-1,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower_Cooling,0);  % 定格消費エネルギー
            %             refset_SubPower(2*iREF-1,3)    = refset_Count(2*iREF-1,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower_Cooling,0);   % 定格補機電力
            %             refset_PrimaryPumpPower(2*iREF-1,3) = refset_Count(2*iREF-1,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower_Cooling,0);  % 一次ポンプ定格電力
            %             refset_CTCapacity(2*iREF-1,3)  = refset_Count(2*iREF-1,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTCapacity_Cooling,0);  % 冷却塔能力
            %             refset_CTFanPower(2*iREF-1,3)  = refset_Count(2*iREF-1,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTFanPower_Cooling,0);  % 冷却塔ファン電力
            %             refset_CTPumpPower(2*iREF-1,3) = refset_Count(2*iREF-1,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTPumpPower_Cooling,0); % 冷却塔
        end
        
        % 暖房
        for rr = 1:10
            if INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order_Heating == rr
                refset_Count(2*iREF,rr)       = mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count_Heating,0);      % 台数
                refset_Type{2*iREF,rr}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
                refset_Capacity(2*iREF,rr)         = refset_Count(2*iREF,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity_Heating,0);   % 定格能力
                refset_MainPower(2*iREF,rr)        = refset_Count(2*iREF,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower_Heating,0);  % 定格消費エネルギー
                refset_SubPower(2*iREF,rr)         = refset_Count(2*iREF,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower_Heating,0);   % 定格補機電力
                refset_PrimaryPumpPower(2*iREF,rr) = refset_Count(2*iREF,rr) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower_Heating,0);  % 一次ポンプ定格電力
            end
            %         elseif INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order_Heating == 2
            %             refset_Count(2*iREF,2)       = mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count_Heating,0);      % 台数
            %             refset_Type{2*iREF,2}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
            %             refset_Capacity(2*iREF,2)    = refset_Count(2*iREF,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity_Heating,0);   % 定格能力
            %             refset_MainPower(2*iREF,2)   = refset_Count(2*iREF,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower_Heating,0);  % 定格消費エネルギー
            %             refset_SubPower(2*iREF,2)    = refset_Count(2*iREF,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower_Heating,0);   % 定格補機電力
            %             refset_PrimaryPumpPower(2*iREF,2) = refset_Count(2*iREF,2) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower_Heating,0);  % 一次ポンプ定格電力
            %
            %         elseif INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order_Heating == 3
            %             refset_Count(2*iREF,3)       = mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count_Heating,0);      % 台数
            %             refset_Type{2*iREF,3}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
            %             refset_Capacity(2*iREF,3)    = refset_Count(2*iREF,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity_Heating,0);   % 定格能力
            %             refset_MainPower(2*iREF,3)   = refset_Count(2*iREF,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower_Heating,0);  % 定格消費エネルギー
            %             refset_SubPower(2*iREF,3)    = refset_Count(2*iREF,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower_Heating,0);   % 定格補機電力
            %             refset_PrimaryPumpPower(2*iREF,3) = refset_Count(2*iREF,3) * mytfunc_null2value(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower_Heating,0);  % 一次ポンプ定格電力
            %
        end
        
    end
end
