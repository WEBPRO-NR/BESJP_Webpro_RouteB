clear
clc

tic

addpath('./subfunction')

RES = ECS_routeB_run('NSRI_School_IVb_Case0.xml');

% for i=0
%     eval(['RES',int2str(i),' = ECS_routeB_run(''./InputFiles/“s“à–^•¶Œn‘åŠw/ver20120830_VI/R‹c‰ï—pCase',int2str(i),'_CSV/NSRI_School_VI_Case',int2str(i),'.xml'');'])
%     toc
% end
% 
% % RES8 = ECS_routeB_run('./InputFiles/“s“à–^•¶Œn‘åŠw/ver20120830_IVb/R‹c‰ï—pCase0_CSV/NSRI_School_IVb_Case0.xml');
% % toc
% % 
% % RES9 = ECS_routeB_run('./InputFiles/“s“à–^•¶Œn‘åŠw/ver20120830_Ia/R‹c‰ï—pCase0_CSV/NSRI_School_Ia_Case0.xml');
% % toc

rmpath('./subfunction')