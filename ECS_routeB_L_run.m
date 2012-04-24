% ECS_routeB_L_run.m
%                                          by Masato Miyata 2011/04/20
%----------------------------------------------------------------------
% 省エネ基準：照明計算プログラム
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
% function y = ECS_routeB_L_run(inputfilename,OutputOption)

clear
clc
inputfilename = 'output.xml';
addpath('./subfunction/')
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

% 照明室数
numOfRoom =  length(model.LightingSystems.LightingRoom);

BldgType   = cell(numOfRoom,1);
RoomType   = cell(numOfRoom,1);
RoomFloor  = cell(numOfRoom,1);
RoomName   = cell(numOfRoom,1);
RoomArea   = zeros(numOfRoom,1);
RoomWidth  = zeros(numOfRoom,1);
RoomDepth  = zeros(numOfRoom,1);
RoomHeight = zeros(numOfRoom,1);
RoomIndex  = zeros(numOfRoom,1);
numofUnit  = zeros(numOfRoom,1);

for iROOM = 1:numOfRoom
    
    BldgType{iROOM}  = model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.BldgType;
    RoomType{iROOM}  = model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomType;
    RoomFloor{iROOM} = model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomFloor;
    RoomName{iROOM}  = model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomName;
    RoomArea(iROOM)  = model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomArea;
    
    if strcmp(model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomWidth,'Null') == 0
        RoomWidth(iROOM)    = model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomWidth;
    end
    if strcmp(model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomDepth,'Null') == 0
        RoomDepth(iROOM)    = model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomDepth;
    end
    if strcmp(model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomHeight,'Null') == 0
        RoomHeight(iROOM)   = model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomHeight;
    end
    if strcmp(model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomIndex,'Null') == 0
        RoomIndex(iROOM)    = model.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomIndex;
    end
    
    numofUnit(iROOM)  = length(model.LightingSystems.LightingRoom(iROOM).LightingUnit);
    
    for iUNIT = 1:numofUnit(iROOM)
        
        if strcmp(model.LightingSystems.LightingRoom(iROOM).LightingUnit(iUNIT).ATTRIBUTE.Count,'Null') == 0
            Count(iROOM,iUNIT) = model.LightingSystems.LightingRoom(iROOM).LightingUnit(iUNIT).ATTRIBUTE.Count;
        end
        Power(iROOM,iUNIT) = model.LightingSystems.LightingRoom(iROOM).LightingUnit(iUNIT).ATTRIBUTE.Power;
        
        ControlFlag_C1{iROOM,iUNIT} = model.LightingSystems.LightingRoom(iROOM).LightingUnit(iUNIT).ATTRIBUTE.ControlFlag_C1;
        ControlFlag_C2{iROOM,iUNIT} = model.LightingSystems.LightingRoom(iROOM).LightingUnit(iUNIT).ATTRIBUTE.ControlFlag_C2;
        ControlFlag_C3{iROOM,iUNIT} = model.LightingSystems.LightingRoom(iROOM).LightingUnit(iUNIT).ATTRIBUTE.ControlFlag_C3;
        ControlFlag_C4{iROOM,iUNIT} = model.LightingSystems.LightingRoom(iROOM).LightingUnit(iUNIT).ATTRIBUTE.ControlFlag_C4;
        ControlFlag_C5{iROOM,iUNIT} = model.LightingSystems.LightingRoom(iROOM).LightingUnit(iUNIT).ATTRIBUTE.ControlFlag_C5;
        
        % ユニットタイプ
        UnitType{iROOM,iUNIT} = model.LightingSystems.LightingRoom(iROOM).LightingUnit(iUNIT).ATTRIBUTE.UnitType;
        UnitName{iROOM,iUNIT} = model.LightingSystems.LightingRoom(iROOM).LightingUnit(iUNIT).ATTRIBUTE.UnitName;
        
    end
end


%% 各室の照明時間・基準値を探査
timeL = zeros(numOfRoom,1);
Es    = zeros(numOfRoom,1);

for iROOM = 1:numOfRoom
    
    % 標準室使用条件を探索
    for iDB = 1:length(perDB_RoomType)
        if strcmp(perDB_RoomType{iDB,2},BldgType{iROOM}) && ...
                strcmp(perDB_RoomType{iDB,5},RoomType{iROOM})
            
            % 照明時間 [hour]
            timeL(iROOM) = str2double(perDB_RoomType(iDB,23));
            
            % 基準設定消費電力 [kW]
            Es(iROOM) = str2double(perDB_RoomType(iDB,25));
            
        end
    end
    
