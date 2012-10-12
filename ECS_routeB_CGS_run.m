% ECS_routeB_CGS_run.m
%                                          by Masato Miyata 2012/10/12
%----------------------------------------------------------------------
% 省エネ基準：コジェネレーションシステム計算プログラム
%----------------------------------------------------------------------
% 入力
%  inputfilename : XMLファイル名称
%  OutputOption  : 出力制御（ON: 詳細出力、OFF: 簡易出力）
% 出力
%  y(1) : 省エネルギー量 [MJ/年]
%----------------------------------------------------------------------
function y = ECS_routeB_CGS_run(inputfilename,OutputOption)

% clear
% clc
% inputfilename = './output.xml';
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


%% 情報の抽出

% システム数
numOfSystem =  length(model.CogenerationSystems.CogenerationSet);

for iSYS = 1:numOfSystem
    
    % 年間電力需要 [MWh]
    DemandAC(iSYS)     = model.CogenerationSystems.CogenerationSet(iSYS).ATTRIBUTE.ElectricalDemand_AC;
    DemandV(iSYS)      = model.CogenerationSystems.CogenerationSet(iSYS).ATTRIBUTE.ElectricalDemand_V;
    DemandL(iSYS)      = model.CogenerationSystems.CogenerationSet(iSYS).ATTRIBUTE.ElectricalDemand_L;
    DemandHW(iSYS)     = model.CogenerationSystems.CogenerationSet(iSYS).ATTRIBUTE.ElectricalDemand_HW;
    DemandEV(iSYS)     = model.CogenerationSystems.CogenerationSet(iSYS).ATTRIBUTE.ElectricalDemand_EV;
    DemandOthers(iSYS) = model.CogenerationSystems.CogenerationSet(iSYS).ATTRIBUTE.ElectricalDemand_Others;
    
    % コジェネレーションユニットの数
    numOfUnit(iSYS) = length(model.CogenerationSystems.CogenerationSet(iSYS).CogenerationUnit);
    
    for iUNIT = 1:numOfUnit(iSYS)
        
        % 発電効率 [-]
        effc(iSYS,iUNIT) = ...
            model.CogenerationSystems.CogenerationSet(iSYS).CogenerationUnit(iUNIT).ATTRIBUTE.GeneratingEfficiency;
        % 排熱回収率 [-]
        effh(iSYS,iUNIT) = ...
            model.CogenerationSystems.CogenerationSet(iSYS).CogenerationUnit(iUNIT).ATTRIBUTE.ExhaustHeatRecoveryRatio;
        % 発電依存率 [-]
        a(iSYS,iUNIT) = ...
            model.CogenerationSystems.CogenerationSet(iSYS).CogenerationUnit(iUNIT).ATTRIBUTE.ElectricalDependencyRatio;
        % 有効熱利用率 [-]
        R(iSYS,iUNIT) = ...
            model.CogenerationSystems.CogenerationSet(iSYS).CogenerationUnit(iUNIT).ATTRIBUTE.HeatUtilizationRatio;
        % 有効排熱量の冷熱利用比 [-]
        alpha(iSYS,iUNIT) = ...
            model.CogenerationSystems.CogenerationSet(iSYS).CogenerationUnit(iUNIT).ATTRIBUTE.RatioForCooling;
        % 温水吸収冷凍機または排熱投入型冷温水機の成績係数 [-]
        COPgar(iSYS,iUNIT) = ...
            model.CogenerationSystems.CogenerationSet(iSYS).CogenerationUnit(iUNIT).ATTRIBUTE.RefrigeratorCOP;
        
    end
end


%% 年間創エネルギー量の計算

Kele = 9760;     % 電力の一次エネルギー換算値 [kJ/kWh]
effboiler = 0.8; % 温水ボイラ効率 [-]
COPar = 1.0;     % 冷温水発生器の冷熱生成時の成績係数 [-]

for iSYS = 1:numOfSystem
    
    % 年間電力需要量 [MWh/年]
    E = DemandAC(iSYS) + DemandV(iSYS) + DemandL(iSYS) + DemandHW(iSYS) + DemandEV(iSYS) + DemandOthers(iSYS);
    
    for iUNIT = 1:numOfUnit(iSYS)
        
        tmpA = 3600*a(iSYS,iUNIT)*E/effc(iSYS,iUNIT);
        tmpB = 9760*effc(iSYS,iUNIT)/3600;
        tmpC = R(iSYS,iUNIT)*effh(iSYS,iUNIT);
        tmpD = (1-alpha(iSYS,iUNIT))/effboiler + alpha(iSYS,iUNIT)*COPgar(iSYS,iUNIT)/COPar;
        
        % 省エネルギー量 [MJ/年]
        Eper(iSYS,iUNIT) =  tmpA*(tmpB + tmpC*tmpD - 1);
        
    end
end

% 年間省エネルギー量合計 [MJ/年]
y = sum(sum(Eper));

