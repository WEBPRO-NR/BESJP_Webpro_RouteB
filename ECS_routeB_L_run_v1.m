% ECS_routeB_L_run_v1.m
%                                          by Masato Miyata 2011/04/05
%----------------------------------------------------------------------
% 給湯計算プログラム
%----------------------------------------------------------------------
function y = ECS_routeB_L_run_v1(inputfilename,OutputOption)

% clear
% clc
% tic
% inputfilename = 'output.xml';
% OutputOption = 'ON';

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

% 照明器具数
numofUnit  = length(model.LightingSystems.LightingUnit);

BldgType   = cell(1,numofUnit);
RoomType   = cell(1,numofUnit);
RoomFloor  = cell(1,numofUnit);
RoomName   = cell(1,numofUnit);
RoomArea   = zeros(1,numofUnit);
RoomWidth  = zeros(1,numofUnit);
RoomDepth  = zeros(1,numofUnit);
RoomHeight = zeros(1,numofUnit);
RoomIndex  = zeros(1,numofUnit);
Count      = ones(1,numofUnit);
Power      = zeros(1,numofUnit);
ControlFlag_C1 = cell(1,numofUnit);
ControlFlag_C2 = cell(1,numofUnit);
ControlFlag_C3 = cell(1,numofUnit);
ControlFlag_C4 = cell(1,numofUnit);
UnitType = cell(1,numofUnit);
UnitName = cell(1,numofUnit);

for iUNIT = 1:numofUnit
    
    BldgType{iUNIT}     = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.BldgType;
    RoomFloor{iUNIT}    = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomFloor;
    RoomName{iUNIT}    = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomName;
    RoomType{iUNIT}     = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomType;
    RoomArea(iUNIT)     = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomArea;
    if strcmp(model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomWidth,'Null') == 0
        RoomWidth(iUNIT)    = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomWidth;
    end
    if strcmp(model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomDepth,'Null') == 0
        RoomDepth(iUNIT)    = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomDepth;
    end
    if strcmp(model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomHeight,'Null') == 0
        RoomHeight(iUNIT)   = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomHeight;
    end
    if strcmp(model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomIndex,'Null') == 0
        RoomIndex(iUNIT)    = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.RoomIndex;
    end
    if strcmp(model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.Count,'Null') == 0
        Count(iUNIT)        = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.Count;
    end
    Power(iUNIT)        = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.Power;
    
    ControlFlag_C1{iUNIT} = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.ControlFlag_C1;
    ControlFlag_C2{iUNIT} = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.ControlFlag_C2;
    ControlFlag_C3{iUNIT} = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.ControlFlag_C3;
    ControlFlag_C4{iUNIT} = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.ControlFlag_C4;
    
    % ユニットタイプ
    UnitType{iUNIT} = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.UnitType;
    UnitName{iUNIT} = model.LightingSystems.LightingUnit(iUNIT).ATTRIBUTE.UnitName;
    
end

%% 各室の照明時間を探査
timeL = zeros(1,numofUnit);
Es    = zeros(1,numofUnit);

for iUNIT = 1:numofUnit
    
    % 標準室使用条件を探索
    for iDB = 1:length(perDB_RoomType)
        if strcmp(perDB_RoomType{iDB,2},BldgType{iUNIT}) && ...
                strcmp(perDB_RoomType{iDB,5},RoomType{iUNIT})
            
            % 照明時間 [hour]
            timeL(iUNIT) = str2double(perDB_RoomType(iDB,23));
            
            % 基準設定消費電力 [kW]
            Es(iUNIT) = str2double(perDB_RoomType(iDB,25));
            
        end
    end
    
end

%% 室指数補正係数の決定
hosei_RI = ones(1,numofUnit);

