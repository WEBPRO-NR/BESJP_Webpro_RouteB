% ECS_routeB_CGSdetail_run.m
%--------------------------------------------------------------------------
% コジェネ（詳細版）の計算プログラム
%--------------------------------------------------------------------------

function y = ECS_routeB_CGSdetail_run(inputfilename,OutputOption)

% clear
% clc
% tic
% inputfilename = './InputFiles/1005_コジェネテスト/model_CGS_case00.xml';
% OutputOption = 'ON';
% addpath('./subfunction/')



%% 2.	計算設定、事前処理

% 建物モデル読み込み
model = xml_read(inputfilename);

% 他設備計算結果の読み込み
load CGSmemory.mat

% 2.1

% CGSの発電機容量	kW
Ecgs_rated = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.CGUCapacity;
% CGS設置台数	台
Ncgs = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Count;
% CGSの定格発電効率(低位発熱量基準)	無次元
fcgs_e_rated = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.PowerGenerationEfficiency100;
% CGSの負荷率0.75時発電効率(低位発熱量基準)	無次元
fcgs_e_75 = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.PowerGenerationEfficiency075;
% CGSの負荷率0.50時発電効率(低位発熱量基準)	無次元
fcgs_e_50 = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.PowerGenerationEfficiency050;
% CGSの定格排熱効率(低位発熱量基準)	無次元
fcgs_hr_rated = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.HeatRecoveryEfficiency100;
% CGSの負荷率0.75時排熱効率(低位発熱量基準)	無次元
fcgs_hr_75 = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.HeatRecoveryEfficiency075;
% CGSの負荷率0.50時排熱効率(低位発熱量基準)	無次元
fcgs_hr_50 = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.HeatRecoveryEfficiency050;
% 排熱利用優先順位(冷熱源)　※1	無次元
npri_hr_c = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_cooling;
% 排熱利用優先順位(温熱源) 　※1	無次元
npri_hr_h = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_heating;
% 排熱利用優先順位(給湯) 　※1	無次元
npri_hr_w = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_hotwater;
% CGS24時間運転の有無　※2	-
C24ope = model.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Operation24H;



% 排熱投入型吸収式冷温水機jの定格冷却能力	ｋW/台
qAC_link_c_j_rated = CGSmemory.qAC_link_c_j_rated;
% 排熱投入型吸収式冷温水機jの主機定格消費エネルギー	ｋW/台
EAC_link_c_j_rated = CGSmemory.EAC_link_c_j_rated;

% 2.2

% 日付dにおける空気調和設備の電力消費量	MWh/日
EAC_total_d = CGSmemory.RESALL(:,2);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての主機の一次エネルギー消費量	MJ/日
EAC_ref_c_d = CGSmemory.RESALL(:,7);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての負荷率 	無次元
mxLAC_ref_c_d = CGSmemory.RESALL(:,8);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の主機の一次エネルギー消費量	MJ/日
EAC_ref_h_hr_d = CGSmemory.RESALL(:,9);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の熱源負荷	MJ/日
qAC_ref_h_hr_d = CGSmemory.RESALL(:,10);
% 日付dにおける機械換気設備の電力消費量	MWh/日
EV_total_d = CGSmemory.RESALL(:,11);
% 日付dにおける照明設備の電力消費量	MWh/日
EL_total_d = CGSmemory.RESALL(:,12);
% 日付dにおける給湯設備の電力消費量	MWh/日
EW_total_d = CGSmemory.RESALL(:,13);
% 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の一次エネルギー消費量	MJ/日
EW_hr_d = CGSmemory.RESALL(:,14);
% 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の給湯負荷	MJ/日
qW_hr_d = CGSmemory.RESALL(:,15);
% 日付dにおける昇降機の電力消費量	MWh/日
EEV_total_d = CGSmemory.RESALL(:,16);
% 日付dにおける効率化設備（太陽光発電）の発電量	MWh/日
EPV_total_d = CGSmemory.RESALL(:,17);
% 日付dにおけるその他の電力消費量	MWh/日
EM_total_d = CGSmemory.RESALL(:,18);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の運転時間	h/日
TAC_c_d = CGSmemory.RESALL(:,19);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の運転時間	h/日
TAC_h_d = CGSmemory.RESALL(:,20);


% 2.3 その他設定値

