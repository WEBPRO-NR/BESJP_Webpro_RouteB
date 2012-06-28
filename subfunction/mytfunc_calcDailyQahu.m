% mytfunc_calcDailyQahu.m
%                                       by Masato Miyata 2012/03/02
%------------------------------------------------------------------
% “úÏZ‹ó’²•‰‰×‚ÌZo
%------------------------------------------------------------------
function [Qahu_c,Qahu_h,Qahu_CEC] = mytfunc_calcDailyQahu(AHUsystemT,...
    Tahu_c,Tahu_h,QroomAHUc,QroomAHUh,qoaAHU,qoaAHU_CEC,ahuOAcut)


if Tahu_c==0 && Tahu_h==0
    
    % ŠO‹C•‰‰×‚¾‚¯‚Ìê‡(ˆ—ãC—â–[•‰‰×‚É“ü‚ê‚Ä‚¨‚­)
    if ahuOAcut == 0
        Qahu_c = qoaAHU.*AHUsystemT.*3600/1000; % ÏZ’l [MJ/day]
    elseif ahuOAcut == 1 % ŠO‹CƒJƒbƒg‚ ‚è
        if AHUsystemT>1 % ‹ó’²ŠÔ‚ª1ŠÔ–¢–‚Ì‚Æ‚«‚Í—áŠOˆ—
            Qahu_c = qoaAHU.*(AHUsystemT-1).*3600/1000; % ÏZ’l [MJ/day]
        else
            Qahu_c = qoaAHU.*AHUsystemT.*3600/1000; % ÏZ’l [MJ/day]
        end
    end
    
    Qahu_h = 0;
    
else
    
    % —â–[•‰‰× [MJ/day]
    if Tahu_c > 0
        if ahuOAcut == 1 && Tahu_c > 1 && (Tahu_c >= Tahu_h)
            Qahu_c = QroomAHUc + qoaAHU.*(Tahu_c-1).*3600/1000; % ÏZ’l [MJ/day]
        else
            Qahu_c = QroomAHUc + qoaAHU.*Tahu_c.*3600/1000; % ÏZ’l [MJ/day]
        end
    else
        Qahu_c = 0;
    end
    
    % ’g–[•‰‰× [MJ/day]
    if Tahu_h > 0
        if ahuOAcut == 1 && Tahu_h > 1 && (Tahu_c < Tahu_h)
            Qahu_h = QroomAHUh + qoaAHU.*(Tahu_h-1).*3600/1000; % ÏZ’l [MJ/day]
        else
            Qahu_h = QroomAHUh + qoaAHU.*Tahu_h.*3600/1000; % ÏZ’l [MJ/day]
        end
    else
        Qahu_h = 0;
    end
    
end

% ‰¼‘z‹ó’²•‰‰× [MJ/day]
Qahu_CEC = abs(QroomAHUc) + abs(QroomAHUh) + abs(qoaAHU_CEC.*AHUsystemT.*3600/1000);


