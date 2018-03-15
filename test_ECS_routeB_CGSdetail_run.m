% test_ECS_routeB_CGSdetail_run
%--------------------------------------------------------------------------
% コジェネ詳細版の総合テスト
%--------------------------------------------------------------------------
% 実行：
%　results = runtests('test_ECS_routeB_CGSdetail_run.m');
%--------------------------------------------------------------------------

function tests = test_ECS_routeB_CGSdetail_run

    tests = functiontests(localfunctions);

end

% ホテルケース0
function testCase00(testCase)

% 事務所
load ./test/test_Hotel_Case00.mat inputdata

% 日付dにおける空気調和設備の電力消費量	MWh/日
EAC_total_d = inputdata(:,1);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての主機の一次エネルギー消費量	MJ/日
EAC_ref_c_d = inputdata(:,2);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての負荷率 	無次元
mxLAC_ref_c_d = inputdata(:,3);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の主機の一次エネルギー消費量	MJ/日
EAC_ref_h_hr_d = inputdata(:,4);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の熱源負荷	MJ/日
qAC_ref_h_hr_d = inputdata(:,5);
% 日付dにおける機械換気設備の電力消費量	MWh/日
EV_total_d = inputdata(:,6);
% 日付dにおける照明設備の電力消費量	MWh/日
EL_total_d = inputdata(:,7);
% 日付dにおける給湯設備の電力消費量	MWh/日
EW_total_d = inputdata(:,8);
% 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の一次エネルギー消費量	MJ/日
EW_hr_d = inputdata(:,9);
% 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の給湯負荷	MJ/日
qW_hr_d = inputdata(:,10);
% 日付dにおける昇降機の電力消費量	MWh/日
EEV_total_d = inputdata(:,11);
% 日付dにおける効率化設備（太陽光発電）の発電量	MWh/日
EPV_total_d = inputdata(:,12);
% 日付dにおけるその他の電力消費量	MWh/日
EM_total_d = inputdata(:,13);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の運転時間	h/日
TAC_c_d = inputdata(:,14);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の運転時間	h/日
TAC_h_d = inputdata(:,15);


% CGSの発電機容量	kW
Ecgs_rated = 150;
% CGS設置台数	台
Ncgs = 2;
% CGSの定格発電効率(低位発熱量基準)	無次元
fcgs_e_rated = 0.336;
% CGSの負荷率0.75時発電効率(低位発熱量基準)	無次元
fcgs_e_75 = 0.325;
% CGSの負荷率0.50時発電効率(低位発熱量基準)	無次元
fcgs_e_50 = 0.292;
% CGSの定格排熱効率(低位発熱量基準)	無次元
fcgs_hr_rated = 0.507;
% CGSの負荷率0.75時排熱効率(低位発熱量基準)	無次元
fcgs_hr_75 = 0.518;
% CGSの負荷率0.50時排熱効率(低位発熱量基準)	無次元
fcgs_hr_50 = 0.546;
% 排熱利用優先順位(冷熱源)　※1	無次元
npri_hr_c = 3;
% 排熱利用優先順位(温熱源) 　※1	無次元
npri_hr_h = 2;
% 排熱利用優先順位(給湯) 　※1	無次元
npri_hr_w = 1;
% CGS24時間運転の有無　※2	-
C24ope = 0;
% 排熱投入型吸収式冷温水機jの定格冷却能力	ｋW/台　（→行列にすべき？ 3.3参照）
qAC_link_c_j_rated = 617.22;
% 排熱投入型吸収式冷温水機jの主機定格消費エネルギー	ｋW/台（→行列にすべき？ 3.3参照）
EAC_link_c_j_rated = 561.21;
% CGSの排熱利用が可能な系統にある排熱投入型吸収式冷温水機の台数	台
NAC_ref_link = 3;

% 建物の運用時間帯と非運用時間帯の平均電力差	無次元
feopeHi = 10;

