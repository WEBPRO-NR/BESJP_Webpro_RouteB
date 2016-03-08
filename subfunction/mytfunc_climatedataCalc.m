% mytfunc_climatedataCalc.m
%--------------------------------------------------------------------------
% 気象データから外気温、日射量などを計算
% 出力
% y: 日積算日射量 [Wh/m2]
% y_ita：入射角特性込の日積算日射量（0.89で基準化済み） [Wh/m2]
%--------------------------------------------------------------------------

function [y,yita] = mytfunc_climatedataCalc(phi,longi,ToutALL,XouALL,IodALL,IosALL,InnALL)

% テスト用
% filename = './weathdat/C1_6158195.has';
% [ToutALL,XouALL,IodALL,IosALL,InnALL] = mytfunc_climatedataRead(filename);
% phi   = 34.658;
% longi = 133.918;

y    = zeros(365,22);


% 日平均外気温度 [℃]
y(:,4) = mean(ToutALL,2);
y(:,5) = mean(ToutALL(:,7:18),2);  % 7～18時
y(:,6) = mean(ToutALL(:,[1:6,19:24]),2);  % 19時から6時

% 日平均絶対湿度 [g/kgDA]
y(:,7) = mean(XouALL,2).*1000;
y(:,8) = mean(XouALL(:,7:18),2).*1000;  % 7～18時
y(:,9) = mean(XouALL(:,[1:6,19:24]),2).*1000;  % 19時から6時

% 入射角特性込の値の格納用変数
yita = y;


% 日射量

% °からラジアンへの変換係数
rad    = 2*pi/360;
% 各月の日数
DAYMAX = [31,28,31,30,31,30,31,31,30,31,30,31];


go    = 1;


for alp = [0,45,90,135,180,225,270,315,360] % 日射量を求める面の方位角
    
    % 日射量を求める面の傾斜角
    if alp == 360
        bet = 0;  % 水平面（最後のループ）
    else
        bet = 90;  % 垂直面（最後のループ以外）
    end
    
    Id = zeros(365,24);
    Id_ita = zeros(365,24);
    Is = zeros(365,24);
    ita = zeros(365,24);
    
    % 通算日数(1/1が1、12/31が365)
    DN = 0;
    
    for month = 1:12
        for day = 1:DAYMAX(month)
            
            % 日数カウント
            DN = DN + 1;
            
            for hour = 1:24
                
                % 日射量 [W/m2]
                Iod  = IodALL(DN,hour); % 法線面直達日射量 [W/m2]
                Ios  = IosALL(DN,hour); % 水平面天空日射量 [W/m2]
                Ion  = InnALL(DN,hour); % 水平面夜間放射量 [W/m2]
                
                % 中央標準時を求める
                t = hour + 0 / 60;
                % 日赤緯を求める(HASP教科書P24(2-22)参照)
                del = del04(month,day);
                % 均時差を求める
                e = eqt04(month,day);
                % 時角を求める
                Tim = (15.0 * t + 15.0 * e + longi - 315.0) * rad;
                
                sinPhi = sin(deg2rad(phi)); % 緯度の正弦
                cosPhi = cos(deg2rad(phi)); % 緯度の余弦
                sinAlp = sin(alp * rad);    % 方位角正弦
                cosAlp = cos(alp * rad);    % 方位角余弦
                sinBet = sin(bet * rad);    % 傾斜角正弦
                cosBet = cos(bet * rad);    % 傾斜角余弦
                sinDel = sin(del);          % 日赤緯の正弦
                cosDel = cos(del);          % 日赤緯の余弦
                sinTim = sin(Tim);          % 時角の正弦
                cosTim = cos(Tim);          % 時角の余弦
                
                % 太陽高度の正弦を求める(HASP教科書 P25 (2.25)参照 )
                sinh   = sinPhi * sinDel + cosPhi * cosDel * cosTim;
                               
                % 太陽高度の余弦、太陽方位の正弦・余弦を求める(HASP 教科書P25 (2.25)参照)
                cosh   = sqrt(1 - sinh^2);                           % 太陽高度の余弦
                sinA   = cosDel * sinTim / cosh;                     % 太陽方位の正弦
                cosA   = (sinh * sinPhi - sinDel)/(cosh * cosPhi);   % 太陽方位の余弦
                
                % 傾斜壁から見た太陽高度を求める(HASP 教科書 P26(2.26)参照)
                sinh2  = sinh * cosBet + cosh * sinBet * (cosA * cosAlp + sinA * sinAlp);

                if sinh2 < 0
                    sinh2 = 0;
                end
                
                tmp(DN,hour)=sinh2;
                
                % 入射角特性
                ita(DN,hour) = 2.392 * sinh2 - 3.8636 * sinh2^3 + 3.7568 * sinh2^5 - 1.3952 * sinh2^7;
                
                % 傾斜面入射日射量(直達日射量)（W/m2）
                Id(DN,hour) = go * Iod * sinh2;
                
                % 傾斜面入射日射量(直達日射量)（W/m2）　入射角特性込み（0.89で除して基準化済み）
                Id_ita(DN,hour) = go * Iod * sinh2 * ita(DN,hour)/0.89;
                
                % 傾斜面入射日射量(天空日射量)（W/m2）
                if bet == 90
                    Is(DN,hour) = 0.5*Ios + 0.1*0.5*(Ios + Iod*sinh);
                elseif bet == 0
                    Is(DN,hour) = Ios;
                end
                
            end
        end
    end
    
    % 長波長放射
    if bet == 90
        Insr = sum(InnALL,2)/2;
    elseif bet == 0
        Insr = sum(InnALL,2);
    end
    
    if alp == 0  % 南
        y(:,10) = sum(Id,2);
        yita(:,10) = sum(Id_ita,2);
        y(:,19) = sum(Is,2);
        yita(:,19) = sum(Is,2);
        y(:,21) = sum(Insr,2);
        yita(:,21) = sum(Insr,2);
    elseif alp == 45
        y(:,11) = sum(Id,2);
        yita(:,11) = sum(Id_ita,2);
    elseif alp == 90
        y(:,12) = sum(Id,2);
        yita(:,12) = sum(Id_ita,2);
    elseif alp == 135
        y(:,13) = sum(Id,2);
        yita(:,13) = sum(Id_ita,2);
    elseif alp == 180
        y(:,14) = sum(Id,2);
        yita(:,14) = sum(Id_ita,2);
    elseif alp == 225
        y(:,15) = sum(Id,2);
        yita(:,15) = sum(Id_ita,2);
    elseif alp == 270
        y(:,16) = sum(Id,2);
        yita(:,16) = sum(Id_ita,2);
    elseif alp == 315
        y(:,17) = sum(Id,2);
        yita(:,17) = sum(Id_ita,2);
    elseif alp == 360  % 水平
        y(:,18) = sum(Id,2);
        yita(:,18) = sum(Id_ita,2);
        y(:,20) = sum(Is,2);
        yita(:,20) = sum(Is,2);
        y(:,22) = sum(Insr,2);
        yita(:,22) = sum(Insr,2);
    end
    
    
end

