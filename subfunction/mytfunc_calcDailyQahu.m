% mytfunc_calcDailyQahu.m
%                                       by Masato Miyata 2012/03/02
%------------------------------------------------------------------
% 日積算空調負荷の算出
%------------------------------------------------------------------
function [Qahu_c,Qahu_h,Qahu_CEC] = mytfunc_calcDailyQahu(AHUsystemT,...
    Tahu_c,Tahu_h,QroomAHUc,QroomAHUh,qoaAHU,qoaAHU_CEC,ahuOAcut)


if Tahu_c==0 && Tahu_h==0
    
    % 外気負荷だけの場合(処理上，冷房負荷に入れておく)
    if ahuOAcut == 0
        Qahu_c = qoaAHU.*AHUsystemT.*3600/1000; % 積算値 [MJ/day]
    elseif ahuOAcut == 1 % 外気カットあり
        if AHUsystemT>1 % 空調時間が1時間未満のときは例外処理
            Qahu_c = qoaAHU.*(AHUsystemT-1).*3600/1000; % 積算値 [MJ/day]
        else
            Qahu_c = qoaAHU.*AHUsystemT.*3600/1000; % 積算値 [MJ/day]
        end
    end
    
    Qahu_h = 0;
    
else
    
    % 冷房負荷 [MJ/day]
    if Tahu_c > 0
        if ahuOAcut == 1 && Tahu_c > 1
            Qahu_c = QroomAHUc + qoaAHU.*(Tahu_c-1).*3600/1000; % 積算値 [MJ/day]
        else
            Qahu_c = QroomAHUc + qoaAHU.*Tahu_c.*3600/1000; % 積算値 [MJ/day]
        end
    else
        Qahu_c = 0;
    end
    
    % 暖房負荷 [MJ/day]
    if Tahu_h > 0
        if ahuOAcut == 1 && Tahu_h > 1
            Qahu_h = QroomAHUh + qoaAHU.*(Tahu_h-1).*3600/1000; % 積算値 [MJ/day]
        else
            Qahu_h = QroomAHUh + qoaAHU.*Tahu_h.*3600/1000; % 積算値 [MJ/day]
        end
    else
        Qahu_h = 0;
    end
    
end

% 仮想空調負荷 [MJ/day]
Qahu_CEC = abs(QroomAHUc) + abs(QroomAHUh) + abs(qoaAHU_CEC.*AHUsystemT.*3600/1000);


