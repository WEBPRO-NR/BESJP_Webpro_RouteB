% mytfunc_matrixPUMP.m
%                                                                                by Masato Miyata 2011/10/15
%-----------------------------------------------------------------------------------------------------------
% ポンプ負荷データを元に，負荷の出現頻度マトリックスを作成する．
%-----------------------------------------------------------------------------------------------------------
% 入力
%   MODE   : 計算モード（時系列newHASP，日積算newHASP，簡略法）
%   Qps    : ポンプ負荷（時間積算or日積算）[kW]
%   Qpsr   : ポンプ定格能力 [kW]
%   Tps    : ポンプ運転時間（日積算のみ）[hour]
% 出力
%   Mxc    : 負荷出現頻度マトリックス
%-----------------------------------------------------------------------------------------------------------

function [Mxc] = mytfunc_matrixPUMP(MODE,Qps,Qpsr,Tps,mxL)


switch MODE
    
    case {0,4}
        
        % 時系列データ
        Mxc = zeros(8760,1);
        
        for dd = 1:365
            for hh = 1:24
                
                % 1月1日0時からの時間数
                num = 24*(dd-1)+hh;
                
                tmp = Qps(num,1)/Qpsr; % 負荷率
                
                if tmp > 0    
                    ix = mytfunc_countMX(tmp,mxL);
                    Mxc(num,1) = ix;
                end
                
            end
        end
        
    case {1}
        
        % マトリックス
        Mxc = zeros(1,length(mxL)); % 冷房マトリックス
        
        % 時刻別にマトリックスに格納していく
        for dd = 1:365
            for hh = 1:24
                num = 24*(dd-1)+hh;
                
                tmp = Qps(num,1)/Qpsr; % 負荷率
                
                if tmp > 0
                    ix = mytfunc_countMX(tmp,mxL);
                    Mxc(1,ix) = Mxc(1,ix) + 1;
                end
                
            end
        end
        
    case {2,3}
        
        % マトリックス
        Mxc = zeros(1,length(mxL)); % 冷房マトリックス
        
        Lpump = (Qps./Tps.*1000./3600)./Qpsr;
        Tpump = Tps;
        
        for dd = 1:365
            if isnan(Lpump(dd,1)) == 0 % ゼロ割でNaNになっている値を飛ばす
                if Lpump(dd,1) > 0
                    % 出現時間マトリックスを作成
                    ix = mytfunc_countMX(Lpump(dd,1),mxL);
                    Mxc(1,ix) = Mxc(1,ix) + Tpump(dd,1);
                end
            end
        end
        
end

