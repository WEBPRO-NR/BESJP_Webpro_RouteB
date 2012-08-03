% HASP形式の気象データを読み込むプログラム

function [ToutALL,XouALL,IodALL,IosALL,InnALL] = mytfunc_climatedataRead(filename)

% 気象データ読み込み
eval(['A = textread(''./',filename,''',''%s'',''delimiter'',''\n'',''whitespace'','''');'])

for day = 1:365
    for hour = 1:25
        if hour < 25
            X1data{day,hour} = A{ 7*(day-1)+1 }( 3*(hour-1)+1:3*hour);
            X2data{day,hour} = A{ 7*(day-1)+2 }( 3*(hour-1)+1:3*hour);
            X3data{day,hour} = A{ 7*(day-1)+3 }( 3*(hour-1)+1:3*hour);
            X4data{day,hour} = A{ 7*(day-1)+4 }( 3*(hour-1)+1:3*hour);
            X5data{day,hour} = A{ 7*(day-1)+5 }( 3*(hour-1)+1:3*hour);
            X6data{day,hour} = A{ 7*(day-1)+6 }( 3*(hour-1)+1:3*hour);
            X7data{day,hour} = A{ 7*(day-1)+7 }( 3*(hour-1)+1:3*hour);
        else
            X1data{day,hour} = A{ 7*(day-1)+1 }(end-7:end);
            X2data{day,hour} = A{ 7*(day-1)+2 }(end-7:end);
            X3data{day,hour} = A{ 7*(day-1)+3 }(end-7:end);
            X4data{day,hour} = A{ 7*(day-1)+4 }(end-7:end);
            X5data{day,hour} = A{ 7*(day-1)+5 }(end-7:end);
            X6data{day,hour} = A{ 7*(day-1)+6 }(end-7:end);
            X7data{day,hour} = A{ 7*(day-1)+7 }(end-7:end);
        end
    end
end

ToutALL = (str2double(X1data(:,1:end-1))-500)/10;         % 外気温 [℃]
XouALL  = str2double(X2data(:,1:end-1))/1000/10;          % 外気絶対湿度 [kg/kgDA]
IodALL  = str2double(X3data(:,1:end-1)).*4.18*1000/3600;  % 法線面直達日射量 [kcal/m2h] → [W/m2]
IosALL  = str2double(X4data(:,1:end-1)).*4.18*1000/3600;  % 水平面天空日射量 [kcal/m2h] → [W/m2]
InnALL  = str2double(X5data(:,1:end-1)).*4.18*1000/3600;  % 水平面夜間放射量 [kcal/m2h] → [W/m2]