% 実行
y = ECS_routeB_CGSdetail_run( EAC_total_d,EAC_ref_c_d,mxLAC_ref_c_d,...
    EAC_ref_h_hr_d,qAC_ref_h_hr_d,EV_total_d,EL_total_d,EW_total_d,EW_hr_d,....
    qW_hr_d,EEV_total_d,EPV_total_d,EM_total_d,TAC_c_d,TAC_h_d,...
    Ecgs_rated,Ncgs,fcgs_e_rated,...
    fcgs_e_75,fcgs_e_50,fcgs_hr_rated,fcgs_hr_75,fcgs_hr_50,...
    npri_hr_c,npri_hr_h,npri_hr_w,C24ope,qAC_link_c_j_rated,...
    EAC_link_c_j_rated,NAC_ref_link,feopeHi);

actSolution = y;
% エクセルプログラムより
expSolution = [10220,0.62,955.72,5864.56,12386.55,27.78,47.35,901.62,5337.73,69.30,8799.80,934.24,1117.64,4621.61,3086.74];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.01)

end

% ホテルケース1
function testCase01(testCase)

% 事務所
load ./test/test_Hotel_Case01.mat inputdata

% 日付dにおける空気調和設備の電力消費量	MWh/日
EAC_total_d = inputdata(:,1);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての主機の一次エネルギー消費量	MJ/日
EAC_ref_c_d = inputdata(:,2);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての負荷率 	無次元
mxLAC_ref_c_d = inputdata(:,3);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の主機の一次エネルギー消費量	MJ/日
EAC_ref_h_hr_d = inputdata(:,4);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の熱源負荷	MJ/日
qAC_ref_h_hr_d = inputdata(:,5);
% 日付dにおける機械換気設備の電力消費量	MWh/日
EV_total_d = inputdata(:,6);
% 日付dにおける照明設備の電力消費量	MWh/日
EL_total_d = inputdata(:,7);
% 日付dにおける給湯設備の電力消費量	MWh/日
EW_total_d = inputdata(:,8);
% 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の一次エネルギー消費量	MJ/日
EW_hr_d = inputdata(:,9);
% 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の給湯負荷	MJ/日
qW_hr_d = inputdata(:,10);
% 日付dにおける昇降機の電力消費量	MWh/日
EEV_total_d = inputdata(:,11);
% 日付dにおける効率化設備（太陽光発電）の発電量	MWh/日
EPV_total_d = inputdata(:,12);
% 日付dにおけるその他の電力消費量	MWh/日
EM_total_d = inputdata(:,13);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の運転時間	h/日
TAC_c_d = inputdata(:,14);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の運転時間	h/日
TAC_h_d = inputdata(:,15);


% CGSの発電機容量	kW
Ecgs_rated = 50;
% CGS設置台数	台
Ncgs = 6;
% CGSの定格発電効率(低位発熱量基準)	無次元
fcgs_e_rated = 0.336;
% CGSの負荷率0.75時発電効率(低位発熱量基準)	無次元
fcgs_e_75 = 0.325;
% CGSの負荷率0.50時発電効率(低位発熱量基準)	無次元
fcgs_e_50 = 0.292;
% CGSの定格排熱効率(低位発熱量基準)	無次元
fcgs_hr_rated = 0.507;
% CGSの負荷率0.75時排熱効率(低位発熱量基準)	無次元
fcgs_hr_75 = 0.518;
% CGSの負荷率0.50時排熱効率(低位発熱量基準)	無次元
fcgs_hr_50 = 0.546;
% 排熱利用優先順位(冷熱源)　※1	無次元
npri_hr_c = 3;
% 排熱利用優先順位(温熱源) 　※1	無次元
npri_hr_h = 2;
% 排熱利用優先順位(給湯) 　※1	無次元
npri_hr_w = 1;
% CGS24時間運転の有無　※2	-
C24ope = 0;
% 排熱投入型吸収式冷温水機jの定格冷却能力	ｋW/台　（→行列にすべき？ 3.3参照）
qAC_link_c_j_rated = 617.22;
% 排熱投入型吸収式冷温水機jの主機定格消費エネルギー	ｋW/台（→行列にすべき？ 3.3参照）
EAC_link_c_j_rated = 561.21;
% CGSの排熱利用が可能な系統にある排熱投入型吸収式冷温水機の台数	台
NAC_ref_link = 3;

% 建物の運用時間帯と非運用時間帯の平均電力差	無次元
feopeHi = 10;