% 運転判定基準必要電力比率	無次元
feopeMn	= 0.5;
% 運転判定基準必要排熱比率	無次元
fhopeMn	=0.5;
% CGS補機動力比率	無次元
fesub_CGS_wc = 0.06; % 冷却塔がある場合
fesub_CGS_ac = 0.05; % 冷却塔がない場合
% ガスの高位発熱量に対する低位発熱量の比率	無次元
flh	=0.90222;
% 電気の一次エネルギー換算係数	MJ/kWh
fprime_e = 9.76;
% 排熱投入型吸収式冷温水機の排熱利用時のCOP	無次元
fCOP_link_hr = 0.75;
% CGSによる電力負荷の最大負担率	無次元
felmax = 0.95;
% CGSの標準稼働時間 h/日
Tstn = 14;
% 発電効率補正
fcgs_e_cor = 0.99;
% 排熱の熱損失率の補正
fhr_loss = 0.97;

% 建物の運用時間帯と非運用時間帯の平均電力差 feopeHi の算出
load CGSmemory.mat  % ECS_routeB_Others_run.m で算出

ratio_AreaWeightedSchedule = CGSmemory.ratio_AreaWeightedSchedule;
Ee_total_hour = zeros(8760,1);
feopeHi = ones(365,1);

for dd = 1:365
    for hh = 1:24
        
        nn = 24*(dd-1)+hh;
        
        Ee_total_hour(nn,1) = EAC_total_d(dd,1) .* ratio_AreaWeightedSchedule(nn,1) ...
            +  EV_total_d(dd,1)./24 ...
            +  EL_total_d(dd,1) .* ratio_AreaWeightedSchedule(nn,2) ...
            +  EW_total_d(dd,1)./24 ...
            +  EEV_total_d(dd,1)./24 ...
            +  EM_total_d(dd,1).* ratio_AreaWeightedSchedule(nn,3);
        
    end
end

for dd = 1:365
    
    % 運転時間 7時から20時までの14時間）
    Eday   = sum(Ee_total_hour(24*(dd-1)+7:24*(dd-1)+20,1)) - EPV_total_d(dd);
    Enight = sum(Ee_total_hour(24*(dd-1)+1:24*(dd-1)+6,1)) +  sum(Ee_total_hour(24*(dd-1)+21:24*(dd-1)+24,1));
    
    if Eday < 0
        feopeHi(dd,1) = 1;
    elseif Enight == 0
        feopeHi(dd,1) = 100;
    else
        feopeHi(dd,1) = Eday ./ Enight;
    end
    
    % 上限・下限
    if feopeHi(dd,1) < 1
        feopeHi(dd,1) = 1;
    elseif feopeHi(dd,1) > 100
        feopeHi(dd,1) = 100;
    end
end


% 検証用
% feopeHi = ones(365,1).*10;


% 2.4 CGS特性式各係数
[fe2,fe1,fe0,fhr2,fhr1,fhr0] = perfCURVE(fcgs_e_rated,fcgs_e_75,fcgs_e_50,fcgs_hr_rated,fcgs_hr_75,fcgs_hr_50);

% 2.5 最大稼働時間
if strcmp(C24ope,'True')
    T_ST = 24;
else
    T_ST = Tstn;
end


%% 3. 負荷集計と運転時間計算

% 3.1 電力負荷
% Ee_total_d : 日付dおける建物の電力消費量 [kWh/day]

Ee_total_d = ( EAC_total_d +EV_total_d + EL_total_d + EW_total_d + EEV_total_d + EM_total_d - EPV_total_d ) .* 1000;


% 3.2 排熱投入型温水吸収冷温水機の排熱利用可能率
% flink_d : 日付dにおける排熱投入型吸収式冷温水機の排熱利用可能率

flink_rated_b = 0.15;  % 排熱投入型吸収式冷温水機の定格運転時の排熱投入可能率 [-]
flink_min_b = 0.30;    % 排熱投入型吸収式冷温水機が排熱のみで運転できる最大負荷率 [-]
flink_down = 0.125;  % 排熱温度による排熱投入可能率の低下率 [-]

flink_rated = flink_rated_b * (1 - flink_down);
flink_min   = flink_min_b - (flink_rated_b - flink_rated);

mx      = zeros(365,1);
flink_d = zeros(365,1);
for dd = 1:365
    
    mx(dd,1) = mxLAC_ref_c_d(dd,1);
    
    if mx(dd,1) < flink_min
        
        flink_d(dd,1) = 1.0;
        
    else
        
        k = (flink_rated - flink_min) / (1 - flink_min);
        
        flink_d(dd,1) = 1 - ( (mx(dd,1) - ( k*mx(dd,1) + flink_rated-k ))/mx(dd,1) );
        
    end
