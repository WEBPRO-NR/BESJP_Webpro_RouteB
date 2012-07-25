clear
clc

tic

addpath('./subfunction/')


for i=1
    
    casenum = int2str(i);
    if i==192
        casenum = '19Åf';
    elseif i==193
        casenum = '19ÅfÅf';
    elseif i==211
        casenum = '21Åf';
    elseif i==221
        casenum = '22+Éø';
    elseif i==231
        casenum = '23+Éø';
    end
    eval(['disp(''ÉPÅ[ÉX',casenum,'Å@é¿çsíÜ'')'])
    
    inputfilename =  './repair_ivb_new.xml';
    OutputOption  = 'ON';
    
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
    
    eval(['save RES',casenum,'.mat RES'])
    
    toc
    
end

rmpath('./subfunction/')

toc
