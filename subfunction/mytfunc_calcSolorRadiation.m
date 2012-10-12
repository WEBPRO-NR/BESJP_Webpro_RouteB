% mytfunc_calcSolorRadiation.m
%                                                 by Masato Miyata 2012/10/12
%-----------------------------------------------------------------------------
% 日射量を求めるプログラム
% 
% 入力
% climatedatafile : 気象データのファイル名
% phi             : 緯度
% longi           : 経度
% alp             : 日射量を求める面の方位角
% bet             : 日射量を求める面の傾斜角
% go              : 日射量を求める面の直達日射照射率 [-]
%-----------------------------------------------------------------------------
function [dailyIds,hourlyIds] = mytfunc_calcSolorRadiation(IodALL,IosALL,InnALL,phi,longi,alp,bet,go)

% % 気象データファイル名
% climatedatafile  = './weathdat/C1_6158195.has';
% 気象データ読み込み
% [~,~,IodALL,IosALL,InnALL] = mytfunc_climatedataRead(climatedatafile);
% phi   = 34.658;
% longi = 133.918;
% alp   = 0;
% bet   = 30;
% go    = 1;

% 定数
% gs     = 0.808;     % 天空日射の日射熱取得率 [-]
rhoG  = 0.8;
rad    = 2*pi/360;  % °からラジアンへの変換係数

%% 傾斜面の日射量計算

% 各月の日数
DAYMAX = [31,28,31,30,31,30,31,31,30,31,30,31];
% 通算日数(1/1が1、12/31が365)
DN = 0;

% 日積算日射量
Id = zeros(365,24);
Is = zeros(365,24);
In = zeros(365,24);
gt = zeros(365,24);
dailyIds = zeros(365,1);

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
            
            % 傾斜面入射日射量(直達日射量)（W/m2）
            Id(DN,hour) = go * Iod * sinh2;
            % 傾斜面入射日射量(天空日射量)（W/m2）
            Is(DN,hour) = (1+cosBet)/2*Ios + (1-cosBet)/2*rhoG*(Iod*sinh+Ios);
            % 傾斜面夜間放射量
            In(DN,hour) = (1+cosBet)/2*Ion;
            
            % 標準ガラスの直達日射熱取得率を求める（滝沢の式）．
            gt(DN,hour) = glassf04(sinh2);
            
            % 参考（面から見た太陽高度）
            % DATA(DN,hour) = asin(sinh2)/rad;
            
        end
    
        % 日積算日射量 [MJ/m2/day]
        dailyIds(DN,:) =sum(Id(DN,:) + Is(DN,:))*(3600)/1000000;

    end
end

% 時刻別日射量 [W/m2]
hourlyIds = Id + Is;