end

% 3.3 冷熱源排熱負荷
% qAC_ref_c_hr_d : 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての排熱負荷
% EAC_ref_c_hr_d : 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての主機の一次エネルギー消費量のうち排熱による削減可能量

qAC_ref_c_hr_d = EAC_ref_c_d .* ( sum(qAC_link_c_j_rated) ./ sum(EAC_link_c_j_rated)) .* flink_d ./ fCOP_link_hr;
EAC_ref_c_hr_d = EAC_ref_c_d .* flink_d;


% 3.4 CGS系統熱負荷
% qhr_total_d : 日付dにおけるCGS排熱系統の熱負荷

qhr_ac_c_d = zeros(365,1);  % 日付dにおけるCGS排熱利用が可能な排熱投入型吸収式冷温水器（系統）の排熱負荷 MJ/day
qhr_ac_h_d = zeros(365,1);  % 日付dにおけるCGS排熱利用が可能な温熱源の排熱負荷 MJ/day
qhr_total_d = zeros(365,1); % 日付dにおけるCGS排熱系統の熱負荷 MJ/day

for dd = 1:365
    if TAC_c_d(dd) > T_ST
        qhr_ac_c_d(dd) = qAC_ref_c_hr_d(dd) .* T_ST/TAC_c_d(dd);
    else
        qhr_ac_c_d(dd) = qAC_ref_c_hr_d(dd);
    end
    
    if TAC_h_d(dd) > T_ST
        qhr_ac_h_d(dd) = qAC_ref_h_hr_d(dd) .* T_ST/TAC_h_d(dd);
    else
        qhr_ac_h_d(dd) = qAC_ref_h_hr_d(dd);
    end
    
    qhr_total_d(dd) = qhr_ac_c_d(dd) + qhr_ac_h_d(dd) + qW_hr_d(dd);
    
end

% 3.5 一日の電力消費量に占める運用時間帯の電力消費量の比率
% feope_R : 一日の電力消費量に占める運用時間帯の電力消費量の比率

feope_R = (feopeHi .* T_ST) ./ (feopeHi.*T_ST + (24-T_ST));


% 3.6 CGS運転時間
% Tcgs_d : 日付dにおけるCGSの稼働時間 [hour/日]
Tcgs_d = zeros(365,1);

% 補機動力比率
if Ecgs_rated > 50
    fesub_CGS = fesub_CGS_wc;  % 0.06
else
    fesub_CGS = fesub_CGS_ac;  % 0.05
end

for dd = 1:365
    
    % a*bで電力基準運転時間
    a = qhr_total_d(dd,1) ./ (Ecgs_rated .* 3.6 .* fhopeMn);
    b = fcgs_e_rated ./ fcgs_hr_rated;   %% 仕様書では fcgs,h,ratedとなっている。
    
    % c/dで排熱基準運転時間
    c = Ee_total_d(dd,1) .* feope_R(dd,1) .* ( 1 + fesub_CGS );
    d = Ecgs_rated .* feopeMn;
    
    if TAC_c_d(dd,1) >= TAC_h_d(dd,1)
        
        if a*b >= T_ST && c/d >= T_ST
            
            Tcgs_d(dd,1) = T_ST;
            
        elseif (a*b >= TAC_c_d(dd,1)) && c/d >= TAC_c_d(dd,1)
            
            Tcgs_d(dd,1) = TAC_c_d(dd,1);
            
        else
            
            Tcgs_d(dd,1) = 0;
            
        end
        
    elseif TAC_c_d(dd,1) < TAC_h_d(dd,1)
        
        if a*b >= T_ST && c/d >= T_ST
            
            Tcgs_d(dd,1) = T_ST;
            
        elseif a*b >= TAC_h_d(dd,1) && c/d >= TAC_h_d(dd,1)
            
            Tcgs_d(dd,1) = TAC_h_d(dd,1);
            
        else
            
            Tcgs_d(dd,1) = 0;
            
        end
    end
    
end


% 3.7 CGS運転時間における負荷

Ee_total_on_d  = Ee_total_d .* feope_R .* Tcgs_d/T_ST;
EW_hr_on_d     = EW_hr_d;
qW_hr_on_d     = qW_hr_d;

