clear
clc

tic

addpath('./subfunction/')

INPUTFILENAME = 'routeB_inputXML_0-1.xml';
y = ECS_routeB_AC_run_v11(INPUTFILENAME,'ON');

% BEIHW = ECS_routeB_HW_run_v1('IVa','事務所等','給湯室シート.csv','給湯_機器シート.csv');

rmpath('./subfunction/')

toc