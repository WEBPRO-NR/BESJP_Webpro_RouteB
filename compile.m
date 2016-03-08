clear
clc

addpath('./subfunction')
addpath('./XMLfileMake')

% mcc -m ECS_XMLfileMake_run -d ./compiled

mcc -m ECS_routeB_AC_run.m xml_read.m xml_write.m mytscript_readDBfiles.m mytfunc_REFparaSET.m -d ./compiled
% mcc -m ECS_routeB_V_run.m xml_read.m xml_write.m mytscript_readDBfiles.m mytfunc_REFparaSET.m -d ./compiled
% mcc -m ECS_routeB_L_run.m xml_read.m xml_write.m mytscript_readDBfiles.m mytfunc_REFparaSET.m -d ./compiled
% mcc -m ECS_routeB_HW_run.m xml_read.m xml_write.m mytscript_readDBfiles.m mytfunc_REFparaSET.m -d ./compiled
% mcc -m ECS_routeB_EV_run.m xml_read.m xml_write.m mytscript_readDBfiles.m mytfunc_REFparaSET.m -d ./compiled

% addpath('./groundModel')
% mcc -m ECS_routeB_GroundModel_run.m xml_read.m xml_write.m mytscript_readDBfiles.m mytfunc_REFparaSET.m -d ./compiled
% rmpath('./groundModel')


rmpath('./subfunction/')
rmpath('./XMLfileMake')
