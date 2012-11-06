% XML作成からエネルギー計算までを一気に実行するスクリプト
clear
clc
tic

xmlfilename = 'csv2xml_config.xml';
region = 'IVb';


addpath('./subfunction')
addpath('./XMLfileMake')

% XML作成
copyfile(xmlfilename,'./XMLfileMake/csv2xml_config.xml')
mytfunc_csv2xml_run('output.xml',region);

% 計算実行
RES = ECS_routeB_run('output.xml');

rmpath('./subfunction')
rmpath('./XMLfileMake')