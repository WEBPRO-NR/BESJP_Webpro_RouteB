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
% function y = ECS_routeB_Others_run(inputfilename)

clear
clc
tic
inputfilename = 'model_Area6_Case01.xml';
addpath('./subfunction/')


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
Eothers = zeros(numOfRoom,1);

for iROOM = 1:numOfRoom
    
    % 原単位の抽出 MJ/m2
    Eothers_perArea(iROOM,1) = mytfunc_calcOApowerUsage(BldgType{iROOM,1},RoomType{iROOM,1},perDB_RoomType,perDB_calendar);
    % その他電力 [MJ/年]
    Eothers(iROOM,1) = Eothers_perArea(iROOM,1) * RoomArea(iROOM,1);
    
end

y = sum(Eothers);