EAC_ref_c_hr_on_d = zeros(365,1);
EAC_ref_h_hr_on_d = zeros(365,1);
qAC_ref_c_hr_on_d = zeros(365,1);
qAC_ref_h_hr_on_d = zeros(365,1);
qtotal_hr_on_d    = zeros(365,1);

for dd = 1:365
    
    if TAC_c_d(dd,1) <= Tcgs_d (dd,1)
        EAC_ref_c_hr_on_d(dd,1) = EAC_ref_c_hr_d(dd,1);
        qAC_ref_c_hr_on_d(dd,1) = qAC_ref_c_hr_d(dd,1);
    else
        EAC_ref_c_hr_on_d(dd,1) = EAC_ref_c_hr_d(dd,1) .* Tcgs_d(dd,1)./TAC_c_d(dd,1);
        qAC_ref_c_hr_on_d(dd,1) = qAC_ref_c_hr_d(dd,1) .* Tcgs_d(dd,1)./TAC_c_d(dd,1);
    end
    
    if TAC_h_d(dd,1) <= Tcgs_d (dd,1)
        EAC_ref_h_hr_on_d(dd,1) = EAC_ref_h_hr_d(dd,1);
        qAC_ref_h_hr_on_d(dd,1) = qAC_ref_h_hr_d(dd,1);
    else
        EAC_ref_h_hr_on_d(dd,1) = EAC_ref_h_hr_d(dd,1) .* Tcgs_d(dd,1)./TAC_h_d(dd,1);
        qAC_ref_h_hr_on_d(dd,1) = qAC_ref_h_hr_d(dd,1) .* Tcgs_d(dd,1)./TAC_h_d(dd,1);
    end
    
    
    qtotal_hr_on_d(dd,1) = qAC_ref_c_hr_on_d(dd,1) + qAC_ref_h_hr_on_d(dd,1) + qW_hr_on_d(dd,1);
    
    
end


% 3.8 CGS最大稼働台数
for dd = 1:365
    
    if Tcgs_d(dd,1)  == 0
        Ndash_cgs_on_max_d(dd,1) = 0;
    else
        Ndash_cgs_on_max_d(dd,1) = qhr_total_d(dd,1) /( Ecgs_rated * fhopeMn) * fcgs_e_rated /(fcgs_hr_rated * Tcgs_d(dd,1));
    end
    
    if (Ndash_cgs_on_max_d(dd,1) >= Ncgs)
        Ncgs_on_max_d(dd,1) = Ncgs;
    else
        Ncgs_on_max_d(dd,1) = Ndash_cgs_on_max_d(dd,1);
    end
    
end

%% 4. CGSの計算

% 4.1 発電電力負荷
% Ee_load_d : 日付dおけるCGSの発電電力負荷 [kWh/day]

Ee_load_d = Ee_total_on_d .* felmax .* ( 1 + fesub_CGS );


% 4.2 運転台数
% Ndash_cgs_on_d : 日付dおけるCGSの運転台数暫定値 [台]
Ndash_cgs_on_d = zeros(365,1);

for dd = 1:365
    
    if Tcgs_d(dd,1) > 0
        
        Ndash_cgs_on_d(dd,1) = Ee_load_d(dd,1) ./ (Ecgs_rated .* Tcgs_d(dd,1) );
        
    elseif Tcgs_d(dd,1) == 0
        
        Ndash_cgs_on_d(dd,1) = 0;
        
    end
    
    % Ncgs_on_d : 日付dおけるCGSの運転台数 [台]
    if Ndash_cgs_on_d(dd,1) >= Ncgs_on_max_d(dd,1)
        Ncgs_on_d(dd,1) = Ncgs_on_max_d(dd,1);
    elseif Ncgs_on_max_d(dd,1) > Ndash_cgs_on_d(dd,1) && Ndash_cgs_on_d(dd,1) > 0
        Ncgs_on_d(dd,1) = ceil(Ndash_cgs_on_d(dd,1));
    elseif Ndash_cgs_on_d(dd,1) <= 0
        Ncgs_on_d(dd,1) = 0;
    end
    
end

% 4.3 発電負荷率
% mxLcgs_d : 日付dにおけるCGSの負荷率 [-]
mxLcgs_d = zeros(365,1);

