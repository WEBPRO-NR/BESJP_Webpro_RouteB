clear
clc

tic

addpath('./subfunction/')


for i=[5,7,18,19,192,193,21,211,22,221,231]
    
    casenum = int2str(i);
    if i==192
        casenum = '19f';
    elseif i==193
        casenum = '19ff';
    elseif i==211
        casenum = '21f';
    elseif i==221
        casenum = '22+ƒ¿';
    elseif i==231
        casenum = '23+ƒ¿';
    end
    eval(['disp(''ƒP[ƒX',casenum,'@Às’†'')'])
    
    %     eval(['inputfilename = ''./InputFiles/IBECƒ‚ƒfƒ‹/IBECƒ‚ƒfƒ‹6_CaseStudy120625_Ib/Case',casenum,'/IBEC6_Ib_Case',casenum,'.xml'';'])
    %     eval(['copyfile ./InputFiles/IBECƒ‚ƒfƒ‹/IBECƒ‚ƒfƒ‹6_CaseStudy120625_Ib/Case',casenum,'/WCON.csv ./database '])
    %     eval(['copyfile ./InputFiles/IBECƒ‚ƒfƒ‹/IBECƒ‚ƒfƒ‹6_CaseStudy120625_Ib/Case',casenum,'/WIND.csv ./database '])
        
    eval(['inputfilename = ''./InputFiles/––±Š10000‰üC/‰üCVer5/Ib’nˆæ/10000‡u‰üCCase',casenum,'/Repair_Ib_Case',casenum,'.xml'';'])
    eval(['copyfile ./InputFiles/––±Š10000‰üC/‰üCVer5/Ib’nˆæ/10000‡u‰üCCase',casenum,'/WCON.csv ./database '])
    eval(['copyfile ./InputFiles/––±Š10000‰üC/‰üCVer5/Ib’nˆæ/10000‡u‰üCCase',casenum,'/WIND.csv ./database '])
    
%     eval(['inputfilename = ''./InputFiles/“s“à–^•¶Œn‘åŠw/ver20120627_IVb/Case',casenum,'/NSRI_School_IVb_Case',casenum,'.xml'';'])
%     eval(['copyfile ./InputFiles/“s“à–^•¶Œn‘åŠw/ver20120627_IVb/Case',casenum,'/WCON.csv ./database'])
%     eval(['copyfile ./InputFiles/“s“à–^•¶Œn‘åŠw/ver20120627_IVb/Case',casenum,'/WIND.csv ./database'])
%     %
%         eval(['inputfilename = ''./InputFiles/–^•a‰@/ver3/Case',casenum,'/sohmecHospital_Case',casenum,'.xml'';'])
%         eval(['copyfile ./InputFiles/–^•a‰@/ver3/Case',casenum,'/WCON.csv ./database'])
%         eval(['copyfile ./InputFiles/–^•a‰@/ver3/Case',casenum,'/WIND.csv ./database'])
    
%         eval(['inputfilename = ''./InputFiles/Pƒzƒeƒ‹/ver',casenum,'/TAISEI_Photel.xml'';'])
%         eval(['copyfile ./InputFiles/Pƒzƒeƒ‹/ver',casenum,'/WCON.csv ./database'])
%         eval(['copyfile ./InputFiles/Pƒzƒeƒ‹/ver',casenum,'/WIND.csv ./database'])
    
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
