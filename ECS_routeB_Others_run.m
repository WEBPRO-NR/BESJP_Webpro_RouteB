% ECS_routeB_Others_run.m
%                                          by Masato Miyata 2016/04/17
%----------------------------------------------------------------------
% 省エネ基準：コンセント電力（その他電力）計算プログラム
%----------------------------------------------------------------------
% 入力
%  inputfilename : XMLファイル名称
%  OutputOption  : 出力制御（ON: 詳細出力、OFF: 簡易出力）
% 出力
%  y(1) : その他電力 [MJ/年]
%----------------------------------------------------------------------
function y = ECS_routeB_Others_run(inputfilename,OutputOption)

% clear
% clc
% tic
% inputfilename = './InputFiles/1005_コジェネテスト/model_CGS_case00.xml';
% OutputOption = 'ON';
% addpath('./subfunction/')


switch OutputOption
    case 'ON'
        OutputOptionVar = 1;
    case 'OFF'
        OutputOptionVar = 0;
    otherwise
        error('OutputOptionが不正です。ON か OFF で指定して下さい。')
end

%% データベース読み込み
mytscript_readDBfiles;


%% 建物モデル読み込み
model = xml_read(inputfilename);

% 部屋の数
numOfRoom = length(model.Rooms.Room);

BldgTypeList = cell(numOfRoom,1);
RoomTypeList = cell(numOfRoom,1);
RoomAreaList = zeros(numOfRoom,1);
RoomCalcAC = zeros(numOfRoom,1);
RoomCalcLT = zeros(numOfRoom,1);

for iROOM = 1:numOfRoom
    
    BldgType{iROOM,1} = model.Rooms.Room(iROOM).ATTRIBUTE.BuildingType;
    RoomType{iROOM,1} = model.Rooms.Room(iROOM).ATTRIBUTE.RoomType;
    RoomArea(iROOM,1) = model.Rooms.Room(iROOM).ATTRIBUTE.RoomArea;
    
    if strcmp(model.Rooms.Room(iROOM).ATTRIBUTE.calcAC,'True')
        RoomCalcAC(iROOM,1) = 1;
    end
    if strcmp(model.Rooms.Room(iROOM).ATTRIBUTE.calcL,'True')
        RoomCalcLT(iROOM,1) = 1;
    end
    
end


%% その他電力の計算

Eothers_perArea = zeros(numOfRoom,1);
Eothers_MWh_hourly_perArea  = zeros(8760,numOfRoom);
Eothers_MWh_hourly = zeros(8760,numOfRoom);

Schedule_AC_hour = zeros(8760,numOfRoom);  % 空調スケジュール
Schedule_LT_hour = zeros(8760,numOfRoom);  % 照明発熱スケジュール
Schedule_OA_hour = zeros(8760,numOfRoom);  % 機器発熱スケジュール

AreaWeightedSchedule = zeros(8760,3);

for iROOM = 1:numOfRoom
    
    % 床面積あたりの原単位の抽出（整数値に丸められた告示通りの値） MJ/m2
    [Eothers_perArea(iROOM,1),Eothers_MWh_hourly_perArea(:,iROOM),...
        Schedule_AC_hour(:,iROOM),Schedule_LT_hour(:,iROOM),Schedule_OA_hour(:,iROOM)] = ...
        mytfunc_calcOApowerUsage(BldgType{iROOM,1},RoomType{iROOM,1},perDB_RoomType,perDB_calendar,perDB_RoomOpeCondition);
    
    % 時刻別消費電力の抽出（コジェネ計算用） MWh/m2 * m2 = MWh
    Eothers_MWh_hourly(:,iROOM) = Eothers_MWh_hourly_perArea(:,iROOM) .* RoomArea(iROOM,1);
    
    % 面積重みづけのスケジュール
    if RoomCalcAC(iROOM,1) == 1
        AreaWeightedSchedule(:,1) = AreaWeightedSchedule(:,1) + Schedule_AC_hour(:,iROOM) .*  RoomArea(iROOM,1);
    end
    if RoomCalcLT(iROOM,1) == 1
        AreaWeightedSchedule(:,2) = AreaWeightedSchedule(:,2) + Schedule_LT_hour(:,iROOM) .*  RoomArea(iROOM,1);
    end
    AreaWeightedSchedule(:,3) = AreaWeightedSchedule(:,3) + Schedule_OA_hour(:,iROOM) .*  RoomArea(iROOM,1);
    
end

% AreaWeightedScheduleを日ごとの比率にする。
ratio_AreaWeightedSchedule = zeros(size(AreaWeightedSchedule));

for dd = 1:365
    
    dailysum(1) = sum(AreaWeightedSchedule(24*(dd-1)+1:24*dd,1));
    dailysum(2) = sum(AreaWeightedSchedule(24*(dd-1)+1:24*dd,2));
    dailysum(3) = sum(AreaWeightedSchedule(24*(dd-1)+1:24*dd,3));
    
    for hh = 1:24
        
        if dailysum(1) ~= 0
            ratio_AreaWeightedSchedule(24*(dd-1)+hh,1) = AreaWeightedSchedule(24*(dd-1)+hh,1) ./ dailysum(1);
        end
        if dailysum(2) ~= 0
            ratio_AreaWeightedSchedule(24*(dd-1)+hh,2) = AreaWeightedSchedule(24*(dd-1)+hh,2) ./ dailysum(2);
        end
        if dailysum(3) ~= 0
            ratio_AreaWeightedSchedule(24*(dd-1)+hh,3) = AreaWeightedSchedule(24*(dd-1)+hh,3) ./ dailysum(3);
        end
        
    end
end



%% 結果の集計

% その他一次エネルギー消費量（室単位） [MJ/年]
Eothers = Eothers_perArea .* RoomArea;

% 年積算値が告示の値と一致するように補正
ratio = zeros(numOfRoom,1);
for iROOM = 1:numOfRoom
    if Eothers(iROOM,1) ~= 0
        ratio(iROOM,1) = Eothers(iROOM,1)/(sum(Eothers_MWh_hourly(:,iROOM))*9760);
        Eothers_MWh_hourly(:,iROOM) = Eothers_MWh_hourly(:,iROOM).*ratio(iROOM,1);
    end
end

% その他電力の年積算値 [MJ/年]
y = sum(Eothers);


% 日別に積算する。
Eothers_day = zeros(365,1);
for dd = 1:365
    Eothers_day(dd,1) = sum( sum(Eothers_MWh_hourly(24*(dd-1)+1:24*dd,:)) ); % MWh/day
end


%% 時系列データの出力
if OutputOptionVar == 1
    
    if isempty(strfind(inputfilename,'/'))
        eval(['resfilenameH = ''calcREShourly_Others_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
    else
        tmp = strfind(inputfilename,'/');
        eval(['resfilenameH = ''calcREShourly_Others_',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
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
    
    RESALL = [TimeLabel,sum(Eothers_MWh_hourly,2)];
    
    rfc = {};
    rfc = [rfc;'月,日,時,その他電力消費量[MWh]'];
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

CGSmemory.RESALL(:,18) = Eothers_day;
CGSmemory.ratio_AreaWeightedSchedule = ratio_AreaWeightedSchedule;

save CGSmemory.mat CGSmemory