% 実行
y = ECS_routeB_CGSdetail_run( EAC_total_d,EAC_ref_c_d,mxLAC_ref_c_d,...
    EAC_ref_h_hr_d,qAC_ref_h_hr_d,EV_total_d,EL_total_d,EW_total_d,EW_hr_d,....
    qW_hr_d,EEV_total_d,EPV_total_d,EM_total_d,TAC_c_d,TAC_h_d,...
    Ecgs_rated,Ncgs,fcgs_e_rated,...
    fcgs_e_75,fcgs_e_50,fcgs_hr_rated,fcgs_hr_75,fcgs_hr_50,...
    npri_hr_c,npri_hr_h,npri_hr_w,C24ope,qAC_link_c_j_rated,...
    EAC_link_c_j_rated,NAC_ref_link,feopeHi);

actSolution = y;
% エクセルプログラムより（inputSheet_Ver2.5_20180206_01事務所CGS.xlsm）
expSolution = [21056,0.90,946.70,5198.42,11422.75,29.84,45.51,901.62,4903.43,71.34,8799.80,826.09,775.89,4621.61,3600.64];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.01)

end

% ホテルケース1
function testCase02(testCase)

% 事務所
load ./test/test_Hotel_Case02.mat inputdata

% 日付dにおける空気調和設備の電力消費量	MWh/日
EAC_total_d = inputdata(:,1);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての主機の一次エネルギー消費量	MJ/日
EAC_ref_c_d = inputdata(:,2);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての負荷率 	無次元
mxLAC_ref_c_d = inputdata(:,3);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の主機の一次エネルギー消費量	MJ/日
EAC_ref_h_hr_d = inputdata(:,4);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の熱源負荷	MJ/日
qAC_ref_h_hr_d = inputdata(:,5);
% 日付dにおける機械換気設備の電力消費量	MWh/日
EV_total_d = inputdata(:,6);
% 日付dにおける照明設備の電力消費量	MWh/日
EL_total_d = inputdata(:,7);
% 日付dにおける給湯設備の電力消費量	MWh/日
EW_total_d = inputdata(:,8);
% 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の一次エネルギー消費量	MJ/日
EW_hr_d = inputdata(:,9);
% 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の給湯負荷	MJ/日
qW_hr_d = inputdata(:,10);
% 日付dにおける昇降機の電力消費量	MWh/日
EEV_total_d = inputdata(:,11);
% 日付dにおける効率化設備（太陽光発電）の発電量	MWh/日
EPV_total_d = inputdata(:,12);
% 日付dにおけるその他の電力消費量	MWh/日
EM_total_d = inputdata(:,13);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の運転時間	h/日
TAC_c_d = inputdata(:,14);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の運転時間	h/日
TAC_h_d = inputdata(:,15);


% CGSの発電機容量	kW
Ecgs_rated = 300;
% CGS設置台数	台
Ncgs = 1;
% CGSの定格発電効率(低位発熱量基準)	無次元
fcgs_e_rated = 0.336;
% CGSの負荷率0.75時発電効率(低位発熱量基準)	無次元
fcgs_e_75 = 0.325;
% CGSの負荷率0.50時発電効率(低位発熱量基準)	無次元
fcgs_e_50 = 0.292;
% CGSの定格排熱効率(低位発熱量基準)	無次元
fcgs_hr_rated = 0.507;
% CGSの負荷率0.75時排熱効率(低位発熱量基準)	無次元
fcgs_hr_75 = 0.518;
% CGSの負荷率0.50時排熱効率(低位発熱量基準)	無次元
fcgs_hr_50 = 0.546;
% 排熱利用優先順位(冷熱源)　※1	無次元
npri_hr_c = 3;
% 排熱利用優先順位(温熱源) 　※1	無次元
npri_hr_h = 2;
% 排熱利用優先順位(給湯) 　※1	無次元
npri_hr_w = 1;
% CGS24時間運転の有無　※2	-
C24ope = 0;
% 排熱投入型吸収式冷温水機jの定格冷却能力	ｋW/台　（→行列にすべき？ 3.3参照）
qAC_link_c_j_rated = 617.22;
% 排熱投入型吸収式冷温水機jの主機定格消費エネルギー	ｋW/台（→行列にすべき？ 3.3参照）
EAC_link_c_j_rated = 561.21;
% CGSの排熱利用が可能な系統にある排熱投入型吸収式冷温水機の台数	台
NAC_ref_link = 3;

