% mytfunc_matrixREF.m
%                                                                                by Masato Miyata 2012/03/27
%-----------------------------------------------------------------------------------------------------------
% 熱源負荷データを元に，負荷の出現頻度マトリックスを作成する．
%-----------------------------------------------------------------------------------------------------------
% 入力
%   MODE   : 計算モード（時系列newHASP，日積算newHASP，簡略法）
%   Qps    : ポンプ負荷（時間積算or日積算）[kW]
%   Qpsr   : ポンプ定格能力 [kW]
%   Tps    : ポンプ運転時間（日積算のみ）[hour]
% 出力
%   Mx     : 負荷出現頻度マトリックス
%-----------------------------------------------------------------------------------------------------------

function [Mx,Tx] = mytfunc_matrixREF(MODE,Qref_c,Qrefr_c,Tref,OAdata,mxT,mxL)

Tx = zeros(365,1);

switch MODE
    
    case {0}
        
        % 時系列データ
        Mx = zeros(8760,2);  % 負荷率帯, 外気温帯
        
        for dd = 1:365
            for hh = 1:24
                num = 24*(dd-1)+hh;
                
                Lref = Qref_c(num,1)/Qrefr_c; % 負荷率
                
                if Lref > 0.001 && isnan(Lref) == 0
                    
                    noa = mytfunc_countMX(OAdata(num,1),mxT);
                    ix  = mytfunc_countMX(Lref,mxL);
                    Mx(num,1) = ix;
                    Mx(num,2) = noa;
                    
                end
                
            end
        end
        
    case {1}
        
        % マトリックス
        Mx = zeros(length(mxT),length(mxL)); % 外気温×負荷率
        
        for dd = 1:365
            for hh = 1:24
                num = 24*(dd-1)+hh;
                
                Lref = Qref_c(num,1)/Qrefr_c; % 負荷率
                
                if Lref > 0.001 && isnan(Lref) == 0
                    
                    noa = mytfunc_countMX(OAdata(dd,1),mxT);
                    ix  = mytfunc_countMX(Lref,mxL);
                    Mx(noa,ix) = Mx(noa,ix) + 1;
                    
                end
            end
        end
        
    case {2,3,4}
        
        % マトリックス
        switch MODE
            case {2,3}
                Mx = zeros(length(mxT),length(mxL)); % 外気温×負荷率
            case {4}
                Mx = zeros(365,2);
        end
        
        % 負荷率算出 [-]
        Lref = (Qref_c./Tref.*1000./3600)./Qrefr_c;
        
        for dd = 1:365
            
            if isnan(Lref(dd,1))
                Lref(dd,1) = 0;
            end
            
            if Lref(dd,1)>0
                
                noa = mytfunc_countMX(OAdata(dd,1),mxT);
                ix  = mytfunc_countMX(Lref(dd,1),mxL);
                
                switch MODE
                    case {2,3}
                        Mx(noa,ix) = Mx(noa,ix) + Tref(dd,1);
                    case {4}
                        Mx(dd,1) = ix;
                        Mx(dd,2) = noa;
                        Tx(dd,1) = Tref(dd,1);
                end
                
            end
            
        end
end