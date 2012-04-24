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
% function y = ECS_routeB_V_run(inputfilename,OutputOption)

clear
clc
addpath('./subfunction')
inputfilename = 'output.xml';
OutputOption = 'ON';


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

% データベースファイル
filename_calendar             = './database/CALENDAR.csv';   % カレンダー
filename_ClimateArea          = './database/AREA.csv';       % 地域区分
filename_RoomTypeList         = './database/ROOM_SPEC.csv';  % 室用途リスト
filename_roomOperateCondition = './database/ROOM_COND.csv';  % 標準室使用条件
filename_refList              = './database/REFLIST.csv';    % 熱源機器リスト
filename_performanceCurve     = './database/REFCURVE.csv';   % 熱源特性

% データベース読み込み
mytscript_readDBfiles;


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
    
    % 送風機
    if isfield(model.VentilationSystems.VentilationRoom(iROOM),'VentilationFANUnit')
        
        numOfVfan(iROOM) = length(model.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit);
        
        for iVFAN = 1:numOfVfan(iROOM)
            UnitNameFAN{iROOM,iVFAN} = model.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(iVFAN).ATTRIBUTE.UnitName;
            UnitTypeFAN{iROOM,iVFAN} = model.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(iVFAN).ATTRIBUTE.UnitType;
            
            if strcmp(model.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(iVFAN).ATTRIBUTE.FanVolume,'Null') == 0
                FanVolumeFAN(iROOM,iVFAN) = model.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(iVFAN).ATTRIBUTE.FanVolume;
            else
                FanVolumeFAN(iROOM,iVFAN) = 0;
            end
            
            if strcmp(model.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(iVFAN).ATTRIBUTE.FanPower,'Null') == 0
                FanPowerFAN(iROOM,iVFAN) = model.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(iVFAN).ATTRIBUTE.FanPower;
            else
                FanPowerFAN(iROOM,iVFAN) = 0;
            end
                        
            ControlFlag_C1{iROOM,iVFAN} = model.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(iVFAN).ATTRIBUTE.ControlFlag_C1;
            ControlFlag_C2{iROOM,iVFAN} = model.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(iVFAN).ATTRIBUTE.ControlFlag_C2;
            ControlFlag_C3{iROOM,iVFAN} = model.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(iVFAN).ATTRIBUTE.ControlFlag_C3;
            
        end
    end
    
    % 冷房
    if isfield(model.VentilationSystems.VentilationRoom(iROOM),'VentilationACUnit')
        
        numOfVac(iROOM)  = length(model.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit);
        
        for iVAC = 1:numOfVac(iROOM)
            
            UnitNameAC{iROOM,iVAC} = model.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(iVAC).ATTRIBUTE.UnitName;
            
            
            if strcmp(model.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(iVAC).ATTRIBUTE.CoolingCapacity,'Null') == 0
                CoolingCapacityAC(iROOM,iVAC) = model.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(iVAC).ATTRIBUTE.CoolingCapacity;
            else
                CoolingCapacityAC(iROOM,iVAC) = 0;
            end
            
            if strcmp(model.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(iVAC).ATTRIBUTE.COP,'Null') == 0
                COPAC(iROOM,iVAC) = model.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(iVAC).ATTRIBUTE.COP;
            else
                COPAC(iROOM,iVAC) = 0;
            end
            
            if strcmp(model.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(iVAC).ATTRIBUTE.FanPower,'Null') == 0
                FanPowerAC(iROOM,iVAC) = model.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(iVAC).ATTRIBUTE.FanPower;
            else
                FanPowerAC(iROOM,iVAC) = 0;
            end
            
            if strcmp(model.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(iVAC).ATTRIBUTE.PumpPower,'Null') == 0
                PumpPowerAC(iROOM,iVAC) = model.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(iVAC).ATTRIBUTE.PumpPower;
            else
                PumpPowerAC(iROOM,iVAC) = 0;
            end
           
        end
    end
    
    if numOfVac(iROOM) == 0
        UnitNameAC{iROOM,1}  = ' ';
        CoolingCapacityAC(iROOM,1) = 0;
        COPAC(iROOM,1)       = 0;
        FanPowerAC(iROOM,1)  = 0;
        PumpPowerAC(iROOM,1) = 0;
    end
    
end


%% 各室の換気時間・基準値を探査
timeL  = zeros(numOfRoom,1);
kv     = zeros(numOfRoom,1);
Vroom  = zeros(numOfRoom,1);
Proom  = zeros(numOfRoom,1);
Eme    = zeros(numOfRoom,1);
Es_2nd = zeros(numOfRoom,1);
Es_1st = zeros(numOfRoom,1);
xL     = zeros(numOfRoom,1);

