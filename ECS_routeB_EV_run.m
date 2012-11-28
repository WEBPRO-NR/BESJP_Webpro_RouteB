% ECS_routeB_EV_run_v1.m
%                                          by Masato Miyata 2011/04/05
%----------------------------------------------------------------------
% 省エネ基準：昇降機計算プログラム
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
function y = ECS_routeB_EV_run(inputfilename,OutputOption)

% clear
% clc
% tic
% 
% inputfilename = './NSRI_School_IVb_Case0.xml';
% addpath('./subfunction/')
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
TransportCapacityFactor = zeros(1,numofUnit);

for iUNIT = 1:numofUnit
    
    Name{iUNIT}        = model.Elevators.Elevator(iUNIT).ATTRIBUTE.Name;
    BldgType{iUNIT}    = model.Elevators.Elevator(iUNIT).ATTRIBUTE.BldgType;
    RoomFloor{iUNIT}   = model.Elevators.Elevator(iUNIT).ATTRIBUTE.RoomFloor;
    RoomName{iUNIT}    = model.Elevators.Elevator(iUNIT).ATTRIBUTE.RoomName;
    RoomType{iUNIT}    = model.Elevators.Elevator(iUNIT).ATTRIBUTE.RoomType;

    Count(iUNIT)       = model.Elevators.Elevator(iUNIT).ATTRIBUTE.Count;
    LoadLimit(iUNIT)   = model.Elevators.Elevator(iUNIT).ATTRIBUTE.LoadLimit;
    Velocity(iUNIT)    = model.Elevators.Elevator(iUNIT).ATTRIBUTE.Velocity;
    
    % 輸送能力係数
    if strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.TransportCapacityFactor,'Null')
        TransportCapacityFactor(iUNIT) = 1;
    else
        TransportCapacityFactor(iUNIT) = model.Elevators.Elevator(iUNIT).ATTRIBUTE.TransportCapacityFactor;
    end
    if TransportCapacityFactor(iUNIT) < 0
        TransportCapacityFactor(iUNIT) = 0;
    end
    
    if strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType,'VVVF_Regene_GearLess')
        kControlT(iUNIT) = 1/50;
        kControlT_name{iUNIT} = '可変電圧可変周波数制御方式（電力回生制御ありギアレス巻上機）';
    elseif strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType,'VVVF_Regene')
        kControlT(iUNIT) = 1/45;
        kControlT_name{iUNIT} = '可変電圧可変周波数制御方式（電力回生制御あり）';
    elseif strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType,'VVVF_GearLess')
        kControlT(iUNIT) = 1/45;
        kControlT_name{iUNIT} = '可変電圧可変周波数制御方式（電力回生制御なしギアレス巻上機）';
    elseif strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType,'VVVF')
        kControlT(iUNIT) = 1/40;
        kControlT_name{iUNIT} = '可変電圧可変周波数制御方式（電力回生制御なし）';
    elseif strcmp(model.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType,'AC_FeedbackControl')
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
            
            % 昇降機運転時間 [hour] (照明時間とする)
            timeEV(iUNIT) = str2double(perDB_RoomType(iDB,23));
            
        end
    end
    
end

% エネルギー消費量計算 [MJ/年]
Edesign_MWh   = LoadLimit.* Velocity.* kControlT.* Count.* timeEV ./860 ./1000;
Estandard_MWh = LoadLimit.* Velocity.* (1/40).* TransportCapacityFactor .* Count.* timeEV ./860 ./1000;
Edesign_MJ   = 9760.* Edesign_MWh;
Estandard_MJ = 9760.* Estandard_MWh;
 
y(1) = sum(Edesign_MWh);
y(2) = NaN;
y(3) = sum(Edesign_MJ);
y(4) = NaN;
y(5) = sum(Estandard_MWh);
y(6) = NaN;
y(7) = sum(Estandard_MJ);
y(8) = NaN;
y(9) = y(3)/y(7);


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
   
    rfc = {};
    
    for iUNIT = 1:numofUnit
        tmprfc = {};
        tmprfc = strcat(Name(iUNIT),',',...
            num2str(Count(iUNIT)),',',...
            num2str(LoadLimit(iUNIT)),',',...
            num2str(Velocity(iUNIT)),',',...
            kControlT_name{iUNIT},',',...
            num2str(kControlT(iUNIT)),',',...
            RoomFloor(iUNIT),',',...
            RoomName(iUNIT),',',...
            BldgType(iUNIT),',',...
            RoomType(iUNIT),',',...
            num2str(timeEV(iUNIT)),',',...
            num2str(Edesign_MWh(iUNIT)),',',...
            num2str(Edesign_MJ(iUNIT)),',',...
            num2str(Estandard_MWh(iUNIT)),',',...
            num2str(Estandard_MJ(iUNIT)),',',...
            num2str(y(3)/y(7)));
        
        rfc = [rfc; tmprfc];
    end
    
    
    % 出力
    fid = fopen(resfilenameD,'w+');
    for i=1:size(rfc,1)
        fprintf(fid,'%s\r\n',rfc{i});
    end
    fclose(fid);
    
end

