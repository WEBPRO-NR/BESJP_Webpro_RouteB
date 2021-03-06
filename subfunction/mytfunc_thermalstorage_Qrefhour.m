% mytfunc_thermalstorage_Qrefhour
%                                                                2016/01/11
%--------------------------------------------------------------------------
% 蓄熱負荷計算（時系列計算用）
%--------------------------------------------------------------------------

function [Qref_hour,Qref_hour_discharge] = mytfunc_thermalstorage_Qrefhour(Qref_hour,REFstorage,storageEffratio,refsetStorageSize,numOfRefs,refset_Capacity,refsetID,QrefrMax)

Qref_hour_discharge = zeros(8760,numOfRefs);

% 放熱＋追掛け
for iREF = 1:numOfRefs
    if REFstorage(iREF) == -1  % 採熱＋追掛け
        
        % 一時間あたりの採熱最大量（熱交換器の容量） [kW]
        Qmax   = refset_Capacity(iREF,1);
        % 最大蓄熱量（蓄熱槽効率を加味した正味の利用可能量） [MJ]
        Qlimit = storageEffratio(iREF) * refsetStorageSize(iREF);

        % 一日毎に切り出す
        for dd = 1:365
            
            % 各日の時刻別負荷（24時間分）[kW]
            Qref_daily = Qref_hour(24*(dd-1)+1:24*dd,iREF);
            
            % 各日の時刻別の放熱量 [kW]
            Qref_discharge = zeros(24,1);
            
            if sum(Qref_daily) > 0  % 負荷があれば
                
                for hh = [13:19,12:-1:8,20:22]  % この順番で蓄熱槽からの放熱を行う
                    
                    % 蓄熱槽からの放熱量[kW]
                    Qref_discharge(hh,1) = min(Qref_daily(hh), Qmax);
                    
                    if sum(Qref_discharge) > Qlimit*1000/3600
                        
                        % オーバー分を差し引く
                        Qref_discharge(hh,1) = Qref_discharge(hh,1) - (sum(Qref_discharge)-Qlimit*1000/3600);
                        
                        % チェック
                        if (sum(Qref_discharge) - Qlimit*1000/3600) / Qlimit > 0.01
                            error('蓄熱量と放熱量が合いません')
                        end
                        break
                    end
                end
                
            end
            
            % 追掛け運転が必要な負荷 [kW]
            Qref_hour(24*(dd-1)+1:24*dd,iREF) = (Qref_daily - Qref_discharge);
            % 蓄熱槽からの放熱量 [kW]
            Qref_hour_discharge(24*(dd-1)+1:24*dd,iREF) = Qref_discharge;
            
        end
        
    end
end

% 蓄熱
for iREF = 1:numOfRefs
    if REFstorage(iREF) == 1  % 蓄熱
        
        % 放熱負荷[kW]を求める（＝必要蓄熱量を求める）。
        Qref_hour_storage = zeros(8760,1);
        for iREFdb = 1:numOfRefs
            if strcmp(refsetID(iREF),refsetID(iREFdb)) && REFstorage(iREFdb) == -1
                Qref_hour_storage = Qref_hour_discharge(:,iREFdb);
                break
            end
        end
        
        % 一日毎に切り出す
        for dd = 2:365

            % 各日の時刻別負荷（24時間分、但し前日22時から当日21時まで） [kW]
            Qref_r_daily = Qref_hour_storage(24*(dd-1)-1:24*dd-2);
            
            % 蓄熱負荷 [kW]
            Qref_s_daily = zeros(24,1);
            
            if sum(Qref_r_daily) > 0
                
                % 必要蓄熱時間 [hour]
                T_storage = (sum(Qref_r_daily)+(refsetStorageSize(iREF)*0.03*1000/3600)) / QrefrMax(iREF);
                
                % 蓄熱は22時から翌朝6時まで
                if T_storage > 9
                    error('必要蓄熱時間が9時間を超えました。')
                else
                    
                    % 各日の蓄熱負荷 [kW]
                    Qref_s_daily(1:floor(T_storage)) = QrefrMax(iREF) * ones(floor(T_storage),1);
                    Qref_s_daily(floor(T_storage)+1) = QrefrMax(iREF) * (T_storage-floor(T_storage)) ;
                    
                end

            end
            
            % 蓄熱負荷 [kW]
            Qref_hour(24*(dd-1)-1:24*dd-2,iREF) = Qref_s_daily;
            
        end
        
    end
end