for iUNIT = 1:numofUnit
    
    % 室指数の計算
    if RoomIndex(iUNIT) == 0 || isempty(RoomIndex(iUNIT))
        if RoomHeight(iUNIT)*(RoomWidth(iUNIT)+RoomDepth(iUNIT)) ~= 0
            RoomIndex(iUNIT) = (RoomWidth(iUNIT)*RoomDepth(iUNIT)) / ...
                ( RoomHeight(iUNIT)*(RoomWidth(iUNIT)+RoomDepth(iUNIT)) );
        else
            RoomIndex(iUNIT) = 2.5;  % デフォルト値
        end
    end
    
    % 室指数補正係数 hosei_RI
    if isnan(RoomIndex(iUNIT)) == 0
        if RoomIndex(iUNIT) < 0.75
            hosei_RI(iUNIT) = 0.50;
        elseif RoomIndex(iUNIT) < 0.95
            hosei_RI(iUNIT) = 0.60;
        elseif RoomIndex(iUNIT) < 1.25
            hosei_RI(iUNIT) = 0.70;
        elseif RoomIndex(iUNIT) < 1.75
            hosei_RI(iUNIT) = 0.80;
        elseif RoomIndex(iUNIT) < 2.50
            hosei_RI(iUNIT) = 0.90;
        elseif RoomIndex(iUNIT) < 4.30
            hosei_RI(iUNIT) = 1.00;
        else
            hosei_RI(iUNIT) = 1.1;
        end
        
    end
end


%% 制御補正係数の決定

% hosei_C1 = ones(1,numofUnit);
% hosei_C2 = ones(1,numofUnit);
% hosei_C3 = ones(1,numofUnit);
% hosei_C4 = ones(1,numofUnit);
% hosei_C1_name = cell(1,numofUnit);
% hosei_C2_name = cell(1,numofUnit);
% hosei_C3_name = cell(1,numofUnit);
% hosei_C4_name = cell(1,numofUnit);

for iUNIT = 1:numofUnit
    
    % 在室検知制御
    if strcmp(ControlFlag_C1(iUNIT),'None')
        hosei_C1(iUNIT) = 1.0;
        hosei_C1_name{iUNIT} = ' ';
    elseif strcmp(ControlFlag_C1(iUNIT),'dimmer')
        hosei_C1(iUNIT) = 0.80;
        hosei_C1_name{iUNIT} = '廊下(減)';
    elseif strcmp(ControlFlag_C1(iUNIT),'onoff')
        hosei_C1(iUNIT) = 0.70;
        hosei_C1_name{iUNIT} = '廊下(点滅)';
    elseif strcmp(ControlFlag_C1(iUNIT),'sensing64')
        hosei_C1(iUNIT) = 0.95;
        hosei_C1_name{iUNIT} = '事(6.4m)';
    elseif strcmp(ControlFlag_C1(iUNIT),'sensing32')
        hosei_C1(iUNIT) = 0.85;
        hosei_C1_name{iUNIT} = '事(3.2m)';
    elseif strcmp(ControlFlag_C1(iUNIT),'eachunit')
        hosei_C1(iUNIT) = 0.80;
        hosei_C1_name{iUNIT} = '事(個)';
    else
        error('在室検知制御の方式が不正です')
    end
    
    % タイムスケジュール制御
    if strcmp(ControlFlag_C2(iUNIT),'None')
        hosei_C2(iUNIT) = 1.0;
        hosei_C2_name{iUNIT} = ' ';
    elseif strcmp(ControlFlag_C2(iUNIT),'dimmer')
        hosei_C2(iUNIT) = 0.95;
        hosei_C2_name{iUNIT} = '減光';
    elseif strcmp(ControlFlag_C2(iUNIT),'onoff')
        hosei_C2(iUNIT) = 0.90;
        hosei_C2_name{iUNIT} = '点滅';
    else
        error('タイムスケジュール制御の方式が不正です')
    end
    
    % 初期照度補正制御
    if strcmp(ControlFlag_C3(iUNIT),'None')
        hosei_C3(iUNIT) = 1.0;
        hosei_C3_name{iUNIT} = ' ';
    elseif strcmp(ControlFlag_C3(iUNIT),'True')
        hosei_C3(iUNIT) = 0.85;
        hosei_C3_name{iUNIT} = '有';
    else
        ControlFlag_C3(iUNIT)
        error('初期照度補正制御の方式が不正です')
    end
    
    % 明るさ感知制御
    if strcmp(ControlFlag_C4(iUNIT),'None')
        hosei_C4(iUNIT) = 1.0;
        hosei_C4_name{iUNIT} = ' ';
    elseif strcmp(ControlFlag_C4(iUNIT),'dimmer')
        hosei_C4(iUNIT) = 0.8;
        hosei_C4_name{iUNIT} = '点滅';
    elseif strcmp(ControlFlag_C4(iUNIT),'eachSideWithBlind')
        hosei_C4(iUNIT) = 0.9;
        hosei_C4_name{iUNIT} = '昼片VB無';
    elseif strcmp(ControlFlag_C4(iUNIT),'eachSideWithoutBlind')
        hosei_C4(iUNIT) = 0.85;
        hosei_C4_name{iUNIT} = '昼片VB有';
    elseif strcmp(ControlFlag_C4(iUNIT),'bothSidesWithBlind')
        hosei_C4(iUNIT) = 0.85;
        hosei_C4_name{iUNIT} = '昼両VB無';
    elseif strcmp(ControlFlag_C4(iUNIT),'bothSidesWithoutBlind')
        hosei_C4(iUNIT) = 0.8;
        hosei_C4_name{iUNIT} = '昼両VB有';
    else
        error('明るさ感知制御の方式が不正です')
    end
    