for dd = 1:365
    
    if Tcgs_d(dd,1) > 0
        
        mxLcgs_d(dd,1) = Ee_load_d(dd,1) ./ (Ecgs_rated .* Tcgs_d(dd,1) .* Ncgs_on_d(dd,1) );
        
        if mxLcgs_d(dd,1) > 1
            mxLcgs_d(dd,1) = 1;
        end
        
    elseif Tcgs_d(dd,1) == 0
        
        mxLcgs_d(dd,1) = 0;
        
    end
    
end

% 4.4 発電効率、排熱回収効率
% mxRe_cgs_d : 日付dにおけるCGSの発電効率(低位発熱量基準)
% mxRhr_cgs_d : 日付dにおけるCGSの発電効率(低位発熱量基準)

mxRe_cgs_d  = fe2 .* mxLcgs_d.^2 + fe1 .* mxLcgs_d + fe0;
mxRhr_cgs_d = fhr2 .* mxLcgs_d.^2 + fhr1 .* mxLcgs_d + fhr0;


% 4.5 発電量、有効発電量
% Ee_cgs_d  : 日付dにおけるCGSの発電量 [kWh/day]
% Eee_cgs_d : 日付dにおけるCGSの有効発電量（補機動力を除く発電量） [kWh/day]

Ee_cgs_d  = Ecgs_rated .* Ncgs_on_d .* Tcgs_d .* mxLcgs_d;
Eee_cgs_d = Ee_cgs_d ./ ( 1 + fesub_CGS );


% 4.6 燃料消費量、排熱回収量
% Es_cgs_d  : 日付dにおけるCGSの燃料消費量（高位発熱量基準） [MJ/day]
% qhr_cgs_d : 日付dにおけるCGSの排熱回収量 [MJ/day]

Es_cgs_d  = Ee_cgs_d .* 3.6./(mxRe_cgs_d .* fcgs_e_cor .*flh);
qhr_cgs_d = Es_cgs_d .* fcgs_e_cor .* mxRhr_cgs_d .* flh;


% 4.7	有効排熱回収量
% qehr_cgs_d : 日付dにおけるCGSの有効排熱回収量 [MJ/day]

qehr_cgs_d = zeros(365,1);
for dd = 1:365
    
    if qhr_cgs_d(dd,1)*fhr_loss >= qtotal_hr_on_d(dd,1)
        qehr_cgs_d(dd,1) = qtotal_hr_on_d(dd,1);
    else
        qehr_cgs_d(dd,1) = qhr_cgs_d(dd,1) .* fhr_loss;
    end
    
end

% 4.8 各用途の排熱利用量

if npri_hr_c == 1
    qpri1_ehr_on_d = qAC_ref_c_hr_on_d;
elseif npri_hr_h == 1
    qpri1_ehr_on_d = qAC_ref_h_hr_on_d;
elseif npri_hr_w == 1
    qpri1_ehr_on_d = qW_hr_on_d;
end

if npri_hr_c == 2
    qpri2_ehr_on_d = qAC_ref_c_hr_on_d;
elseif npri_hr_h == 2
    qpri2_ehr_on_d = qAC_ref_h_hr_on_d;
elseif npri_hr_w == 2
    qpri2_ehr_on_d = qW_hr_on_d;
else
    qpri2_ehr_on_d = zeros(365,1);
end

if npri_hr_c == 3
    qpri3_ehr_on_d = qAC_ref_c_hr_on_d;
elseif npri_hr_h == 3
    qpri3_ehr_on_d = qAC_ref_h_hr_on_d;
elseif npri_hr_w == 3
    qpri3_ehr_on_d = qW_hr_on_d;
else
    qpri3_ehr_on_d = zeros(365,1);
end


qpri1_ehr_d = zeros(365,1);
qpri2_ehr_d = zeros(365,1);
qpri3_ehr_d = zeros(365,1);

qAC_ref_c_ehr_d = zeros(365,1);
qAC_ref_h_ehr_d = zeros(365,1);
qW_ehr_d = zeros(365,1);