end


%% 室指数補正係数の決定
hosei_RI = ones(numOfRoom,1);

for iROOM = 1:numOfRoom
    
    % 室指数の計算
    if RoomIndex(iROOM) == 0 || isempty(RoomIndex(iROOM))
        if RoomHeight(iROOM)*(RoomWidth(iROOM)+RoomDepth(iROOM)) ~= 0
            RoomIndex(iROOM) = (RoomWidth(iROOM)*RoomDepth(iROOM)) / ...
                ( RoomHeight(iROOM)*(RoomWidth(iROOM)+RoomDepth(iROOM)) );
        else
            RoomIndex(iROOM) = 2.5;  % デフォルト値
        end
    end
    
    % 室指数補正係数 hosei_RI
    if isnan(RoomIndex(iROOM)) == 0
        if RoomIndex(iROOM) < 0.75
            hosei_RI(iROOM) = 0.50;
        elseif RoomIndex(iROOM) < 0.95
            hosei_RI(iROOM) = 0.60;
        elseif RoomIndex(iROOM) < 1.25
            hosei_RI(iROOM) = 0.70;
        elseif RoomIndex(iROOM) < 1.75
            hosei_RI(iROOM) = 0.80;
        elseif RoomIndex(iROOM) < 2.50
            hosei_RI(iROOM) = 0.90;
        elseif RoomIndex(iROOM) < 4.30
            hosei_RI(iROOM) = 1.00;
        else
            hosei_RI(iROOM) = 1.1;
        end
        
    end
end


%% 制御補正係数の決定

