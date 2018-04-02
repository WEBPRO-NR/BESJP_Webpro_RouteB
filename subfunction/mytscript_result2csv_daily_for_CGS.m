% mytscript_result2csv_daily_for_CGS.m
%                                                  2018/03/15 by Masato Miyata
%------------------------------------------------------------------------------
% 省エネ基準ルートB：計算結果をcsvファイルに保存する（CGS計算用）。
%------------------------------------------------------------------------------

% 初期化
if exist('CGSmemory.mat','file') == 0
    CGSmemory = [];
else
    load CGSmemory.mat
end
if isfield(CGSmemory,'RESALL') == 0
    CGSmemory.RESALL = zeros(365,20);
end

RESALL = CGSmemory.RESALL;

% 日付
RESALL(:,1) = [1:365]';

% 熱源主機の電力消費量 [MWh/day]
RESALL(:,3) = E_ref_source_day(:,1);  % 後半でCGSから排熱供給を受ける熱源群の電力消費量を差し引く。
% 熱源補機の電力消費量 [MWh/day]
RESALL(:,4) = sum(E_ref_ACc_day,2) + sum(E_PPc_day,2) + sum(E_CTfan_day,2) + sum(E_CTpump_day,2);
% 二次ポンプ群の電力消費量 [MWh/day]
RESALL(:,5) = sum(E_pump_day,2);
% 空調機群の電力消費量 [MWh/day]
RESALL(:,6) = sum(E_fan_day,2) + sum(E_AHUaex_day,2);


%% 排熱利用熱源系統

E_ref_cgsC_ABS_day = zeros(365,1);
Lt_ref_cgsC_day    = zeros(365,1);
E_ref_cgsH_day     = zeros(365,1);
Q_ref_cgsH_day     = zeros(365,1);
T_ref_cgsC_day     = zeros(365,1);
T_ref_cgsH_day     = zeros(365,1);
NAC_ref_link = 0;
qAC_link_c_j_rated = 0;
EAC_link_c_j_rated = 0;

for iREF = 1:numOfRefs
    
    % CGS系統の「排熱利用する冷熱源」
    if strcmp(refsetID{iREF}, strcat(CGS_refName_C,'_C'))
        
        % CGS系統の「排熱利用する冷熱源」の「吸収式冷凍機（都市ガス）」の一次エネルギー消費量 [MJ]
        for iREFSUB = 1:refsetRnum(iREF)
            if strcmp(refset_Type{iREF,iREFSUB},'AbcorptionChiller_Steam') || ...
                    strcmp(refset_Type{iREF,iREFSUB},'AbcorptionChiller_Steam_CTVWV') || ...
                    strcmp(refset_Type{iREF,iREFSUB},'AbcorptionChiller_HotWater') || ...
                    strcmp(refset_Type{iREF,iREFSUB},'AbcorptionChiller_Combination_CityGas') || ...
                    strcmp(refset_Type{iREF,iREFSUB},'AbcorptionChiller_Combination_CityGas_CTVWV') || ...
                    strcmp(refset_Type{iREF,iREFSUB},'AbcorptionChiller_Combination_LPG') || ...
                    strcmp(refset_Type{iREF,iREFSUB},'AbcorptionChiller_Combination_LPG_CTVWV') || ...
                    strcmp(refset_Type{iREF,iREFSUB},'AbcorptionChiller_Combination_Steam') || ...
                    strcmp(refset_Type{iREF,iREFSUB},'AbcorptionChiller_Combination_Steam_CTVWV')

                E_ref_cgsC_ABS_day(:,1) =  E_ref_cgsC_ABS_day(:,1) + E_refsys_day(:,iREF,iREFSUB);
                
                % 排熱投入型吸収式冷温水機jの定格冷却能力
                qAC_link_c_j_rated = qAC_link_c_j_rated + refset_Capacity(iREF,iREFSUB);
                % 排熱投入型吸収式冷温水機jの主機定格消費エネルギー
                EAC_link_c_j_rated = EAC_link_c_j_rated + refset_MainPower(iREF,iREFSUB);
                
                NAC_ref_link = NAC_ref_link + 1;
            end
        end
        
        % CGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての負荷率 [-]
        for dd = 1:365
            if LdREF(dd,iREF) == 0
                Lt_ref_cgsC_day(dd,1) = 0;
            elseif LdREF(dd,iREF) == 11
                Lt_ref_cgsC_day(dd,1) = 1.2;
            else
                Lt_ref_cgsC_day(dd,1) = 0.1*LdREF(dd,iREF)-0.05;
            end
        end
        
        % CGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の運転時間 [h/日]
        T_ref_cgsC_day = TimedREF(:,iREF);
        
    end
    
    % CGS系統の「排熱利用する温熱源」
    if strcmp(strcat(CGS_refName_H,'_H'),refsetID{iREF})
        
        % 当該温熱源群の主機の消費電力を差し引く。
        RESALL(:,3) = RESALL(:,3) - E_ref_source_Ele_day(:,iREF);
        
        % CGSの排熱利用が可能な温熱源群の主機の一次エネルギー消費量 [MJ/日]
        E_ref_cgsH_day(:,1) = E_ref_day(:,iREF);  % [MJ]
        % CGSの排熱利用が可能な温熱源群の熱源負荷 [MJ/日]
        Q_ref_cgsH_day(:,1) = Qref(:,iREF);  % [MJ]
        % CGSの排熱利用が可能な温熱源群の運転時間 [h/日]
        T_ref_cgsH_day = TimedREF(:,iREF);
        
    end
    
