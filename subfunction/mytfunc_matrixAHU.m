% mytfunc_matrixAHU.m
%                                                                                by Masato Miyata 2012/03/27
%-----------------------------------------------------------------------------------------------------------
% 空調負荷データを元に，負荷の出現頻度マトリックスを作成する．
%-----------------------------------------------------------------------------------------------------------
% 入力
%   MODE   : 計算モード（時系列newHASP，日積算newHASP，簡略法）
%   Qa_c   : 冷房負荷（時間積算or日積算）[kW]
%   Qar_c  : 冷房定格能力 [kW]
%   Ta_c   : 冷房運転時間（日積算のみ）[hour]
%   Qa_h   : 暖房負荷（時間積算or日積算）[kW]
%   Qar_h  : 暖房定格能力 [kW]
%   Ta_h   : 暖房運転時間（日積算のみ）[kW]
% 出力
%   Mxc : 負荷出現頻度マトリックス（冷熱）
%   Mxh : 負荷出現頻度マトリックス（温熱）
%-----------------------------------------------------------------------------------------------------------

function [Mxc,Mxh,Tdc,Tdh] = mytfunc_matrixAHU(MODE,Qa_c,Qar_c,Ta_c,Qa_h,Qar_h,Ta_h,AHUCHmode,WIN,MID,SUM,mxL)

% 日別運転時間（MODE=4）
Tdc = zeros(365,2);
Tdh = zeros(365,2);


