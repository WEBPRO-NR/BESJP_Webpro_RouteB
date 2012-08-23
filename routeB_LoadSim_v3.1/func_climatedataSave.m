function y = func_climatedataSave(filename,X1data,X2data,X3data,X4data,X5data,X6data,X7data)

% 気象データ再生成
for day=1:365
    for n=1:7
        eval(['Xdata = X',int2str(n),'data;']) 
        newWeatherData{ 7*(day-1)+n ,:} = ...
            strcat(Xdata{day,1},Xdata{day,2},Xdata{day,3},Xdata{day,4},Xdata{day,5},Xdata{day,6},Xdata{day,7},...
            Xdata{day,8},Xdata{day,9},Xdata{day,10},Xdata{day,11},Xdata{day,12},Xdata{day,13},Xdata{day,14},...
            Xdata{day,15},Xdata{day,16},Xdata{day,17},Xdata{day,18},Xdata{day,19},Xdata{day,20},Xdata{day,21},...
            Xdata{day,22},Xdata{day,23},Xdata{day,24},Xdata{day,25});
    end
end

eval(['fid = fopen(''',filename,''',''w+'');'])
for i=1:length(newWeatherData)
fprintf(fid,'%s\r\n',newWeatherData{i});
end
y = fclose(fid);