end

% 空気調和設備の電力消費量 [MWh/day]
RESALL(:,2) = sum(RESALL(:,3:6),2);

RESALL(:,7)  = E_ref_cgsC_ABS_day;
RESALL(:,8)  = Lt_ref_cgsC_day;
RESALL(:,9)  = E_ref_cgsH_day;
RESALL(:,10) = Q_ref_cgsH_day;
RESALL(:,19) = T_ref_cgsC_day;
RESALL(:,20) = T_ref_cgsH_day;


CGSmemory.RESALL = RESALL;
CGSmemory.NAC_ref_link = NAC_ref_link;
CGSmemory.qAC_link_c_j_rated = qAC_link_c_j_rated;
CGSmemory.EAC_link_c_j_rated = EAC_link_c_j_rated;

save CGSmemory.mat CGSmemory


% CSVファイルへの出力
if OutputOptionVar == 1
    
    % 出力するファイル名
    if isempty(strfind(INPUTFILENAME,'/'))
        eval(['resfilenameD = ''calcRESdaily_ACforCGS_',INPUTFILENAME(1:end-4),'_',datestr(now,30),'.csv'';'])
    else
        tmp = strfind(INPUTFILENAME,'/');
        eval(['resfilenameD = ''calcRESdaily_ACforCGS_',INPUTFILENAME(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
    end
    
    % 結果格納用変数
    rfc = {};
    rfc = [rfc; '日,空気調和設備の電力消費量 [MWh/日],空気調和設備のうち熱源群主機の電力消費量 [MWh/日],'...
        '空気調和設備のうち熱源群補機の電力消費量 [MWh/日],空気調和設備のうち二次ポンプ群の電力消費量 [MWh/日],'...
        '空気調和設備のうち空調機群の電力消費量 [MWh/日],CGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての主機の一次エネルギー消費量 [MJ/日],'...
        'CGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の冷熱源としての負荷率 [-],CGSの排熱利用が可能な温熱源群の主機の一次エネルギー消費量 [MJ/日],'...
        'CGSの排熱利用が可能な温熱源群の熱源負荷 [MJ/日],機械換気設備の電力消費量 [MWh/日],'...
        '照明設備の電力消費量 [MWh/日],給湯設備の電力消費量 [MWh/日],'...
        'CGSの排熱利用が可能な給湯機(系統)の一次エネルギー消費量 [MJ/日],CGSの排熱利用が可能な給湯機(系統)の給湯負荷 [MJ/日],'...
        '昇降機の電力消費量 [MWh/日],効率化設備（太陽光発電）の発電量 [MWh/日],その他の電力消費量 [MWh/日],'...
        'CGSの排熱利用が可能な排熱投入型吸収式冷温水機(系統)の運転時間 [h/日],CGSの排熱利用が可能な温熱源群の運転時間 [h/日]'];
    
    rfc = mytfunc_oneLinecCell(rfc,RESALL);
    
    % 出力
    fid = fopen(resfilenameD,'w+');
    for i=1:size(rfc,1)
        fprintf(fid,'%s\r\n',rfc{i});
    end
    fclose(fid);
    
end