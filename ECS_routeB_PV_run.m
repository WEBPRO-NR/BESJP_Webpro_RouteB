% ECS_routeB_PV_run.m
%                                          by Masato Miyata 2012/10/12
%----------------------------------------------------------------------
% 省エネ基準：太陽光発電計算プログラム
%----------------------------------------------------------------------
% 入力
%  inputfilename : XMLファイル名称
%  OutputOption  : 出力制御（ON: 詳細出力、OFF: 簡易出力）
% 出力
%  y(1) : 創エネルギー量 [MJ/年]
%----------------------------------------------------------------------
function y = ECS_routeB_PV_run(inputfilename,OutputOption)

% clear
% clc
% inputfilename = './model_routeB_sample01.xml';
% addpath('./subfunction/')
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


%% 気象データ等読み込み

% データベース読み込み
mytscript_readDBfiles;

% 地域区分
climateAREA = num2str(model.ATTRIBUTE.Region);

check = 0;
for iDB = 1:length(perDB_climateArea(:,2))
    if strcmp(perDB_climateArea(iDB,1),climateAREA) || strcmp(perDB_climateArea(iDB,2),climateAREA)
        % 気象データファイル名
        eval(['climatedatafile  = ''./weathdat/C1_',perDB_climateArea{iDB,6},''';'])
        % 緯度
        phi   = str2double(perDB_climateArea(iDB,4));
        % 経度
        longi = str2double(perDB_climateArea(iDB,5));
        
        check = 1;
    end
end
if check == 0
    error('地域区分が不正です')
end

% 日射データ読み込み(外気温、法線面直達日射量、水平面天空日射量、水平面夜間放射量)
[ToutALL,~,IodALL,IosALL,InnALL] = mytfunc_climatedataRead(climatedatafile);


%% 情報の抽出

% ユニット数
numOfUnit =  length(model.PhotovoltaicGenerationSystems.PhotovoltaicGeneration);

PV_Name = cell(numOfUnit,1);
PV_Type = cell(numOfUnit,1);
PV_InstallationMode = cell(numOfUnit,1);
PV_Capacity = zeros(numOfUnit,1);
PV_PanelDirection = zeros(numOfUnit,1);
PV_PanelAngle = zeros(numOfUnit,1);
PV_SolorIrradiationRegion = cell(numOfUnit,1);
PV_Info = cell(numOfUnit,1);

for iUNIT = 1:numOfUnit
    
    % 名称
    PV_Name{iUNIT} = ...
        model.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.Name;
    % 太陽電池の種類
    PV_Type{iUNIT} = ...
        model.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.Type;
    % アレイ設置方式
    PV_InstallationMode{iUNIT} = ...
        model.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.InstallationMode;
    % アレイのシステム容量
    PV_Capacity(iUNIT) = ...
        model.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.Capacity;
    % パネルの方位角
    PV_PanelDirection(iUNIT) = ...
        model.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.PanelDirection;
    % パネルの傾斜角
    PV_PanelAngle(iUNIT) = ...
        model.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.PanelAngle;
    % 年間日射量地域区分
    PV_SolorIrradiationRegion{iUNIT} = ...
        model.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.SolorIrradiationRegion;
    % 備考
    PV_Info{iUNIT} = ...
        model.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.Info;
    
end


%% 太陽電池アレイによる年間発電量の計算

Ep = zeros(numOfUnit,1);

for iUNIT = 1:numOfUnit
    
    % 太陽電池アレイの総合設計係数を求める。
    
    switch PV_Type{iUNIT}
        case 'Crystalline'  % 結晶系
            Khd = 0.97; % 日射量年変動補正係数
            Khs = 1.0;  % 日陰補正係数
            Kpd = 0.95; % 継時変化補正係数
            Kpa = 0.94; % アレイ負荷整合補正係数
            Kpm = 0.97; % アレイ回路補正係数
            Kin = 0.90; % インバータ回路補正係数
            apmax = -0.41;  % 最大出力温度係数
        case 'NonCrystalline'  % 非結晶系
            Khd = 0.97; % 日射量年変動補正係数
            Khs = 1.0;  % 日陰補正係数
            Kpd = 0.87; % 継時変化補正係数
            Kpa = 0.94; % アレイ負荷整合補正係数
            Kpm = 0.97; % アレイ回路補正係数
            Kin = 0.90; % インバータ回路補正係数
            apmax = -0.20;  % 最大出力温度係数
        otherwise
            error('太陽電池の種類が不正です')
    end
    
    % モジュール温度を求めるための係数 Fa
    switch PV_InstallationMode{iUNIT}
        case 'RackMountType'  % 架台設置形
            Fa = 46;
        case 'RoomMountType'  % 屋根置き形
            Fa = 50;
        case 'Others'  % その他
            Fa = 57;
        otherwise
            error('アレイ設置方式が不正です')
    end
    
    % パネルに入射する日射量を求める : hourlyIds => (365×24) [W/m2]
    [~,hourlyIds] = mytfunc_calcSolorRadiation(IodALL,IosALL,InnALL,phi,longi,...
        PV_PanelDirection(iUNIT),PV_PanelAngle(iUNIT),1);
    
    % 太陽電池アレイの加重平均太陽電池モジュール温度 Tcr(365×24)
    Tcr = ToutALL + (Fa+2).*hourlyIds./1000 - 2;
    
    % 太陽電池アレイの温度補正係数 Kpt(365×24)
    Kpt = 1 + apmax./100.*(Tcr-25);
    
    % 太陽電池アレイの総合設計係数 Kp(365×24)
    Kp = (Khd*Khs*Kpd*Kpa*Kpm*Kin)*ones(365,24) .* Kpt;
    
    % 太陽電池アレイによる年間発電量 [MJ]
    Ep(iUNIT) =sum(sum( PV_Capacity(iUNIT)*ones(365,24) .* hourlyIds .* Kp * 3600*10^(-6) ));
    
end

% 年間創エネルギー量合計 [MJ/年]
y = sum(Ep);


