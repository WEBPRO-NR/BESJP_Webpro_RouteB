function [X1data,X2data,X3data,X4data,X5data,X6data,X7data] = func_climatedataRead(filename);

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





