% mytfunc_readXMLSetting.m
%                                                  2011/01/01 by Masato Miyata
%------------------------------------------------------------------------------
% 省エネ基準ルートB：設定ファイル（XMLファイル）を読み込む。
%------------------------------------------------------------------------------

% XMLファイル読込み
INPUT = xml_read(INPUTFILENAME);

% Modelの属性
climateAREA  = INPUT.ATTRIBUTE.Region; % 地域区分
BuildingArea = INPUT.ATTRIBUTE.Area;   % 延床面積 [m2]
BuildingType = INPUT.ATTRIBUTE.Type;   % 建物用途


%----------------------------------
% 室要素のパラメータ

numOfRooomEs = length(INPUT.Rooms.Room);
for iROOMEL = 1:numOfRooomEs
    roomElementName{iROOMEL}   = INPUT.Rooms.Room(iROOMEL).ATTRIBUTE.ID;     % 室ID
    roomElementType{iROOMEL}   = INPUT.Rooms.Room(iROOMEL).ATTRIBUTE.Type;   % 室用途
    roomElementArea(iROOMEL)   = INPUT.Rooms.Room(iROOMEL).ATTRIBUTE.Area;   % 室面積
    roomElementCount(iROOMEL)  = 1;  % 室数
    roomElementFloorHeight(iROOMEL) = INPUT.Rooms.Room(iROOMEL).ATTRIBUTE.FloorHeight; % 階高
    roomElementHeight(iROOMEL) = INPUT.Rooms.Room(iROOMEL).ATTRIBUTE.Height; % 室高
end
    
%----------------------------------
% 空調室のパラメータ
numOfRoooms = length(INPUT.AirConditioningSystem.AirConditioningRoom);
for iROOM = 1:numOfRoooms
    
    roomName{iROOM}   = INPUT.AirConditioningSystem.AirConditioningRoom(iROOM).ATTRIBUTE.ID;           % 空調室ID
    roomElements{iROOM}   = INPUT.AirConditioningSystem.AirConditioningRoom(iROOM).ATTRIBUTE.RoomIDs;  % 室の群｛a,b,c}
    EnvelopeRef{iROOM} = INPUT.AirConditioningSystem.AirConditioningRoom(iROOM).ATTRIBUTE.EnvelopeID;  % 外皮ID
    
    % 空調機ID　＜複数系統・未対応＞
    for iAHU = 1:2
        if strcmp(INPUT.AirConditioningSystem.AirConditioningRoom(iROOM).AirHandlingUnitRef(iAHU).ATTRIBUTE.Load,'Room')
            % 室負荷を処理する空調機ID
            roomAHU_Qroom{iROOM} = INPUT.AirConditioningSystem.AirConditioningRoom(iROOM).AirHandlingUnitRef(iAHU).ATTRIBUTE.ID;
        elseif strcmp(INPUT.AirConditioningSystem.AirConditioningRoom(iROOM).AirHandlingUnitRef(iAHU).ATTRIBUTE.Load,'OutsideAir')
            % 室負荷を処理する空調機ID
            roomAHU_Qoa{iROOM} = INPUT.AirConditioningSystem.AirConditioningRoom(iROOM).AirHandlingUnitRef(iAHU).ATTRIBUTE.ID;
        end
    end
    
end

%----------------------------------
% 外皮
numOfENVs = length(INPUT.AirConditioningSystem.Envelope);
for iENV = 1:numOfENVs
    envelopeID{iENV} = INPUT.AirConditioningSystem.Envelope(iENV).ATTRIBUTE.ID;
    numOfWalls(iENV) = length(INPUT.AirConditioningSystem.Envelope(iENV).Wall);
    for iWALL = 1:numOfWalls(iENV)
        WallConfigure{iENV,iWALL} = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WallConfigure;  % 外壁種類
        WallArea(iENV,iWALL)      = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WallArea;       % 外皮面積 [m2]
        WindowType{iENV,iWALL}    = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WindowType;     % 窓種類
        WindowArea(iENV,iWALL)    = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.WindowArea;     % 窓面積 [m2]
        Direction{iENV,iWALL}     = INPUT.AirConditioningSystem.Envelope(iENV).Wall(iWALL).ATTRIBUTE.Direction;      % 方位
    end