switch MODE

    case {0,1}
        
        switch MODE
            case {0}
                % 時系列データ
                Mxc = zeros(8760,1);
                Mxh = zeros(8760,1);
            case {1}
                % マトリックス
                Mxc = zeros(1,length(mxL)); % 冷房マトリックス
                Mxh = zeros(1,length(mxL)); % 暖房マトリックス
        end
        
        if AHUCHmode == 1  % 冷暖同時運転有
            
            % 時刻別にマトリックスに格納していく
            for dd = 1:365
                for hh = 1:24
                    num = 24*(dd-1)+hh;
                    
                    if Qa_c(num,1) > 0  % 冷房負荷
                        
                        ix = mytfunc_countMX(Qa_c(num,1)/Qar_c,mxL);
                        
                        switch MODE
                            case {0}
                                Mxc(num,1) = ix;
                            case {1}
                                Mxc(1,ix) = Mxc(1,ix) + 1;
                        end
                        
                    elseif Qa_c(num,1) < 0  % 暖房負荷
                        
                        ix = mytfunc_countMX((-1)*Qa_c(num,1)/Qar_h,mxL);
                        
                        switch MODE
                            case {0}
                                Mxh(num,1) = ix;
                            case {1}
                                Mxh(1,ix) = Mxh(1,ix) + 1;
                        end
                        
                    end
                end
            end
            
            
        elseif AHUCHmode == 0   % 冷暖切替（季節ごと）
            
            % 季節別、時刻別にマトリックスに格納していく
            for iSEASON = 1:3
                
                if iSEASON == 1
                    seasonspan = WIN;
                elseif iSEASON == 2
                    seasonspan = MID;
                elseif iSEASON == 3
                    seasonspan = SUM;
                else
                    error('シーズン番号が不正です')
                end
                
                for dd = seasonspan
                    for hh = 1:24
                        num = 24*(dd-1)+hh;
                        
                        if Qa_c(num,1) ~= 0 && (iSEASON == 2 || iSEASON == 3) % 冷房負荷
                            
                            ix = mytfunc_countMX(Qa_c(num,1)/Qar_c,mxL);
                            
                            switch MODE
                                case {0}
                                    Mxc(num,1) = ix;
                                case {1}
                                    Mxc(1,ix) = Mxc(1,ix) + 1;
                            end
                            
                        elseif Qa_c(num,1) ~= 0 && iSEASON == 1  % 暖房負荷
                            
                            ix = mytfunc_countMX((-1)*Qa_c(num,1)/Qar_h,mxL);
                            
                            switch MODE
                                case {0}
                                    Mxh(num,1) = ix;
                                case {1}
                                    Mxh(1,ix) = Mxh(1,ix) + 1;
                            end
                        end
                    end
                end
            end
            
        else
            error('二管式／四管式の設定が不正です')
        end
        
        
    case {2,3,4}
        
        switch MODE
            case {2,3}
                Mxc = zeros(1,length(mxL)); % 冷房マトリックス
                Mxh = zeros(1,length(mxL)); % 暖房マトリックス
            case {4}
                Mxc = zeros(365,2); % 日別データ
                Mxh = zeros(365,2); % 日別データ
        end
        
        
        for ich = 1:2
            
            if ich == 1 % 室内負荷が冷房要求の場合
                
                % 2013/06/06修正(冷房定格能力と暖房定格能力で場合分け)
                for dd = 1:length(Qa_c)
                    if Qa_c(dd) >= 0
                        La(dd,1) = (Qa_c(dd,1)./Ta_c(dd,1).*1000./3600)./Qar_c;  % 負荷率 [-]
                    else
                        La(dd,1) = (Qa_c(dd,1)./Ta_c(dd,1).*1000./3600)./Qar_h;  % 負荷率 [-]
                    end
                end
                Ta = Ta_c;
                
            elseif ich == 2 % 室内負荷が暖房要求の場合
                
                % 2013/06/06修正(冷房定格能力と暖房定格能力で場合分け)
                for dd = 1:length(Qa_h)
                    if Qa_h(dd) <= 0
                        La(dd,1) = (Qa_h(dd,1)./Ta_h(dd,1).*1000./3600)./Qar_h;  % 負荷率 [-]
                    else
                        La(dd,1) = (Qa_h(dd,1)./Ta_h(dd,1).*1000./3600)./Qar_c;  % 負荷率 [-]
                    end
                end
                Ta = Ta_h;
                
            end
            
            if (Qar_c > 0) || (Qar_h > 0)  % 定格能力＞０　→　AHU or FCU があれば
                
                if AHUCHmode == 1  % 冷暖同時運転有
                    
                    for dd = 1:365
                        if isnan(La(dd,1)) == 0 % ゼロ割でNaNになっている値を飛ばす
                            
                            if La(dd,1) > 0 % 冷房負荷であれば
                                ix = mytfunc_countMX(La(dd,1),mxL);
                                
                                switch MODE
                                    case {2,3}
                                        Mxc(1,ix) = Mxc(1,ix) + Ta(dd,1);
                                    case {4}
                                        Mxc(dd,1) = ix;
                                        Tdc(dd,1) = Tdc(dd,1) + Ta(dd,1);
                                end
                                
                            elseif La(dd,1) < 0 % 暖房負荷であれば
                                ix = mytfunc_countMX((-1)*La(dd,1),mxL);
                                
                                switch MODE
                                    case {2,3}
                                        Mxh(1,ix) = Mxh(1,ix) + Ta(dd,1);
                                    case {4}
                                        Mxh(dd,1) = ix;
                                        Tdh(dd,1) = Tdh(dd,1) + Ta(dd,1);
                                end
                                
                            end
                        end
                    end
                    
                elseif AHUCHmode == 0   % 冷暖切替（季節ごと）
                    
                    for iSEASON = 1:3
                        if iSEASON == 1
                            seasonspan = WIN;
                        elseif iSEASON == 2
                            seasonspan = MID;
                        elseif iSEASON == 3
                            seasonspan = SUM;
                        else
                            error('シーズン番号が不正です')
                        end
                        
                        for dd = seasonspan
                            if isnan(La(dd,1)) == 0 % ゼロ割でNaNになっている値を飛ばす
                                if La(dd,1) ~= 0  && (iSEASON == 2 || iSEASON == 3) % 冷房期間であれば
                                    ix = mytfunc_countMX(La(dd,1),mxL);
                                                                        
                                    switch MODE
                                        case {2,3}
                                            Mxc(1,ix) = Mxc(1,ix) + Ta(dd,1);
                                        case {4}
                                            if ich == 1
                                                Mxc(dd,1) = ix;
                                                Tdc(dd,1) = Tdc(dd,1) + Ta(dd,1);
                                            elseif ich == 2
                                                Mxc(dd,2) = ix;
                                                Tdc(dd,2) = Tdc(dd,2) + Ta(dd,1);
                                            end
                                    end
                                    
                                elseif La(dd,1) ~= 0 && iSEASON == 1  % 暖房期間であれば
                                    ix = mytfunc_countMX((-1)*La(dd,1),mxL);
                                    
                                    switch MODE
                                        case {2,3}
                                            Mxh(1,ix) = Mxh(1,ix) + Ta(dd,1);
                                        case {4}
                                            if ich == 1 
                                                Mxh(dd,1) = ix;
                                                Tdh(dd,1) = Tdh(dd,1) + Ta(dd,1);
                                            elseif ich == 2
                                                Mxh(dd,2) = ix;
                                                Tdh(dd,2) = Tdh(dd,2) + Ta(dd,1);
                                            end
                                            
                                    end
                                end
                            end
                        end
                        
                    end
                    
                end
                
                
            end
        end

end



end



