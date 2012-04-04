function [Tps_c,pumpTime_Start,pumpTime_Stop] =...
    mytfunc_PUMPOpeTIME(Qps_c,AHUsystemName,PUMPahuSet,ahuTime_start,ahuTime_stop)

for dd = 1:365
    
    tmpStart = [];
    tmpStop  = [];
    
    %         if Qps_c(dd,1) > 0    % DEBUG(年中2次ポンプを動かす)
    
    for i = 1:length(PUMPahuSet)
        for j = 1:length(AHUsystemName)
            if strcmp(PUMPahuSet(i),AHUsystemName(j))
                break
            end
        end
        if ahuTime_start(dd,j)==0 && ahuTime_stop(dd,j)==0
            tmpStart = [tmpStart,ahuTime_start(dd,j)];  % DEBUG(年中2次ポンプを動かす)
            tmpStop  = [tmpStop,ahuTime_stop(dd,j)];    % DEBUG(年中2次ポンプを動かす)
        else
            tmpStart = [tmpStart,ahuTime_start(dd,j)];
            tmpStop  = [tmpStop,ahuTime_stop(dd,j)];
        end
    end
    
    pumpTime_Start(dd,1) = min(tmpStart);
    pumpTime_Stop(dd,1)  = max(tmpStop);
    
    if max(tmpStop) >= min(tmpStart)
        Tps_c(dd,1) = max(tmpStop)-min(tmpStart);
    else
        Tps_c(dd,1) = min(tmpStart)+(24-max(tmpStop));
    end
    
    % DEBUG(年中2次ポンプを動かす)
    %         else
    %             Tps_c(dd,1) = 0;
    %             pumpTime_Start(dd,1) = 0;
    %             pumpTime_Stop(dd,1) = 0;
    %         end
    
end
end