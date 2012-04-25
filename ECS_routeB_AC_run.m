% ECS_routeB_AC_run.m
%                                           by Masato Miyata 2012/04/25
%----------------------------------------------------------------------
% 省エネ基準：空調計算プログラム
%----------------------------------------------------------------------
% 入力
%  inputfilename : XMLファイル名称
%  OutputOption  : 出力制御（ON: 詳細出力、OFF: 簡易出力）
% 出力
%  y(1)  : 一次エネルギー消費量　評価値 [MJ/m2年]
%  y(2)  : 年間冷房負荷[MJ/m2・年]
%  y(3)  : 年間暖房負荷[MJ/m2・年]
%  y(4)  : 消費電力　全熱交換機 [MJ/m2]
%  y(5)  : 消費電力　空調ファン [MJ/m2]
%  y(6)  : 消費電力　二次ポンプ [MJ/m2]
%  y(7)  : 消費電力　熱源主機 [MJ/m2]
%  y(8)  : 消費電力　熱源補機 [MJ/m2]
%  y(9)  : 消費電力　一次ポンプ [MJ/m2]
%  y(10) : 消費電力　冷却塔ファン [MJ/m2]
%  y(11) : 消費電力　冷却水ポンプ [MJ/m2]
%  y(12) : 未処理負荷(冷) [MJ/m2]
%  y(13) : 未処理負荷(温) [MJ/m2]
%  y(14) : 熱源過負荷(冷) [MJ/m2]
%  y(15) : 熱源過負荷(温) [MJ/m2]
%  y(16) : CEC/AC* [-]
%  y(17) : 一次エネルギー消費量　基準値 [MJ/m2年]
%  y(18) : BEI (=評価値/基準値） [-]
%----------------------------------------------------------------------
% function y = ECS_routeB_AC_run(INPUTFILENAME,OutputOption)

clear
clc
tic
INPUTFILENAME = 'input.xml';
addpath('./subfunction/')
OutputOption = 'ON';

switch OutputOption
    case 'ON'
        OutputOptionVar = 1;
    case 'OFF'
        OutputOptionVar = 0;
    otherwise
        error('OutputOptionが不正です。ON か OFF で指定して下さい。')
end

% 計算モード（1:newHASPによる時刻別計算、2:newHASPによる日別計算、3:簡略法による日別計算）
MODE = 2;
% 熱源方式（2:二管式、4:四管式）
PIPE = 2;
% 負荷分割数（5か10）
DivNUM = 5;

% 夏、中間期、冬の順番、-1：暖房、+1：冷房
SeasonMODE = [1,1,-1];

% ファン・ポンプの発熱比率
k_heatup = 0.84;


%% 計算の設定

% 各種データベース
filename_calendar             = './database/CALENDAR.csv';   % カレンダー
filename_ClimateArea          = './database/AREA.csv';       % 地域区分
filename_RoomTypeList         = './database/ROOM_SPEC.csv';  % 室用途リスト
filename_roomOperateCondition = './database/ROOM_COND.csv';  % 標準室使用条件
filename_refList              = './database/REFLIST.csv';    % 熱源機器リスト
filename_performanceCurve     = './database/REFCURVE.csv';   % 熱源特性


%% データベース読み込み

mytscript_readDBfiles;     % CSVファイル読み込み
mytscript_readXMLSetting;  % XMLファイル読み込み


%% システム特性
if DivNUM == 5
    % 負荷マトリックス
    mxL = [0.2,0.4,0.6,0.8,1.0,1.2];
    % VAV効果係数
    kfVAVeffi = [0.1,0.3,0.5,0.7,0.9,1.0].^2;
    % VWV効果係数
    kpVWVeffi = [0.1,0.3,0.5,0.7,0.9,1.0].^2;
    
elseif DivNUM == 10
    
    mxL = [0.1:0.1:1.0,1.2];
    kfVAVeffi = [0.1:0.1:1.0,1.0].^2;
    kpVWVeffi = [0.1:0.1:1.0,1.0].^2;
    
else
    error('分割数 %s は指定できません', int2str(DivNUM))
end

aveL = zeros(size(mxL));
for iL = 1:length(mxL)
    if iL == 1
        aveL(iL) = mxL(iL)/2;
    else
        aveL(iL) = mxL(iL-1) + (mxL(iL)-mxL(iL-1))/2;
    end
end


% 冷暖房期間の設定
switch climateAREA
    case {'Ia','Ib'}
        WIN = [1:120,305:365]; MID = [121:181,274:304]; SUM = [182:273];
        
        mxTC   = [5,10,15,20,25,30];
        mxTH   = [-10,-5,0,5,10,15];
        ToadbC = [2.5,7.5,12.5,17.5,22.5,27.5];  % 外気温度 [℃]
        ToadbH = [-12.5,-7.5,-2.5,2.5,7.5,12.5]; % 外気温度 [℃]
        
        ToawbC = 0.8921.*ToadbC -1.0759;   % 湿球温度 [℃]
        ToawbH = 0.8921.*ToadbH -1.0759;   % 湿球温度 [℃]
        
        TctwC  = ToawbC + 3;
        
    case {'II','III','IVa','IVb','V'}
        WIN = [1:90,335:365]; MID = [91:151,274:334]; SUM = [152:273];
        
        mxTC   = [10,15,20,25,30,35];
        mxTH   = [-5,0,5,10,15,20];
        ToadbC = [7.5,12.5,17.5,22.5,27.5,32.5]; % 外気温度 [℃]
        ToadbH = [-7.5,-2.5,2.5,7.5,12.5,17.5];  % 外気温度 [℃]
        
        ToawbC = 0.9034.*ToadbC -1.4545;   % 湿球温度 [℃]
        ToawbH = 0.9034.*ToadbH -1.4545;   % 湿球温度 [℃]
        
        TctwC  = ToawbC + 3;

    case {'VI'}
        WIN = [1:90]; MID = [91:120,305:365]; SUM = [121:304];
        
        mxTC   = [10,15,20,25,30,35];
        mxTH   = [10,15,20,25,30,35];
        
        ToadbC = [7.5,12.5,17.5,22.5,27.5,32.5]; % 外気温度 [℃]
        ToadbH = [7.5,12.5,17.5,22.5,27.5,32.5]; % 外気温度 [℃]
        
        ToawbC = 1.0372.*ToadbC -3.9758;   % 湿球温度 [℃]
        ToawbH = 1.0372.*ToadbH -3.9758;   % 湿球温度 [℃]
        
        TctwC  = ToawbC + 3;
end


% 季節依存変数の定義（室内エンタルピー、運転モード）
Hroom = zeros(365,1);
ModeOpe = zeros(365,1);
SUMcell = {};
for iSUM = 1:length(SUM)
    SUMcell = [SUMcell;SUM(iSUM)];
    Hroom(SUM(iSUM),1) = 52.91; % 夏期（２６℃，５０％ＲＨ）
    ModeOpe(SUM(iSUM),1) = SeasonMODE(1);
end
MIDcell = {};
for iMID = 1:length(MID)
    MIDcell = [MIDcell;MID(iMID)];
    Hroom(MID(iMID),1) = 47.81; % 中間期（２４℃，５０％ＲＨ）
    ModeOpe(MID(iMID),1) = SeasonMODE(2);
end
WINcell = {};
for iWIN = 1:length(WIN)
    WINcell = [WINcell;WIN(iWIN)];
    Hroom(WIN(iWIN),1) = 38.81;  % 冬期（２２℃，４０％ＲＨ）
    ModeOpe(WIN(iWIN),1) = SeasonMODE(3);
end


% 機器データの加工
mytscript_systemDef;



%%-----------------------------------------------------------------------------------------------------------
%% １）室負荷の計算

switch MODE
    
    case {1,2}
        
        % newHASP設定ファイル(newHASPinput_室名.txt)自動生成
        mytscript_newHASPinputGen_run;
        
        % 負荷計算実行(newHASP)
        [QroomDc,QroomDh,QroomHour] = ...
            mytfunc_newHASPrun(roomID,climateDatabase,roomClarendarNum,roomArea,OutputOptionVar);
        
        % 気象データ読み込み
        [OAdataAll,OAdataDay,OAdataNgt,OAdataHourly] = mytfunc_weathdataRead('weath.dat');
        delete weath.dat
        
        
    case {3}
        
        % 負荷簡略計算法
        error('未実装')
        
end


%%-----------------------------------------------------------------------------------------------------------
%% ２）空調負荷計算

QroomAHUc     = zeros(365,numOfAHUs);  % 日積算室負荷（冷房）[MJ/day]
QroomAHUh     = zeros(365,numOfAHUs);  % 日積算室負荷（暖房）[MJ/day]
Qahu_hour     = zeros(365,numOfAHUs);  % 時刻別空調負荷[MJ/day]
Tahu_c        = zeros(365,numOfAHUs);  % 日積算冷房運転時間 [h]
Tahu_h        = zeros(365,numOfAHUs);  % 日積算暖房運転時間 [h]


% 日毎の空調運転時間(ahuDayMode: 1昼，2夜，0終日)
[AHUsystemT,ahuTime_start,ahuTime_stop,ahuDayMode] = ...
    mytfunc_AHUOpeTIME(ahuID,roomID,ahuQallSet,roomTime_start,roomTime_stop,roomDayMode);

switch MODE
    case {1}  % 毎時計算
        
        QroomAHUhour  = zeros(8760,numOfAHUs); % 時刻別室負荷 [MJ/h]
        Qahu_oac_hour = zeros(8760,numOfAHUs); % 外気冷房効果 [kW]
        qoaAHUhour    = zeros(8760,numOfAHUs); % 外気負荷 [kW]
        AHUVovc_hour  = zeros(8760,numOfAHUs); % 外気冷房時風量 [kg/s]
        qoaAHU_CEC_hour = zeros(8760,numOfAHUs); % 仮想外気負荷 [kW]
        Qahu_hour_CEC =  zeros(8760,numOfAHUs); % 仮想空調負荷 [MJ/h]
        
        % 日積算室負荷を空調系統ごとに集計
        for iROOM=1:numOfRoooms
            for iAHU=1:numOfAHUs
                switch roomID{iROOM}
                    case ahuQroomSet{iAHU,:}
                        QroomAHUc(:,iAHU)    = QroomAHUc(:,iAHU)    + QroomDc(:,iROOM).*roomCount(iROOM);   % 室数かける
                        QroomAHUh(:,iAHU)    = QroomAHUh(:,iAHU)    + QroomDh(:,iROOM).*roomCount(iROOM);   % 室数かける
                        QroomAHUhour(:,iAHU) = QroomAHUhour(:,iAHU) + QroomHour(:,iROOM).*roomCount(iROOM); % 室数かける
                end
            end
        end
        
        for iAHU = 1:numOfAHUs
            for dd = 1:365
                for hh = 1:24
                    
                    % 1月1日0時からの時間数
                    num = 24*(dd-1)+hh;
                    
                    % 時刻別の外気負荷[kW]を求める．
                    [qoaAHUhour(num,iAHU),AHUVovc_hour(num,iAHU),Qahu_oac_hour(num,iAHU),qoaAHU_CEC_hour(num,iAHU)]...
                        = mytfunc_calcOALoad_hourly(hh,ModeOpe(dd),AHUsystemT(dd,iAHU),...
                        ahuTime_start(dd,iAHU),ahuTime_stop(dd,iAHU),OAdataHourly(num,3),...
                        Hroom(dd,1),ahuVoa(iAHU),ahuOAcut(iAHU),AEXbypass(iAHU),ahuaexeff(iAHU),ahuOAcool(iAHU),ahuaexV(iAHU));
                    
                    % 空調負荷を求める．[kW] = [MJ/h]*1000/3600 + [kW]
                    Qahu_hour(num,iAHU) = QroomAHUhour(num,iAHU)*1000/3600 + qoaAHUhour(num,iAHU);
                    
                    % 仮想空調負荷を求める。 [MJ/h] 
                    Qahu_hour_CEC(num,iAHU) = abs(QroomAHUhour(num,iAHU)) + abs(qoaAHU_CEC_hour(num,iAHU)*3600/1000);
                    
                    % 冷暖房空調時間（日積算）を求める．
                    if Qahu_hour(num,iAHU) > 0
                        Tahu_c(dd,iAHU) = Tahu_c(dd,iAHU) + 1;
                    elseif Qahu_hour(num,iAHU) < 0
                        Tahu_h(dd,iAHU) = Tahu_h(dd,iAHU) + 1;
                    end
                    
                end
            end
        end
        
        
    case {2,3}  % 日単位の計算
        
        % 変数定義
        qoaAHU     = zeros(365,numOfAHUs);  % 日平均外気負荷 [kW]
        qoaAHU_CEC = zeros(365,numOfAHUs);  % 日平均仮想外気負荷 [kW]
        AHUVovc   = zeros(365,numOfAHUs);  % 外気冷房風量 [kg/s]
        Qahu_oac  = zeros(365,numOfAHUs);  % 外気冷房効果 [MJ/day]
        Qahu_c    = zeros(365,numOfAHUs);  % 日積算空調負荷(冷房) [MJ/day]
        Qahu_h    = zeros(365,numOfAHUs);  % 日積算空調負荷(暖房) [MJ/day]
        Qahu_CEC  = zeros(365,numOfAHUs);  % CECの仮想空調負荷 [MJ/day]
        
        for iAHU=1:numOfAHUs
            
            % 日積算室負荷を空調系統ごとに集計（QroomAHUc,QroomAHUhを求める）
            for iROOM=1:numOfRoooms
                switch roomID{iROOM}
                    case ahuQroomSet{iAHU,:}
                        QroomAHUc(:,iAHU) = QroomAHUc(:,iAHU) + QroomDc(:,iROOM);   % 室数かける
                        QroomAHUh(:,iAHU) = QroomAHUh(:,iAHU) + QroomDh(:,iROOM);   % 室数かける
                end
            end
            
            % 日別のループ
            for dd = 1:365
                
                % 空調運転時間の振り分け（冷房 Tahu_c・暖房 Tahu_h）
                [Tahu_c(dd,iAHU),Tahu_h(dd,iAHU)] = ...
                    mytfunc_AHUOpeTimeSplit(QroomAHUc(dd,iAHU),QroomAHUh(dd,iAHU),AHUsystemT(dd,iAHU));
                
                % 外気エンタルピー
                HoaDayAve = [];
                if ahuDayMode(iAHU) == 1
                    HoaDayAve = OAdataDay(dd,3);
                elseif ahuDayMode(iAHU) == 2
                    HoaDayAve = OAdataNgt(dd,3);
                elseif ahuDayMode(iAHU) == 0
                    HoaDayAve = OAdataAll(dd,3);
                end
                
                % 外気負荷 qoaAHU、外冷時風量 AHUVovc、外冷効果 Qahu_oac の算出
                [qoaAHU(dd,iAHU),AHUVovc(dd,iAHU),Qahu_oac(dd,iAHU),qoaAHU_CEC(dd,iAHU)] = ...
                    mytfunc_calcOALoad(ModeOpe(dd),QroomAHUc(dd,iAHU),Tahu_c(dd,iAHU),ahuVoa(iAHU),ahuVsa(iAHU),...
                    HoaDayAve,Hroom(dd,1),AHUsystemT(dd,iAHU),ahuaexeff(iAHU),AEXbypass(iAHU),ahuOAcool(iAHU),ahuaexV(iAHU));
                
                % 日積算空調負荷 Qahu_c, Qahu_h の算出
                [Qahu_c(dd,iAHU),Qahu_h(dd,iAHU),Qahu_CEC(dd,iAHU)] = mytfunc_calcDailyQahu(AHUsystemT(dd,iAHU),...
                    Tahu_c(dd,iAHU),Tahu_h(dd,iAHU),QroomAHUc(dd,iAHU),QroomAHUh(dd,iAHU),...
                    qoaAHU(dd,iAHU),qoaAHU_CEC(dd,iAHU),ahuOAcut(iAHU));
                
            end
        end
end


%%-----------------------------------------------------------------------------------------------------------
%% 空調エネルギー計算

% 空調負荷マトリックス作成 (AHUとFCUの運転時間は常に同じで良いか？→日積算であれば判別の仕様がない)
MxAHUc    = zeros(numOfAHUs,length(mxL));
MxAHUh    = zeros(numOfAHUs,length(mxL));
MxAHUcE   = zeros(numOfAHUs,length(mxL));
MxAHUhE   = zeros(numOfAHUs,length(mxL));
AHUvavfac = ones(numOfAHUs,length(mxL));
AHUaex    = zeros(1,numOfAHUs);

for iAHU = 1:numOfAHUs
    
    switch MODE
        case {1}
            % 時刻別計算の場合
            [MxAHUc(iAHU,:),MxAHUh(iAHU,:)] = ...
                mytfunc_matrixAHU(MODE,Qahu_hour(:,iAHU),ahuQcmax(iAHU),[],[],ahuQhmax(iAHU),[],PIPE,WIN,MID,SUM,mxL);
            
        case {2,3}
            % 日単位の計算の場合
            [MxAHUc(iAHU,:),MxAHUh(iAHU,:)] = ...
                mytfunc_matrixAHU(MODE,Qahu_c(:,iAHU),ahuQcmax(iAHU),Tahu_c(:,iAHU),...
                Qahu_h(:,iAHU),ahuQhmax(iAHU),Tahu_h(:,iAHU),PIPE,WIN,MID,SUM,mxL);
    end
    
    % CAVかVAVか
    if ahuFanVAV(iAHU) == 1
        AHUvavfac(iAHU,:) = kfVAVeffi;
        for i=1:length(mxL)
            if aveL(length(mxL)+1-i) < ahuFanVAVmin(iAHU) % VAV最小開度
                AHUvavfac(iAHU,length(mxL)+1-i) = AHUvavfac(iAHU,length(mxL)+1-i+1);
            end
        end
    end
    % エネルギー計算（空調機ファン） 出現時間 * 単位エネルギー [MWh]
    MxAHUcE(iAHU,:) = MxAHUc(iAHU,:).* ahuEfan(iAHU).*AHUvavfac(iAHU,:)./1000;
    MxAHUhE(iAHU,:) = MxAHUh(iAHU,:).* ahuEfan(iAHU).*AHUvavfac(iAHU,:)./1000;
    
    % 全熱交換機のエネルギー消費量 [MWh] →　バイパスの影響は？
    AHUaex(iAHU) = ahuaexE(iAHU).*sum(AHUsystemT(:,iAHU))./1000;
    
end

% 空調機のエネルギー消費量 [MWh]
E_fun = sum(sum(MxAHUcE+MxAHUhE));
E_aex = sum(AHUaex);

% 積算運転時間(システム毎)
TcAHU = sum(MxAHUc,2);
ThAHU = sum(MxAHUh,2);


%------------------------------
% 二管式/四管式の処理（未処理負荷を0にする）

% 未処理負荷 [MJ/day]
if PIPE == 2
    switch MODE
        case {1}
            
            Qahu_remainChour = zeros(8760,numOfAHUs);
            Qahu_remainHhour = zeros(8760,numOfAHUs);
            
            for iAHU = 1:numOfAHUs
                for dd = 1:365
                    for hh = 1:24
                        
                        num = 24*(dd-1)+hh;
                        
                        if ModeOpe(dd,1) == -1  % 暖房モード
                            if Qahu_hour(num,iAHU) > 0
                                Qahu_remainChour(num,iAHU) = Qahu_remainChour(num,iAHU) + Qahu_hour(num,iAHU);
                                Qahu_hour(num,iAHU) = 0;
                            end
                        elseif ModeOpe(dd,1) == 1  % 冷房モード
                            if Qahu_hour(num,iAHU) < 0
                                Qahu_remainHhour(num,iAHU) = Qahu_remainHhour(num,iAHU) + Qahu_hour(num,iAHU);
                                Qahu_hour(num,iAHU) = 0;
                            end
                        else
                            error('運転モード ModeOpe が不正です。')
                        end
                        
                    end
                end
            end
            
        case {2,3}
            
            Qahu_remainC = zeros(365,numOfAHUs);
            Qahu_remainH = zeros(365,numOfAHUs);

            for iAHU = 1:numOfAHUs
                for dd = 1:365
                    if ModeOpe(dd,1) == -1  % 暖房モード
                        if Qahu_c(dd,iAHU) > 0
                            Qahu_remainC(dd,iAHU) = Qahu_remainC(dd,iAHU) + abs(Qahu_c(dd,iAHU));
                            Qahu_c(dd,iAHU) = 0;
                        end
                        if Qahu_h(dd,iAHU) > 0
                            Qahu_remainC(dd,iAHU) = Qahu_remainC(dd,iAHU) + abs(Qahu_h(dd,iAHU));
                            Qahu_h(dd,iAHU) = 0;
                        end
                    elseif ModeOpe(dd,1) == 1  % 冷房モード
                        if Qahu_c(dd,iAHU) < 0
                            Qahu_remainH(dd,iAHU) = Qahu_remainH(dd,iAHU) + abs(Qahu_c(dd,iAHU));
                            Qahu_c(dd,iAHU) = 0;
                        end
                        if Qahu_h(dd,iAHU) < 0
                            Qahu_remainH(dd,iAHU) = Qahu_remainH(dd,iAHU) + abs(Qahu_h(dd,iAHU));
                            Qahu_h(dd,iAHU) = 0;
                        end
                    else
                        error('運転モード ModeOpe が不正です。')
                    end
                    
                end
            end
    end
end

%%-----------------------------------------------------------------------------------------------------------
%% 二次搬送系の負荷計算

switch MODE
    
    case {1}
        Qpsahu_fan_hour = zeros(8760,numOfPumps);  % ファン発熱量 [kW]
        Qpsahu_hour     = zeros(8760,numOfPumps);  % ポンプ負荷 [kW]
        
        for iPUMP = 1:numOfPumps
            
            % ポンプ負荷の積算
            for iAHU = 1:numOfAHUs
                switch ahuID{iAHU}  % 属する空調機を見つける
                    case PUMPahuSet{iPUMP}
                        
                        % ポンプ負荷[kW]
                        for num= 1:8760
                            
                            if PUMPtype(iPUMP) == 1 % 冷水ポンプ
                                
                                % ファン発熱量 [kW]
                                tmp = 0;
                                if ahuTypeNum(iAHU) == 1  % 空調機であれば
                                    if Qahu_hour(num,iAHU) > 0
                                        tmp = sum(MxAHUcE(iAHU,:))*(k_heatup)./TcAHU(iAHU,1).*1000;
                                        Qpsahu_fan_hour(num,iAHU) = Qpsahu_fan_hour(num,iAHU) + tmp;
                                    end
                                end
                                
                                if Qahu_hour(num,iAHU) > 0
                                    if ahuOAcool(iAHU) == 1 % 外冷あり
                                        if abs(Qahu_hour(num,iAHU) - Qahu_oac_hour(num,iAHU)) < 1
                                            Qpsahu_hour(num,iPUMP) = Qpsahu_hour(num,iPUMP) + 0;
                                        else
                                            Qpsahu_hour(num,iPUMP) = Qpsahu_hour(num,iPUMP) + Qahu_hour(num,iAHU) - Qahu_oac_hour(num,iAHU);
                                        end
                                    else
                                        Qpsahu_hour(num,iPUMP) = Qpsahu_hour(num,iPUMP) + Qahu_hour(num,iAHU) - Qahu_oac_hour(num,iAHU) + tmp;
                                    end
                                end

                            elseif PUMPtype(iPUMP) == 2 % 温水ポンプ
                                
                                % ファン発熱量 [kW]
                                tmp = 0;
                                if ahuTypeNum(iAHU) == 1  % 空調機であれば
                                    if Qahu_hour(num,iAHU) < 0
                                        tmp = sum(MxAHUhE(iAHU,:))*(k_heatup)./ThAHU(iAHU,1).*1000;
                                        Qpsahu_fan_hour(num,iAHU) = Qpsahu_fan_hour(num,iAHU) + tmp;
                                    end
                                end
                                
                                if Qahu_hour(num,iAHU) < 0
                                    Qpsahu_hour(num,iPUMP) = Qpsahu_hour(num,iPUMP) + (-1)*(Qahu_hour(num,iAHU)+tmp);
                                end
                            end
                        end
                end
            end
        end
        
        
    case {2,3}
        
        Qpsahu_fan = zeros(365,numOfPumps);   % ファン発熱量 [MJ/day]
        Tps        = zeros(365,numOfPumps);
        pumpTime_Start = zeros(365,numOfPumps);
        pumpTime_Stop  = zeros(365,numOfPumps);
        Qps = zeros(365,numOfPumps); % ポンプ負荷 [MJ/day]
        Tps = zeros(365,numOfPumps);
        
        for iPUMP = 1:numOfPumps
            
            % ポンプ負荷の積算
            for iAHU = 1:numOfAHUs
                switch ahuID{iAHU}
                    case PUMPahuSet{iPUMP}
                        
                        for dd = 1:365
                            
                            if PUMPtype(iPUMP) == 1 % 冷水ポンプ
                                
                                % ファン発熱量 Qpsahu_fan [MJ/day] の算出
                                tmp = 0;
                                if ahuTypeNum(iAHU) == 1  % 空調機であれば
                                    if Qahu_c(dd,iAHU) > 0
                                        tmp = sum(MxAHUcE(iAHU,:))*(k_heatup)./TcAHU(iAHU,1).*Tahu_c(dd,iAHU).*3600;
                                        Qpsahu_fan(dd,iPUMP) = Qpsahu_fan(dd,iPUMP) + tmp;
                                    end
                                    if Qahu_h(dd,iAHU) > 0
                                        tmp = sum(MxAHUhE(iAHU,:))*(k_heatup)./ThAHU(iAHU,1).*Tahu_h(dd,iAHU).*3600;
                                        Qpsahu_fan(dd,iPUMP) = Qpsahu_fan(dd,iPUMP) + tmp;
                                    end
                                end
                                
                                % 日積算ポンプ負荷 Qpsahu [MJ/day] の算出
                                if Qahu_c(dd,iAHU) > 0
                                    if Qahu_oac(dd,iAHU) > 0 % 外冷時はファン発熱量足さない　⇒　小さな負荷が出てしまう
                                        if abs(Qahu_c(dd,iAHU) - Qahu_oac(dd,iAHU)) < 1  % 計算誤差まるめ
                                            Qps(dd,iPUMP) = Qps(dd,iPUMP) + 0;
                                        else
                                            Qps(dd,iPUMP) = Qps(dd,iPUMP) + Qahu_c(dd,iAHU) - Qahu_oac(dd,iAHU);
                                        end
                                    else
                                        Qps(dd,iPUMP) = Qps(dd,iPUMP) + Qahu_c(dd,iAHU) - Qahu_oac(dd,iAHU) + tmp;
                                    end
                                end
                                if Qahu_h(dd,iAHU) > 0
                                    Qps(dd,iPUMP) = Qps(dd,iPUMP) + Qahu_h(dd,iAHU) - Qahu_oac(dd,iAHU) + tmp;
                                end
                                
                            elseif PUMPtype(iPUMP) == 2 % 温水ポンプ
                                
                                % ファン発熱量 Qpsahu_fan [MJ/day] の算出
                                tmp = 0;
                                if ahuTypeNum(iAHU) == 1  % 空調機であれば
                                    if Qahu_c(dd,iAHU) < 0
                                        tmp = sum(MxAHUcE(iAHU,:))*(k_heatup)./TcAHU(iAHU,1).*Tahu_c(dd,iAHU).*3600;
                                        Qpsahu_fan(dd,iPUMP) = Qpsahu_fan(dd,iPUMP) + tmp;
                                    end
                                    if Qahu_h(dd,iAHU) < 0
                                        tmp = sum(MxAHUhE(iAHU,:))*(k_heatup)./ThAHU(iAHU,1).*Tahu_h(dd,iAHU).*3600;
                                        Qpsahu_fan(dd,iPUMP) = Qpsahu_fan(dd,iPUMP) + tmp;
                                    end
                                end
                                
                                % 日積算ポンプ負荷 Qpsahu [MJ/day] の算出<符号逆転させる>
                                if Qahu_c(dd,iAHU) < 0
                                    Qps(dd,iPUMP) = Qps(dd,iPUMP) + (-1).*(Qahu_c(dd,iAHU) + tmp);
                                end
                                if Qahu_h(dd,iAHU) < 0
                                    Qps(dd,iPUMP) = Qps(dd,iPUMP) + (-1).*(Qahu_h(dd,iAHU) + tmp);
                                end
                                
                            end
                        end
                end
            end
            
            % ポンプ運転時間
            [Tps(:,iPUMP),pumpTime_Start(:,iPUMP),pumpTime_Stop(:,iPUMP)]...
                = mytfunc_PUMPOpeTIME(Qps(:,iPUMP),ahuID,PUMPahuSet{iPUMP},ahuTime_start,ahuTime_stop);
            
        end
end


%% ポンプエネルギー計算

% ポンプ定格能力（想定）[kW]
Qpsr = Td_PUMP.*pumpCount.*pumpFlow.*4.186*1000/3600;
MxPUMP    = zeros(numOfPumps,length(mxL));
MxPUMPNum = zeros(numOfPumps,length(mxL));
MxPUMPE   = zeros(numOfPumps,length(mxL));
PUMPvwvfac = ones(numOfPumps,length(mxL));

for iPUMP = 1:numOfPumps
    
    if Qpsr(iPUMP) ~= 0 % ビルマル用仮想ポンプは除く
        
        % ポンプ負荷マトリックス作成
        switch MODE
            case {1}
                MxPUMP(iPUMP,:) = mytfunc_matrixPUMP(MODE,Qpsahu_hour(:,iPUMP),Qpsr(iPUMP),[],mxL);
            case {2,3}
                MxPUMP(iPUMP,:) = mytfunc_matrixPUMP(MODE,Qps(:,iPUMP),Qpsr(iPUMP),Tps(:,iPUMP),mxL);
        end
        
        % ポンプ運転台数 [台]
        if PUMPnumctr(iPUMP) == 0
            MxPUMPNum(iPUMP,:) = pumpCount(iPUMP).*ones(1,length(mxL));
        elseif PUMPnumctr(iPUMP) == 1
            MxPUMPNum(iPUMP,:) = ceil(aveL.*pumpCount(iPUMP));
            
            % 過負荷の場合は最大台数で固定
            MxPUMPNum(iPUMP,length(mxL)) = pumpCount(iPUMP);
        end
        
        
        % CWVかVWVか
        if PUMPvwv(iPUMP) == 1
            if PUMPnumctr(iPUMP) == 0
                PUMPvwvfac(iPUMP,:) = kpVWVeffi;
                for i=1:length(mxL)
                    if aveL(length(mxL)+1-i) < pumpVWVmin(iPUMP) % VWV最小開度
                        PUMPvwvfac(iPUMP,length(mxL)+1-i) = PUMPvwvfac(iPUMP,length(mxL)+1-i+1);
                    end
                end
            elseif PUMPnumctr(iPUMP) == 1
                PUMPvwvfac(iPUMP,:) = kpVWVeffi.*(pumpCount(iPUMP)./MxPUMPNum(iPUMP,:));
                for i=1:length(mxL)
                    if aveL(length(mxL)+1-i) < pumpVWVmin(iPUMP) % VWV最小開度
                        PUMPvwvfac(iPUMP,length(mxL)+1-i) = PUMPvwvfac(iPUMP,length(mxL)+1-i+1);
                    end
                end
            end
        end
        
        % ポンプエネルギー消費量 [MWh]
        MxPUMPE(iPUMP,:) = MxPUMP(iPUMP,:).*MxPUMPNum(iPUMP,:).*pumpPower(iPUMP).*PUMPvwvfac(iPUMP,:)./1000;
        
    end
end

% エネルギー消費量 [MWh]
E_pump = sum(sum(MxPUMPE));
% 積算運転時間(システム毎)
TcPUMP = sum(MxPUMP,2);


%%-----------------------------------------------------------------------------------------------------------
%% 熱源系統の計算

switch MODE
    case {1}
        
        Qref_hour = zeros(8760,numOfRefs);   % 時刻別熱源負荷 [kW]
        Qref_OVER_hour = zeros(8760,numOfRefs);   % 過負荷 [MJ/h]
        
        for iREF = 1:numOfRefs
            
            % 日積算熱源負荷 [MJ/Day]
            for iPUMP = 1:numOfPumps
                switch pumpName{iPUMP}
                    case REFpumpSet{iREF}
                        % ポンプ発熱量 [kW]
                        if TcPUMP(iPUMP,1) ~= 0
                            pumpHeatup(iPUMP) = sum(MxPUMPE(iPUMP,:)).*(k_heatup)./TcPUMP(iPUMP,1).*1000;
                        else
                            pumpHeatup(iPUMP) = 0;  % 仮想ポンプ用
                        end
                        
                        for num=1:8760
                            if Qpsahu_hour(num,iPUMP) ~= 0  % 停止時除く
                                
                                if REFtype(iREF) == 1 % 冷房負荷→冷房熱源に
                                    
                                    tmp = Qpsahu_hour(num,iPUMP) + pumpHeatup(iPUMP);
                                    Qref_hour(num,iREF) = Qref_hour(num,iREF) + tmp;
                                    
                                elseif REFtype(iREF) == 2 % 暖房負荷→暖房熱源に
                                    
                                    tmp = Qpsahu_hour(num,iPUMP) - pumpHeatup(iPUMP);
                                    if tmp<0
                                        tmp = 0;
                                    end
                                    Qref_hour(num,iREF) = Qref_hour(num,iREF) + tmp;
                                    
                                end
                                
                            end
                        end
                end
            end
            
            for num = 1:8760
                if Qref_hour(num,iREF) > QrefrMax(iREF)
                    Qref_OVER_hour(num,iREF) = Qref_hour(num,iREF)*3600/1000;
                end
            end
            
        end
        
    case {2,3}
        
        Qref          = zeros(365,numOfRefs);    % 日積算熱源負荷 [MJ/day]
        Qref_kW       = zeros(365,numOfRefs);    % 日平均熱源負荷 [kW]
        Qref_OVER     = zeros(365,numOfRefs);    % 日積算過負荷 [MJ/day]
        Qpsahu_pump   = zeros(1,numOfPumps);     % ポンプ発熱量 [kW]
        Tref          = zeros(365,numOfRefs);
        refTime_Start = zeros(365,numOfRefs);
        refTime_Stop  = zeros(365,numOfRefs);
        
        for iREF = 1:numOfRefs
            
            % 日積算熱源負荷 [MJ/Day]
            for iPUMP = 1:numOfPumps
                switch pumpName{iPUMP}
                    case REFpumpSet{iREF}
                        
                        % 二次ポンプ発熱量 [kW]
                        if TcPUMP(iPUMP,1) > 0
                            Qpsahu_pump(iPUMP) = sum(MxPUMPE(iPUMP,:)).*(k_heatup)./TcPUMP(iPUMP,1).*1000;
                        end
                        
                        for dd = 1:365
                            
                            if REFtype(iREF) == 1  % 冷熱生成モード
                                % 日積算熱源負荷  [MJ/day]
                                if Qps(dd,iPUMP) > 0
                                    Qref(dd,iREF)  = Qref(dd,iREF) + Qps(dd,iPUMP) + Qpsahu_pump(iPUMP).*Tps(dd,iPUMP).*3600/1000;
                                end
                            elseif REFtype(iREF) == 2 % 温熱生成モード
                                % 日積算熱源負荷  [MJ/day] (Qpsの符号が変わっていることに注意)
                                if Qps(dd,iPUMP) + (-1).*Qpsahu_pump(iPUMP).*Tps(dd,iPUMP).*3600/1000 > 0
                                    Qref(dd,iREF)  = Qref(dd,iREF) + Qps(dd,iPUMP) + (-1).*Qpsahu_pump(iPUMP).*Tps(dd,iPUMP).*3600/1000;
                                end
                            end
                        end
                end
                
                % 熱源運転時間
                [Tref(:,iREF),refTime_Start(:,iREF),refTime_Stop(:,iREF)] =...
                    mytfunc_REFOpeTIME(Qref(:,iREF),pumpName,REFpumpSet{iREF},pumpTime_Start,pumpTime_Stop);
                
                % 瞬時負荷[kW]を出す。→　ピーク負荷を出すために必要。
                Qref_kW(:,iREF) = Qref(:,iREF)./Tref(:,iREF).*1000./3600;
                
                % 過負荷判定
                for dd = 1:365
                    if Qref_kW(dd,iREF) > QrefrMax(iREF)
                        % 過負荷分を足す [MJ/day]
                        Qref_OVER(dd,iREF) = Qref_kW(dd,iREF).*Tref(dd,iREF)*3600/1000;
                    end
                end
                
            end
        end
end


%% 熱源エネルギー計算
MxREF     = zeros(length(ToadbC),length(mxL),numOfRefs);
MxREFnum  = zeros(length(ToadbC),length(mxL),numOfRefs);
MxREFxL   = zeros(length(ToadbC),length(mxL),numOfRefs);
MxREFperE = zeros(length(ToadbC),length(mxL),numOfRefs);
MxREF_E   = zeros(numOfRefs,length(mxL));
MxREFSUBperE = zeros(length(ToadbC),length(mxL),numOfRefs,3);
MxREFSUBE = zeros(numOfRefs,3,length(mxL));
Qrefr_mod = zeros(numOfRefs,3,length(ToadbC));
Erefr_mod = zeros(numOfRefs,3,length(ToadbC));


for iREF = 1:numOfRefs
    
    % 熱源負荷マトリックス
    switch MODE
        case {1}
            if REFtype(iREF) == 1
                MxREF(:,:,iREF)  = mytfunc_matrixREF(MODE,Qref_hour(:,iREF),QrefrMax(iREF),[],OAdataAll,mxTC,mxL);
            else
                MxREF(:,:,iREF)  = mytfunc_matrixREF(MODE,Qref_hour(:,iREF),QrefrMax(iREF),[],OAdataAll,mxTH,mxL);
            end
            
        case {2,3}
            if REFtype(iREF) == 1
                MxREF(:,:,iREF)  = mytfunc_matrixREF(MODE,Qref(:,iREF),QrefrMax(iREF),Tref(:,iREF),OAdataAll,mxTC,mxL);
            else
                MxREF(:,:,iREF)  = mytfunc_matrixREF(MODE,Qref(:,iREF),QrefrMax(iREF),Tref(:,iREF),OAdataAll,mxTH,mxL);
            end
    end
    
    
    % 各熱源の計算
    for iREFSUB = 1:refsetRnum(iREF)   % 熱源台数分だけ繰り返す
        
        % 最大能力、最大入力の設定
        for iX = 1:length(ToadbC)
            
            % 各外気温区分における最大能力 [kW]
            Qrefr_mod(iREF,iREFSUB,iX) = refset_Capacity(iREF,iREFSUB) .* xQratio(iREF,iREFSUB,iX);
            
            % 各外気温区分における最大入力 [kW]  (1次エネルギー換算値であることに注意）
            Erefr_mod(iREF,iREFSUB,iX) = refset_MainPowerELE(iREF,iREFSUB) .* xPratio(iREF,iREFSUB,iX);
            
            xqsave(iREF,iX) = xTALL(iREF,iREFSUB,iX);
            xpsave(iREF,iX) = xTALL(iREF,iREFSUB,iX);
            
        end
    end
    
    
    % 運転台数
    if REFnumctr(iREF) == 0  % 台数制御なし
        
        MxREFnum(:,:,iREF) = refsetRnum(iREF).*ones(length(ToadbC),length(mxL));
        
    elseif REFnumctr(iREF) == 1 % 台数制御あり
        for ioa = 1:length(ToadbC)
            for iL = 1:length(mxL)
                
                % 処理負荷 [kW]
                tmpQ  = QrefrMax(iREF)*aveL(iL);
                
                if refsetRnum(iREF) == 1
                    if (Qrefr_mod(iREF,1,ioa) > tmpQ)
                        MxREFnum(ioa,iL,iREF) = 1;
                    else
                        MxREFnum(ioa,iL,iREF) = 1;
                    end
                    
                elseif refsetRnum(iREF) == 2
                    
                    if (Qrefr_mod(iREF,1,ioa) > tmpQ)
                        MxREFnum(ioa,iL,iREF) = 1;
                    elseif (Qrefr_mod(iREF,1,ioa)+Qrefr_mod(iREF,2,ioa) > tmpQ)
                        MxREFnum(ioa,iL,iREF) = 2;
                    else
                        MxREFnum(ioa,iL,iREF) = 2;
                    end
                    
                elseif refsetRnum(iREF) == 3
                    
                    if (Qrefr_mod(iREF,1,ioa) > tmpQ)
                        MxREFnum(ioa,iL,iREF) = 1;
                    elseif (Qrefr_mod(iREF,1,ioa)+Qrefr_mod(iREF,2,ioa) > tmpQ)
                        MxREFnum(ioa,iL,iREF) = 2;
                    elseif (Qrefr_mod(iREF,1,ioa)+Qrefr_mod(iREF,2,ioa)+Qrefr_mod(iREF,3,ioa) > tmpQ)
                        MxREFnum(ioa,iL,iREF) = 3;
                    else
                        MxREFnum(ioa,iL,iREF) = 3;
                    end
                    
                end
            end
        end
    end
    
    
    % 部分負荷率
    
    for ioa = 1:length(ToadbC)
        for iL = 1:length(mxL)
            
            % 処理負荷 [kW]
            tmpQ  = QrefrMax(iREF)*aveL(iL);
            
            if MxREFnum(ioa,iL,iREF) == 1
                MxREFxL(ioa,iL,iREF) = tmpQ./(Qrefr_mod(iREF,1,ioa));
            elseif MxREFnum(ioa,iL,iREF) == 2
                MxREFxL(ioa,iL,iREF) = tmpQ./(Qrefr_mod(iREF,1,ioa)+Qrefr_mod(iREF,2,ioa));
            elseif MxREFnum(ioa,iL,iREF) == 3
                MxREFxL(ioa,iL,iREF) = tmpQ./(Qrefr_mod(iREF,1,ioa)+Qrefr_mod(iREF,2,ioa)+Qrefr_mod(iREF,3,ioa));
            end
            
            % どの部分負荷特性を使うか（インバータターボなど、冷却水温度によって特性が異なる場合がある）
            if isnan(xXratioMX(iREF,iREFSUB)) == 0
                if xTALL(iREF,iREFSUB,ioa) <= xXratioMX(iREF,iREFSUB)
                    xCurveNum = 1;
                else
                    xCurveNum = 2;
                end
            else
                xCurveNum = 1;
            end
            
            % 上下限
            if MxREFxL(ioa,iL,iREF) < RerPerC_x_min(iREF,iREFSUB,xCurveNum)
                MxREFxL(ioa,iL,iREF) = RerPerC_x_min(iREF,iREFSUB,xCurveNum);
            elseif MxREFxL(ioa,iL,iREF) > RerPerC_x_max(iREF,iREFSUB,xCurveNum) || iL == length(mxL)
                MxREFxL(ioa,iL,iREF) = RerPerC_x_max(iREF,iREFSUB,xCurveNum);
            end

            % 部分負荷特性（各負荷率・各温度帯について）
            tmpL = MxREFxL(ioa,iL,iREF);
            for iREFSUB = 1:MxREFnum(ioa,iL,iREF)
                
                coeff_x(iREFSUB) = ...
                    RerPerC_x_coeffi(iREF,iREFSUB,xCurveNum,1).*tmpL.^4 + ...
                    RerPerC_x_coeffi(iREF,iREFSUB,xCurveNum,2).*tmpL.^3 + ...
                    RerPerC_x_coeffi(iREF,iREFSUB,xCurveNum,3).*tmpL.^2 + ...
                    RerPerC_x_coeffi(iREF,iREFSUB,xCurveNum,4).*tmpL + ...
                    RerPerC_x_coeffi(iREF,iREFSUB,xCurveNum,5);
                
                if iL == length(mxL)
                    coeff_x(iREFSUB) = coeff_x(iREFSUB).* 1.2;  % 過負荷時のペナルティ（要検討）
                end
                
            end
            
            % 送水温度特性
            if TC(iREF) < RerPerC_w_min(iREF,iREFSUB)
                TCtmp = RerPerC_w_min(iREF,iREFSUB);
            elseif TC(iREF) > RerPerC_w_max(iREF,iREFSUB)
                TCtmp = RerPerC_w_max(iREF,iREFSUB);
            else
                TCtmp = TC(iREF);
            end
            
            coeff_tw(iREFSUB) = RerPerC_w_coeffi(iREF,iREFSUB,1).*TCtmp.^4 + ...
                RerPerC_w_coeffi(iREF,iREFSUB,2).*TCtmp.^3 + RerPerC_w_coeffi(iREF,iREFSUB,3).*TCtmp.^2 +...
                RerPerC_w_coeffi(iREF,iREFSUB,4).*TCtmp + RerPerC_w_coeffi(iREF,iREFSUB,5);
            
            
            % エネルギー消費量 [kW] (1次エネルギー換算後の値であることに注意）
            if MxREFnum(ioa,iL,iREF) == 1
                
                MxREFperE(ioa,iL,iREF)      = Erefr_mod(iREF,1,ioa).*coeff_x(1).*coeff_tw(1);
                MxREFSUBperE(ioa,iL,iREF,1) = Erefr_mod(iREF,1,ioa).*coeff_x(1).*coeff_tw(1);
                
            elseif MxREFnum(ioa,iL,iREF) == 2
                
                MxREFperE(ioa,iL,iREF) = ...
                    Erefr_mod(iREF,1,ioa).*coeff_x(1).*coeff_tw(1) + ...
                    Erefr_mod(iREF,2,ioa).*coeff_x(2).*coeff_tw(2);
                
                MxREFSUBperE(ioa,iL,iREF,1) = Erefr_mod(iREF,1,ioa).*coeff_x(1).*coeff_tw(1);
                MxREFSUBperE(ioa,iL,iREF,2) = Erefr_mod(iREF,2,ioa).*coeff_x(2).*coeff_tw(2);
                
                
            elseif MxREFnum(ioa,iL,iREF) == 3
                
                MxREFperE(ioa,iL,iREF) = ...
                    Erefr_mod(iREF,1,ioa).*coeff_x(1).*coeff_tw(1) + ...
                    Erefr_mod(iREF,2,ioa).*coeff_x(2).*coeff_tw(2) + ...
                    Erefr_mod(iREF,3,ioa).*coeff_x(3).*coeff_tw(3);
                
                MxREFSUBperE(ioa,iL,iREF,1) = Erefr_mod(iREF,1,ioa).*coeff_x(1).*coeff_tw(1);
                MxREFSUBperE(ioa,iL,iREF,2) = Erefr_mod(iREF,2,ioa).*coeff_x(2).*coeff_tw(2);
                MxREFSUBperE(ioa,iL,iREF,3) = Erefr_mod(iREF,3,ioa).*coeff_x(3).*coeff_tw(3);
                
            end
            
        end
    end
    
    
    % 補機群のエネルギー消費量
    for ioa = 1:length(ToadbC)
        for iL = 1:length(mxL)
            if MxREFnum(ioa,iL,iREF) == 1
                ErefaprALL(ioa,iL,iREF)  = refset_SubPower(iREF,1);          % 補機電力
                EpprALL(ioa,iL,iREF)     = refset_PrimaryPumpPower(iREF,1);  % 一次ポンプ
                EctfanrALL(ioa,iL,iREF)  = refset_CTFanPower(iREF,1);        % 冷却塔ファン
                EctpumprALL(ioa,iL,iREF) = refset_CTPumpPower(iREF,1);       % 冷却水ポンプ
            elseif MxREFnum(ioa,iL,iREF) == 2
                ErefaprALL(ioa,iL,iREF)  = refset_SubPower(iREF,1) + refset_SubPower(iREF,2);
                EpprALL(ioa,iL,iREF)     = refset_PrimaryPumpPower(iREF,1) + refset_PrimaryPumpPower(iREF,2);
                EctfanrALL(ioa,iL,iREF)  = refset_CTFanPower(iREF,1) + refset_CTFanPower(iREF,2);
                EctpumprALL(ioa,iL,iREF) = refset_CTPumpPower(iREF,1) + refset_CTPumpPower(iREF,2);
            elseif MxREFnum(ioa,iL,iREF) == 3
                ErefaprALL(ioa,iL,iREF)  = refset_SubPower(iREF,1) + ...
                    refset_SubPower(iREF,2) + refset_SubPower(iREF,3);
                EpprALL(ioa,iL,iREF)     = refset_PrimaryPumpPower(iREF,1) + ...
                    refset_PrimaryPumpPower(iREF,2) + refset_PrimaryPumpPower(iREF,3);
                EctfanrALL(ioa,iL,iREF)  = refset_CTFanPower(iREF,1) + ...
                    refset_CTFanPower(iREF,2) + refset_CTFanPower(iREF,3);
                EctpumprALL(ioa,iL,iREF) = refset_CTPumpPower(iREF,1) + ...
                    refset_CTPumpPower(iREF,2) + refset_CTPumpPower(iREF,3);
            end
        end
    end
    
    MxREF_E(iREF,:)   = nansum(MxREF(:,:,iREF) .* MxREFperE(:,:,iREF)).*3600/1000;  % 熱源群エネルギー消費量  [MJ]
    MxREFACcE(iREF,:) = nansum(MxREF(:,:,iREF) .* ErefaprALL(:,:,iREF)./1000);  % 補機電力 [MWh]
    MxPPcE(iREF,:)    = nansum(MxREF(:,:,iREF) .* EpprALL(:,:,iREF)./1000);     % 一次ポンプ電力 [MWh]
    MxCTfan(iREF,:)   = nansum(MxREF(:,:,iREF) .* EctfanrALL(:,:,iREF)./1000);  % 冷却塔ファン電力 [MWh]
    MxCTpump(iREF,:)  = nansum(MxREF(:,:,iREF) .* EctpumprALL(:,:,iREF)./1000); % 冷却水ポンプ電力 [MWh]
    
    % 熱源別エネルギー消費量 [MJ]
    for iREFSUB = 1:refsetRnum(iREF)
        MxREFSUBE(iREF,iREFSUB,:) = nansum(MxREF(:,:,iREF) .* MxREFSUBperE(:,:,iREF,iREFSUB).*3600)./1000;
    end
    
    
end

% 熱源エネルギー消費量 [*] （各燃料の単位に戻す）
E_ref = zeros(1,8);
E_refsysr = sum(MxREF_E,2);

for iREF = 1:numOfRefs
    for iREFSUB = 1:refsetRnum(iREF)
        
        if refInputType(iREF,iREFSUB) == 1
            E_ref(1,refInputType(iREF,iREFSUB)) = E_ref(1,refInputType(iREF,iREFSUB)) + sum(sum(MxREFSUBE(iREF,iREFSUB,:)))./(9760);      % [MWh]
        elseif refInputType(iREF,iREFSUB) == 2
            E_ref(1,refInputType(iREF,iREFSUB)) = E_ref(1,refInputType(iREF,iREFSUB)) + sum(sum(MxREFSUBE(iREF,iREFSUB,:)))./(45000/1000); % [m3/h]
        elseif refInputType(iREF,iREFSUB) == 3
            E_ref(1,refInputType(iREF,iREFSUB)) = E_ref(1,refInputType(iREF,iREFSUB)) + sum(sum(MxREFSUBE(iREF,iREFSUB,:)))./(41000/1000);
        elseif refInputType(iREF,iREFSUB) == 4
            E_ref(1,refInputType(iREF,iREFSUB)) = E_ref(1,refInputType(iREF,iREFSUB)) + sum(sum(MxREFSUBE(iREF,iREFSUB,:)))./(37000/1000);
        elseif refInputType(iREF,iREFSUB) == 5
            E_ref(1,refInputType(iREF,iREFSUB)) = E_ref(1,refInputType(iREF,iREFSUB)) + sum(sum(MxREFSUBE(iREF,iREFSUB,:)))./(50000/1000);
        elseif refInputType(iREF,iREFSUB) == 6
            E_ref(1,refInputType(iREF,iREFSUB)) = E_ref(1,refInputType(iREF,iREFSUB)) + sum(sum(MxREFSUBE(iREF,iREFSUB,:)))./(1.36/1000);
        elseif refInputType(iREF,iREFSUB) == 7
            E_ref(1,refInputType(iREF,iREFSUB)) = E_ref(1,refInputType(iREF,iREFSUB)) + sum(sum(MxREFSUBE(iREF,iREFSUB,:)))./(1.36/1000);
        elseif refInputType(iREF,iREFSUB) == 8
            E_ref(1,refInputType(iREF,iREFSUB)) = E_ref(1,refInputType(iREF,iREFSUB)) + sum(sum(MxREFSUBE(iREF,iREFSUB,:)))./(1.36/1000);
        end
        
    end
end

% 熱源補機電力消費量 [MWh]
E_refac = sum(sum(MxREFACcE));
% 一次ポンプ電力消費量 [MWh]
E_pumpP = sum(sum(MxPPcE));
% 冷却塔ファン電力消費量 [MWh]
E_ctfan = sum(sum(MxCTfan));
% 冷却水ポンプ電力消費量 [MWh]
E_ctpump = sum(sum(MxCTpump));


%%-----------------------------------------------------------------------------------------------------------
%% エネルギー消費量合計

% 2次エネルギー
E2nd_total =[E_aex,zeros(1,7);E_fun,zeros(1,7);E_pump,zeros(1,7);E_ref;E_refac,zeros(1,7);...
    E_pumpP,zeros(1,7);E_ctfan,zeros(1,7);E_ctpump,zeros(1,7)];
E2nd_total = [E2nd_total;sum(E2nd_total)];

% 1次エネルギー [MJ]
unitE = [9760,45,41,37,50,1.36,1.36,1.36];
for i=1:size(E2nd_total,1)
    E1st_total(i,:) = E2nd_total(i,:) .* unitE;
end
E1st_total = [E1st_total,sum(E1st_total,2)];
E1st_total = [E1st_total;E1st_total(end,:)/roomAreaTotal];


%% 負荷合計
Qctotal = 0;
Qhtotal = 0;
Qcpeak = 0;
Qhpeak = 0;
Qcover = 0;
Qhover = 0;

switch MODE
    case {1}
        tmpQcpeak = zeros(8760,1);
        tmpQhpeak = zeros(8760,1);
        for iREF = 1:numOfRefs
            if REFtype(iREF) == 1  % 冷房 [kW]→[MJ/day]
                Qctotal = Qctotal + sum(Qref_hour(:,iREF)).*3600./1000;
                Qcover = Qcover + sum(Qref_OVER_hour(:,iREF));
                tmpQcpeak = tmpQcpeak + Qref_hour(:,iREF);
            else
                Qhtotal = Qhtotal + sum(Qref_hour(:,iREF)).*3600./1000;
                Qhover = Qhover + sum(Qref_OVER_hour(:,iREF));
                tmpQhpeak = tmpQhpeak + Qref_hour(:,iREF);
            end
        end
        
    case {2,3}
        tmpQcpeak = zeros(365,1);
        tmpQhpeak = zeros(365,1);
        
        for iREF = 1:numOfRefs
            if REFtype(iREF) == 1  % 冷房 [MJ/day]
                Qctotal = Qctotal + sum(Qref(:,iREF));
                Qcover = Qcover + sum(Qref_OVER(:,iREF));
                tmpQcpeak = tmpQcpeak + Qref_kW(:,iREF);
            else
                Qhtotal = Qhtotal + sum(Qref(:,iREF));
                Qhover = Qhover + sum(Qref_OVER(:,iREF));
                tmpQhpeak = tmpQhpeak + Qref_kW(:,iREF);
            end
        end
end

% ピーク負荷 [W/m2]
Qcpeak = max(tmpQcpeak)./roomAreaTotal .*1000;
Qhpeak = max(tmpQhpeak)./roomAreaTotal .*1000;


%% 基準値計算

switch climateAREA
    case 'Ia'
        stdLineNum = 1;
    case 'Ib'
        stdLineNum = 2;
    case 'II'
        stdLineNum = 3;
    case 'III'
        stdLineNum = 4;
    case 'IVa'
        stdLineNum = 5;
    case 'IVb'
        stdLineNum = 6;
    case 'V'
        stdLineNum = 7;
    case 'VI'
        stdLineNum = 8;
end

standardValue = mytfunc_calcStandardValue(buildingType,roomType,roomArea,stdLineNum)/sum(roomArea);


%----------------------------
% 計算結果取りまとめ

y(1)  = E1st_total(end,end);  % 一次エネルギー消費量合計 [MJ/m2]
y(2)  = Qctotal/roomAreaTotal; % 年間冷房負荷[MJ/m2・年]
y(3)  = Qhtotal/roomAreaTotal; % 年間暖房負荷[MJ/m2・年]
y(4)  = E1st_total(1,end)/roomAreaTotal;  % 全熱交換機 [MJ/m2]
y(5)  = E1st_total(2,end)/roomAreaTotal;  % 空調ファン [MJ/m2]
y(6)  = E1st_total(3,end)/roomAreaTotal;  % 二次ポンプ [MJ/m2]
y(7)  = E1st_total(4,end)/roomAreaTotal;  % 熱源主機 [MJ/m2]
y(8)  = E1st_total(5,end)/roomAreaTotal;  % 熱源補機 [MJ/m2]
y(9)  = E1st_total(6,end)/roomAreaTotal;  % 一次ポンプ [MJ/m2]
y(10) = E1st_total(7,end)/roomAreaTotal;  % 冷却塔ファン [MJ/m2]
y(11) = E1st_total(8,end)/roomAreaTotal;  % 冷却水ポンプ [MJ/m2]


% CEC/ACのようなもの（未処理負荷は差し引く）
switch MODE
    case {1}
        % 未処理負荷[MJ/m2]
        y(12) = nansum(sum(abs(Qahu_remainChour)))./roomAreaTotal;
        y(13) = nansum(sum(abs(Qahu_remainHhour)))./roomAreaTotal;
        y(14) = nansum(Qcover)./roomAreaTotal;
        y(15) = nansum(Qhover)./roomAreaTotal;
        y(16) = y(1)./( ((sum(sum(Qahu_hour_CEC))))./roomAreaTotal -y(12) -y(13) );
    case {2}
        % 未処理負荷[MJ/m2]
        y(12) = nansum(sum(abs(Qahu_remainC)))./roomAreaTotal;
        y(13) = nansum(sum(abs(Qahu_remainH)))./roomAreaTotal;
        y(14) = nansum(Qcover)./roomAreaTotal;
        y(15) = nansum(Qhover)./roomAreaTotal;
        y(16) = y(1)./( ((sum(sum(Qahu_CEC))))./roomAreaTotal -y(12) -y(13) );
end

y(17) = standardValue;
y(18) = y(1)/y(17);

%%-----------------------------------------------------------------------------------------------------------
%% 詳細出力
if OutputOptionVar == 1 && MODE == 2
    mytscript_result2csv;
end

%% 簡易出力
% 出力するファイル名
if isempty(strfind(INPUTFILENAME,'/'))
    eval(['resfilenameS = ''calcRES_',INPUTFILENAME(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(INPUTFILENAME,'/');
    eval(['resfilenameS = ''calcRES',INPUTFILENAME(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
end
csvwrite(resfilenameS,y);



disp('---------')
eval(['disp(''一次エネルギー消費量 評価値： ', num2str(y(1)) ,'  MJ/m2・年'')'])
eval(['disp(''一次エネルギー消費量 基準値： ', num2str(y(17)) ,'  MJ/m2・年'')'])
eval(['disp(''BEI/AC       ： ', num2str(y(18)) ,''')'])
disp('---------')
eval(['disp(''年間冷房負荷： ', num2str(y(2)) ,'  MJ/m2・年'')'])
eval(['disp(''年間暖房負荷： ', num2str(y(3)) ,'  MJ/m2・年'')'])
disp('---------')
eval(['disp(''全熱交換機Ｅ  ： ', num2str(y(4)) ,'  MJ/m2・年'')'])
eval(['disp(''空調ファンＥ  ： ', num2str(y(5)) ,'  MJ/m2・年'')'])
eval(['disp(''二次ポンプＥ  ： ', num2str(y(6)) ,'  MJ/m2・年'')'])
eval(['disp(''熱源主機Ｅ    ： ', num2str(y(7)) ,'  MJ/m2・年'')'])
eval(['disp(''熱源補機Ｅ    ： ', num2str(y(8)) ,'  MJ/m2・年'')'])
eval(['disp(''一次ポンプＥ  ： ', num2str(y(9)) ,'  MJ/m2・年'')'])
eval(['disp(''冷却塔ファンＥ： ', num2str(y(10)) ,'  MJ/m2・年'')'])
eval(['disp(''冷却水ポンプＥ： ', num2str(y(11)) ,'  MJ/m2・年'')'])
disp('---------')
eval(['disp(''ピーク負荷(冷)： ', num2str(Qcpeak) ,'  W/m2'')'])
eval(['disp(''ピーク負荷(温)： ', num2str(Qhpeak) ,'  W/m2'')'])
eval(['disp(''未処理負荷(冷)： ', num2str(y(12)) ,'  MJ/m2・年'')'])
eval(['disp(''未処理負荷(温)： ', num2str(y(13)) ,'  MJ/m2・年'')'])
eval(['disp(''熱源過負荷(冷)： ', num2str(y(14)) ,'  MJ/m2・年'')'])
eval(['disp(''熱源過負荷(温)： ', num2str(y(15)) ,'  MJ/m2・年'')'])
eval(['disp(''CEC/AC*      ： ', num2str(y(16)) ,''')'])