% 建物の運用時間帯と非運用時間帯の平均電力差	無次元
feopeHi = 10;

% 実行
y = ECS_routeB_CGSdetail_run( EAC_total_d,EAC_ref_c_d,mxLAC_ref_c_d,...
    EAC_ref_h_hr_d,qAC_ref_h_hr_d,EV_total_d,EL_total_d,EW_total_d,EW_hr_d,....
    qW_hr_d,EEV_total_d,EPV_total_d,EM_total_d,TAC_c_d,TAC_h_d,...
    Ecgs_rated,Ncgs,fcgs_e_rated,...
    fcgs_e_75,fcgs_e_50,fcgs_hr_rated,fcgs_hr_75,fcgs_hr_50,...
    npri_hr_c,npri_hr_h,npri_hr_w,C24ope,qAC_link_c_j_rated,...
    EAC_link_c_j_rated,NAC_ref_link,feopeHi);

actSolution = y;
% エクセルプログラムより（inputSheet_Ver2.5_20180206_01事務所CGS.xlsm）
expSolution = [4788,0.62,894.91,5492.94,11600.61,27.77,47.35,844.25,5093.61,70.11,8239.91,881.43,1078.64,4382.22,2981.59];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.01)

end

% 事務所
function testCase03(testCase)

% 事務所
load ./test/test_Office_Case03.mat inputdata

% 日付dにおける空気調和設備の電力消費量	MWh/日
EAC_total_d = inputdata(:,1);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての主機の一次エネルギー消費量	MJ/日
EAC_ref_c_d = inputdata(:,2);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての負荷率 	無次元
mxLAC_ref_c_d = inputdata(:,3);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の主機の一次エネルギー消費量	MJ/日
EAC_ref_h_hr_d = inputdata(:,4);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の熱源負荷	MJ/日
qAC_ref_h_hr_d = inputdata(:,5);
% 日付dにおける機械換気設備の電力消費量	MWh/日
EV_total_d = inputdata(:,6);
% 日付dにおける照明設備の電力消費量	MWh/日
EL_total_d = inputdata(:,7);
% 日付dにおける給湯設備の電力消費量	MWh/日
EW_total_d = inputdata(:,8);
% 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の一次エネルギー消費量	MJ/日
EW_hr_d = inputdata(:,9);
% 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の給湯負荷	MJ/日
qW_hr_d = inputdata(:,10);
% 日付dにおける昇降機の電力消費量	MWh/日
EEV_total_d = inputdata(:,11);
% 日付dにおける効率化設備（太陽光発電）の発電量	MWh/日
EPV_total_d = inputdata(:,12);
% 日付dにおけるその他の電力消費量	MWh/日
EM_total_d = inputdata(:,13);
% 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の運転時間	h/日
TAC_c_d = inputdata(:,14);
% 日付dにおけるCGSの排熱利用が可能な温熱源群の運転時間	h/日
TAC_h_d = inputdata(:,15);


% CGSの発電機容量	kW
Ecgs_rated = 200;
% CGS設置台数	台
Ncgs = 1;
% CGSの定格発電効率(低位発熱量基準)	無次元
fcgs_e_rated = 0.236;
% CGSの負荷率0.75時発電効率(低位発熱量基準)	無次元
fcgs_e_75 = 0.225;
% CGSの負荷率0.50時発電効率(低位発熱量基準)	無次元
fcgs_e_50 = 0.192;
% CGSの定格排熱効率(低位発熱量基準)	無次元
fcgs_hr_rated = 0.507;
% CGSの負荷率0.75時排熱効率(低位発熱量基準)	無次元
fcgs_hr_75 = 0.518;
% CGSの負荷率0.50時排熱効率(低位発熱量基準)	無次元
fcgs_hr_50 = 0.546;
% 排熱利用優先順位(冷熱源)　※1	無次元
npri_hr_c = 3;
% 排熱利用優先順位(温熱源) 　※1	無次元
npri_hr_h = 2;
% 排熱利用優先順位(給湯) 　※1	無次元
npri_hr_w = 1;
% CGS24時間運転の有無　※2	-
C24ope = 0;
% 排熱投入型吸収式冷温水機jの定格冷却能力	ｋW/台　（→行列にすべき？ 3.3参照）
qAC_link_c_j_rated = 1093.5;
% 排熱投入型吸収式冷温水機jの主機定格消費エネルギー	ｋW/台（→行列にすべき？ 3.3参照）
EAC_link_c_j_rated = 994.08;
% CGSの排熱利用が可能な系統にある排熱投入型吸収式冷温水機の台数	台
NAC_ref_link = 3;