end

%% エネルギー消費量計算

% 評価値 Edesign [MJ/年]
Edesign_noRI = 9760.*Power.*Count.*timeL.*(hosei_C1.*hosei_C2.*hosei_C3.*hosei_C4) ./1000000;
Edesign = 9760.*Power.*Count.*timeL.*hosei_RI.*(hosei_C1.*hosei_C2.*hosei_C3.*hosei_C4) ./1000000;

% 評価値 Edesign_m2 [MJ/m2年]
Edesign_m2 = sum(Edesign)/sum(RoomArea);

% 基準値 Estandard [MJ/年]
Estandard = 9760.*Es.*RoomArea.*timeL./1000000;
Estandard_m2 = sum(Estandard)/sum(RoomArea);

y(1) = sum(Edesign);
y(2) = Edesign_m2;


%% 簡易出力
% 出力するファイル名
if isempty(strfind(inputfilename,'/'))
    eval(['resfilenameS = ''calcRES_L_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(inputfilename,'/');
    eval(['resfilenameS = ''calcRES_L',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
end
csvwrite(resfilenameS,y);


%% 詳細出力

if OutputOptionVar == 1
    
    % 出力するファイル名
    if isempty(strfind(inputfilename,'/'))
        eval(['resfilenameD = ''calcRESdetail_L_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
    else
        tmp = strfind(inputfilename,'/');
        eval(['resfilenameD = ''calcRESdetail_L_',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
    end
    
    % 結果格納用変数
    rfc = {};
    rfc = mytfunc_oneLinecCell(rfc,RoomFloor);
    rfc = mytfunc_oneLinecCell(rfc,RoomName);
    rfc = mytfunc_oneLinecCell(rfc,RoomType);
    rfc = mytfunc_oneLinecCell(rfc,RoomHeight);
    rfc = mytfunc_oneLinecCell(rfc,RoomWidth);
    rfc = mytfunc_oneLinecCell(rfc,RoomDepth);
    rfc = mytfunc_oneLinecCell(rfc,RoomArea);
    rfc = mytfunc_oneLinecCell(rfc,RoomIndex);
    rfc = mytfunc_oneLinecCell(rfc,hosei_RI);
    
    rfc = mytfunc_oneLinecCell(rfc,UnitType);
    rfc = mytfunc_oneLinecCell(rfc,UnitName);
    
    rfc = mytfunc_oneLinecCell(rfc,Power);
    rfc = mytfunc_oneLinecCell(rfc,Count);
    rfc = mytfunc_oneLinecCell(rfc,(Power.*Count)./RoomArea);
    rfc = mytfunc_oneLinecCell(rfc,Es);
    
    rfc = mytfunc_oneLinecCell(rfc,hosei_C1_name);
    rfc = mytfunc_oneLinecCell(rfc,hosei_C2_name);
    rfc = mytfunc_oneLinecCell(rfc,hosei_C3_name);
    rfc = mytfunc_oneLinecCell(rfc,hosei_C4_name);
    rfc = mytfunc_oneLinecCell(rfc,hosei_C1.*hosei_C2.*hosei_C3.*hosei_C4);
    rfc = mytfunc_oneLinecCell(rfc,timeL);
    
    rfc = mytfunc_oneLinecCell(rfc,Edesign);
    rfc = mytfunc_oneLinecCell(rfc,Edesign_noRI);
    rfc = mytfunc_oneLinecCell(rfc,Estandard);
    rfc = mytfunc_oneLinecCell(rfc,Edesign./Estandard);
    
    % 出力
    fid = fopen(resfilenameD,'w+');
    for i=1:size(rfc,1)
        fprintf(fid,'%s\r\n',rfc{i});
    end
    fclose(fid);
    
end