for dd = 1:365
    
    if  qehr_cgs_d(dd,1) >= qpri1_ehr_on_d(dd,1)
        
        qpri1_ehr_d(dd,1) = qpri1_ehr_on_d(dd,1);
        
        if qehr_cgs_d(dd,1) - qpri1_ehr_d(dd,1) >= qpri2_ehr_on_d(dd,1)
            
            qpri2_ehr_d(dd,1) = qpri2_ehr_on_d(dd,1);
            
            if qehr_cgs_d(dd,1) - qpri1_ehr_d(dd,1) - qpri2_ehr_d(dd,1) >= qpri3_ehr_on_d(dd,1)
                
                qpri3_ehr_d(dd,1) = qpri3_ehr_on_d(dd,1);
                
            elseif qehr_cgs_d(dd,1) - qpri1_ehr_d(dd,1) - qpri2_ehr_d(dd,1) < qpri3_ehr_on_d(dd,1)
                
                qpri3_ehr_d(dd,1) = qehr_cgs_d(dd,1) - qpri1_ehr_d(dd,1) - qpri2_ehr_d(dd,1);
                
            end
            
        elseif qehr_cgs_d(dd,1) - qpri1_ehr_d(dd,1) < qpri2_ehr_on_d(dd,1)
            
            qpri2_ehr_d(dd,1) = qehr_cgs_d(dd,1) - qpri1_ehr_d(dd,1);
            qpri3_ehr_d(dd,1) = 0;
            
        end
        
        
    elseif qehr_cgs_d(dd,1) < qpri1_ehr_on_d(dd,1)
        
        qpri1_ehr_d(dd,1) = qehr_cgs_d(dd,1);
        qpri2_ehr_d(dd,1) = 0;
        qpri3_ehr_d(dd,1) = 0;
        
    end
    
    
    if npri_hr_c == 0
        qAC_ref_c_ehr_d(dd,1) = 0;
    elseif npri_hr_c == 1
        qAC_ref_c_ehr_d(dd,1) = qpri1_ehr_d(dd,1);
    elseif npri_hr_c == 2
        qAC_ref_c_ehr_d(dd,1) = qpri2_ehr_d(dd,1);
    elseif npri_hr_c == 3
        qAC_ref_c_ehr_d(dd,1) = qpri3_ehr_d(dd,1);
    end
    
    if npri_hr_h == 0
        qAC_ref_h_ehr_d(dd,1) = 0;
    elseif npri_hr_h == 1
        qAC_ref_h_ehr_d(dd,1) = qpri1_ehr_d(dd,1);
    elseif npri_hr_h == 2
        qAC_ref_h_ehr_d(dd,1) = qpri2_ehr_d(dd,1);
    elseif npri_hr_h == 3
        qAC_ref_h_ehr_d(dd,1) = qpri3_ehr_d(dd,1);
    end
    
    if npri_hr_w == 0
        qW_ehr_d(dd,1) = 0;
    elseif npri_hr_w == 1
        qW_ehr_d(dd,1) = qpri1_ehr_d(dd,1);
    elseif npri_hr_w == 2
        qW_ehr_d(dd,1) = qpri2_ehr_d(dd,1);
    elseif npri_hr_w == 3
        qW_ehr_d(dd,1) = qpri3_ehr_d(dd,1);
    end
    
end


% 4.9 各用途の一次エネルギー削減量
EAC_ref_c_red_d = zeros(365,1);
EAC_ref_h_red_d = zeros(365,1);
EW_red_d        = zeros(365,1);

for dd = 1:365
    
    % EAC_ref_c_red_d : 日付dにおける冷房の一次エネルギー削減量 [MJ/day]
    if qAC_ref_c_hr_on_d(dd,1) == 0
        EAC_ref_c_red_d(dd,1) = 0;
    else
        EAC_ref_c_red_d(dd,1) = EAC_ref_c_hr_on_d(dd,1) .* qAC_ref_c_ehr_d(dd,1) ./ qAC_ref_c_hr_on_d(dd,1);
    end
    
    % EAC_ref_h_red_d : 日付dにおける暖房の一次エネルギー削減量 [MJ/day]
    if qAC_ref_h_hr_on_d(dd,1) == 0
        EAC_ref_h_red_d(dd,1) = 0;
    else
        EAC_ref_h_red_d(dd,1) = EAC_ref_h_hr_on_d(dd,1) * qAC_ref_h_ehr_d(dd,1) / qAC_ref_h_hr_on_d(dd,1) ;
    end
    
    % EW_red_d : 日付dにおける給湯の一次エネルギー削減量 [MJ/day]
    if qW_hr_on_d(dd,1) == 0
        EW_red_d(dd,1) = 0;
    else
        EW_red_d(dd,1) = EW_hr_on_d(dd,1) * qW_ehr_d(dd,1) / qW_hr_on_d(dd,1);
    end
    
end

