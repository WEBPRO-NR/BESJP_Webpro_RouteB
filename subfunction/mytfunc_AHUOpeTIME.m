% mytfunc_AHUOpeTIME.m
%                                                                                by Masato Miyata 2011/10/15
%-----------------------------------------------------------------------------------------------------------
% 室接続を元に空調運転時間を求める．各室の空調時間の和集合とする．
%-----------------------------------------------------------------------------------------------------------
% 入力
%   AHUsystemName  : 空調系統名称リスト
%   roomNAME       : 室系統名称リスト
%   AHUQallSet     : 空調系統ごとの接続室リスト（室負荷＋外気負荷）
%   roomTime_start : 各室の空調開始時刻
%   roomTime_stop  : 各室の空調停止時刻
%   roomDayMode    : 室ごとの空調運転時間モード（0:終日，1:昼，2:夜）
% 出力
%   AHUsystemT     : 空調運転時間（365日分×システム数）[h]
%   ahuTime_start  : 空調開始時刻（365日分×システム数）
%   ahuTime_stop   : 空調終了時刻（365日分×システム数）
%   ahuDayMode     : 空調運転時間モード（0:終日，1:昼，2:夜）
%-----------------------------------------------------------------------------------------------------------

function [AHUsystemT,ahuTime_start,ahuTime_stop,ahuDayMode]...
    = mytfunc_AHUOpeTIME(AHUsystemName,roomNAME,AHUQallSet,roomTime_start,roomTime_stop,roomDayMode)

AHUsystemT    = zeros(365,length(AHUsystemName));  % 空調運転時間
ahuTime_start = zeros(365,length(AHUsystemName));  % 空調開始時刻
ahuTime_stop  = zeros(365,length(AHUsystemName));  % 空調終了時刻

for sysa=1:length(AHUsystemName) % 空調系統ごと
       
    for dd = 1:365 % 日のループ
        
        tmpStart = [];
        tmpStop  = [];
        tmpMode  = [];
        
        for sysm = 1:length(AHUQallSet{sysa}) % 接続室ごと
            
            % マッチする室を探す
            for i=1:length(roomNAME)
                if strcmp(AHUQallSet{sysa}(sysm),roomNAME(i))
                    break
                end
            end
            
            tmpStart = [tmpStart, roomTime_start(dd,i)];
            tmpStop  = [tmpStop, roomTime_stop(dd,i)];
            
            if dd==1
                tmpMode = [tmpMode, roomDayMode(i)];
            end
            
        end
        
        % 和集合をとる．
        if isempty(tmpStart)
            ahuTime_start(dd,sysa) = 0;
        else
            ahuTime_start(dd,sysa) = min(tmpStart); % 一番早い時間が開始時刻
        end
        if isempty(tmpStop)
            ahuTime_stop(dd,sysa) = 0;
        else
            ahuTime_stop(dd,sysa)  = max(tmpStop);  % 一番遅い時間が終了時刻
        end
        
        % 空調時間
        if isempty(tmpStart) == 0 && isempty(tmpStop) == 0
            if max(tmpStop) >= min(tmpStart)
                % 日を跨がない場合
                AHUsystemT(dd,sysa) = max(tmpStop)-min(tmpStart);
            else
                % 日を跨ぐ場合
                AHUsystemT(dd,sysa) = min(tmpStart)+(24-max(tmpStop));
            end
        else
            AHUsystemT(dd,sysa) = 0;
        end
        
    end
    
    % 使用時間帯（PROD：配列の要素の積）
    if prod(tmpMode) == 1
        ahuDayMode(sysa) = 1; % '昼'
    elseif prod(tmpMode) == 0
        ahuDayMode(sysa) = 0; % '終日'
    elseif prod(tmpMode./2) == 1
        ahuDayMode(sysa) = 2; % '夜'
    else
        ahuDayMode(sysa) = 0; % '終日'
    end
    
end
