% run.m
%----------------------------------------------------------------------------------------
% 非定常負荷計算（newHASP）と定常負荷計算を行い，負荷の相関を分析する
%----------------------------------------------------------------------------------------
clear
clc

% 気象データファイル名
climatedatafile  = './weathdat/6158195.has';
% 建物データファイル名
buildingdatafile = './input/42OKAY_0101_122222H_base.txt';

% 気象データの加工(1にすると励振なし)
cd_change(1)    = 0; % 外気温
cd_change(2)    = 0; % 外気湿度
cd_change(3)    = 0; % 直達日射
cd_change(4)    = 0; % 天空日射
cd_change(5)    = 0; % 夜間放射
heatGain_change = 0; % 内部発熱

% 壁の書き換え
WallType   = 'type2';
WindowType = 'type1';
% 階高[m]
StoryHeight = 4.5;
% 窓面積率[-]
WindowRatio = 0.5;
% 室奥行き[m]
roomDepth   = 10;

% 定数
alph_o = 23.3;      % 外壁側の総合熱伝達率 [W/m2K]
gs     = 0.808;     % 天空日射の日射熱取得率 [-]
rad    = 2*pi/360;  % °からラジアンへの変換係数


%% 建物データファイル読み込み(書き換え)
[phi,longi,rhoG,alp,bet,AreaRoom,awall,Fs,AreaWall,AreaWind,seasonS,seasonM,seasonW,TroomS,TroomM,TroomW,...
    Kwall,Kwind,SCC,SCR] = func_buildingdataRead(buildingdatafile,WallType,WindowType,StoryHeight,WindowRatio,roomDepth);

go    = 1;       % 窓面の直達日射照射率 [-]


%% 気象データ読み込み　→　書き換えて再生成

[X1data,X2data,X3data,X4data,X5data,X6data,X7data] = func_climatedataRead(climatedatafile);

ToutALL = (str2double(X1data(:,1:end-1))-500)/10;         % 外気温 [℃]
XouALL  = str2double(X2data(:,1:end-1))/1000/10;          % 外気絶対湿度 [kg/kgDA]
IodALL  = str2double(X3data(:,1:end-1)).*4.18*1000/3600;  % 法線面直達日射量 [kcal/m2h] → [W/m2]
IosALL  = str2double(X4data(:,1:end-1)).*4.18*1000/3600;  % 水平面天空日射量 [kcal/m2h] → [W/m2]
InnALL  = str2double(X5data(:,1:end-1)).*4.18*1000/3600;  % 水平面夜間放射量 [kcal/m2h] → [W/m2]

% 曜日の分析（１：日曜～７：土曜，０：祝日）
for dd = 1:365
    X1data{dd,end}(end-1) = '4';
    X2data{dd,end}(end-1) = '4';
    X3data{dd,end}(end-1) = '4';
    X4data{dd,end}(end-1) = '4';
    X5data{dd,end}(end-1) = '4';
    X6data{dd,end}(end-1) = '4';
    X7data{dd,end}(end-1) = '4';
    WeekNum(dd,1) = str2double(X1data{dd,end}(end-1));
end

for i=1:365
    for j=1:24
        if cd_change(1) == 1
            ToutALL(i,j)= 24;
            X1data{i,j} = '740';
        end
        if cd_change(2) == 1
            XouALL(i,j) = 9.4;
            X2data{i,j} = ' 94';
        end
        if cd_change(3) == 1
            IodALL(i,j)=0;
            X3data{i,j} = '  0';
        end
        if cd_change(4) == 1
            IosALL(i,j)=0;
            X4data{i,j} = '  0';
        end
        if cd_change(5) == 1
            InnALL(i,j)=0;
            X5data{i,j} = '  0';
        end
    end
end

% 新たな気象データ保存
savefilename = 'climatedata.has';
checksum = func_climatedataSave(savefilename,X1data,X2data,X3data,X4data,X5data,X6data,X7data);


%% 非定常負荷計算（newHASP）実行

% 設定ファイル
NHKsettingL{1} = 'buildingdata.txt';
NHKsettingL{2} = 'climatedata.has';
NHKsettingL{3} = 'out20.dat';
NHKsettingL{4} = 'input\wndwtabl.dat';
NHKsettingL{5} = 'input\wcontabl.dat';

fid = fopen('NHKsetting.txt','w+');
for i=1:5
    fprintf(fid,'%s\r\n',NHKsettingL{i});
end
y = fclose(fid);

% 実行
system('RunHasp.bat');