for iROOM = 1:numOfRoom
    for iUNIT = 1:numofUnit(iROOM)
        
        % 在室検知制御
        if strcmp(ControlFlag_C1(iROOM,iUNIT),'None')
            hosei_C1(iROOM,iUNIT) = 1.0;
            hosei_C1_name{iROOM,iUNIT} = ' ';
        elseif strcmp(ControlFlag_C1(iROOM,iUNIT),'dimmer')
            hosei_C1(iROOM,iUNIT) = 0.80;
            hosei_C1_name{iROOM,iUNIT} = '廊下(減)';
        elseif strcmp(ControlFlag_C1(iROOM,iUNIT),'onoff')
            hosei_C1(iROOM,iUNIT) = 0.70;
            hosei_C1_name{iROOM,iUNIT} = '廊下(点滅)';
        elseif strcmp(ControlFlag_C1(iROOM,iUNIT),'sensing64')
            hosei_C1(iROOM,iUNIT) = 0.95;
            hosei_C1_name{iROOM,iUNIT} = '事(6.4m)';
        elseif strcmp(ControlFlag_C1(iROOM,iUNIT),'sensing32')
            hosei_C1(iROOM,iUNIT) = 0.85;
            hosei_C1_name{iROOM,iUNIT} = '事(3.2m)';
        elseif strcmp(ControlFlag_C1(iROOM,iUNIT),'eachunit')
            hosei_C1(iROOM,iUNIT) = 0.80;
            hosei_C1_name{iROOM,iUNIT} = '事(個)';
        else
            error('在室検知制御の方式が不正です')
        end
        
        % タイムスケジュール制御
        if strcmp(ControlFlag_C2(iROOM,iUNIT),'None')
            hosei_C2(iROOM,iUNIT) = 1.0;
            hosei_C2_name{iROOM,iUNIT} = ' ';
        elseif strcmp(ControlFlag_C2(iROOM,iUNIT),'dimmer')
            hosei_C2(iROOM,iUNIT) = 0.95;
            hosei_C2_name{iROOM,iUNIT} = '減光';
        elseif strcmp(ControlFlag_C2(iROOM,iUNIT),'onoff')
            hosei_C2(iROOM,iUNIT) = 0.90;
            hosei_C2_name{iROOM,iUNIT} = '点滅';
        else
            error('タイムスケジュール制御の方式が不正です')
        end
        
        % 初期照度補正制御
        if strcmp(ControlFlag_C3(iROOM,iUNIT),'None')
            hosei_C3(iROOM,iUNIT) = 1.0;
            hosei_C3_name{iROOM,iUNIT} = ' ';
        elseif strcmp(ControlFlag_C3(iROOM,iUNIT),'Timer')
            hosei_C3(iROOM,iUNIT) = 0.90;
            hosei_C3_name{iROOM,iUNIT} = 'タイマー';
        elseif strcmp(ControlFlag_C3(iROOM,iUNIT),'Sensor')
            hosei_C3(iROOM,iUNIT) = 0.85;
            hosei_C3_name{iROOM,iUNIT} = 'センサー';
        else
            ControlFlag_C3(iROOM,iUNIT)
            error('初期照度補正制御の方式が不正です')
        end
        
        % 昼光利用制御
        if strcmp(ControlFlag_C4(iROOM,iUNIT),'None')
            hosei_C4(iROOM,iUNIT) = 1.0;
            hosei_C4_name{iROOM,iUNIT} = ' ';
        elseif strcmp(ControlFlag_C4(iROOM,iUNIT),'eachSideWithBlind')
            hosei_C4(iROOM,iUNIT) = 0.9;
            hosei_C4_name{iROOM,iUNIT} = '昼片VB無';
        elseif strcmp(ControlFlag_C4(iROOM,iUNIT),'eachSideWithoutBlind')
            hosei_C4(iROOM,iUNIT) = 0.85;
            hosei_C4_name{iROOM,iUNIT} = '昼片VB有';
        elseif strcmp(ControlFlag_C4(iROOM,iUNIT),'bothSidesWithBlind')
            hosei_C4(iROOM,iUNIT) = 0.85;
            hosei_C4_name{iROOM,iUNIT} = '昼両VB無';
        elseif strcmp(ControlFlag_C4(iROOM,iUNIT),'bothSidesWithoutBlind')
            hosei_C4(iROOM,iUNIT) = 0.8;
            hosei_C4_name{iROOM,iUNIT} = '昼両VB有';
        else
            error('昼光利用制御の方式が不正です')
        end
        
        if strcmp(ControlFlag_C5(iROOM,iUNIT),'None')
            hosei_C5(iROOM,iUNIT) = 1;
            hosei_C5_name{iROOM,iUNIT} = '　';
        elseif strcmp(ControlFlag_C5(iROOM,iUNIT),'dimmer')
            hosei_C5(iROOM,iUNIT) = 0.8;
            hosei_C5_name{iROOM,iUNIT} = '点滅';
        else
            error('明るさ感知制御の方式が不正です')
        end
        
        hosei_ALL(iROOM,iUNIT) = hosei_C1(iROOM,iUNIT)*hosei_C2(iROOM,iUNIT)*...
            hosei_C3(iROOM,iUNIT)*hosei_C4(iROOM,iUNIT)*hosei_C5(iROOM,iUNIT);
        
    end
end

%% エネルギー消費量計算

% 評価値 Edesign [MJ/年]
Edesign_noRI_MWh = repmat(timeL,1,max(numofUnit)).*Power.*Count.*(hosei_C1.*hosei_C2.*hosei_C3.*hosei_C4.*hosei_C5) ./1000000;
Edesign_noRI_MJ  = 9760.*Edesign_noRI_MWh;
Edesign_MWh      = repmat(timeL,1,max(numofUnit)).*repmat(hosei_RI,1,max(numofUnit))...
    .*Power.*Count.*(hosei_C1.*hosei_C2.*hosei_C3.*hosei_C4.*hosei_C5) ./1000000;
Edesign_MJ       = 9760.*Edesign_MWh;

% 評価値 Edesign_m2 [MJ/m2年]
Edesign_MWh_m2 = sum(nansum(Edesign_MWh))/sum(RoomArea);
Edesign_MJ_m2  = sum(nansum(Edesign_MJ))/sum(RoomArea);

% 基準値 Estandard [MJ/年]
Estandard_MWh = Es.*RoomArea.*timeL./1000000;
Estandard_MJ  = 9760.*Estandard_MWh;
Estandard_MWh_m2 = nansum(Estandard_MWh)/sum(RoomArea);
Estandard_MJ_m2  = nansum(Estandard_MJ)/sum(RoomArea);

