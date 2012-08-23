% run.m
%----------------------------------------------------------------------------------------
% 非定常負荷計算（newHASP）と定常負荷計算を行い，負荷の相関を分析する
%----------------------------------------------------------------------------------------

function [a,R2] = func_multirun(WallType,WindowType,StoryHeight,WindowRatio,roomDepth)

% 気象データファイル名
climatedatafile  = './weathdat/6158195.has';
% 建物データファイル名
buildingdatafile = './input/42OKAY_0101_122222N_base24.txt';

% 気象データの加工(1にすると励振なし)
cd_change(1)    = 0; % 外気温
cd_change(2)    = 0; % 外気湿度
cd_change(3)    = 1; % 直達日射
cd_change(4)    = 1; % 天空日射
cd_change(5)    = 1; % 夜間放射
heatGain_change = 1; % 内部発熱

% 前日繰越の処理（0なし，1あり）
ThermalStorage = 1;

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
    %     X1data{dd,end}(end-1) = '4';
    %     X2data{dd,end}(end-1) = '4';
    %     X3data{dd,end}(end-1) = '4';
    %     X4data{dd,end}(end-1) = '4';
    %     X5data{dd,end}(end-1) = '4';
    %     X6data{dd,end}(end-1) = '4';
    %     X7data{dd,end}(end-1) = '4';
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
newHASP_Qhour = newHASPresult(:,9) + newHASPresult(:,14);

% 日積算化（冷房負荷と暖房負荷に分離）
newHASP_Qday = zeros(365,2);
for i=1:365
    for j=1:24
        num = 24*(i-1)+j;
        if newHASP_Qhour(num,1)>=0
            newHASP_Qday(i,1) = newHASP_Qday(i,1) + newHASP_Qhour(num,1);  % 冷房負荷
        else
            newHASP_Qday(i,2) = newHASP_Qday(i,2) + newHASP_Qhour(num,1);  % 暖房負荷
        end
    end
    
    if newHASP_Qday(i,1) == 0
        newHASP_Qday(i,1) = NaN;
    end
    if newHASP_Qday(i,2) == 0
        newHASP_Qday(i,2) = NaN;
    end
end


%% 定常負荷計算実行

% 各月の日数
DAYMAX = [31,28,31,30,31,30,31,31,30,31,30,31];
min  = 00;
DN   = 0;

static_Qday  = zeros(365,1);
static_QdayC = zeros(365,1);
static_QdayH = zeros(365,1);

% 蓄熱分
tmpStorageQ = zeros(365,1);

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
        case seasonM
            Troom = TroomM;
        case seasonS
            Troom = TroomS;
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
        QI(DN,:)   = (SCC+SCR*0.6) * (gt(DN,:).*Id(DN,:) + gs.*Is(DN,:)).*AreaWind./AreaRoom;
        
        
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
                    static_Qday(DN,1) = (sum(Qk1(DN,:)) + sum(Qk2(DN,:)) + sum(Qk3(DN,:))) + sum(QI(DN,:)) + sum(Qh(DN,:)) + tmpStorageQ(DN-1,1)*0.5;
                end
                
            case {1,7,0}
                
                if ThermalStorage == 1
                    % 蓄熱分（翌日に繰り越す）
                    tmpStorageQ(DN,1) = (sum(Qk1(DN,:)) + sum(Qk2(DN,:)) + sum(Qk3(DN,:))) + sum(QI(DN,:));
                end
                
                % ③ 内部発熱量
                Qh(DN,:)   = zeros(1,24);
                
                static_Qday(DN,1) = sum(Qh(DN,:));
                
        end
        
    end
end

x = static_Qday;
y = nansum(newHASP_Qday,2);
a = fminbnd('func_fitting',0,1,[],x,y);

% 決定係数
e =  y - a.* x;
R2 = 1 - sum(e.^2)/sum((y-mean(y)).^2);


% AAA = [static_Qday,newHASP_Qday(:,1),newHASP_Qday(:,2),nansum(newHASP_Qday,2)];

% 
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