% 結果ファイル分析
% 1)年，2)月，3)日，4)曜日，5)時，6)分，7)フラグ，
% 8)室温，9)冷房負荷(顕熱)[W/m2]，10)室除去熱量(顕熱)[W/m2]，11)装置除去熱量(顕熱)[W/m2]，12)フラグ
% 13)湿度[g/kgDA]，14)冷房負荷(潜熱)[W/m2]，15)室除去熱量(潜熱)[W/m2]，16)装置除去熱量(潜熱)[W/m2]，17)フラグ
newHASPresult = xlsread('ROOM.csv');

% 室除去熱量（全熱，毎時）
newHASP_Qhour   = newHASPresult(:,9) + newHASPresult(:,14);  % 室負荷
newHASP_Qachour = newHASPresult(:,10) + newHASPresult(:,15); % 空調負荷

% 日積算化（冷房負荷と暖房負荷に分離）
newHASP_Qday   = zeros(365,2);
newHASP_Qacday = zeros(365,2);
newHASP_TimeC  = zeros(365,1);
newHASP_TimeH  = zeros(365,1);

for i=1:365
    for j=1:24
        num = 24*(i-1)+j;
        
        % 室負荷
        if newHASP_Qhour(num,1)>=0
            newHASP_Qday(i,1) = newHASP_Qday(i,1) + newHASP_Qhour(num,1);  % 冷房室負荷
        else
            newHASP_Qday(i,2) = newHASP_Qday(i,2) + newHASP_Qhour(num,1);  % 暖房室負荷
        end
        
        % 空調負荷
        if newHASP_Qachour(num,1)>=0
            newHASP_Qacday(i,1) = newHASP_Qacday(i,1) + newHASP_Qachour(num,1);  % 冷房空調負荷
            if newHASP_Qachour(num,1)>0
                newHASP_TimeC(i,1)  = newHASP_TimeC(i,1) + 1;
            end
        else
            newHASP_Qacday(i,2) = newHASP_Qacday(i,2) + newHASP_Qachour(num,1);  % 暖房空調負荷
            newHASP_TimeH(i,1)  = newHASP_TimeH(i,1) + 1;
        end
    end
    
    if newHASP_Qday(i,1) == 0
        newHASP_Qday(i,1) = NaN;
    end
    if newHASP_Qday(i,2) == 0
        newHASP_Qday(i,2) = NaN;
    end
    if newHASP_Qacday(i,1) == 0
        newHASP_Qacday(i,1) = NaN;
    end
    if newHASP_Qacday(i,2) == 0
        newHASP_Qacday(i,2) = NaN;
    end
    
    
end


%% 定常負荷計算実行

% 各月の日数
DAYMAX = [31,28,31,30,31,30,31,31,30,31,30,31];
min  = 0;
DN   = 0;

static_Qday  = zeros(365,1);
static_QdayC = zeros(365,1);
static_QdayH = zeros(365,1);

opeSETime1 = [9:21];
opeSETime2 = [];
opeSETime3 = [];
AHUtime1  = length(opeSETime1);    % 空調時間 [h]
AHUtime2  = length(opeSETime2);    % 空調時間 [h]
AHUtime3  = length(opeSETime3);    % 空調時間 [h]

