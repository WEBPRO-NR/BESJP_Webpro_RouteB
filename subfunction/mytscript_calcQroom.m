% mytscript_calcQroom.m
%                                       by Masato Miyata 2012/07/13
%------------------------------------------------------------------
% 簡略負荷計算法
%------------------------------------------------------------------


%% データベース読み込み

% 補正係数データベースの読み込み（行ごと）
DB_COEFFI = textread('./database/QROOM_COEFFI.csv','%s','delimiter','\n','whitespace','');

% CSVファイルのデータ読み込み（変数 perDB_COEFFI）
for i=1:length(DB_COEFFI)
    conma = strfind(DB_COEFFI{i},',');
    for j = 1:length(conma)
        if j == 1
            perDB_COEFFI{i,j} = DB_COEFFI{i}(1:conma(j)-1);
        elseif j == length(conma)
            perDB_COEFFI{i,j}   = DB_COEFFI{i}(conma(j-1)+1:conma(j)-1);
            perDB_COEFFI{i,j+1} = DB_COEFFI{i}(conma(j)+1:end);
        else
            perDB_COEFFI{i,j} = DB_COEFFI{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 該当地域のデータを切り出し(変数 C_sta2dyn)
switch climateAREA
    case {'Ia'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,7:9]);
    case {'Ib'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,10:12]);
    case {'II'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,13:15]);
    case {'III'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,16:18]);
    case {'IVa'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,19:21]);
    case {'IVb'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,22:24]);
    case {'V'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,25:27]);
    case {'VI'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,28:30]);
    otherwise
        error('')
end

% 各室の補正係数を抜き出す
C_sta2dyn_CTC = zeros(numOfRoooms,3);
C_sta2dyn_CTH = zeros(numOfRoooms,3);
C_sta2dyn_CSR = zeros(numOfRoooms,3);
C_sta2dyn_HTC = zeros(numOfRoooms,3);
C_sta2dyn_HTH = zeros(numOfRoooms,3);
C_sta2dyn_HSR = zeros(numOfRoooms,3);
C_sta2dyn_MTC = zeros(numOfRoooms,3);
C_sta2dyn_MTH = zeros(numOfRoooms,3);
C_sta2dyn_MSR = zeros(numOfRoooms,3);
C_sta2dyn_CTC_off = zeros(numOfRoooms,3); 
C_sta2dyn_CTH_off = zeros(numOfRoooms,3); 
C_sta2dyn_CSR_off = zeros(numOfRoooms,3); 
C_sta2dyn_HTC_off = zeros(numOfRoooms,3); 
C_sta2dyn_HTH_off = zeros(numOfRoooms,3); 
C_sta2dyn_HSR_off = zeros(numOfRoooms,3); 
C_sta2dyn_MTC_off = zeros(numOfRoooms,3); 
C_sta2dyn_MTH_off = zeros(numOfRoooms,3); 
C_sta2dyn_MSR_off = zeros(numOfRoooms,3); 

