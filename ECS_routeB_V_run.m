% ECS_routeB_V_run.m
%                                          by Masato Miyata 2011/04/20
%----------------------------------------------------------------------
% 省エネ基準：換気計算プログラム
%----------------------------------------------------------------------
% 入力
%  inputfilename : XMLファイル名称
%  OutputOption  : 出力制御（ON: 詳細出力、OFF: 簡易出力）
% 出力
%  y(1) : 評価値 [MWh/年]
%  y(2) : 評価値 [MWh/m2/年]
%  y(3) : 評価値 [MJ/年]
%  y(4) : 評価値 [MJ/m2/年]
%  y(5) : 基準値 [MWh/年]
%  y(6) : 基準値 [MWh/m2/年]
%  y(7) : 基準値 [MJ/年]
%  y(8) : 基準値 [MJ/m2/年]
%  y(9) : BEI (=評価値/基準値） [-]
%----------------------------------------------------------------------
function y = ECS_routeB_V_run(inputfilename,OutputOption)

% clear
% clc
% addpath('./subfunction')
% inputfilename = './InputFiles/1005_コジェネテスト/model_CGS_case00.xml';
% OutputOption = 'OFF';


%% 設定
model = xml_read(inputfilename);

switch OutputOption
    case 'ON'
        OutputOptionVar = 1;
    case 'OFF'
        OutputOptionVar = 0;
    otherwise
        error('OutputOptionが不正です。ON か OFF で指定して下さい。')
end

% データベース読み込み
mytscript_readDBfiles;

climateAREA  = num2str(model.ATTRIBUTE.Region);   % 地域区分
switch climateAREA
    case {'1'}
        Toa_ave_design = 22.7;
    case {'2'}
        Toa_ave_design = 22.5;
    case {'3'}
        Toa_ave_design = 24.7;
    case {'4'}
        Toa_ave_design = 27.1;
    case {'5'}
        Toa_ave_design = 26.7;
    case {'6'}
        Toa_ave_design = 27.5;
    case {'7'}
        Toa_ave_design = 25.8;
    case {'8'}
        Toa_ave_design = 26.2;
end


%% 情報抽出

% 換気対象室数
numOfRoom =  length(model.VentilationSystems.VentilationRoom);

BldgType   = cell(numOfRoom,1);
RoomType   = cell(numOfRoom,1);
RoomFloor  = cell(numOfRoom,1);
RoomName   = cell(numOfRoom,1);
RoomArea   = zeros(numOfRoom,1);
numOfVfan  = zeros(numOfRoom,1);
numOfVac   = zeros(numOfRoom,1);

for iROOM = 1:numOfRoom
    
    % 建物用途
    BldgType{iROOM} = model.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.BuildingType;
    % 室用途
    RoomType{iROOM} = model.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.RoomType;
    % 階数
    RoomFloor{iROOM} = model.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.RoomFloor;
    % 室名
    RoomName{iROOM}  = model.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.RoomName;
    % 室面積
    RoomArea(iROOM)  = model.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.RoomArea;
    
    % 接続されているユニット数（送風機＋空調機）
    numOfVtotal(iROOM) = length(model.VentilationSystems.VentilationRoom(iROOM).VentilationUnitRef);
    
    numOfVfan(iROOM)   = 0;
    numOfVAC(iROOM)    = 0;
    
    for iUNIT = 1:numOfVtotal(iROOM)
        
        % 機器名称
        unitName = model.VentilationSystems.VentilationRoom(iROOM).VentilationUnitRef(iUNIT).ATTRIBUTE.Name;
        unitType = model.VentilationSystems.VentilationRoom(iROOM).VentilationUnitRef(iUNIT).ATTRIBUTE.UnitType;
        
        check = 0;
        if isfield(model.VentilationSystems,'VentilationFANUnit')
            for iDB = 1:length(model.VentilationSystems.VentilationFANUnit)
                
                if strcmp(unitName,model.VentilationSystems.VentilationFANUnit(iDB).ATTRIBUTE.Name)
                    
                    check = 1;
                    numOfVfan(iROOM) = numOfVfan(iROOM) + 1;
                    
                    % 機器名称
                    UnitNameFAN{iROOM,numOfVfan(iROOM)} = unitName;
                    UnitTypeFAN{iROOM,numOfVfan(iROOM)} = unitType;
                    
                    % 送風量
                    if strcmp(model.VentilationSystems.VentilationFANUnit(iDB).ATTRIBUTE.FanVolume,'Null') == 0
                        FanVolumeFAN(iROOM,numOfVfan(iROOM)) = model.VentilationSystems.VentilationFANUnit(iDB).ATTRIBUTE.FanVolume;
                    else
                        FanVolumeFAN(iROOM,numOfVfan(iROOM)) = 0;
                    end
                    
                    % 消費電力
                    if strcmp(model.VentilationSystems.VentilationFANUnit(iDB).ATTRIBUTE.FanPower,'Null') == 0
                        FanPowerFAN(iROOM,numOfVfan(iROOM)) = model.VentilationSystems.VentilationFANUnit(iDB).ATTRIBUTE.FanPower;
                    else
                        FanPowerFAN(iROOM,numOfVfan(iROOM)) = 0;
                    end
                    
                    ControlFlag_C1{iROOM,numOfVfan(iROOM)} = model.VentilationSystems.VentilationFANUnit(iDB).ATTRIBUTE.ControlFlag_C1;
                    ControlFlag_C2{iROOM,numOfVfan(iROOM)} = model.VentilationSystems.VentilationFANUnit(iDB).ATTRIBUTE.ControlFlag_C2;
                    ControlFlag_C3{iROOM,numOfVfan(iROOM)} = model.VentilationSystems.VentilationFANUnit(iDB).ATTRIBUTE.ControlFlag_C3;
                    
                end
                
            end
        end
        
        if isfield(model.VentilationSystems,'VentilationACUnit')
            for iDB = 1:length(model.VentilationSystems.VentilationACUnit)
                
                if strcmp(unitName,model.VentilationSystems.VentilationACUnit(iDB).ATTRIBUTE.Name)
                    
                    if check == 1
                        error('名称の重複があります')
                    else
                        
                        check = 1;
                        numOfVac(iROOM) = numOfVac(iROOM) + 1;
                        
                        % 機器名称
                        UnitNameAC{iROOM,numOfVac(iROOM)} = unitName;
                        UnitTypeAC{iROOM,numOfVac(iROOM)} = model.VentilationSystems.VentilationACUnit(iDB).ATTRIBUTE.roomType;
                        
                        % 必要冷却能力
                        if strcmp(model.VentilationSystems.VentilationACUnit(iDB).ATTRIBUTE.CoolingCapacity,'Null') == 0
                            CoolingCapacityAC(iROOM,numOfVac(iROOM)) = model.VentilationSystems.VentilationACUnit(iDB).ATTRIBUTE.CoolingCapacity;
                        else
                            CoolingCapacityAC(iROOM,numOfVac(iROOM)) = 0;
                        end
                        
                        % 熱源効率
                        if strcmp(model.VentilationSystems.VentilationACUnit(iDB).ATTRIBUTE.COP,'Null') == 0
                            COPAC(iROOM,numOfVac(iROOM)) = model.VentilationSystems.VentilationACUnit(iDB).ATTRIBUTE.COP;
                        else
                            COPAC(iROOM,numOfVac(iROOM)) = 0;
                        end
                        
                        % ポンプ消費電力
                        if strcmp(model.VentilationSystems.VentilationACUnit(iDB).ATTRIBUTE.PumpPower,'Null') == 0
                            PumpPowerAC(iROOM,numOfVac(iROOM)) = model.VentilationSystems.VentilationACUnit(iDB).ATTRIBUTE.PumpPower;
                        else
                            PumpPowerAC(iROOM,numOfVac(iROOM)) = 0;
                        end
                        
                        % 送風機の数
                        if isfield(model.VentilationSystems.VentilationACUnit(iDB), 'Fan') == 0
                            
                            numFacAC(iROOM,numOfVac(iROOM)) = 0;
                            
                        else
                            numFacAC(iROOM,numOfVac(iROOM)) = length(model.VentilationSystems.VentilationACUnit(iDB).Fan);
                            
                            for iFanAC = 1:numFacAC(iROOM,numOfVac(iROOM))
                                
                                FanTypeAC{iROOM,numOfVac(iROOM),iFanAC}    = model.VentilationSystems.VentilationACUnit(iDB).Fan(iFanAC).ATTRIBUTE.FanType;
                                FanVolumeAC(iROOM,numOfVac(iROOM),iFanAC)  = model.VentilationSystems.VentilationACUnit(iDB).Fan(iFanAC).ATTRIBUTE.FanVolume;
                                FanPowerAC(iROOM,numOfVac(iROOM),iFanAC)   = model.VentilationSystems.VentilationACUnit(iDB).Fan(iFanAC).ATTRIBUTE.FanPower;
                                FanCtrlAC_C1{iROOM,numOfVac(iROOM),iFanAC} = model.VentilationSystems.VentilationACUnit(iDB).Fan(iFanAC).ATTRIBUTE.ControlFlag_C1;
                                FanCtrlAC_C2{iROOM,numOfVac(iROOM),iFanAC} = model.VentilationSystems.VentilationACUnit(iDB).Fan(iFanAC).ATTRIBUTE.ControlFlag_C2;
                                FanCtrlAC_C3{iROOM,numOfVac(iROOM),iFanAC} = model.VentilationSystems.VentilationACUnit(iDB).Fan(iFanAC).ATTRIBUTE.ControlFlag_C3;
                                
                            end
                        end
                        
                    end
                end
            end
        end
        
        if check == 0
            unitName
            error('機器が見つかりません')
        end
        
        if numOfVfan(iROOM) == 0
            UnitNameFAN{iROOM,1}  = [];
            UnitTypeFAN{iROOM,1}  = [];
            FanVolumeFAN(iROOM,1) = 0;
            FanPowerFAN(iROOM,1)  = 0;
            ControlFlag_C1{iROOM,1}  = 'None';
            ControlFlag_C2{iROOM,1}  = 'None';
            ControlFlag_C3{iROOM,1}  = 'None';
        end
        
        if numOfVac(iROOM) == 0
            UnitNameAC{iROOM,1}  = [];
            UnitTypeAC{iROOM,1}  = [];
            CoolingCapacityAC(iROOM,1) = 0;
            COPAC(iROOM,1)       = 0;
            FanPowerAC(iROOM,1)  = 0;
            PumpPowerAC(iROOM,1) = 0;
            numFacAC(iROOM,1) = 0;
        end
        
    end
end


%% 各室の換気時間・基準値を探査
timeV  = zeros(numOfRoom,1);
kv     = zeros(numOfRoom,1);
Vroom  = zeros(numOfRoom,1);
Proom  = zeros(numOfRoom,1);
Eme    = zeros(numOfRoom,1);
Es_2nd = zeros(numOfRoom,1);
Es_1st = zeros(numOfRoom,1);
xL     = zeros(numOfRoom,1);

opeMode_Vroom = zeros(numOfRoom,365,24);

for iROOM = 1:numOfRoom
    
    % 標準室使用条件を探索
    for iDB = 1:length(perDB_RoomType)
        if strcmp(perDB_RoomType{iDB,2},BldgType{iROOM}) && ...
                strcmp(perDB_RoomType{iDB,5},RoomType{iROOM})
            
            % 換気時間 [hour]
            timeV(iROOM) = str2double(perDB_RoomType(iDB,26));
            
            % 換気スケジュール（時刻別）
            [opeMode_Vroom(iROOM,:,:),~,~] = mytfunc_getRoomCondition(perDB_RoomType,perDB_RoomOpeCondition,perDB_calendar,BldgType{iROOM},RoomType{iROOM});
            
            % 基準設定消費電力 [kW]
            if strcmp(perDB_RoomType(iDB,27),'-')
                error('室用途「 %s 」は換気対象室ではありません',strcat(BldgType{iROOM},':',RoomType{iROOM}))
            else
                
                % 換気方式
                if strcmp(perDB_RoomType(iDB,27),'第一種')
                    kv(iROOM) = 2;
                else
                    kv(iROOM) = 1;
                end
                
                % 基準設定換気風量 [m3/m2/h]
                Vroom(iROOM) = str2double(perDB_RoomType(iDB,28));
                % 基準設定全圧損失 [Pa]
                Proom(iROOM) = str2double(perDB_RoomType(iDB,29));
                
                %                 % 負荷率
                %                 if strcmp(RoomType{iROOM},'電気・機械室（高発熱）') || strcmp(RoomType{iROOM},'機械室')
                %                     xL(iROOM) = 0.6;
                %                 elseif strcmp(RoomType{iROOM},'電気・機械室（標準）') || strcmp(RoomType{iROOM},'電気室')
                %                     xL(iROOM) = 0.6;
                %                 else
                %                     xL(iROOM) = 1;
                %                 end
                
            end
        end
    end
end


%% 制御補正係数の決定

for iROOM = 1:numOfRoom
    
    if numOfVfan(iROOM)>0
        
        for iVFAN = 1:numOfVfan(iROOM)
            
            if strcmp(ControlFlag_C1(iROOM,iVFAN),'None')
                hosei_C1(iROOM,iVFAN) = 1;
                hosei_C1_name{iROOM,iVFAN} = ' ';
            elseif strcmp(ControlFlag_C1(iROOM,iVFAN),'True')
                hosei_C1(iROOM,iVFAN) = 0.95;
                hosei_C1_name{iROOM,iVFAN} = '有';
            else
                error('高効率モータの設定が不正です。')
            end
            
            if strcmp(ControlFlag_C2(iROOM,iVFAN),'None')
                hosei_C2(iROOM,iVFAN) = 1;
                hosei_C2_name{iROOM,iVFAN} = ' ';
            elseif strcmp(ControlFlag_C2(iROOM,iVFAN),'True')
                hosei_C2(iROOM,iVFAN) = 0.6;
                hosei_C2_name{iROOM,iVFAN} = '有';
            else
                error('インバータの設定が不正です。')
            end
            
            if strcmp(ControlFlag_C3(iROOM,iVFAN),'None')
                hosei_C3(iROOM,iVFAN) = 1;
                hosei_C3_name{iROOM,iVFAN} = ' ';
            elseif strcmp(ControlFlag_C3(iROOM,iVFAN),'COconcentration')
                hosei_C3(iROOM,iVFAN) = 0.6;
                hosei_C3_name{iROOM,iVFAN} = 'CO制御';
            elseif strcmp(ControlFlag_C3(iROOM,iVFAN),'Temprature')
                hosei_C3(iROOM,iVFAN) = 0.7;
                hosei_C3_name{iROOM,iVFAN} = '温度制御';
            else
                error('送風量制御の設定が不正です。')
            end
            
            hosei_ALL(iROOM,iVFAN) = hosei_C1(iROOM,iVFAN)*hosei_C2(iROOM,iVFAN)*hosei_C3(iROOM,iVFAN);
            
        end
    end
    
    % 換気代替空調機に属するファンの制御（2016/4/13追加）
    if numOfVac(iROOM) > 0
        for iAC = 1:numOfVac(iROOM)
            
            if  numFacAC(iROOM,iAC) > 0
                
                for iFanAC = 1:numFacAC(iROOM,iAC)
                    
                    if strcmp(FanCtrlAC_C1(iROOM,iAC,iFanAC),'None')
                        hoseiAC_C1(iROOM,iAC,iFanAC) = 1;
                    elseif strcmp(FanCtrlAC_C1(iROOM,iAC,iFanAC),'True')
                        hoseiAC_C1(iROOM,iAC,iFanAC) = 0.95;
                    else
                        error('高効率モータの設定が不正です。')
                    end
                    
                    if strcmp(FanCtrlAC_C2(iROOM,iAC,iFanAC),'None')
                        hoseiAC_C2(iROOM,iAC,iFanAC) = 1;
                    elseif strcmp(FanCtrlAC_C2(iROOM,iAC,iFanAC),'True')
                        hoseiAC_C2(iROOM,iAC,iFanAC) = 0.6;
                    else
                        error('インバータの設定が不正です。')
                    end
                    
                    if strcmp(FanCtrlAC_C3(iROOM,iAC,iFanAC),'None')
                        hoseiAC_C3(iROOM,iAC,iFanAC) = 1;
                    elseif strcmp(FanCtrlAC_C3(iROOM,iAC,iFanAC),'COconcentration')
                        hoseiAC_C3(iROOM,iAC,iFanAC) = 0.6;
                    elseif strcmp(FanCtrlAC_C3(iROOM,iAC,iFanAC),'Temprature')
                        hoseiAC_C3(iROOM,iAC,iFanAC) = 0.7;
                    else
                        error('送風量制御の設定が不正です。')
                    end
                    
                    hoseiAC_ALL(iROOM,iAC,iFanAC) = hoseiAC_C1(iROOM,iAC,iFanAC) * hoseiAC_C2(iROOM,iAC,iFanAC) * hoseiAC_C3(iROOM,iAC,iFanAC);
                    
                end
            end
        end
    end
    
end

%% 機器リストの作成
UnitListFAN = {};
UnitListFANPower = [];
for iUNITx = 1:size(UnitNameFAN,1)
    for iUNITy = 1:size(UnitNameFAN,2)
        if isempty(UnitNameFAN{iUNITx,iUNITy}) == 0
            if iUNITx == 1 && iUNITy == 1
                UnitListFAN = [UnitListFAN;UnitNameFAN(iUNITx,iUNITy)];  % 初期値
                UnitListFANPower = [UnitListFANPower;FanPowerFAN(iUNITx,iUNITy).*hosei_ALL(iUNITx,iUNITy)];  % 初期値
            else
                
                % 変数UnitListを検索
                check = 0;
                for iUNITdb = 1:length(UnitListFAN)
                    if strcmp(UnitListFAN(iUNITdb),UnitNameFAN(iUNITx,iUNITy))
                        check = 1;
                    end
                end
                if check == 0
                    UnitListFAN = [UnitListFAN;UnitNameFAN(iUNITx,iUNITy)];  % 追加
                    UnitListFANPower = [UnitListFANPower;FanPowerFAN(iUNITx,iUNITy).*hosei_ALL(iUNITx,iUNITy)];  % 追加
                end
                
            end
        end
    end
end

UnitListAC = {};
UnitListAC_CoolingCapacity = [];
UnitListAC_COP = [];
UnitListAC_FanPower = [];
UnitListAC_PumpPower = [];

UnitListAC_Power = [];

for iUNITx = 1:size(UnitNameAC,1)
    for iUNITy = 1:size(UnitNameAC,2)
        
        if isempty(UnitNameAC{iUNITx,iUNITy}) == 0
            
            % 変数UnitListを検索（重複を調べる）
            if iUNITx == 1 && iUNITy == 1
                check = 0;
            else
                check = 0;
                for iUNITdb = 1:length(UnitListAC)
                    if strcmp(UnitListAC(iUNITdb),UnitNameAC(iUNITx,iUNITy))
                        check = 1;
                    end
                end
            end
            
            if check == 0
                
                UnitListAC = [UnitListAC; UnitNameAC(iUNITx,iUNITy)];
                
                % ファンを分類
                FanPowerAC_ac = 0;
                FanPowerAC_fan = 0;
                for iFanAC = 1:length(FanTypeAC(iUNITx,iUNITy,:))
                    if strcmp(FanTypeAC(iUNITx,iUNITy,iFanAC),'AC')
                        FanPowerAC_ac = FanPowerAC_ac + FanPowerAC(iUNITx,iUNITy,iFanAC) .* hoseiAC_ALL(iUNITx,iUNITy,iFanAC);
                    else
                        FanPowerAC_fan = FanPowerAC_fan + FanPowerAC(iUNITx,iUNITy,iFanAC) .* hoseiAC_ALL(iUNITx,iUNITy,iFanAC);
                    end
                end
                
                FanVolumeAC_supply = 0;
                FanVolumeAC_exit   = 0;
                for iFanAC = 1:length(FanTypeAC(iUNITx,iUNITy,:))
                    if strcmp(FanTypeAC(iUNITx,iUNITy,iFanAC),'Supply')
                        FanVolumeAC_supply = FanVolumeAC_supply + FanVolumeAC(iUNITx,iUNITy,iFanAC);
                    elseif strcmp(FanTypeAC(iUNITx,iUNITy,iFanAC),'Exist')
                        FanVolumeAC_exit   = FanVolumeAC_exit   + FanVolumeAC(iUNITx,iUNITy,iFanAC);
                    elseif strcmp(FanTypeAC(iUNITx,iUNITy,iFanAC),'AC')
                    elseif strcmp(FanTypeAC(iUNITx,iUNITy,iFanAC),'Circulation')
                    else
                        FanTypeAC(iUNITx,iUNITy,iFanAC)
                        error('換気代替空調機のタイプが不正です')
                    end
                end
                FanVolumeAC_check = 0;
                if FanVolumeAC_supply > 0
                    FanVolumeAC_check = FanVolumeAC_supply;
                elseif FanVolumeAC_exit > 0
                    FanVolumeAC_check = FanVolumeAC_exit;
                else
                    FanVolumeAC_check = 0;
                end
                
                % 外気冷房に必要な外気導入量
                Vfmin = 1000 * CoolingCapacityAC(iUNITx,iUNITy) / (0.33*(40-Toa_ave_design));
                
                % 年間稼働率
                if FanVolumeAC_check > Vfmin
                    Cac  = 0.35;
                    Cfan = 0.65;
                else
                    Cac  = 1.00;
                    Cfan = 1.00;
                end
                
                % 負荷率
                if strcmp(UnitTypeAC(iUNITx,iUNITy),'elevator')
                    xL = 0.3;
                elseif strcmp(UnitTypeAC(iUNITx,iUNITy),'powerRoom')
                    xL = 0.6;
                elseif strcmp(UnitTypeAC(iUNITx,iUNITy),'machineRoom')
                    xL = 0.6;
                elseif strcmp(UnitTypeAC(iUNITx,iUNITy),'others')
                    xL = 1.0;
                end
                
                
                tmp = CoolingCapacityAC(iUNITx,iUNITy) * xL / (2.71 * COPAC(iUNITx,iUNITy) ) * Cac ...
                    + PumpPowerAC(iUNITx,iUNITy)/0.75 * Cac ...
                    + FanPowerAC_ac/0.75 * Cac ...
                    + FanPowerAC_fan/0.75 * Cfan;
                
                UnitListAC_Power = [UnitListAC_Power; tmp];
                
            end
        else
            UnitListAC_Power = [UnitListAC_Power; 0];
        end
    end
end

%% 機器別の運転時間の計算(最大値とする)
opeTimeListFAN = zeros(length(UnitListFAN),1);
AreaListFAN = zeros(length(UnitListFAN),1);

opeMode_Vfan = zeros(length(UnitListFAN),365,24);

for iUNIT = 1:length(UnitListFAN)
    
    % データベース検索
    for iROOM = 1:size(UnitNameFAN,1)
        for iUNITdb = 1:size(UnitNameFAN,2)
            if strcmp(UnitListFAN(iUNIT),UnitNameFAN(iROOM,iUNITdb))
                AreaListFAN(iUNIT,1) = AreaListFAN(iUNIT,1) + RoomArea(iROOM);
                if opeTimeListFAN(iUNIT,1) < timeV(iROOM)
                    opeTimeListFAN(iUNIT,1) = timeV(iROOM);
                    opeMode_Vfan(iUNIT,:,:) = opeMode_Vroom(iROOM,:,:);
                end
            end
        end
    end
    
end

opeTimeListAC = zeros(length(UnitListAC),1);
AreaListAC = zeros(length(UnitListAC),1);

opeMode_Vac = zeros(length(UnitListAC),365,24);

for iUNIT = 1:length(UnitListAC)
    
    % データベース検索
    for iROOM = 1:size(UnitNameAC,1)
        for iUNITdb = 1:size(UnitNameAC,2)
            if strcmp(UnitListAC(iUNIT),UnitNameAC(iROOM,iUNITdb))
                AreaListAC(iUNIT,1) = AreaListAC(iUNIT,1) + RoomArea(iROOM);
                if opeTimeListAC(iUNIT,1) < timeV(iROOM)
                    opeTimeListAC(iUNIT,1) = timeV(iROOM);
                    opeMode_Vac(iUNIT,:,:) = opeMode_Vroom(iROOM,:,:);
                end
            end
        end
    end
    
end
if isempty(opeTimeListAC)
    opeTimeListAC = zeros(size(UnitNameAC,1),1);
end


%% エネルギー消費量計算

% 機器ベースで計算
if isempty(UnitListFANPower)
    Edesign_FAN_MWh = 0;
else
    Edesign_FAN_MWh    = opeTimeListFAN .* UnitListFANPower ./(1000*0.75);
end
Edesign_FAN_MJ     = 9760.*Edesign_FAN_MWh;
Edesign_FAN_MWh_m2 = sum(nansum(Edesign_FAN_MWh))/sum(RoomArea);
Edesign_FAN_MJ_m2  = sum(nansum(Edesign_FAN_MJ))/sum(RoomArea);

% % COPを一次換算で入れた場合
% Edesign_AC_kW_ROOM     = CoolingCapacityAC .* repmat(xL,1,size(FanPowerAC,2))./(2.71.*COPAC) + (FanPowerAC+PumpPowerAC) ./0.75;
Edesign_AC_kW_ROOM = UnitListAC_Power;
Edesign_AC_kW  = UnitListAC_Power;
Edesing_AC_Mwh = Edesign_AC_kW .* opeTimeListAC ./1000;

Edesign_AC_MJ     = 9760.*Edesing_AC_Mwh;
Edesign_AC_MWh_m2 = sum(nansum(Edesing_AC_Mwh))/sum(RoomArea);
Edesign_AC_MJ_m2  = sum(nansum(Edesign_AC_MJ))/sum(RoomArea);

% 時刻別の値
Edesign_MWh_hour = zeros(8760,1);
for iUNIT = 1:length(UnitListFAN)
    for dd = 1:365
        for hh = 1:24
            num = 24*(dd-1) + hh;
            Edesign_MWh_hour(num,1) = Edesign_MWh_hour(num,1) + UnitListFANPower(iUNIT).*opeMode_Vfan(iUNIT,dd,hh)./(1000*0.75);
        end
    end
end
for iUNIT = 1:length(UnitListAC)
    for dd = 1:365
        for hh = 1:24
            num = 24*(dd-1) + hh;
            Edesign_MWh_hour(num,1) = Edesign_MWh_hour(num,1) + Edesign_AC_kW(iUNIT).*opeMode_Vac(iUNIT,dd,hh)./1000;
        end
    end
end


% （部屋単位の評価値：面積で按分する）
ratioP_FAN = zeros(size(UnitNameFAN));
for iUNIT = 1:length(UnitListFAN)
    for iROOM = 1:size(UnitNameFAN,1)
        for iUNITdb = 1:size(UnitNameFAN,2)
            if strcmp(UnitNameFAN(iROOM,iUNITdb),UnitListFAN(iUNIT))
                ratioP_FAN(iROOM,iUNITdb) = Edesign_FAN_MJ(iUNIT).*RoomArea(iROOM)./AreaListFAN(iUNIT);
            end
        end
    end
end

ratioP_AC = zeros(size(UnitNameAC));
for iUNIT = 1:length(UnitListAC)
    for iROOM = 1:size(UnitNameAC,1)
        for iUNITdb = 1:size(UnitNameAC,2)
            if strcmp(UnitNameAC(iROOM,iUNITdb),UnitListAC(iUNIT))
                ratioP_AC(iROOM,iUNITdb) = Edesign_AC_MJ(iUNIT).*RoomArea(iROOM)./AreaListAC(iUNIT);
            end
        end
    end
end


%----------------------------------------
% 基準年間エネルギー消費量原単位 [kW/m2]
Eme    = kv.*(10^-5.*Vroom.*Proom.*1.2./(36*0.4))./0.75; % 送風機軸動力[kW/m2]

% 基準値（ROOM_STANDARDVALUE.csv）より値を抜き出す（最終的にはこちらを採用） [MJ]
Estandard_MJ_CSV = mytfunc_calcStandardValue(BldgType,RoomType,RoomArea,18);

Es_MWh    = Eme.*timeV./1000.*RoomArea;      % 基準年間電力消費量原単位[MWh/年]
Es_MWh_m2 = sum(Es_MWh)/sum(RoomArea);
Es_MJ     = 9760.*Es_MWh;                    % 基準年間エネルギー消費量原単位[MJ/年]
Es_MJ_m2  = sum(Es_MJ)/sum(RoomArea);

% 出力
y(1) = sum(nansum(Edesign_FAN_MWh)) + sum(nansum(Edesing_AC_Mwh));
y(2) = Edesign_FAN_MWh_m2 + Edesign_AC_MWh_m2;
y(3) = sum(nansum(Edesign_FAN_MJ))  + sum(nansum(Edesign_AC_MJ));
y(4) = Edesign_FAN_MJ_m2  + Edesign_AC_MJ_m2;

y(5) = nansum(Es_MWh);
y(6) = Es_MWh_m2;
y(7) = Estandard_MJ_CSV;
y(8) = Estandard_MJ_CSV/sum(RoomArea);

y(9) = y(4)/y(8);


%% 簡易出力
% 出力するファイル名
if isempty(strfind(inputfilename,'/'))
    eval(['resfilenameS = ''calcRES_V_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(inputfilename,'/');
    eval(['resfilenameS = ''calcRES_V_',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
end
csvwrite(resfilenameS,y);


%% 詳細出力

if OutputOptionVar == 1
    
    rfc = {};
    
    for iROOM = 1:numOfRoom
        if numOfVfan(iROOM) > 0
            for iUNIT = 1:numOfVfan(iROOM)
                tmpdata = '';
                if iUNIT == 1
                    tmpdata = strcat(RoomFloor(iROOM),',',...
                        RoomName(iROOM),',',...
                        BldgType(iROOM),',',...
                        RoomType(iROOM),',',...
                        num2str(RoomArea(iROOM)),',',...
                        '送風機,',...
                        UnitNameFAN{iROOM,iUNIT},',',...
                        UnitTypeFAN{iROOM,iUNIT},',',...
                        num2str(FanVolumeFAN(iROOM,iUNIT)),',',...
                        num2str(FanPowerFAN(iROOM,iUNIT)),',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        num2str(FanPowerFAN(iROOM,iUNIT)./RoomArea(iROOM)*1000),',',...
                        num2str(Eme(iROOM)*1000),',',...
                        hosei_C1_name(iROOM,iUNIT),',',...
                        hosei_C2_name(iROOM,iUNIT),',',...
                        hosei_C3_name(iROOM,iUNIT),',',...
                        num2str(hosei_ALL(iROOM,iUNIT)),',',...
                        num2str(timeV(iROOM)),',',...
                        num2str(ratioP_FAN(iROOM,iUNIT)),',',...
                        num2str(Es_MJ(iROOM)),',',...
                        num2str( (nansum(ratioP_FAN(iROOM,:)) + nansum(ratioP_AC(iROOM,:))) ./Es_MJ(iROOM)));
                    
                else
                    tmpdata = strcat(',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        '送風機,',...
                        UnitNameFAN{iROOM,iUNIT},',',...
                        UnitTypeFAN{iROOM,iUNIT},',',...
                        num2str(FanVolumeFAN(iROOM,iUNIT)),',',...
                        num2str(FanPowerFAN(iROOM,iUNIT)),',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        num2str(FanPowerFAN(iROOM,iUNIT)./RoomArea(iROOM)*1000),',',...
                        ',',...
                        hosei_C1_name(iROOM,iUNIT),',',...
                        hosei_C2_name(iROOM,iUNIT),',',...
                        hosei_C3_name(iROOM,iUNIT),',',...
                        num2str(hosei_ALL(iROOM,iUNIT)),',',...
                        ',',...
                        num2str(ratioP_FAN(iROOM,iUNIT)),',',...
                        ',',...
                        ' ');
                    
                end
                rfc = [rfc;tmpdata];
            end
            
        end
        
        if numOfVac(iROOM) > 0
            for iUNIT = 1:numOfVac(iROOM)
                tmpdata = '';
                if iUNIT == 1 && numOfVfan(iROOM) == 0
                    
                    tmpdata = strcat(RoomFloor(iROOM),',',...
                        RoomName(iROOM),',',...
                        BldgType(iROOM),',',...
                        RoomType(iROOM),',',...
                        num2str(RoomArea(iROOM)),',',...
                        '冷房,',...
                        UnitNameAC{iROOM,iUNIT},',',...
                        UnitTypeAC{iROOM,iUNIT},',',...
                        ',',...
                        ',',...
                        num2str(CoolingCapacityAC(iROOM,iUNIT)),',',...
                        num2str(COPAC(iROOM,iUNIT)),',',...
                        num2str(FanPowerAC(iROOM,iUNIT)),',',...
                        num2str(PumpPowerAC(iROOM,iUNIT)),',',...
                        num2str(Edesign_AC_kW_ROOM(iROOM,iUNIT)./RoomArea(iROOM)*1000),',',...
                        num2str(Eme(iROOM)*1000),',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        num2str(timeV(iROOM)),',',...
                        num2str(ratioP_AC(iROOM,iUNIT)),',',...
                        num2str(Es_MJ(iROOM)),',',...
                        num2str( (nansum(ratioP_FAN(iROOM,:)) + nansum(ratioP_AC(iROOM,:))) ./Es_MJ(iROOM)));
                    
                else
                    
                    tmpdata = strcat(',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        '冷房,',...
                        UnitNameAC{iROOM,iUNIT},',',...
                        ',',...
                        ',',...
                        ',',...
                        num2str(CoolingCapacityAC(iROOM,iUNIT)),',',...
                        num2str(COPAC(iROOM,iUNIT)),',',...
                        num2str(FanPowerAC(iROOM,iUNIT)),',',...
                        num2str(PumpPowerAC(iROOM,iUNIT)),',',...
                        num2str(Edesign_AC_kW_ROOM(iROOM,iUNIT)./RoomArea(iROOM)*1000),',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        num2str(ratioP_AC(iROOM,iUNIT)),',',...
                        ',',...
                        ' ');
                    
                end
                rfc = [rfc;tmpdata];
            end
        end
        
    end
    
    % 出力するファイル名
    if isempty(strfind(inputfilename,'/'))
        eval(['resfilenameD = ''calcRESdetail_V_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
    else
        tmp = strfind(inputfilename,'/');
        eval(['resfilenameD = ''calcRESdetail_V_',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
    end
    
    % 出力
    fid = fopen(resfilenameD,'w+');
    for i=1:size(rfc,1)
        fprintf(fid,'%s\r\n',rfc{i,:});
    end
    fclose(fid);
    
end

% 日別に積算する。
Edesign_MWh_day = [];
for dd = 1:365
    Edesign_MWh_day(dd,1) = sum( Edesign_MWh_hour(24*(dd-1)+1:24*dd,1));
end


%% 時系列データの出力
if OutputOptionVar == 1
    
    if isempty(strfind(inputfilename,'/'))
        eval(['resfilenameH = ''calcREShourly_V_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
    else
        tmp = strfind(inputfilename,'/');
        eval(['resfilenameH = ''calcREShourly_V_',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
    end
    
    % 月：日：時
    TimeLabel = zeros(8760,3);
    for dd = 1:365
        for hh = 1:24
            % 1月1日0時からの時間数
            num = 24*(dd-1)+hh;
            t = datenum(2015,1,1) + (dd-1) + (hh-1)/24;
            TimeLabel(num,1) = str2double(datestr(t,'mm'));
            TimeLabel(num,2) = str2double(datestr(t,'dd'));
            TimeLabel(num,3) = str2double(datestr(t,'hh'));
        end
    end
    
    RESALL = [ TimeLabel,Edesign_MWh_hour];
    
    rfc = {};
    rfc = [rfc;'月,日,時,換気電力消費量[MWh]'];
    rfc = mytfunc_oneLinecCell(rfc,RESALL);
    
    fid = fopen(resfilenameH,'w+');
    for i=1:size(rfc,1)
        fprintf(fid,'%s\r\n',rfc{i});
    end
    fclose(fid);
   
end



%% コジェネ用の変数
if exist('CGSmemory.mat','file') == 0
    CGSmemory = [];
else
    load CGSmemory.mat
end

CGSmemory.RESALL(:,11) = Edesign_MWh_day;

save CGSmemory.mat CGSmemory

