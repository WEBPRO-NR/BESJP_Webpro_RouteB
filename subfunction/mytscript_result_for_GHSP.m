% mytscript_result_for_GSHP.m
%                                                  2016/02/04 by Masato Miyata
%------------------------------------------------------------------------------
% 省エネ基準ルートB：地盤結果をcsvファイルに保存する。
%------------------------------------------------------------------------------

% 出力するファイル名
if isempty(strfind(INPUTFILENAME,'/'))
    eval(['resfilenameD = ''calcREShourly_QforGound_',INPUTFILENAME(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(INPUTFILENAME,'/');
    eval(['resfilenameD = ''calcREShourly_QforGound_',INPUTFILENAME(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
end

% 地盤に投入される熱 [W] を抜き出す
HeatforGround = zeros(8760,1);
for iREF = 1:numOfRefs
    for iREFSUB = 1:refsetRnum(iREF)
        
        if refHeatSourceType(iREF,iREFSUB) == 3  % 地中熱の場合

            for hh = 1:8760
                if LtREF(hh,iREF) > 0 && REFtype(iREF) == 1  % 冷房
                    HeatforGround(hh,1) = HeatforGround(hh,1) + ( (Q_refsys_hour(hh,iREF,iREFSUB)*1000) + (E_refsys_hour(hh,iREF,iREFSUB)*1000000./9760) );
                    
                elseif LtREF(hh,iREF) > 0 && REFtype(iREF) == 2  % 暖房
                    HeatforGround(hh,1) = HeatforGround(hh,1) + (-1) * ( (Q_refsys_hour(hh,iREF,iREFSUB)*1000) - (E_refsys_hour(hh,iREF,iREFSUB)*1000000./9760) );
                    
                end
            end
            
        end
    end
end


% 結果格納用変数
rfc = {};
rfc = [rfc;'地盤への投入熱量[W]'];
rfc = mytfunc_oneLinecCell(rfc,HeatforGround);

% 出力
fid = fopen(resfilenameD,'w+');
for i=1:size(rfc,1)
    fprintf(fid,'%s\r\n',rfc{i});
end
fclose(fid);