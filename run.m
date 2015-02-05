% XML作成からエネルギー計算までを一気に実行するスクリプト
clear
clc
tic

addpath('./subfunction')
addpath('./XMLfileMake')

xmlfilename = 'csv2xml_config.xml';
region = 'IVb';

% XML作成
copyfile(xmlfilename,'./XMLfileMake/csv2xml_config.xml')
mytfunc_csv2xml_run('output.xml',region);

% 計算実行
RES = ECS_routeB_run('output.xml');


% for j = 1:8
%     
%     if j == 1
%         region = 'Ia';
%     elseif j == 2
%         region = 'Ib';
%     elseif j == 3
%         region = 'II';
%     elseif j == 4
%         region = 'III';
%     elseif j == 5
%         region = 'IVa';
%     elseif j == 6
%         region = 'IVb';
%     elseif j == 7
%         region = 'V';
%     elseif j == 8
%         region = 'VI';
%     end
%     
%     
%     for i = 1:3
%         
%         if i == 1
%             if j <= 2
%                 xmlfilename = 'csv2xml_config_ガス1台_resion1.xml';
%             elseif j <= 4
%                 xmlfilename = 'csv2xml_config_ガス1台_resion3.xml';
%             else
%                 xmlfilename = 'csv2xml_config_ガス1台.xml';
%             end
%         elseif i == 2
%             if j <= 2
%                 xmlfilename = 'csv2xml_config_ガス2台_resion1.xml';
%             elseif j <= 4
%                 xmlfilename = 'csv2xml_config_ガス2台_resion3.xml';
%             else
%                 xmlfilename = 'csv2xml_config_ガス2台.xml';
%             end
%         elseif i == 3
%             if j <= 2
%                 xmlfilename = 'csv2xml_config_ガス3台_resion1.xml';
%             elseif j <= 4
%                 xmlfilename = 'csv2xml_config_ガス3台_resion3.xml';
%             else
%                 xmlfilename = 'csv2xml_config_ガス3台.xml';
%             end
%         elseif i == 4
%             if j <= 2
%                 xmlfilename = 'csv2xml_config_石油1台_resion1.xml';
%             elseif j <= 4
%                 xmlfilename = 'csv2xml_config_石油1台_resion3.xml';
%             else
%                 xmlfilename = 'csv2xml_config_石油1台.xml';
%             end
%         elseif i == 5
%             if j <= 2
%                 xmlfilename = 'csv2xml_config_石油2台_resion1.xml';
%             elseif j <= 4
%                 xmlfilename = 'csv2xml_config_石油2台_resion3.xml';
%             else
%                 xmlfilename = 'csv2xml_config_石油2台.xml';
%             end
%         elseif i == 6
%             if j <= 2
%                 xmlfilename = 'csv2xml_config_石油3台_resion1.xml';
%             elseif j <= 4
%                 xmlfilename = 'csv2xml_config_石油3台_resion3.xml';
%             else
%                 xmlfilename = 'csv2xml_config_石油3台.xml';
%             end
%         end
%         
%         % XML作成
%         copyfile(xmlfilename,'./XMLfileMake/csv2xml_config.xml')
%         mytfunc_csv2xml_run('output.xml',region);
%         
%         % 計算実行
%         RES = ECS_routeB_run('output.xml');
%         
%     end
%     
% end

rmpath('./subfunction')
rmpath('./XMLfileMake')

