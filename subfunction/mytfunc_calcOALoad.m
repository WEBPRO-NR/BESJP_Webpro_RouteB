% mytfunc_calcOALoad.m
%                                      by Masato Miyata 2012/03/02
%------------------------------------------------------------------
% 外気負荷、外気冷房効果などを算出する。
%------------------------------------------------------------------
function [qoaAHU,AHUVovc,Qahu_oac,qoaAHU_CEC] = mytfunc_calcOALoad(ModeOperation,QroomAHUc,Tahu_c,ahuVoa,ahuVsa,...
    HoaDayAve,Hroom,AHUsystemT,ahuaexeff,AEXbypass,ahuOAcool,ahuaexV)


%% 外気負荷の算出
if AHUsystemT == 0
    
    % 空調OFF時は外気導入しない
    qoaAHU   = 0;
    AHUVovc  = 0;
    Qahu_oac = 0;
    qoaAHU_CEC = 0;
    
else
    
    % 全熱交換機風量 [m3/h] → [kg/s]
    if ahuaexV*1.293/3600 > ahuVoa
        ahuaexV = ahuVoa;
    elseif ahuaexV <= 0
        ahuaexV = 0;
    else
        ahuaexV = ahuaexV*1.293/3600;
    end
    
    % 外気負荷の算出
    if ModeOperation == -1  % 暖房時
        
        if HoaDayAve > Hroom && AEXbypass == 1
            % バイパス有の場合はそのまま外気導入する。
            qoaAHU = (HoaDayAve-Hroom).*ahuVoa;
        else
            qoaAHU = (HoaDayAve-Hroom).*(ahuVoa-ahuaexV.*ahuaexeff);
        end
        
    elseif ModeOperation == 1 % 冷房時
        
        if HoaDayAve < Hroom && AEXbypass == 1
            % バイパス有の場合はそのまま外気導入する。
            qoaAHU = (HoaDayAve-Hroom).*ahuVoa;
        else
            qoaAHU = (HoaDayAve-Hroom).*(ahuVoa-ahuaexV.*ahuaexeff);
        end
        
    else
        error('運転モードが不正です')
    end
    
    % 仮想外気負荷 [kW] = [kJ/kgDA * kg/s]
    qoaAHU_CEC = (HoaDayAve-Hroom).*ahuVoa;
    
    % 外気冷房効果の推定
    if ahuOAcool == 1 && Tahu_c>0 % 外気冷房ONで冷房運転がされていたら
        
        % 外気冷房時の風量 [kg/s]
        AHUVovc = QroomAHUc / ((Hroom-HoaDayAve)*(3600/1000)*Tahu_c);
        
        % 上限・下限
        if AHUVovc < ahuVoa
            AHUVovc = ahuVoa; % 下限（外気取入量）
        elseif AHUVovc > ahuVsa*1.293/3600
            AHUVovc = ahuVsa*1.293/3600; % 上限（給気風量 [m3/h]→[kg/s]）
        end
        
        % 必要外気量（外気冷房分のみ）[kW]
        AHUVovc = AHUVovc - ahuVoa;
    else
        AHUVovc = 0;
    end
    
    % 外気冷房効果 [MJ/day]
    if ahuOAcool == 1
        if AHUVovc > 0 % 外冷時風量＞０であれば
            Qahu_oac = AHUVovc*(Hroom-HoaDayAve)*3600/1000*Tahu_c;
        else
            Qahu_oac = 0;
        end
    else
        Qahu_oac = 0;
    end
    
end