for iROOM = 1:numOfRoooms
    
    % 各室の建物用途
    switch buildingType{iROOM}
        case 'Office'
            BTname = '事務所等';
        case 'Hotel'
            BTname = 'ホテル等';
        case 'Hospital'
            BTname = '病院等';
        case 'Store'
            BTname = '店舗等';
        case 'School'
            BTname = '学校等';
        case 'Restaurant'
            BTname = '飲食店等';
        case 'MeetingPlace'
            BTname = '集会所等';
        otherwise
            error('建物用途が不正です')
    end
    
    % データベース C_sta2dyn 検索
    check = 0; % チェック用
    for iDB = 5:length(C_sta2dyn)
        
        if strcmp(C_sta2dyn(iDB,1),BTname) && strcmp(C_sta2dyn(iDB,2),roomType{iROOM}) % 建物用途と室用途を検索
            
            % 冷房期・貫流熱・冷房
            C_sta2dyn_CTC(iROOM,1:3) = str2double(C_sta2dyn(iDB,7:9));
            % 冷房期・貫流熱・暖房
            C_sta2dyn_CTH(iROOM,1:3) = str2double(C_sta2dyn(iDB+1,7:9));
            % 冷房期・日射熱
            C_sta2dyn_CSR(iROOM,1:3) = str2double(C_sta2dyn(iDB+2,7:9));
            
            % 暖房期・貫流熱・冷房
            C_sta2dyn_HTC(iROOM,1:3) = str2double(C_sta2dyn(iDB+3,7:9));
            % 暖房期・貫流熱・暖房
            C_sta2dyn_HTH(iROOM,1:3) = str2double(C_sta2dyn(iDB+4,7:9));
            % 暖房期・日射熱
            C_sta2dyn_HSR(iROOM,1:3) = str2double(C_sta2dyn(iDB+5,7:9));
            
            % 中間期・貫流熱・冷房
            C_sta2dyn_MTC(iROOM,1:3) = str2double(C_sta2dyn(iDB+6,7:9));
            % 中間期・貫流熱・暖房
            C_sta2dyn_MTH(iROOM,1:3) = str2double(C_sta2dyn(iDB+7,7:9));
            % 中間期・日射熱
            C_sta2dyn_MSR(iROOM,1:3) = str2double(C_sta2dyn(iDB+8,7:9));
            
            % 前日休みの場合の係数
            if isempty(C_sta2dyn{iDB+9,1})  % （iDB+9）行目が空であれば前日休みの場合の係数ありとみなす
                % 冷房期・貫流熱・冷房
                C_sta2dyn_CTC_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+9,7:9));
                % 冷房期・貫流熱・暖房
                C_sta2dyn_CTH_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+10,7:9));
                % 冷房期・日射熱
                C_sta2dyn_CSR_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+11,7:9));
                
                % 暖房期・貫流熱・冷房
                C_sta2dyn_HTC_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+12,7:9));
                % 暖房期・貫流熱・暖房
                C_sta2dyn_HTH_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+13,7:9));
                % 暖房期・日射熱
                C_sta2dyn_HSR_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+14,7:9));
                
                % 中間期・貫流熱・冷房
                C_sta2dyn_MTC_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+15,7:9));
                % 中間期・貫流熱・暖房
                C_sta2dyn_MTH_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+16,7:9));
                % 中間期・日射熱
                C_sta2dyn_MSR_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+17,7:9));
            end
            
            check = 1;
        end
        
    end
    
    % 検索結果の判定
    if check == 0
        error('室用途 %s が見つかりません', roomType{iROOM})
    end
    
end


% 気象データの読み込み（行ごと）
DB_WEATHER = textread(cell2mat(strcat('./weathdat/',strrep(climateDatabase,'.has','_NM1D.csv'))),...
    '%s','delimiter','\n','whitespace','');