for month = 1:12
    
    % 室内設定温度 [℃]
    switch month
        case seasonW
            Troom = TroomW;
            Hroom = 38.81;
        case seasonM
            Troom = TroomM;
            Hroom = 47.81;
        case seasonS
            Troom = TroomS;
            Hroom = 52.91;
    end
    
    for day = 1:DAYMAX(month)
        
        % 日数カウント
        DN = DN + 1;
        
        for hour = 1:24
            
            %% 面に入射する日射量を求める
            
            Iod  = IodALL(DN,hour);
            Ios  = IosALL(DN,hour);
            Ion  = InnALL(DN,hour);
            
            % 中央標準時を求める
            t = hour + min / 60;
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
            
            % 傾斜面入射日射量(直達日射量)
            Id(DN,hour) = go * Iod * sinh2;
            % 傾斜面入射日射量(天空日射量)
            Is(DN,hour) = (1+cosBet)/2*Ios + (1-cosBet)/2*rhoG*(Iod*sinh+Ios);
            % 傾斜面夜間放射量
            In(DN,hour) = (1+cosBet)/2*Ion;
            
            % 標準ガラスの直達日射熱取得率を求める（滝沢の式）．
            gt(DN,hour) = glassf04(sinh2);
            
            % 参考（面から見た太陽高度）
            DATA(DN,hour) = asin(sinh2)/rad;
            
            
        end
        
        % ① 貫流熱
        Qk1(DN,:)  = (ToutALL(DN,:)-Troom).*(AreaWall*Kwall+AreaWind*Kwind)./AreaRoom;        % 気温分
        Qk2(DN,:)  = awall./alph_o.*(Id(DN,:)+Is(DN,:)).*(AreaWall*Kwall)./AreaRoom;          % 日射分
        Qk3(DN,:)  = (-1).*Fs./alph_o.*(In(DN,:)).*(AreaWall*Kwall+AreaWind*Kwind)./AreaRoom; % 夜間放射
        % ② 日射侵入熱(透過日射熱取得)
        QI(DN,:)   = (SCC+SCR) * (gt(DN,:).*Id(DN,:) + gs.*Is(DN,:)).*AreaWind./AreaRoom;
        
        % 外気負荷 [W/m2]
        Qoa(DN,:) = (mytfunc_enthalpy(mean(ToutALL(DN,opeSETime1)),mean(XouALL(DN,opeSETime1)))-Hroom).*1.293.*5./3600.*1000;
        
        switch WeekNum(DN)
            case {2,3,4,5,6}
                
                % ③ 内部発熱量
                Qh(DN,:)   = zeros(1,24);
                if heatGain_change == 0
                    Qh(DN,opeSETime1)   = 388.8/13;
                end
                
                % ①＋②＋③
                if DN == 1
                    static_Qday(DN,1) = (sum(Qk1(DN,:)) + sum(Qk2(DN,:)) + sum(Qk3(DN,:))) + sum(QI(DN,:)) + sum(Qh(DN,:));
                else
                    static_Qday(DN,1) = (sum(Qk1(DN,:)) + sum(Qk2(DN,:)) + sum(Qk3(DN,:))) + sum(QI(DN,:)) + sum(Qh(DN,:));
                end
                
            case {1,7,0}
                
                static_Qday(DN,1) = 0;
                
        end
        
    end
end

% x = static_Qday;
% y = nansum(newHASP_Qday,2);
% a = fminbnd('func_fitting',0,1,[],x,y);
%
% % 決定係数
% e =  y - a.* x;
% R2 = 1 - sum(e.^2)/sum((y-mean(y)).^2);

% AAA = [static_Qday,newHASP_Qday(:,1),newHASP_Qday(:,2),nansum(newHASP_Qday,2)];
AAA = [static_Qday,newHASP_Qday(:,1),newHASP_Qday(:,2)];

% figure
% plot(static_Qday)
% hold on
% plot(nansum(newHASP_Qday,2),'r')
% legend('定常','非定常')
% grid on
%
%
% figure
% plot(static_Qday,nansum(newHASP_Qday,2),'rx')
% grid on



%% 定常負荷→非定常負荷

for i=1:365
    
    % 非定常日積算負荷
    dQsim_C(i,1) = 0.7261*static_Qday(i)+214.11;  % 負荷変換 [Wh/m2]
    if dQsim_C(i)<0
        dQsim_C(i) = 0;
    end
    dQsim_H(i,1) = 0.055*static_Qday(i)-40.79;    % 負荷変換 [Wh/m2]
    if dQsim_H(i)>0
        dQsim_H(i) = 0;
    end
    
    % 運転時間
    if abs(dQsim_C(i)) < abs(dQsim_H(i))
        Tsim_C(i,1) = ceil( AHUtime1 * abs(dQsim_C(i))/(abs(dQsim_C(i)) + abs(dQsim_H(i))) );      % 運転時間 [h]
        Tsim_H(i,1) = AHUtime1 - Tsim_C(i);
    else
        Tsim_H(i,1) = ceil( AHUtime1 * ( abs(dQsim_H(i))/(abs(dQsim_C(i)) + abs(dQsim_H(i)) )));   % 運転時間 [h]
        Tsim_C(i,1) = AHUtime1 - Tsim_H(i);
    end
    
    % 瞬時室負荷 [W/m2]の計算
    if Tsim_C(i) ~= 0
        dQsim_Ckw(i,1) =  dQsim_C(i)/Tsim_C(i);
    else
        dQsim_Ckw(i,1) =  0;
    end
    if Tsim_H(i) ~= 0
        dQsim_Hkw(i,1) =  dQsim_H(i)/Tsim_H(i);
    else
        dQsim_Hkw(i,1) =  0;
    end
    
    % 空調負荷（外気負荷足す）
    dQsim_CkwOA(i,1) = dQsim_Ckw(i,1) + Qoa(i,1);
    dQsim_HkwOA(i,1) = dQsim_Hkw(i,1) + Qoa(i,1);
    
    % 冷暖房負荷逆転の場合の処理
    if dQsim_CkwOA(i,1) < 0
        dQsim_HkwOA(i,1) = (dQsim_HkwOA(i,1)*Tsim_H(i,1)+dQsim_CkwOA(i,1) *Tsim_C(i,1)) ./(Tsim_H(i,1)+Tsim_C(i,1));
        Tsim_H(i,1) = Tsim_H(i,1) + Tsim_C(i,1);
        dQsim_CkwOA(i,1) = 0;
        Tsim_C(i,1) = 0;
    end
    
    if dQsim_HkwOA(i,1) > 0
        dQsim_CkwOA(i,1) = (dQsim_HkwOA(i,1)*Tsim_H(i,1)+dQsim_CkwOA(i,1) *Tsim_C(i,1)) ./(Tsim_H(i,1)+Tsim_C(i,1));
        Tsim_C(i,1) = Tsim_C(i,1) + Tsim_H(i,1);
        dQsim_HkwOA(i,1) = 0;
        Tsim_H(i,1) = 0;
    end
    
    
