% コジェネ計算用
clear
clc
tic

inputfilename = './InputFiles/1005_コジェネテスト/model_CGS_case_hotel_01.xml';

addpath('./subfunction')

%% 計算実行

disp('空気調和設備の計算を実行中．．．')
RES_AC = ECS_routeB_AC_run(inputfilename,'OFF','4','Calc','0');

toc

disp('機械換気設備の計算を実行中．．．')
RES_V  = ECS_routeB_V_run(inputfilename,'OFF');

toc

disp('照明設備の計算を実行中．．．')
RES_L  = ECS_routeB_L_run(inputfilename,'OFF');

toc

disp('給湯設備の計算を実行中．．．')
RES_HW = ECS_routeB_HW_run(inputfilename,'OFF');

toc

disp('昇降機の計算を実行中．．．')
RES_EV = ECS_routeB_EV_run(inputfilename,'OFF');

toc

disp('その他エネルギーの計算を実行中．．．')
RES_OA = ECS_routeB_Others_run(inputfilename,'OFF');

toc

disp('コジェネの計算を実行中．．．')
y = ECS_routeB_CGSdetail_run(inputfilename,'OFF');
toc

% rmpath('./subfunction')
