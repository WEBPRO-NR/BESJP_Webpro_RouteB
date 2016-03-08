% mytfunc_calcOALoad_hourly.m
%                                      by Masato Miyata 2012/03/27
%------------------------------------------------------------------
% 外気負荷、外気冷房効果などを算出する（一時間毎に呼び出される）。
%------------------------------------------------------------------
% ＜出力＞
% qoaAHUhour(num,iAHU)      : 外気負荷 [kW]
% AHUVovc_hour(num,iAHU)    : 外気冷房時風量 [kg/s]
% Qahu_oac_hour(num,iAHU)   : 外気冷房効果 [kW]
% qoaAHU_CEC_hour(num,iAHU) : 仮想外気負荷 [kW]
%
% ＜入力＞
% hh              : 時刻（1～24）
% ModeOpe(dd)     : 各日の運転モード（-1：暖房、　+1：冷房）
% AHUsystemOpeTime(iAHU,dd,:)  : 各日の空調運転時間（24時間分）
% OAdataHourly(num,3)  : 時刻別気象データ（エンタルピー）
% Hroom(dd,1)     : 室内エンタルピー
% ahuVoa(iAHU)    : 外気取入量 [kg/s]
% ahuOAcut(iAHU)  : 外気カットの有無
% AEXbypass(iAHU) : 全熱交換器バイパス制御の有無
% ahuaexeff(iAHU) : 全熱交換効率
% ahuOAcool(iAHU) : 外気冷房の有無
% ahuaexV(iAHU)   : 全熱交換器の風量
% QroomAHUhour(num,iAHU)  :  時刻別室負荷
% ahuVsa(iAHU)  : 給気風量（＝外気冷房時風量上限値） [m3/h]
%------------------------------------------------------------------
function [qoaAHUhour,AHUVovc_hour,Qahu_oac_hour,qoaAHU_CEC_hour] = ...
    mytfunc_calcOALoad_hourly(hh,ModeOpe,AHUsystemOpeTime,...
    OAdataHourly,Hroom,ahuVoa,ahuOAcut,AEXbypass,ahuaexeff,ahuOAcool,ahuaexV,QroomAHUhour,ahuVsa)


% 外気導入ON/OFFの判定(2013/03/11 ahuTime_stop は使わない方がよい、日を跨ぐ場合の処理を再検討)
OAintake = 0;

if AHUsystemOpeTime(1,1,hh) > 0
    OAintake = 1;
end

if OAintake == 0
    
    % 空調OFF時は外気導入しない
    qoaAHUhour      = 0;
    qoaAHU_CEC_hour = 0;
    Qahu_oac_hour   = 0;
    AHUVovc_hour    = 0;
    
else
    
    % 全熱交換器を通過する風量の上限（取入外気量を上限とする）
    if ahuaexV > ahuVoa
        ahuaexV = ahuVoa;
    end
    
    % 外気負荷 qoaAHUhour の算出
    if ahuOAcut == 1 && hh > 1 && (AHUsystemOpeTime(1,1,hh) == 1 && AHUsystemOpeTime(1,1,hh-1) == 0) % 外気カットがある場合
        
        % 外気カット制御があり、1時間前が停止状態であれば、外気負荷は０とする。
        qoaAHUhour = 0;
        
    else
        
        if ModeOpe == -1          % 暖房運転
            
            % 時刻別の外気負荷 [kW] = [kJ/kgDA]*[kg/s]
            if OAdataHourly > Hroom  &&  AEXbypass == 1
                % 全熱交換器のバイパス制御が有る場合
                qoaAHUhour = (OAdataHourly-Hroom).*ahuVoa;
            else
                % 全熱交換器のバイパス制御が無い場合
                qoaAHUhour = (OAdataHourly-Hroom).*(ahuVoa-ahuaexV.*ahuaexeff);
            end
            
        elseif ModeOpe == 1       % 冷房運転
            
            % 時刻別の外気負荷 [kW] = [kJ/kgDA]*[kg/s]
            if OAdataHourly < Hroom  &&  AEXbypass == 1
                % 全熱交換器のバイパス制御が有る場合
                qoaAHUhour = (OAdataHourly-Hroom).*ahuVoa;
            else
                % 全熱交換器のバイパス制御が無い場合
                qoaAHUhour = (OAdataHourly-Hroom).*(ahuVoa-ahuaexV.*ahuaexeff);
            end
            
        else
            error('時刻別外気温の設定が不正です')
        end
        
    end
    
    % 仮想外気負荷 [kW] = [kJ/kgDA * kg/s]
    qoaAHU_CEC_hour = (OAdataHourly-Hroom).*ahuVoa;
    
    
    
    % 冷房運転時、外気冷房がある場合
    if ahuOAcool == 1  &&  ModeOpe == 1
        
        % 暫定空調負荷を求める．[kW] = [MJ/h]*1000/3600 + [kW]
        Qahu_hour = QroomAHUhour*1000/3600 + qoaAHUhour;
        
        % 条件１：冷房負荷であること，条件２：室外側のエンタルピーの方が低いこと
        if Qahu_hour > 0  && Hroom-OAdataHourly > 0
            
            % 冷房負荷を0にするための追加外気量 [kg/s]
            AHUVovc_hour = Qahu_hour ./ (Hroom-OAdataHourly);
            
            % 送風量の上限（給気風量 [m3/h]→[kg/s]）
            if AHUVovc_hour > ahuVsa.*1.293/3600 - ahuVoa
                AHUVovc_hour = ahuVsa.*1.293/3600 - ahuVoa;
            elseif AHUVovc_hour < 0
                AHUVovc_hour = 0;
            end
            
            % 外気冷房による負荷削減量 [kW]
            Qahu_oac_hour = AHUVovc_hour*(Hroom-OAdataHourly);
            
        else
            % 外気冷房による負荷削減量 [kW]
            Qahu_oac_hour = 0;
            AHUVovc_hour  = 0;
        end
        
    else
        % 外気冷房による負荷削減量 [kW]
        Qahu_oac_hour = 0;
        AHUVovc_hour  = 0;
    end
    
end

