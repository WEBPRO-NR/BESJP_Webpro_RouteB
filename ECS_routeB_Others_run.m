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
% function y = ECS_routeB_Others_run(inputfilename,OutputOption)

clear
clc
tic
inputfilename = 'model_routeB_sample04.xml';
OutputOption = 'ON';
addpath('./subfunction/')


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

for iROOM = 1:numOfRoom
    
    BldgType{iROOM,1} = model.Rooms.Room(iROOM).ATTRIBUTE.BuildingType;
    RoomType{iROOM,1} = model.Rooms.Room(iROOM).ATTRIBUTE.RoomType;
    RoomArea(iROOM,1) = model.Rooms.Room(iROOM).ATTRIBUTE.RoomArea;
    
end


%% その他電力の計算

Eothers_perArea = zeros(numOfRoom,1);
Eothers_hourly_perArea = zeros(8760,numOfRoom);
Eothers = zeros(numOfRoom,1);
Eothers_hourly = zeros(8760,numOfRoom);

for iROOM = 1:numOfRoom
    
    % 原単位の抽出 MJ/m2
    Eothers_perArea(iROOM,1) = mytfunc_calcOApowerUsage(BldgType{iROOM,1},RoomType{iROOM,1},perDB_RoomType,perDB_calendar);
    
    % 時刻別原単位の抽出 MWh/m2
    Eothers_hourly_perArea(:,iROOM) = mytfunc_calcOApowerUsage_hourly(BldgType{iROOM,1},RoomType{iROOM,1},perDB_RoomType,perDB_calendar);
    
    % その他電力 [MJ/年]
    Eothers(iROOM,1) = Eothers_perArea(iROOM,1) * RoomArea(iROOM,1);
    % その他電力 [MWh/年]
    Eothers_hourly(:,iROOM) = Eothers_hourly_perArea(:,iROOM) .* RoomArea(iROOM,1);
    
end

y = sum(Eothers);


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
    
    RESALL = [ TimeLabel,sum(Eothers_hourly,2)];
    
    rfc = {};
    rfc = [rfc;'月,日,時,その他電力消費量[MWh]'];
    rfc = mytfunc_oneLinecCell(rfc,RESALL);
    
    fid = fopen(resfilenameH,'w+');
    for i=1:size(rfc,1)
        fprintf(fid,'%s\r\n',rfc{i});
    end
    fclose(fid);
    
    
end