end


%----------------------------------
% 空調機のパラメータ

numOfAHUs = length(INPUT.AirConditioningSystem.AirHandlingUnit);
for iAHU = 1:numOfAHUs
    
    ahuName{iAHU}  = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.ID;    % 空調機ID
    ahuType{iAHU}  = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.Type;  % 空調機タイプ
    
    ahuCount(iAHU) = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.Count;  % 台数
    
    ahuQcmax(iAHU) = ahuCount(iAHU) * INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.CoolingCapacity;  % 定格冷房能力
    ahuQhmax(iAHU) = ahuCount(iAHU) * INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.HeatingCapacity;  % 定格暖房能力
    ahuVsa(iAHU)   = ahuCount(iAHU) * INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.SupplyAirVolume;  % 給気風量
    ahuEfsa(iAHU)  = ahuCount(iAHU) * INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.SupplyFanPower;   % 給気ファン消費電力
    ahuEfra(iAHU)  = ahuCount(iAHU) * INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.ReturnFanPower;   % 還気ファン消費電力
    ahuEfoa(iAHU)  = ahuCount(iAHU) * INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.OutsideAirFanPower;   % 外気ファン消費電力
    
    ahuFlowControl{iAHU}       = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.FlowControl;           % 風量制御
    ahuMinDamperOpening(iAHU)  = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.MinDamperOpening;      % VAV最小開度
    ahuOACutCtrl{iAHU}         = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.OutsideAirCutControl;  % 外気カット制御
    ahuFreeCoolingCtrl{iAHU}   = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.FreeCoolingControl;    % 外気冷房制御
    ahuHeatExchangeCtrl{iAHU}  = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.HeatExchanger;          % 全熱交換機制御
    ahuHeatExchangeEff(iAHU)   = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.HeatExchangerEfficiency;  % 全熱交効率
    ahuHeatExchangePower(iAHU) = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).ATTRIBUTE.HeatExchangerPower;    % 全熱交動力
    
    ahuRef_cooling{iAHU}  = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).HeatSourceSetRef.ATTRIBUTE.CoolingID;  % 熱源接続（冷房）
    ahuRef_heating{iAHU}  = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).HeatSourceSetRef.ATTRIBUTE.HeatingID;  % 熱源接続（暖房）
    ahuPump_cooling{iAHU} = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).SecondaryPumpRef.ATTRIBUTE.CoolingID;  % ポンプ接続（冷房）
    ahuPump_heating{iAHU} = INPUT.AirConditioningSystem.AirHandlingUnit(iAHU).SecondaryPumpRef.ATTRIBUTE.HeatingID;  % ポンプ接続（暖房）
    
end


%----------------------------------
% ポンプのパラメータ
if isfield(INPUT.AirConditioningSystem,'SecondaryPump')
    numOfPumps = length(INPUT.AirConditioningSystem.SecondaryPump);
    for iPUMP = 1:numOfPumps
        pumpName{iPUMP}         = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.ID;          % ポンプ名称
        pumpMode{iPUMP}         = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.Mode;        % ポンプ運転モード
        pumpCount(iPUMP)        = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.Count;       % ポンプ台数
        pumpFlow(iPUMP)         = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.RatedFlow;   % ポンプ流量
        pumpPower(iPUMP)        = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.RatedPower;  % ポンプ定格電力
        pumpFlowCtrl{iPUMP}     = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.FlowControl; % ポンプ流量制御
        pumpQuantityCtrl{iPUMP} = INPUT.AirConditioningSystem.SecondaryPump(iPUMP).ATTRIBUTE.QuantityControl; % ポンプ台数制御
    end
