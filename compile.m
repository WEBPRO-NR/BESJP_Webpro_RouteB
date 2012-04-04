clear
clc

addpath('./subfunction')

% mcc -m ECS_routeB_run_v10.m ./subfunction/xml_read.m ./subfunction/xml_write.m -d ./routeB_v10exe
% mcc -m ECS_routeB_AC_run_v10.m xml_read.m xml_write.m mytscript_readDBfiles.m -d ./routeB_v10exe
mcc -m ECS_routeB_HW_run_v1.m xml_read.m xml_write.m mytscript_readDBfiles.m -d ./routeB_v10exe

rmpath('./subfunction/')