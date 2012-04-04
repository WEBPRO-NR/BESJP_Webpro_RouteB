% mytfunc_calcOALoad_hourly.m
%                                      by Masato Miyata 2012/03/27
%------------------------------------------------------------------
% 外気負荷、外気冷房効果などを算出する。
%------------------------------------------------------------------
function [qoaAHUhour,AHUVovc_hour,Qahu_oac_hour,qoaAHU_CEC_hour] = ...
    mytfunc_calcOALoad_hourly(hh,ModeOpe,AHUsystemT,...
    ahuTime_start,ahuTime_stop,OAdataHourly,Hroom,ahuVoa,ahuOAcut,AEXbypass,ahuaexeff,ahuOAcool,ahuaexV)


% 外気導入ON/OFFの判定
OAintake = 0;
if AHUsystemT > 0
    if ahuTime_stop > AHUsystemT
        if hh > ahuTime_start && hh <= ahuTime_stop
            OAintake = 1;
        end
    else
        if hh > ahuTime_start || hh <= ahuTime_stop
            OAintake = 1;
        end
    end
end

if OAintake == 0
    
    % 空調OFF時は外気導入しない
    qoaAHUhour      = 0;
    qoaAHU_CEC_hour = 0;
    Qahu_oac_hour   = 0;
    AHUVovc_hour    = 0;
    
else
    
    if ahuaexV > ahuVoa
        ahuaexV = ahuVoa;
    end
    
    if ahuOAcut == 1 && hh == ahuTime_start+1   % 外気カットがある場合
        qoaAHUhour = 0;
    else
        if ModeOpe == -1
            if OAdataHourly > Hroom  &&  AEXbypass == 1
                % 時刻別の外気負荷 [kW] = [kJ/kgDA]*[kg/s]
                qoaAHUhour = (OAdataHourly-Hroom).*ahuVoa;
            else
                % 時刻別の外気負荷 [kW] = [kJ/kgDA]*[kg/s]
                qoaAHUhour = (OAdataHourly-Hroom).*(ahuVoa-ahuaexV.*ahuaexeff);
            end
        elseif ModeOpe == 1
            if OAdataHourly < Hroom  &&  AEXbypass == 1
                % 時刻別の外気負荷 [kW] = [kJ/kgDA]*[kg/s]
                qoaAHUhour = (OAdataHourly-Hroom).*ahuVoa;
            else
                % 時刻別の外気負荷 [kW] = [kJ/kgDA]*[kg/s]
                qoaAHUhour = (OAdataHourly-Hroom).*(ahuVoa-ahuaexV.*ahuaexeff);
            end
        else
            error('時刻別外気温の設定が不正です')
        end
    end
    
    % 仮想外気負荷 [kW] = [kJ/kgDA * kg/s]
    qoaAHU_CEC_hour = (OAdataHourly-Hroom).*ahuVoa;
    
    % 外気冷房がある場合
    if ahuOAcool == 1
        
        % 条件１：冷房負荷であること，条件２：室外側のエンタルピーの方が低いこと
        if Qahu_hour > 0  && Hroom-OAdataHourly > 0
            
            % 冷房負荷を0にするための追加外気量 [kg/s]
            AHUVovc_hour = Qahu_hour ./ (Hroom-OAdataHourly) ;
            
            % 送風量の上限
            if AHUVovc_hour > ahuVsa.*1.293/3600 - ahuVoa
                AHUVovc_hour = ahuVsa.*1.293/3600 - ahuVoa;
            end
            
            % 外気冷房による負荷削減量 [kW]
            Qahu_oac_hour = AHUVovc_hour*(Hroom-OAdataHourly);
            
        else
            % 外気冷房による負荷削減量 [kW]
            Qahu_oac_hour = 0;
        end
    else
        % 外気冷房による負荷削減量 [kW]
        Qahu_oac_hour = 0;
        AHUVovc_hour  = 0;
    end
    
end

