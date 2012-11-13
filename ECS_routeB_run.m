function y = ECS_routeB_run(inputfilename)

tic

OutputOption  = 'OFF';

resAC = ECS_routeB_AC_run(inputfilename,OutputOption);
resV  = ECS_routeB_V_run(inputfilename,OutputOption);
resL  = ECS_routeB_L_run(inputfilename,OutputOption);
resHW = ECS_routeB_HW_run(inputfilename,OutputOption);
resEV = ECS_routeB_EV_run(inputfilename,OutputOption);

Sac = resAC(20);

RES = [];
RES = [(resAC(2)+resAC(3))*Sac,resAC(17).*Sac*0.8;...
    resAC(1)*Sac,resAC(17).*Sac;...
    resV(3),resV(7);...
    resL(3),resL(7);...
    resHW(1),resHW(3);...
    resEV(3),resEV(7);...
    0,0];

RES = [RES;
    sum(RES(2:end,:),1);
    resAC(19)*Sac,resAC(19)*Sac;
    sum(RES(2:end,1))+resAC(19)*Sac,sum(RES(2:end,2))+resAC(19)*Sac];

if isempty(strfind(inputfilename,'/'))
    eval(['resfilenameS = ''calcRES_ALL_',inputfilename(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(inputfilename,'/');
    eval(['resfilenameS = ''calcRES_ALL_',inputfilename(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
end

csvwrite(resfilenameS,RES);

y = RES;

toc