end


% 空調負荷集計
RES = [dQsim_CkwOA,Tsim_C,dQsim_HkwOA,Tsim_H,...
    newHASP_Qacday(:,1)./newHASP_TimeC,newHASP_TimeC,newHASP_Qacday(:,2)./newHASP_TimeH,newHASP_TimeH];



% 頻度分布の計算
Cmax = 120;
Hmax =  80;

histC = zeros(1,6);
histH = zeros(1,6);
histCnewHASP = zeros(1,6);
histHnewHASP = zeros(1,6);

histCrQ = zeros(1,6);
histHrQ = zeros(1,6);
histCnewHASPrQ = zeros(1,6);
histHnewHASPrQ = zeros(1,6);


for i = 1:365
    
    % 冷房
    tmp = dQsim_CkwOA(i,1)./Cmax;
    if tmp<0.2 && tmp>0
        histC(1,1) = histC(1,1) + Tsim_C(i,1);
    elseif tmp<0.4
        histC(1,2) = histC(1,2) + Tsim_C(i,1);
    elseif tmp<0.6
        histC(1,3) = histC(1,3) + Tsim_C(i,1);
    elseif tmp<0.8
        histC(1,4) = histC(1,4) + Tsim_C(i,1);
    elseif tmp<1.0
        histC(1,5) = histC(1,5) + Tsim_C(i,1);
    else
        histC(1,6) = histC(1,6) + Tsim_C(i,1);
    end
    
    % 暖房
    tmp = (-1)*dQsim_HkwOA(i,1)./Hmax;
    if tmp<0.2 && tmp>0
        histH(1,1) = histH(1,1) + Tsim_H(i,1);
    elseif tmp<0.4
        histH(1,2) = histH(1,2) + Tsim_H(i,1);
    elseif tmp<0.6
        histH(1,3) = histH(1,3) + Tsim_H(i,1);
    elseif tmp<0.8
        histH(1,4) = histH(1,4) + Tsim_H(i,1);
    elseif tmp<1.0
        histH(1,5) = histH(1,5) + Tsim_H(i,1);
    else
        histH(1,6) = histH(1,6) + Tsim_H(i,1);
    end
    
    % 冷房
    tmp = (newHASP_Qacday(i,1)./newHASP_TimeC(i,1))./Cmax;
    if tmp<0.2 && tmp>0
        histCnewHASP(1,1) = histCnewHASP(1,1) + newHASP_TimeC(i,1);
    elseif tmp<0.4
        histCnewHASP(1,2) = histCnewHASP(1,2) + newHASP_TimeC(i,1);
    elseif tmp<0.6
        histCnewHASP(1,3) = histCnewHASP(1,3) + newHASP_TimeC(i,1);
    elseif tmp<0.8
        histCnewHASP(1,4) = histCnewHASP(1,4) + newHASP_TimeC(i,1);
    elseif tmp<1.0
        histCnewHASP(1,5) = histCnewHASP(1,5) + newHASP_TimeC(i,1);
    else
        histCnewHASP(1,6) = histCnewHASP(1,6) + newHASP_TimeC(i,1);
    end
    
    % 暖房
    tmp = (-1)*(newHASP_Qacday(i,2)./newHASP_TimeH(i,1))./Hmax;
    if tmp<0.2 && tmp>0
        histHnewHASP(1,1) = histHnewHASP(1,1) + newHASP_TimeH(i,1);
    elseif tmp<0.4
        histHnewHASP(1,2) = histHnewHASP(1,2) + newHASP_TimeH(i,1);
    elseif tmp<0.6
        histHnewHASP(1,3) = histHnewHASP(1,3) + newHASP_TimeH(i,1);
    elseif tmp<0.8
        histHnewHASP(1,4) = histHnewHASP(1,4) + newHASP_TimeH(i,1);
    elseif tmp<1.0
        histHnewHASP(1,5) = histHnewHASP(1,5) + newHASP_TimeH(i,1);
    else
        histHnewHASP(1,6) = histHnewHASP(1,6) + newHASP_TimeH(i,1);
    end
    
    
    
    % 室負荷
    % 冷房
    tmp = dQsim_Ckw(i,1)./Cmax;
    if tmp<0.2 && tmp>0
        histCrQ(1,1) = histCrQ(1,1) + Tsim_C(i,1);
    elseif tmp<0.4
        histCrQ(1,2) = histCrQ(1,2) + Tsim_C(i,1);
    elseif tmp<0.6
        histCrQ(1,3) = histCrQ(1,3) + Tsim_C(i,1);
    elseif tmp<0.8
        histCrQ(1,4) = histCrQ(1,4) + Tsim_C(i,1);
    elseif tmp<1.0
        histCrQ(1,5) = histCrQ(1,5) + Tsim_C(i,1);
    else
        histCrQ(1,6) = histCrQ(1,6) + Tsim_C(i,1);
    end
    
    % 暖房
    tmp = (-1)*dQsim_Hkw(i,1)./Hmax;
    if tmp<0.2 && tmp>0
        histHrQ(1,1) = histHrQ(1,1) + Tsim_H(i,1);
    elseif tmp<0.4
        histHrQ(1,2) = histHrQ(1,2) + Tsim_H(i,1);
    elseif tmp<0.6
        histHrQ(1,3) = histHrQ(1,3) + Tsim_H(i,1);
    elseif tmp<0.8
        histHrQ(1,4) = histHrQ(1,4) + Tsim_H(i,1);
    elseif tmp<1.0
        histHrQ(1,5) = histHrQ(1,5) + Tsim_H(i,1);
    else
        histHrQ(1,6) = histHrQ(1,6) + Tsim_H(i,1);
    end
    
    % 冷房
    tmp = (newHASP_Qday(i,1)./newHASP_TimeC(i,1))./Cmax;
    if tmp<0.2 && tmp>0
        histCnewHASPrQ(1,1) = histCnewHASPrQ(1,1) + newHASP_TimeC(i,1);
    elseif tmp<0.4
        histCnewHASPrQ(1,2) = histCnewHASPrQ(1,2) + newHASP_TimeC(i,1);
    elseif tmp<0.6
        histCnewHASPrQ(1,3) = histCnewHASPrQ(1,3) + newHASP_TimeC(i,1);
    elseif tmp<0.8
        histCnewHASPrQ(1,4) = histCnewHASPrQ(1,4) + newHASP_TimeC(i,1);
    elseif tmp<1.0
        histCnewHASPrQ(1,5) = histCnewHASPrQ(1,5) + newHASP_TimeC(i,1);
    else
        histCnewHASPrQ(1,6) = histCnewHASPrQ(1,6) + newHASP_TimeC(i,1);
    end
    
    % 暖房
    tmp = (-1)*(newHASP_Qday(i,2)./newHASP_TimeH(i,1))./Hmax;
    if tmp<0.2 && tmp>0
        histHnewHASPrQ(1,1) = histHnewHASPrQ(1,1) + newHASP_TimeH(i,1);
    elseif tmp<0.4
        histHnewHASPrQ(1,2) = histHnewHASPrQ(1,2) + newHASP_TimeH(i,1);
    elseif tmp<0.6
        histHnewHASPrQ(1,3) = histHnewHASPrQ(1,3) + newHASP_TimeH(i,1);
    elseif tmp<0.8
        histHnewHASPrQ(1,4) = histHnewHASPrQ(1,4) + newHASP_TimeH(i,1);
    elseif tmp<1.0
        histHnewHASPrQ(1,5) = histHnewHASPrQ(1,5) + newHASP_TimeH(i,1);
    else
        histHnewHASPrQ(1,6) = histHnewHASPrQ(1,6) + newHASP_TimeH(i,1);
    end
    
end

RES2 = [histC;histCnewHASP;histH;histHnewHASP;...
    histCrQ;histCnewHASPrQ;histHrQ;histHnewHASPrQ];