for iROOM = 1:numOfRoom
    
    % 標準室使用条件を探索
    for iDB = 1:length(perDB_RoomType)
        if strcmp(perDB_RoomType{iDB,2},BldgType{iROOM}) && ...
                strcmp(perDB_RoomType{iDB,5},RoomType{iROOM})
            
            % 換気時間 [hour]
            timeL(iROOM) = str2double(perDB_RoomType(iDB,26));
            
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
                
                % 負荷率
                if strcmp(RoomType{iROOM},'電気・機械室（高発熱）')
                    xL(iROOM) = 0.6;
                elseif strcmp(RoomType{iROOM},'電気・機械室（標準）')
                    xL(iROOM) = 0.6;
                else
                    xL(iROOM) = 1;
                end

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
                hosei_C2(iROOM,iVFAN) = 0.95;
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
end


%% エネルギー消費量計算

% 評価値計算
Edesign_FAN_MWh    = repmat(timeL,1,size(FanPowerFAN,2)) .* FanPowerFAN .* hosei_ALL ./(1000*0.75);
Edesign_FAN_MJ     = 9760.*Edesign_FAN_MWh;
Edesign_FAN_MWh_m2 = sum(nansum(Edesign_FAN_MWh))/sum(RoomArea);
Edesign_FAN_MJ_m2  = sum(nansum(Edesign_FAN_MJ))/sum(RoomArea);

Edesign_AC_kW     = (2.71 .* CoolingCapacityAC .* repmat(xL,1,size(FanPowerAC,2))./COPAC + (FanPowerAC+PumpPowerAC) ./0.75 );
Edesing_AC_Mwh    = repmat(timeL,1,size(FanPowerAC,2)) .* ...
    (2.71 .* CoolingCapacityAC .* repmat(xL,1,size(FanPowerAC,2))./COPAC + (FanPowerAC+PumpPowerAC) ./0.75 ) ./1000;
Edesign_AC_MJ     = 9760.*Edesing_AC_Mwh;
Edesign_AC_MWh_m2 = sum(nansum(Edesing_AC_Mwh))/sum(RoomArea);
Edesign_AC_MJ_m2  = sum(nansum(Edesign_AC_MJ))/sum(RoomArea);

% 基準年間エネルギー消費量原単位
Eme    = kv.*(10^-5.*Vroom.*Proom.*1.2./(36*0.4))./0.75; % 送風機軸動力[kW/m2]
Es_MWh = Eme.*timeL./1000.*RoomArea;     % 基準年間電力消費量原単位[MWh/年]
Es_MWh_m2 = sum(Es_MWh)/sum(RoomArea);
Es_MJ  = 9760.*Es_MWh;                              % 基準年間エネルギー消費量原単位[MJ/年]
Es_MJ_m2 = sum(Es_MJ)/sum(RoomArea);

% 出力
y(1) = sum(nansum(Edesign_FAN_MWh)) + sum(nansum(Edesing_AC_Mwh));
y(2) = Edesign_FAN_MWh_m2 + Edesign_AC_MWh_m2;
y(3) = sum(nansum(Edesign_FAN_MJ))  + sum(nansum(Edesign_AC_MJ));
y(4) = Edesign_FAN_MJ_m2  + Edesign_AC_MJ_m2;
y(5) = nansum(Es_MWh);
y(6) = Es_MWh_m2;
y(7) = nansum(Es_MJ);
y(8) = Es_MJ_m2;
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
                        num2str(timeL(iROOM)),',',...
                        num2str(Edesign_FAN_MJ(iROOM,iUNIT)),',',...
                        num2str(Es_MJ(iROOM)),',',...
                        num2str( (nansum(Edesign_FAN_MJ(iROOM,:)) + nansum(Edesign_AC_MJ(iROOM,:))) ./Es_MJ(iROOM)));
                    
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
                        num2str(Edesign_FAN_MJ(iROOM,iUNIT)),',',...
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
                        ',',...
                        ',',...
                        ',',...
                        num2str(CoolingCapacityAC(iROOM,iUNIT)),',',...
                        num2str(COPAC(iROOM,iUNIT)),',',...
                        num2str(FanPowerAC(iROOM,iUNIT)),',',...
                        num2str(PumpPowerAC(iROOM,iUNIT)),',',...
                        num2str(Edesign_AC_kW(iROOM,iUNIT)./RoomArea(iROOM)*1000),',',...
                        num2str(Eme(iROOM)*1000),',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        num2str(timeL(iROOM)),',',...
                        num2str(Edesign_AC_MJ(iROOM,iUNIT)),',',...
                        num2str(Es_MJ(iROOM)),',',...
                        num2str( (nansum(Edesign_FAN_MJ(iROOM,:)) + nansum(Edesign_AC_MJ(iROOM,:))) ./Es_MJ(iROOM)));
                    
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
                        num2str(Edesign_AC_kW(iROOM,iUNIT)./RoomArea(iROOM)*1000),',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        ',',...
                        num2str(Edesign_AC_MJ(iROOM,iUNIT)),',',...
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