else
    numOfPumps = 0;
end


%----------------------------------
% 熱源のパラメータ

numOfRefs = length(INPUT.AirConditioningSystem.HeatSourceSet);
for iREF = 1:numOfRefs
    
    refsetID{iREF}           = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.ID;               % 熱源群名称
    refsetMode{iREF}         = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.Mode;             % 運転モード
    refsetStorage{iREF}      = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.ThermalStorage;   % 蓄熱制御
    refsetQuantityCtrl{iREF} = INPUT.AirConditioningSystem.HeatSourceSet(iREF).ATTRIBUTE.QuantityControl;  % 台数制御
    
    refsetRnum(iREF) = length(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource);  % 熱源機器の数（最大3）
    for iREFSUB = 1:refsetRnum(iREF)
        if strcmp(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order,'First')
            refset_Count(iREF,1)       = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count;      % 台数
            refset_Type{iREF,1}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
            refset_Capacity(iREF,1)    = refset_Count(iREF,1) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity;   % 定格能力
            refset_MainPower(iREF,1)   = refset_Count(iREF,1) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower;  % 定格消費エネルギー
            refset_SubPower(iREF,1)    = refset_Count(iREF,1) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower;   % 定格補機電力
            refset_PrimaryPumpPower(iREF,1) = refset_Count(iREF,1) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower;  % 一次ポンプ定格電力
            refset_CTCapacity(iREF,1)  = refset_Count(iREF,1) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTCapacity;  % 冷却塔能力
            refset_CTFanPower(iREF,1)  = refset_Count(iREF,1) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTFanPower;  % 冷却塔ファン電力
            refset_CTPumpPower(iREF,1) = refset_Count(iREF,1) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTPumpPower; % 冷却塔
        elseif strcmp(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order,'Second')
            refset_Count(iREF,2)       = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count;      % 台数
            refset_Type{iREF,2}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
            refset_Capacity(iREF,2)    = refset_Count(iREF,2) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity;   % 定格能力
            refset_MainPower(iREF,2)   = refset_Count(iREF,2) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower;  % 定格消費エネルギー
            refset_SubPower(iREF,2)    = refset_Count(iREF,2) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower;   % 定格補機電力
            refset_PrimaryPumpPower(iREF,2) = refset_Count(iREF,2) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower;  % 一次ポンプ定格電力
            refset_CTCapacity(iREF,2)  = refset_Count(iREF,2) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTCapacity;  % 冷却塔能力
            refset_CTFanPower(iREF,2)  = refset_Count(iREF,2) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTFanPower;  % 冷却塔ファン電力
            refset_CTPumpPower(iREF,2) = refset_Count(iREF,2) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTPumpPower; % 冷却塔
        elseif strcmp(INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Order,'Third')
            refset_Count(iREF,3)       = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Count;      % 台数
            refset_Type{iREF,3}        = INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Type;       % 熱源機種
            refset_Capacity(iREF,3)    = refset_Count(iREF,3) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.Capacity;   % 定格能力
            refset_MainPower(iREF,3)   = refset_Count(iREF,3) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.MainPower;  % 定格消費エネルギー
            refset_SubPower(iREF,3)    = refset_Count(iREF,3) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.SubPower;   % 定格補機電力
            refset_PrimaryPumpPower(iREF,3) = refset_Count(iREF,3) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.PrimaryPumpPower;  % 一次ポンプ定格電力
            refset_CTCapacity(iREF,3)  = refset_Count(iREF,3) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTCapacity;  % 冷却塔能力
            refset_CTFanPower(iREF,3)  = refset_Count(iREF,3) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTFanPower;  % 冷却塔ファン電力
            refset_CTPumpPower(iREF,3) = refset_Count(iREF,3) * INPUT.AirConditioningSystem.HeatSourceSet(iREF).HeatSource(iREFSUB).ATTRIBUTE.CTPumpPower; % 冷却塔
        end
    end
    
end
