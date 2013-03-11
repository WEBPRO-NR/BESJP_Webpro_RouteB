function [Tps_c,pumpsystemOpeTime] =...
    mytfunc_PUMPOpeTIME(Qps_c,AHUsystemName,PUMPahuSet,AHUsystemOpeTime)

% for dd = 1:365

% 各日のポンプ運転時間
Tps_c = zeros(365,1);
% ポンプの運転時間マトリックス
pumpsystemOpeTime = zeros(365,24);

if isempty(PUMPahuSet) == 0
    
%     tmpStart = [];
%     tmpStop  = [];
    
    %         if Qps_c(dd,1) > 0    % DEBUG(年中2次ポンプを動かす)
    
    % 運転時間マトリックス
    tmp = zeros(1,365,24);
    
    for i = 1:length(PUMPahuSet)
        
        for j = 1:length(AHUsystemName)
            if strcmp(PUMPahuSet(i),AHUsystemName(j))
                break
            end
        end
        
        % 運転時間マトリックスに、AHUsystemOpeTime（運転なら1、停止なら0）を足しこむ。
        tmp = tmp + AHUsystemOpeTime(j,:,:);
        
        %             if ahuTime_start(dd,j)==0 && ahuTime_stop(dd,j)==0
        %                 tmpStart = [tmpStart,ahuTime_start(dd,j)];  % DEBUG(年中2次ポンプを動かす)
        %                 tmpStop  = [tmpStop,ahuTime_stop(dd,j)];    % DEBUG(年中2次ポンプを動かす)
        %             else
        %                 tmpStart = [tmpStart,ahuTime_start(dd,j)];
        %                 tmpStop  = [tmpStop,ahuTime_stop(dd,j)];
        %             end
    end
    
    for dd =1:365
        for hh = 1:24
            if tmp(1,dd,hh) > 0
                pumpsystemOpeTime(dd,hh) = 1;
            end
        end
    end
    
    % 各日のポンプ運転時間
    Tps_c(:,1) = sum(pumpsystemOpeTime,2);
    
    
    %     pumpTime_Start(dd,1) = min(tmpStart);
    %     pumpTime_Stop(dd,1)  = max(tmpStop);
    %
    %     if max(tmpStop) >= min(tmpStart)
    %         Tps_c(dd,1) = max(tmpStop)-min(tmpStart);
    %     else
    %         Tps_c(dd,1) = min(tmpStart)+(24-max(tmpStop));
    %     end
    
    % DEBUG(年中2次ポンプを動かす)
    %         else
    %             Tps_c(dd,1) = 0;
    %             pumpTime_Start(dd,1) = 0;
    %             pumpTime_Stop(dd,1) = 0;
    %         end
else
    %     Tps_c(,1)          = 0;
    %     pumpTime_Start(dd,1) = 0;
    %     pumpTime_Stop(dd,1)  = 0;    
end

% end
