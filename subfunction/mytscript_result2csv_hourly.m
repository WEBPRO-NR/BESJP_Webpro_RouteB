% mytscript_result2csv_hourly.m
%                                                  2016/01/05 by Masato Miyata
%------------------------------------------------------------------------------
% 省エネ基準ルートB：計算結果をcsvファイルに保存する。
%------------------------------------------------------------------------------

% 出力するファイル名
if isempty(strfind(INPUTFILENAME,'/'))
    eval(['resfilenameD = ''calcREShourly_AC_',INPUTFILENAME(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(INPUTFILENAME,'/');
    eval(['resfilenameD = ''calcREShourly_AC_',INPUTFILENAME(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
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

RESALL = [ TimeLabel,Qctotal_hour,Qhtotal_hour,sum(E_AHUaex,2),sum(E_fan_hour,2),sum(E_pump_hour,2),...
    E_ref_source_hour,sum(E_ref_ACc_hour,2),sum(E_PPc_hour,2),sum(E_CTfan_hour,2),sum(E_CTpump_hour,2)];


% 結果格納用変数
rfc = {};

rfc = [rfc;'月,日,時,冷房負荷[kW],暖房負荷[kW],電力消費量(全熱交換気)[MWh],電力消費量(空調ファン)[MWh],', ...
    '電力消費量(二次ポンプ)[MWh],電力消費量(熱源主機)[MWh],都市ガス消費量(熱源主機)[m3/h],重油消費量(熱源主機)[L/h],' ...
    '灯油消費量(熱源主機)[L/h],液化石油消費量(熱源主機)[kg/h],他人から供給された蒸気(熱源主機)[MJ],他人から供給された温水(熱源主機)[MJ],' ...
    '他人から供給された冷水(熱源主機)[MJ],電力消費量(熱源補機)[MWh],電力消費量(一次ポンプ)[MWh],電力消費量(冷却塔ファン)[MWh],' ...
    '電力消費量(冷却水ポンプ)[MWh]'];
rfc = mytfunc_oneLinecCell(rfc,RESALL);

% 出力
fid = fopen(resfilenameD,'w+');
for i=1:size(rfc,1)
    fprintf(fid,'%s\r\n',rfc{i});
end
fclose(fid);