% 4.10 電力の一次エネルギー削減量
% Ee_red_d : 日付dにおける発電による電力の一次エネルギー削減量 [MJ/day]
Ee_red_d = Eee_cgs_d .* fprime_e;


% 4.11 CGSによる一次エネルギー削減量
% Etotal_cgs_red_d : 日付dにおけるCGSによる一次エネルギー削減量 [MJ/day]

Etotal_cgs_red_d = EAC_ref_c_red_d + EAC_ref_h_red_d + EW_red_d + Ee_red_d - Es_cgs_d;


y = zeros(1,15);
y(1,1)  = sum(Tcgs_d.* Ncgs_on_d);    % 年間運転時間 [時間・台]
y(1,2)  = sum(Ncgs_on_d.*mxLcgs_d)./sum(Ncgs_on_d);   % 年平均負荷率 [-]
y(1,3)  = sum(Ee_cgs_d)/1000;         % 年間発電量 [MWh]
y(1,4)  = sum(qhr_cgs_d)/1000;        % 年間排熱回収量 [GJ]
y(1,5)  = sum(Es_cgs_d)/1000;         % 年間ガス消費量 [GJ]
y(1,6)  = y(1,3)*3.6/y(1,5)*100;      % 年間発電効率 [%]
y(1,7)  = y(1,4)/y(1,5)*100;          % 年間排熱回収効率 [%]
y(1,8)  = sum(Eee_cgs_d)/1000;        % 年間有効発電量 [%]
y(1,9)  = sum(qehr_cgs_d)/1000;       % 年間有効排熱回収量 [GJ]
y(1,10) = (y(1,8)*3.6+y(1,9))/y(1,5)*100;   % 有効総合効率 [%]
y(1,11) = sum(Ee_red_d)/1000;           % 年間一次エネルギー削減量(電力) [GJ]
y(1,12) = sum(EAC_ref_c_red_d)/1000;    % 年間一次エネルギー削減量(冷房) [GJ]
y(1,13) = sum(EAC_ref_h_red_d)/1000;    % 年間一次エネルギー削減量(暖房) [GJ]
y(1,14) = sum(EW_red_d)/1000;           % 年間一次エネルギー削減量(給湯) [GJ]
y(1,15) = sum(Etotal_cgs_red_d)/1000;   % 年間一次エネルギー削減量合計 [GJ]


CGSmemory.feopeHi = feopeHi;
save CGSmemory.mat CGSmemory

end

%% サブ関数

function [fe2,fe1,fe0,fhr2,fhr1,fhr0] = perfCURVE(fcgs_e_rated,fcgs_e_75,fcgs_e_50,fcgs_hr_rated,fcgs_hr_75,fcgs_hr_50)

% Input
% fcgs_e_rated % CGSの定格発電効率(低位発熱量基準)
% fcgs_e_75 % CGSの負荷率0.75時発電効率(低位発熱量基準)
% fcgs_e_50 % CGSの負荷率0.50時発電効率(低位発熱量基準)
% fcgs_hr_rated % CGSの定格排熱効率(低位発熱量基準)
% fcgs_hr_75 % CGSの負荷率0.75時排熱効率(低位発熱量基準)
% fcgs_hr_50% CGSの負荷率0.50時排熱効率(低位発熱量基準)
%
% Output
% fe2	% CGSの発電効率特性式の2次式の係数項
% fe1	% CGSの発電効率特性式の1次式の係数項
% fe0	% CGSの発電効率特性式の定数項
% fhr2 % CGSの排熱効率特性式の2次式の係数項
% fhr1 % CGSの排熱効率特性式の1次式の係数項
% fhr0 % CGSの排熱効率特性式の定数項

fe2 = 8 * ( fcgs_e_rated - 2*fcgs_e_75 +fcgs_e_50 );
fe1 = -2 * (5*fcgs_e_rated - 12*fcgs_e_75 + 7*fcgs_e_50 );
fe0 = 3 * fcgs_e_rated - 8*fcgs_e_75 + 6*fcgs_e_50 ;

fhr2 = 8 * (fcgs_hr_rated - 2*fcgs_hr_75 + fcgs_hr_50 );
fhr1 = -2 * ( 5*fcgs_hr_rated - 12*fcgs_hr_75 + 7*fcgs_hr_50 );
fhr0 = 3 * fcgs_hr_rated - 8*fcgs_hr_75 + 6*fcgs_hr_50 ;

end