% 建物の運用時間帯と非運用時間帯の平均電力差	無次元
feopeHi = 10;

% 実行
y = ECS_routeB_CGSdetail_run( EAC_total_d,EAC_ref_c_d,mxLAC_ref_c_d,...
    EAC_ref_h_hr_d,qAC_ref_h_hr_d,EV_total_d,EL_total_d,EW_total_d,EW_hr_d,....
    qW_hr_d,EEV_total_d,EPV_total_d,EM_total_d,TAC_c_d,TAC_h_d,...
    Ecgs_rated,Ncgs,fcgs_e_rated,...
    fcgs_e_75,fcgs_e_50,fcgs_hr_rated,fcgs_hr_75,fcgs_hr_50,...
    npri_hr_c,npri_hr_h,npri_hr_w,C24ope,qAC_link_c_j_rated,...
    EAC_link_c_j_rated,NAC_ref_link,feopeHi);

actSolution = y;
% エクセルプログラムより（inputSheet_Ver2.5_20180206_01事務所CGS.xlsm）
expSolution = [2030	1.00	406.00	3139.96	6933.76	21.08	45.29	383.02	2688.68	58.66	3738.26	1825.42	10.91	0.00	-1359.17];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.01)

end

% 
% function testCase01(testCase)
% 
% % 事務所
% load ./test/testCase01.mat inputdata
% 
% % 日付dにおける空気調和設備の電力消費量	MWh/日
% EAC_total_d = inputdata(:,1);
% % 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての主機の一次エネルギー消費量	MJ/日
% EAC_ref_c_d = inputdata(:,2);
% % 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての負荷率 	無次元
% mxLAC_ref_c_d = inputdata(:,3);
% % 日付dにおけるCGSの排熱利用が可能な温熱源群の主機の一次エネルギー消費量	MJ/日
% EAC_ref_h_hr_d = inputdata(:,4);
% % 日付dにおけるCGSの排熱利用が可能な温熱源群の熱源負荷	MJ/日
% qAC_ref_h_hr_d = inputdata(:,5);
% % 日付dにおける機械換気設備の電力消費量	MWh/日
% EV_total_d = inputdata(:,6);
% % 日付dにおける照明設備の電力消費量	MWh/日
% EL_total_d = inputdata(:,7);
% % 日付dにおける給湯設備の電力消費量	MWh/日
% EW_total_d = inputdata(:,8);
% % 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の一次エネルギー消費量	MJ/日
% EW_hr_d = inputdata(:,9);
% % 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の給湯負荷	MJ/日
% qW_hr_d = inputdata(:,10);
% % 日付dにおける昇降機の電力消費量	MWh/日
% EEV_total_d = inputdata(:,11);
% % 日付dにおける効率化設備（太陽光発電）の発電量	MWh/日
% EPV_total_d = inputdata(:,12);
% % 日付dにおけるその他の電力消費量	MWh/日
% EM_total_d = inputdata(:,13);
% % 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の運転時間	h/日
% TAC_c_d = inputdata(:,14);
% % 日付dにおけるCGSの排熱利用が可能な温熱源群の運転時間	h/日
% TAC_h_d = inputdata(:,15);
% 
% 
% % CGSの発電機容量	kW
% Ecgs_rated = 200;
% % CGS設置台数	台
% Ncgs = 1;
% % CGSの定格発電効率(低位発熱量基準)	無次元
% fcgs_e_rated = 0.336;
% % CGSの負荷率0.75時発電効率(低位発熱量基準)	無次元
% fcgs_e_75 = 0.325;
% % CGSの負荷率0.50時発電効率(低位発熱量基準)	無次元
% fcgs_e_50 = 0.292;
% % CGSの定格排熱効率(低位発熱量基準)	無次元
% fcgs_hr_rated = 0.507;
% % CGSの負荷率0.75時排熱効率(低位発熱量基準)	無次元
% fcgs_hr_75 = 0.518;
% % CGSの負荷率0.50時排熱効率(低位発熱量基準)	無次元
% fcgs_hr_50 = 0.546;
% % 排熱利用優先順位(冷熱源)　※1	無次元
% npri_hr_c = 2;
% % 排熱利用優先順位(温熱源) 　※1	無次元
% npri_hr_h = 1;
% % 排熱利用優先順位(給湯) 　※1	無次元
% npri_hr_w = 0;
% % CGS24時間運転の有無　※2	-
% C24ope = 0;
% % 排熱投入型吸収式冷温水機jの定格冷却能力	ｋW/台　（→行列にすべき？ 3.3参照）
% qAC_link_c_j_rated = 1093.5;
% % 排熱投入型吸収式冷温水機jの主機定格消費エネルギー	ｋW/台（→行列にすべき？ 3.3参照）
% EAC_link_c_j_rated = 994.08;
% % CGSの排熱利用が可能な系統にある排熱投入型吸収式冷温水機の台数	台
% NAC_ref_link = 3;
% 
% % 建物の運用時間帯と非運用時間帯の平均電力差	無次元
% feopeHi = 10;
% 
% % 実行
% y = ECS_routeB_CGSdetail_run( EAC_total_d,EAC_ref_c_d,mxLAC_ref_c_d,...
%     EAC_ref_h_hr_d,qAC_ref_h_hr_d,EV_total_d,EL_total_d,EW_total_d,EW_hr_d,....
%     qW_hr_d,EEV_total_d,EPV_total_d,EM_total_d,TAC_c_d,TAC_h_d,...
%     Ecgs_rated,Ncgs,fcgs_e_rated,...
%     fcgs_e_75,fcgs_e_50,fcgs_hr_rated,fcgs_hr_75,fcgs_hr_50,...
%     npri_hr_c,npri_hr_h,npri_hr_w,C24ope,qAC_link_c_j_rated,...
%     EAC_link_c_j_rated,NAC_ref_link,feopeHi);
% 
% actSolution = y;
% % エクセルプログラムより（inputSheet_Ver2.5_20180206_01事務所CGS.xlsm）
% expSolution = [2044,1.00,408.80,2220.66,4903.73,30.01,45.29,385.66,2090.54,70.94,3764.05,1412.23,21.81,0.00,294.36];
% 
% % 検証
% verifyEqual(testCase,actSolution,expSolution,'RelTol',0.01)
% 
% end
% 
% 
% function testCase02(testCase)
% 
% load ./test/testCase02.mat inputdata
% 
% % 日付dにおける空気調和設備の電力消費量	MWh/日
% EAC_total_d = inputdata(:,1);
% % 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての主機の一次エネルギー消費量	MJ/日
% EAC_ref_c_d = inputdata(:,2);
% % 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての負荷率 	無次元
% mxLAC_ref_c_d = inputdata(:,3);
% % 日付dにおけるCGSの排熱利用が可能な温熱源群の主機の一次エネルギー消費量	MJ/日
% EAC_ref_h_hr_d = inputdata(:,4);
% % 日付dにおけるCGSの排熱利用が可能な温熱源群の熱源負荷	MJ/日
% qAC_ref_h_hr_d = inputdata(:,5);
% % 日付dにおける機械換気設備の電力消費量	MWh/日
% EV_total_d = inputdata(:,6);
% % 日付dにおける照明設備の電力消費量	MWh/日
% EL_total_d = inputdata(:,7);
% % 日付dにおける給湯設備の電力消費量	MWh/日
% EW_total_d = inputdata(:,8);
% % 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の一次エネルギー消費量	MJ/日
% EW_hr_d = inputdata(:,9);
% % 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の給湯負荷	MJ/日
% qW_hr_d = inputdata(:,10);
% % 日付dにおける昇降機の電力消費量	MWh/日
% EEV_total_d = inputdata(:,11);
% % 日付dにおける効率化設備（太陽光発電）の発電量	MWh/日
% EPV_total_d = inputdata(:,12);
% % 日付dにおけるその他の電力消費量	MWh/日
% EM_total_d = inputdata(:,13);
% % 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の運転時間	h/日
% TAC_c_d = inputdata(:,14);
% % 日付dにおけるCGSの排熱利用が可能な温熱源群の運転時間	h/日
% TAC_h_d = inputdata(:,15);
% 
% 
% % CGSの発電機容量	kW
% Ecgs_rated = 150;
% % CGS設置台数	台
% Ncgs = 2;
% % CGSの定格発電効率(低位発熱量基準)	無次元
% fcgs_e_rated = 0.336;
% % CGSの負荷率0.75時発電効率(低位発熱量基準)	無次元
% fcgs_e_75 = 0.325;
% % CGSの負荷率0.50時発電効率(低位発熱量基準)	無次元
% fcgs_e_50 = 0.292;
% % CGSの定格排熱効率(低位発熱量基準)	無次元
% fcgs_hr_rated = 0.507;
% % CGSの負荷率0.75時排熱効率(低位発熱量基準)	無次元
% fcgs_hr_75 = 0.518;
% % CGSの負荷率0.50時排熱効率(低位発熱量基準)	無次元
% fcgs_hr_50 = 0.546;
% % 排熱利用優先順位(冷熱源)　※1	無次元
% npri_hr_c = 3;
% % 排熱利用優先順位(温熱源) 　※1	無次元
% npri_hr_h = 2;
% % 排熱利用優先順位(給湯) 　※1	無次元
% npri_hr_w = 1;
% % CGS24時間運転の有無　※2	-
% C24ope = 0;
% % 排熱投入型吸収式冷温水機jの定格冷却能力	ｋW/台　（→行列にすべき？ 3.3参照）
% qAC_link_c_j_rated = 205.74*3;
% % 排熱投入型吸収式冷温水機jの主機定格消費エネルギー	ｋW/台（→行列にすべき？ 3.3参照）
% EAC_link_c_j_rated = 187.07*3;
% % CGSの排熱利用が可能な系統にある排熱投入型吸収式冷温水機の台数	台
% NAC_ref_link = 3;
% 
% feopeHi = 10;
% 
% % 実行
% y = ECS_routeB_CGSdetail_run( EAC_total_d,EAC_ref_c_d,mxLAC_ref_c_d,...
%     EAC_ref_h_hr_d,qAC_ref_h_hr_d,EV_total_d,EL_total_d,EW_total_d,EW_hr_d,....
%     qW_hr_d,EEV_total_d,EPV_total_d,EM_total_d,TAC_c_d,TAC_h_d,...
%     Ecgs_rated,Ncgs,fcgs_e_rated,...
%     fcgs_e_75,fcgs_e_50,fcgs_hr_rated,fcgs_hr_75,fcgs_hr_50,...
%     npri_hr_c,npri_hr_h,npri_hr_w,C24ope,qAC_link_c_j_rated,...
%     EAC_link_c_j_rated,NAC_ref_link,feopeHi);
% 
% actSolution = y;
% expSolution = [10220,0.62,956.08,5865.88,12389.96,27.78,47.34,901.96,5344.77,69.35,8803.13,941.10,1110.00,4621.61,3085.87];
% 
% % 検証
% verifyEqual(testCase,actSolution,expSolution,'RelTol',0.01)
% 
% end
% 
% 
% function testCase03(testCase)
% 
% % 
% load ./test/testCase03.mat inputdata
% 
% % 日付dにおける空気調和設備の電力消費量	MWh/日
% EAC_total_d = inputdata(:,1);
% % 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての主機の一次エネルギー消費量	MJ/日
% EAC_ref_c_d = inputdata(:,2);
% % 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての負荷率 	無次元
% mxLAC_ref_c_d = inputdata(:,3);
% % 日付dにおけるCGSの排熱利用が可能な温熱源群の主機の一次エネルギー消費量	MJ/日
% EAC_ref_h_hr_d = inputdata(:,4);
% % 日付dにおけるCGSの排熱利用が可能な温熱源群の熱源負荷	MJ/日
% qAC_ref_h_hr_d = inputdata(:,5);
% % 日付dにおける機械換気設備の電力消費量	MWh/日
% EV_total_d = inputdata(:,6);
% % 日付dにおける照明設備の電力消費量	MWh/日
% EL_total_d = inputdata(:,7);
% % 日付dにおける給湯設備の電力消費量	MWh/日
% EW_total_d = inputdata(:,8);
% % 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の一次エネルギー消費量	MJ/日
% EW_hr_d = inputdata(:,9);
% % 日付dにおけるCGSの排熱利用が可能な給湯機(系統)の給湯負荷	MJ/日
% qW_hr_d = inputdata(:,10);
% % 日付dにおける昇降機の電力消費量	MWh/日
% EEV_total_d = inputdata(:,11);
% % 日付dにおける効率化設備（太陽光発電）の発電量	MWh/日
% EPV_total_d = inputdata(:,12);
% % 日付dにおけるその他の電力消費量	MWh/日
% EM_total_d = inputdata(:,13);
% % 日付dにおけるCGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の運転時間	h/日
% TAC_c_d = inputdata(:,14);
% % 日付dにおけるCGSの排熱利用が可能な温熱源群の運転時間	h/日
% TAC_h_d = inputdata(:,15);
% 
% 
% % CGSの発電機容量	kW
% Ecgs_rated = 370;
% % CGS設置台数	台
% Ncgs = 1;
% % CGSの定格発電効率(低位発熱量基準)	無次元
% fcgs_e_rated = 0.405;
% % CGSの負荷率0.75時発電効率(低位発熱量基準)	無次元
% fcgs_e_75 = 0.39;
% % CGSの負荷率0.50時発電効率(低位発熱量基準)	無次元
% fcgs_e_50 = 0.349;
% % CGSの定格排熱効率(低位発熱量基準)	無次元
% fcgs_hr_rated = 0.332;
% % CGSの負荷率0.75時排熱効率(低位発熱量基準)	無次元
% fcgs_hr_75 = 0.337;
% % CGSの負荷率0.50時排熱効率(低位発熱量基準)	無次元
% fcgs_hr_50 = 0.369;
% % 排熱利用優先順位(冷熱源)　※1	無次元
% npri_hr_c = 3;
% % 排熱利用優先順位(温熱源) 　※1	無次元
% npri_hr_h = 2;
% % 排熱利用優先順位(給湯) 　※1	無次元
% npri_hr_w = 1;
% % CGS24時間運転の有無　※2	-
% C24ope = 0;
% % 排熱投入型吸収式冷温水機jの定格冷却能力	ｋW/台　（→行列にすべき？ 3.3参照）
% qAC_link_c_j_rated = 1613.7;
% % 排熱投入型吸収式冷温水機jの主機定格消費エネルギー	ｋW/台（→行列にすべき？ 3.3参照）
% EAC_link_c_j_rated = 1467;
% % CGSの排熱利用が可能な系統にある排熱投入型吸収式冷温水機の台数	台
% NAC_ref_link = 2;
% 
% feopeHi = 10;
% 
% 
% % 実行
% y = ECS_routeB_CGSdetail_run( EAC_total_d,EAC_ref_c_d,mxLAC_ref_c_d,...
%     EAC_ref_h_hr_d,qAC_ref_h_hr_d,EV_total_d,EL_total_d,EW_total_d,EW_hr_d,....
%     qW_hr_d,EEV_total_d,EPV_total_d,EM_total_d,TAC_c_d,TAC_h_d,...
%     Ecgs_rated,Ncgs,fcgs_e_rated,...
%     fcgs_e_75,fcgs_e_50,fcgs_hr_rated,fcgs_hr_75,fcgs_hr_50,...
%     npri_hr_c,npri_hr_h,npri_hr_w,C24ope,qAC_link_c_j_rated,...
%     EAC_link_c_j_rated,NAC_ref_link,feopeHi);
% 
% actSolution = y;
% expSolution = [5110,0.96,1815.56,5385.11,18142.97,36.03,29.68,1712.79,5223.55,62.78,16716.88,821.70,893.42,5062.39,5351.42];
% 
% % 検証
% verifyEqual(testCase,actSolution,expSolution,'RelTol',0.01)
% 
% end
% 





