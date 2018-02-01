% mytscript_result2csv_hourly_for_CGS.m
%                                                  2017/04/14 by Masato Miyata
%------------------------------------------------------------------------------
% 省エネ基準ルートB：計算結果をcsvファイルに保存する（CGS計算用）。
%------------------------------------------------------------------------------

% 出力するファイル名
if isempty(strfind(INPUTFILENAME,'/'))
    eval(['resfilenameD = ''calcREShourly_ACforCGS_',INPUTFILENAME(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(INPUTFILENAME,'/');
    eval(['resfilenameD = ''calcREShourly_ACforCGS_',INPUTFILENAME(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
end

% 冷房負荷、暖房負荷（kW）
Qctotal_hour = zeros(8760,1);
Qhtotal_hour = zeros(8760,1);
for iREF = 1:numOfRefs
    if REFtype(iREF) == 1
        Qctotal_hour(:,1) = Qctotal_hour(:,1) + Qref_hour(:,iREF);
    elseif REFtype(iREF) == 2
        Qhtotal_hour(:,1) = Qhtotal_hour(:,1) + Qref_hour(:,iREF);
    end
end

% 月：日：時
TimeLabel = zeros(8760,3);
for dd = 1:365
    for hh = 1:24
        % 1月1日0時からの時間数
        num = 24*(dd-1)+hh;
        t = datenum(2015,1,1) + (dd-1) + (hh-1)/24;
        TimeLabel(num,1) = str2double(datestr(t,'mm'));
        TimeLabel(num,2) = str2double(datestr(t,'dd'));
        TimeLabel(num,3) = str2double(datestr(t,'hh'));
    end
end


%% コジェネ用の処理

E_ref_cgsC_ABS_hour  = zeros(8760,1);
Lt_ref_cgsC_hour = zeros(8760,1);
E_ref_cgsH_hour_MWh = zeros(8760,1);
E_ref_cgsH_hour = zeros(8760,1);
Q_ref_cgsH_hour = zeros(8760,1);

for iREF = 1:numOfRefs
     
    % CGS系統の「排熱利用する温熱源」
    if strcmp(strcat(CGS_refName_H,'_H'),refsetID{iREF})

        % CGS系統の「排熱利用する温熱源」の電力消費量 [MWh]
        for iREFSUB = 1:refsetRnum(iREF)
            if refInputType(iREF,iREFSUB) == 1   % 電力
                E_ref_cgsH_hour_MWh(:,1) = E_ref_cgsH_hour_MWh(:,1) + E_refsys_hour(:,iREF,iREFSUB)./(9760);  % [MWh]
            end
        end
        
        % CGS系統の「排熱利用する温熱源」の一次エネルギー消費量 [MJ]
        E_ref_cgsH_hour(:,1) = E_ref_hour(:,iREF);  % [MJ]
        Q_ref_cgsH_hour(:,1) = Qref_hour(:,iREF).*3600./1000;  % [kW]→[MJ]
        
    end
    
    % CGS系統の「排熱利用する冷熱源」
    if strcmp(strcat(CGS_refName_H,'_C'),refsetID{iREF})
        
        % CGS系統の「排熱利用する冷熱源」の「吸収式冷凍機（都市ガス）」の一次エネルギー消費量 [MJ]
        for iREFSUB = 1:refsetRnum(iREF)
            if strcmp(refset_Type{iREF,iREFSUB},'AbcorptionChiller_CityGas')
                E_ref_cgsC_ABS_hour(:,1) =  E_ref_cgsC_ABS_hour(:,1) + E_refsys_hour(:,iREF,iREFSUB);
            end
        end
        
        % 負荷率[-]
        for dd = 1:365
            for hh = 1:24
                nn = 24*(dd-1)+hh;
                if LtREF(nn,iREF) == 0
                    Lt_ref_cgsC_hour(nn,1) = 0;
                elseif LtREF(nn,iREF) == 11
                    Lt_ref_cgsC_hour(nn,1) = 1.2;
                else
                    Lt_ref_cgsC_hour(nn,1) = 0.1*LtREF(nn,iREF)-0.05;
                end
            end        
        end
    end
    
end


RESALL = [ TimeLabel,sum(E_AHUaex,2),sum(E_fan_hour,2),sum(E_pump_hour,2),...
    E_ref_source_hour(:,1),E_ref_cgsH_hour_MWh(:,1),sum(E_ref_ACc_hour,2),sum(E_PPc_hour,2),sum(E_CTfan_hour,2),sum(E_CTpump_hour,2),...
    E_ref_cgsC_ABS_hour(:,1),Lt_ref_cgsC_hour(:,1),E_ref_cgsH_hour(:,1),Q_ref_cgsH_hour(:,1)];



% 結果格納用変数
rfc = {};

rfc = [rfc;'月,日,時,電力消費量(全熱交換気)[MWh],電力消費量(空調ファン)[MWh],', ...
    '電力消費量(二次ポンプ)[MWh],電力消費量(熱源主機)[MWh],電力消費量(CGS系統の排熱利用する温熱源主機)[MWh],' ...
    '電力消費量(熱源補機)[MWh],電力消費量(一次ポンプ)[MWh],電力消費量(冷却塔ファン)[MWh],電力消費量(冷却水ポンプ)[MWh],'...
    '一次エネルギー消費量(CGS系統の排熱投入型吸収式冷温水機・冷熱源の主機) [MJ],負荷率(CGS系統の排熱投入型吸収式冷温水機・冷熱源群) [MJ],'...
    '一次エネルギー消費量(CGS系統の温熱源群の主機) [MJ],熱源負荷(CGS系統の温熱源群) [MJ]'];
rfc = mytfunc_oneLinecCell(rfc,RESALL);

% 出力
fid = fopen(resfilenameD,'w+');
for i=1:size(rfc,1)
    fprintf(fid,'%s\r\n',rfc{i});
end
fclose(fid);