% 出力
y(1) = sum(nansum(Edesign_MWh));
y(2) = Edesign_MWh_m2;
y(3) = sum(nansum(Edesign_MJ));
y(4) = Edesign_MJ_m2;
y(5) = sum(nansum(Estandard_MWh));
y(6) = Estandard_MWh_m2;
y(7) = nansum(Estandard_MJ);
y(8) = Estandard_MJ_m2;
y(9) = y(4)/y(8);


%% 簡易出力
% 出力するファイル名
if isempty(strfind(inputfilename,'/'))
    eval(['resfilenameS = ''calcRES_L_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(inputfilename,'/');
    eval(['resfilenameS = ''calcRES_L_',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
end
csvwrite(resfilenameS,y);


%% 詳細出力

if OutputOptionVar == 1
    
    rfc = {};
    for iROOM = 1:numOfRoom
        for iUNIT = 1:numofUnit(iROOM)
            
            tmpdata = '';
            
            if iUNIT == 1
                tmpdata = strcat(RoomFloor(iROOM),',',...
                    RoomName(iROOM),',',...
                    BldgType(iROOM),',',...
                    RoomType(iROOM),',',...
                    num2str(RoomHeight(iROOM)),',',...
                    num2str(RoomWidth(iROOM)),',',...
                    num2str(RoomDepth(iROOM)),',',...
                    num2str(RoomArea(iROOM)),',',...
                    num2str(RoomIndex(iROOM)),',',...
                    num2str(hosei_RI(iROOM)),',',...
                    UnitType(iROOM,iUNIT),',',...
                    UnitName(iROOM,iUNIT),',',...
                    num2str(Power(iROOM,iUNIT)),',',...
                    num2str(Count(iROOM,iUNIT)),',',...
                    num2str((Power(iROOM,iUNIT)*Count(iROOM,iUNIT))/RoomArea(iROOM)),',',...
                    num2str(Es(iROOM)),',',...
                    hosei_C1_name(iROOM,iUNIT),',',...
                    hosei_C2_name(iROOM,iUNIT),',',...
                    hosei_C3_name(iROOM,iUNIT),',',...
                    hosei_C4_name(iROOM,iUNIT),',',...
                    hosei_C5_name(iROOM,iUNIT),',',...
                    num2str(hosei_ALL(iROOM,iUNIT)),',',...
                    num2str(timeL(iROOM)),',',...
                    num2str(Edesign_MJ(iROOM,iUNIT)),',',...
                    num2str(Edesign_noRI_MJ(iROOM,iUNIT)),',',...
                    num2str(Estandard_MJ(iROOM)),',',...
                    num2str(sum(Edesign_MJ(iROOM,:))./Estandard_MJ(iROOM)));
                
            else
                tmpdata = strcat(',',...
                    ',',...
                    ',',...
                    ',',...
                    ',',...
                    ',',...
                    ',',...
                    ',',...
                    ',',...
                    ',',...
                    UnitType(iROOM,iUNIT),',',...
                    UnitName(iROOM,iUNIT),',',...
                    num2str(Power(iROOM,iUNIT)),',',...
                    num2str(Count(iROOM,iUNIT)),',',...
                    num2str((Power(iROOM,iUNIT)*Count(iROOM,iUNIT))/RoomArea(iROOM)),',',...
                    ',',...
                    hosei_C1_name(iROOM,iUNIT),',',...
                    hosei_C2_name(iROOM,iUNIT),',',...
                    hosei_C3_name(iROOM,iUNIT),',',...
                    hosei_C4_name(iROOM,iUNIT),',',...
                    hosei_C5_name(iROOM,iUNIT),',',...
                    num2str(hosei_ALL(iROOM,iUNIT)),',',...
                    ',',...
                    num2str(Edesign_MJ(iROOM,iUNIT)),',',...
                    num2str(Edesign_noRI_MJ(iROOM,iUNIT)),',',...
                    ',',...
                    ' ');
                
            end
            
            rfc = [rfc;tmpdata];
            
        end
    end
    
    % 出力するファイル名
    if isempty(strfind(inputfilename,'/'))
        eval(['resfilenameD = ''calcRESdetail_L_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
    else
        tmp = strfind(inputfilename,'/');
        eval(['resfilenameD = ''calcRESdetail_L_',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
    end
    
    % 出力
    fid = fopen(resfilenameD,'w+');
    for i=1:size(rfc,1)
        fprintf(fid,'%s\r\n',rfc{i,:});
    end
    fclose(fid);
    
end