% CSVファイルのデータ読み込み（変数 perDB_WEATHER）
for i=1:length(DB_WEATHER)
    conma = strfind(DB_WEATHER{i},',');
    for j = 1:length(conma)
        if j == 1
            perDB_WEATHER{i,j} = DB_WEATHER{i}(1:conma(j)-1);
        elseif j == length(conma)
            perDB_WEATHER{i,j}   = DB_WEATHER{i}(conma(j-1)+1:conma(j)-1);
            perDB_WEATHER{i,j+1} = DB_WEATHER{i}(conma(j)+1:end);
        else
            perDB_WEATHER{i,j} = DB_WEATHER{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 外気温 [℃]
Toa_ave = str2double(perDB_WEATHER(3:end,4));
Toa_day = str2double(perDB_WEATHER(3:end,5));
Toa_ngt = str2double(perDB_WEATHER(3:end,6));
% 湿度 [kg/kgDA]
Xoa_ave = str2double(perDB_WEATHER(3:end,7))./1000;
Xoa_day = str2double(perDB_WEATHER(3:end,8))./1000;
Xoa_ngt = str2double(perDB_WEATHER(3:end,9))./1000;
% 直達日射量[Wh/m2](ガラス入射角反映・0.89で除して基準化済み)
DSR_S   = str2double(perDB_WEATHER(3:end,10));
DSR_SW  = str2double(perDB_WEATHER(3:end,11));
DSR_W   = str2double(perDB_WEATHER(3:end,12));
DSR_NW  = str2double(perDB_WEATHER(3:end,13));
DSR_N   = str2double(perDB_WEATHER(3:end,14));
DSR_NE  = str2double(perDB_WEATHER(3:end,15));
DSR_E   = str2double(perDB_WEATHER(3:end,16));
DSR_SE  = str2double(perDB_WEATHER(3:end,17));
DSR_H   = str2double(perDB_WEATHER(3:end,18));
% 天空・反射日射量[Wh/m2](ガラス入射角反映ただし0.808は乗じていない)
ISR_V   = str2double(perDB_WEATHER(3:end,19));  % 鉛直
ISR_H   = str2double(perDB_WEATHER(3:end,20));  % 水平
% 夜間放射[Wh/m2]
NSR_V   = str2double(perDB_WEATHER(3:end,21));  % 鉛直
NSR_H   = str2double(perDB_WEATHER(3:end,22));  % 水平

% 出力用
OAdataAll = [Toa_ave,Xoa_ave,mytfunc_enthalpy(Toa_ave,Xoa_ave)];
OAdataDay = [Toa_day,Xoa_day,mytfunc_enthalpy(Toa_day,Xoa_day)];
OAdataNgt = [Toa_ngt,Xoa_ngt,mytfunc_enthalpy(Toa_ngt,Xoa_ngt)];



%% 壁や窓の熱性能の読み込み

% 変数定義
Qwall_T  = zeros(365,numOfRoooms);
Qwall_S  = zeros(365,numOfRoooms);
Qwall_N  = zeros(365,numOfRoooms);
Qwind_T  = zeros(365,numOfRoooms);
Qwind_S  = zeros(365,numOfRoooms);
Qwind_N  = zeros(365,numOfRoooms);
Qroom_CTC  = zeros(365,numOfRoooms);
Qroom_CTH  = zeros(365,numOfRoooms);
Qroom_CSR  = zeros(365,numOfRoooms);
AHUonoff   = zeros(365,numOfRoooms);
Qcool     = zeros(365,numOfRoooms);
Qheat     = zeros(365,numOfRoooms);
QroomDc   = zeros(365,numOfRoooms);
QroomDh   = zeros(365,numOfRoooms);


% 室単位のループ
for iROOM = 1:numOfRoooms
    
    % 外皮ID（EnvelopeRef）から外皮仕様DB(envelopeID の iENV)を探す
    % 外壁の設定がされていない場合は check = 0 として、次のif文で分岐させる。
    check = 0;
    for iENV = 1:numOfENVs
        if strcmp(EnvelopeRef{iROOM},envelopeID{iENV}) == 1
            check = 1;
            break
        end
    end
    
    % 外皮負荷の計算（壁枚数が1以上かつデータベースに設定された外壁があるのとき）
    if numOfWalls(iENV) >= 1 && check == 1
        
        % 外壁・窓の情報を読み込む
        for iWALL = 1:numOfWalls(iENV)
            
            % 方位係数（方位：Direction{iENV,iWALL}）（住宅の方位係数を継承）
            if strcmp(Direction{iENV,iWALL},'N')
                directionV = 0.24;
            elseif strcmp(Direction{iENV,iWALL},'E') || strcmp(Direction{iENV,iWALL},'W')
                directionV = 0.45;
            elseif strcmp(Direction{iENV,iWALL},'S')
                directionV = 0.39;
            elseif strcmp(Direction{iENV,iWALL},'SE') || strcmp(Direction{iENV,iWALL},'SW')
                directionV = 0.45;
            elseif strcmp(Direction{iENV,iWALL},'NE') || strcmp(Direction{iENV,iWALL},'NW')
                directionV = 0.34;
            elseif strcmp(Direction{iENV,iWALL},'Horizontal')
                directionV = 1;
            elseif strcmp(Direction{iENV,iWALL},'Underground')
                directionV = 0;
            else
                directionV = 0.5;
            end
            
            % 外壁があれば（外壁名称 WallConfigure で探査）
            if isempty(WallConfigure{iENV,iWALL}) == 0
                
                % 外壁構成リスト WallNameList の検索
                for iDB = 1:length(WallNameList)
                    if strcmp(WallNameList{iDB},WallConfigure{iENV,iWALL})
                        % U値×外壁面積
                        WallUA = WallUvalueList(iDB)*(WallArea(iENV,iWALL) - WindowArea(iENV,iWALL));
                        
                        % UA,MA保存
                        UAlist(iROOM) = UAlist(iROOM) + WallUA;
                        MAlist(iROOM) = MAlist(iROOM) + directionV*(0.8*0.04)*WallUA;
                        
                        switch Direction{iENV,iWALL}
                            
                            case 'Horizontal'
                                
                                if WallTypeNum(iENV,iWALL) == 1  % 外気に接する壁
                                    Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(Toa_ave-TroomSP).*24;      % 貫流熱取得(365日分)
                                elseif WallTypeNum(iENV,iWALL) == 2  % 接地壁
                                    Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(mean(Toa_ave)*ones(365,1)-TroomSP).*24;      % 貫流熱取得(365日分)
                                else
                                    error('外壁タイプが不正です')
                                end
                                Qwall_S(:,iROOM) = Qwall_S(:,iROOM) + WallUA.*(0.8/23.3).*(DSR_H+ISR_H);  % 日射熱取得(365日分)
                                Qwall_N(:,iROOM) = Qwall_N(:,iROOM) - WallUA.*(0.9/23.3).*NSR_H;          % 夜間放射(365日分)
                                
                            case {'Shade','Underground'}
                                
                                if WallTypeNum(iENV,iWALL) == 1  % 外気に接する壁
                                    Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(Toa_ave-TroomSP).*24;   % 貫流熱取得(365日分)
                                elseif WallTypeNum(iENV,iWALL) == 2  % 接地壁
                                    Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(mean(Toa_ave)*ones(365,1)-TroomSP).*24;      % 貫流熱取得(365日分)
                                else
                                    error('外壁タイプが不正です')
                                end
                                
                                % 日射は何も足さない
                                
                            otherwise
                                
                                if WallTypeNum(iENV,iWALL) == 1  % 外気に接する壁
                                    Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(Toa_ave-TroomSP).*24;      % 貫流熱取得(365日分)
                                elseif WallTypeNum(iENV,iWALL) == 2  % 接地壁
                                    Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(mean(Toa_ave)*ones(365,1)-TroomSP).*24;      % 貫流熱取得(365日分)
                                else
                                    error('外壁タイプが不正です')
                                end
                                
                                eval(['Qwall_S(:,iROOM) = Qwall_S(:,iROOM) + WallUA.*(0.8/23.3).*(DSR_',Direction{iENV,iWALL},'+ISR_V);']);  % 日射熱取得(365日分)
                                Qwall_N(:,iROOM) = Qwall_N(:,iROOM) - WallUA.*(0.9/23.3).*NSR_V;  % 夜間放射(365日分)
                        end
                    end
                end
            end
            
            % 窓があれば（窓名称 WindowType で探査）
            if isempty(WindowType{iENV,iWALL}) == 0 && strcmp(WindowType{iENV,iWALL},'Null') == 0
                
                % 窓リスト WindowNameList の検索
                for iDB = 1:length(WindowNameList)
                    if strcmp(WindowNameList{iDB},WindowType{iENV,iWALL})
                        
                        % U値×窓面積
                        WindowUA = WindowUvalueList(iDB)*WindowArea(iENV,iWALL);
                        % (SCC、SCR)×窓面積
                        WindowSCC = WindowSCCList(iDB)*WindowArea(iENV,iWALL);
                        WindowSCR = WindowSCRList(iDB)*WindowArea(iENV,iWALL);
                        
                        % 日よけ効果係数（冷房）
                        WindowEavesC = Eaves_Cooling{iENV,iWALL};
                        if strcmp(WindowEavesC,'Null') || isnan(WindowEavesC) || isempty(WindowEavesC) || WindowEavesC > 1
                            WindowEavesC = 1;
                        elseif WindowEavesC < 0
                            WindowEavesC = 0;
                        end
                        
                        % 日よけ効果係数（暖房）
                        WindowEavesH = Eaves_Heating{iENV,iWALL};
                        if strcmp(WindowEavesH,'Null') || isnan(WindowEavesH) || isempty(WindowEavesH) || WindowEavesH > 1
                            WindowEavesH = 1;
                        elseif WindowEavesH < 0
                            WindowEavesH = 0;
                        end
                        
                        % UA,MA保存
                        UAlist(iROOM) = UAlist(iROOM) + WindowUA;
                        MAlist(iROOM) = MAlist(iROOM) + WindowEavesC * directionV * WindowMyuList(iDB)*WindowArea(iENV,iWALL);
                        
                        switch Direction{iENV,iWALL}
                            case 'Horizontal'
                                
                                Qwind_T(:,iROOM) = Qwind_T(:,iROOM) + WindowUA.*(Toa_ave-TroomSP).*24;   % 貫流熱取得(365日分)
                                
                                for dd = 1:365
                                    if SeasonMode(dd) == -1  % 暖房
                                        Qwind_S(dd,iROOM) = Qwind_S(dd,iROOM) + WindowEavesH.* (WindowSCC+WindowSCR).*(DSR_H(dd)*0.89+ISR_H(dd)*0.808); % 日射熱取得(365日分)
                                    else
                                        Qwind_S(dd,iROOM) = Qwind_S(dd,iROOM) + WindowEavesC.* (WindowSCC+WindowSCR).*(DSR_H(dd)*0.89+ISR_H(dd)*0.808); % 日射熱取得(365日分)
                                    end
                                end
                                
                                Qwind_N(:,iROOM) = Qwind_N(:,iROOM) - WindowUA.*(0.9/23.3).*NSR_H;  % 夜間放射(365日分)
                                
                            case {'Shade','Underground'}
                                % 何もしない
                                
                            otherwise
                                Qwind_T(:,iROOM) = Qwind_T(:,iROOM) + WindowUA.*(Toa_ave-TroomSP).*24;   % 貫流熱取得(365日分)
                                
                                for dd = 1:365
                                    if SeasonMode(dd) == -1  % 暖房
                                        eval(['Qwind_S(dd,iROOM) = Qwind_S(dd,iROOM) + WindowEavesH.*(WindowSCC+WindowSCR).*(DSR_',Direction{iENV,iWALL},'(dd)*0.89+ISR_V(dd)*0.808);']) % 日射熱取得(365日分)
                                    else
                                        eval(['Qwind_S(dd,iROOM) = Qwind_S(dd,iROOM) + WindowEavesC.*(WindowSCC+WindowSCR).*(DSR_',Direction{iENV,iWALL},'(dd)*0.89+ISR_V(dd)*0.808);']) % 日射熱取得(365日分)
                                    end
                                end
                                
                                Qwind_N(:,iROOM) = Qwind_N(:,iROOM) - WindowUA.*(0.9/23.3).*NSR_V;  % 夜間放射(365日分)
                        end
                        
                    end
                end
            end
            
        end
        
    else
        
        Qwall_T(:,iROOM) = zeros(365,1);
        Qwall_S(:,iROOM) = zeros(365,1);
        Qwall_N(:,iROOM) = zeros(365,1);
        Qwind_T(:,iROOM) = zeros(365,1);
        Qwind_S(:,iROOM) = zeros(365,1);
        Qwind_N(:,iROOM) = zeros(365,1);
        
    end
    
    % 室面積あたりの熱量に変換 [Wh/m2/日]
    Qwall_T(:,iROOM) = Qwall_T(:,iROOM)./roomArea(iROOM);
    Qwall_S(:,iROOM) = Qwall_S(:,iROOM)./roomArea(iROOM);
    Qwall_N(:,iROOM) = Qwall_N(:,iROOM)./roomArea(iROOM);
    Qwind_T(:,iROOM) = Qwind_T(:,iROOM)./roomArea(iROOM);
    Qwind_S(:,iROOM) = Qwind_S(:,iROOM)./roomArea(iROOM);
    Qwind_N(:,iROOM) = Qwind_N(:,iROOM)./roomArea(iROOM);
    
    
    % 日単位で負荷計算を実行
    for dd = 1:365
        
        % スケジュールパターン（１，２，３）
        Sptn = roomDailyOpePattern(dd,iROOM);
        
        % 内部発熱量 [Wh/m2]
        W1(dd,iROOM) = sum(roomScheduleOAapp(iROOM,Sptn,:)) .*roomEnergyOAappUnit(iROOM);  % 機器
        W2(dd,iROOM) = sum(roomScheduleLight(iROOM,Sptn,:)) .*roomEnergyLight(iROOM);      % 照明
        W3(dd,iROOM) = sum(roomSchedulePerson(iROOM,Sptn,:)).*roomEnergyPerson(iROOM);     % 人体
        
        % 空調ONOFF (空調開始時刻と終了時刻が異なれば ON とする)
        if roomTime_start(dd,iROOM) ~= roomTime_stop(dd,iROOM)
            AHUonoff(dd,iROOM) = 1;
        end
        
        if AHUonoff(dd,iROOM) > 0
            
            if SeasonMode(dd) == 1   % 冷房期
                
                if dd > 1 && AHUonoff(dd-1,iROOM)==1
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_CTC(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_CTC(iROOM,3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_CTH(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_CTH(iROOM,3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_CSR(iROOM,1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_CSR(iROOM,3);
                else
                    % 前日が非空調の場合
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_CTC_off(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_CTC_off(iROOM,3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_CTH_off(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_CTH_off(iROOM,3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_CSR_off(iROOM,1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_CSR_off(iROOM,3);
                end
                
            elseif SeasonMode(dd) == -1 % 暖房期
                
                if dd > 1 && AHUonoff(dd-1,iROOM)==1
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_HTC(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_HTC(iROOM,3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_HTH(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_HTH(iROOM,3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_HSR(iROOM,1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_HSR(iROOM,3);
                else
                    % 前日が非空調の場合
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_HTC_off(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_HTC_off(iROOM,3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_HTH_off(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_HTH_off(iROOM,3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_HSR_off(iROOM,1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_HSR_off(iROOM,3);
                end
                
            elseif SeasonMode(dd) == 0  % 中間期
                
                if dd > 1 && AHUonoff(dd-1,iROOM)==1
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_MTC(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_MTC(iROOM,3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_MTH(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_MTH(iROOM,3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_MSR(iROOM,1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_MSR(iROOM,3);
                else
                    % 前日が非空調の場合
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_MTC_off(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_MTC_off(iROOM,3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_MTH_off(iROOM,1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_MTH_off(iROOM,3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_MSR_off(iROOM,1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_MSR_off(iROOM,3);
                end
                
            else
                error('季節区分が不正です')
            end
            
            if Qroom_CTC(dd,iROOM) < 0
                Qroom_CTC(dd,iROOM) = 0;
            end
            if Qroom_CTH(dd,iROOM) > 0
                Qroom_CTH(dd,iROOM) = 0;
            end
            if Qroom_CSR(dd,iROOM) < 0
                Qroom_CSR(dd,iROOM) = 0;
            end
            
            % 日射負荷 Qroom_CSR を暖房負荷 Qroom_CTH に足す
            Qcool(dd,iROOM) = Qroom_CTC(dd,iROOM);
            Qheat(dd,iROOM) = Qroom_CTH(dd,iROOM) + Qroom_CSR(dd,iROOM);
            
            % 日射負荷によって暖房負荷がプラスになった場合は、超過分を冷房負荷に加算
            if Qheat(dd,iROOM) > 0
                Qcool(dd,iROOM) = Qcool(dd,iROOM) + Qheat(dd,iROOM);
                Qheat(dd,iROOM) = 0;
            end
            
            % 内部発熱 W1,W2,W3 を暖房負荷 Qheat に足す
            Qheat(dd,iROOM) = Qheat(dd,iROOM) + (W1(dd,iROOM) + W2(dd,iROOM) + W3(dd,iROOM));
            
            % 内部発熱によって暖房負荷がプラスになった場合は、超過分を冷房負荷に加算
            if Qheat(dd,iROOM) > 0
                Qcool(dd,iROOM) = Qcool(dd,iROOM) + Qheat(dd,iROOM);
                Qheat(dd,iROOM) = 0;
            end
            
        else
            % 空調OFF時は 0 とする
             Qcool(dd,iROOM) = 0;
             Qheat(dd,iROOM) = 0;
        end

    end
    
    % 出力 [Wh/m2/日] → [MJ/day]
    QroomDc(:,iROOM) = Qcool(:,iROOM) .* (3600/1000000) .* roomArea(iROOM);
    QroomDh(:,iROOM) = Qheat(:,iROOM) .* (3600/1000000) .* roomArea(iROOM);
    
end
