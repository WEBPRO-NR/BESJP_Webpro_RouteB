% ECS_routeB_EV_run_v1.m
%                                          by Masato Miyata 2011/04/05
%----------------------------------------------------------------------
% 昇降機計算プログラム
%----------------------------------------------------------------------
function y = ECS_routeB_EV_run_v1(inputfilename,OutputOption)

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

% 昇降機台数
numofUnit  = length(model.Elevators.Elevator);

Name       = cell(1,numofUnit);
BldgType   = cell(1,numofUnit);
RoomType   = cell(1,numofUnit);
RoomFloor  = cell(1,numofUnit);
RoomName   = cell(1,numofUnit);
Count      = ones(1,numofUnit);
LoadLimit  = zeros(1,numofUnit);
Velocity   = zeros(1,numofUnit);
kControlT      = ones(1,numofUnit);
kControlT_name = cell(1,numofUnit);

for iUNIT = 1:numofUnit
    
    Name{iUNIT}        = model.Elevators.Elevator(iUNIT).ATTRIBUTE.Name;
    BldgType{iUNIT}    = model.Elevators.Elevator(iUNIT).ATTRIBUTE.BldgType;
    RoomFloor{iUNIT}   = model.Elevators.Elevator(iUNIT).ATTRIBUTE.RoomFloor;
    RoomName{iUNIT}    = model.Elevators.Elevator(iUNIT).ATTRIBUTE.RoomName;
    RoomType{iUNIT}    = model.Elevators.Elevator(iUNIT).ATTRIBUTE.RoomType;

    Count(iUNIT)       = model.Elevators.Elevator(iUNIT).ATTRIBUTE.Count;
    LoadLimit(iUNIT)   = model.Elevators.Elevator(iUNIT).ATTRIBUTE.LoadLimit;
    Velocity(iUNIT)    = model.Elevators.Elevator(iUNIT).ATTRIBUTE.Velocity;
        
    if strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType,'EV_CT1')
        kControlT(iUNIT) = 1/50;
        kControlT_name{iUNIT} = '可変電圧可変周波数制御方式（電力回生制御ありギアレス巻上機）';
    elseif strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType,'EV_CT2')
        kControlT(iUNIT) = 1/45;
        kControlT_name{iUNIT} = '可変電圧可変周波数制御方式（電力回生制御あり）';
    elseif strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType,'EV_CT3')
        kControlT(iUNIT) = 1/45;
        kControlT_name{iUNIT} = '可変電圧可変周波数制御方式（電力回生制御なしギアレス巻上機）';
    elseif strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType,'EV_CT4')
        kControlT(iUNIT) = 1/40;
        kControlT_name{iUNIT} = '可変電圧可変周波数制御方式（電力回生制御なし）';
    elseif strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType,'EV_CT5')
        kControlT(iUNIT) = 1/20;
        kControlT_name{iUNIT} = '交流帰還制御方式';
    end
    
    
end

%% 各室の照明時間を探査
timeEV = zeros(1,numofUnit);

for iUNIT = 1:numofUnit
    
    % 標準室使用条件を探索
    for iDB = 1:length(perDB_RoomType)
        if strcmp(perDB_RoomType{iDB,2},BldgType{iUNIT}) && ...
                strcmp(perDB_RoomType{iDB,5},RoomType{iUNIT})
            
            % 昇降機運転時間 [hour] (空調時間とする)
            timeEV(iUNIT) = str2double(perDB_RoomType(iDB,22));
            
        end
    end
    
end

% エネルギー消費量計算 [MJ/年]
Edesign   = 9760.* LoadLimit.* Velocity.* kControlT.* Count.* timeEV ./860 ./1000;
Estandard = 9760.* LoadLimit.* Velocity.* (1/40).* Count.* timeEV ./860 ./1000;
 
y(1) = sum(Edesign);
y(2) = Estandard;


%% 簡易出力
% 出力するファイル名
if isempty(strfind(inputfilename,'/'))
    eval(['resfilenameS = ''calcRES_EV_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(inputfilename,'/');
    eval(['resfilenameS = ''calcRES_EV_',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
end
csvwrite(resfilenameS,y);


%% 詳細出力

if OutputOptionVar == 1
    
    % 出力するファイル名
    if isempty(strfind(inputfilename,'/'))
        eval(['resfilenameD = ''calcRESdetail_EV_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
    else
        tmp = strfind(inputfilename,'/');
        eval(['resfilenameD = ''calcRESdetail_EV_',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
    end
    
    % 結果格納用変数
    rfc = {};
    rfc = mytfunc_oneLinecCell(rfc,Edesign);
    rfc = mytfunc_oneLinecCell(rfc,Estandard);
    
    % 出力
    fid = fopen(resfilenameD,'w+');
    for i=1:size(rfc,1)
        fprintf(fid,'%s\r\n',rfc{i});
    end
    fclose(fid);
    
end

