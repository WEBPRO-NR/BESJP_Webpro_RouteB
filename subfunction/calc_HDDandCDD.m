clear

addpath('./subfunction')

% データベース読み込み
mytscript_readDBfiles;

climateAREASET = {'1','2','3','4','5','6','7','8'};

TallDailyAve   = zeros(8,365);
TallMonthlyAve = zeros(8,12);

for C = 1:8
    
    % 地域区分
    climateAREA = climateAREASET{C};
    
    check = 0;
    for iDB = 1:length(perDB_climateArea(:,2))
        if strcmp(perDB_climateArea(iDB,1),climateAREA) || strcmp(perDB_climateArea(iDB,2),climateAREA)
            % 気象データファイル名
            eval(['climatedatafile  = ''./weathdat/C1_',perDB_climateArea{iDB,6},''';'])
            check = 1;
        end
    end
    if check == 0
        error('地域区分が不正です')
    end
    
    % 日射データ読み込み
    [Tall,Xall,IodALL,IosALL,InnALL] = mytfunc_climatedataRead(climatedatafile);
    
    % 日平均外気温度
    TallDailyAve(C,:) = mean(Tall,2);
    
    % 月平均外気温度
    TallMonthlyAve(C,1)  = mean(TallDailyAve(C,1:31));     % 1月
    TallMonthlyAve(C,2)  = mean(TallDailyAve(C,32:59));    % 2月
    TallMonthlyAve(C,3)  = mean(TallDailyAve(C,60:90));    % 3月
    TallMonthlyAve(C,4)  = mean(TallDailyAve(C,91:120));   % 4月
    TallMonthlyAve(C,5)  = mean(TallDailyAve(C,121:151));  % 5月
    TallMonthlyAve(C,6)  = mean(TallDailyAve(C,152:181));  % 6月
    TallMonthlyAve(C,7)  = mean(TallDailyAve(C,182:212));  % 7月
    TallMonthlyAve(C,8)  = mean(TallDailyAve(C,213:243));  % 8月
    TallMonthlyAve(C,9)  = mean(TallDailyAve(C,244:273));  % 9月
    TallMonthlyAve(C,10) = mean(TallDailyAve(C,274:304));  % 10月
    TallMonthlyAve(C,11) = mean(TallDailyAve(C,305:334));  % 11月
    TallMonthlyAve(C,12) = mean(TallDailyAve(C,335:365));  % 12月
    
    
    % HDD(18-18)
    HDD18 = 0;
    for dd = 1:size(Tall,1)
        if TallDailyAve(C,dd) <= 18
            HDD18 = HDD18 + (18 - TallDailyAve(C,dd));
        end
    end
    
    % CDD(24-24)
    CDD24 = 0;
    for dd = 1:size(Tall,1)
        if TallDailyAve(C,dd) > 24
            CDD24 = CDD24 +(TallDailyAve(C,dd) - 24);
        end
    end
    
    % 出力
    eval(['disp(''地域 ',climateAREA,'　：　冷房度日 CDD24-24　',int2str(CDD24),''')'])
    eval(['disp(''地域 ',climateAREA,'　：　暖房度日 HDD18-18　',int2str(HDD18),''')'])

end




