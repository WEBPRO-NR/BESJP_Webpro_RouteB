% mytfunc_newHASPrun.m
%                                                                                by Masato Miyata 2012/01/02
%-----------------------------------------------------------------------------------------------------------
% newHASPによる負荷計算を行う．
%-----------------------------------------------------------------------------------------------------------
% 入力
%   roomID：室名リスト
%   climateDatabase： 気象データファイル名
%   roomClarendarNum: カレンダ番号（室毎）
%   roomArea：室床面積 [m2]
% 出力
%   QroomDc：日積算室負荷（冷房）[MJ/day]
%   QroomDh：日積算室負荷（暖房）[MJ/day]
%   QroomHour：時刻別室負荷　　　[MJ/h]
%-----------------------------------------------------------------------------------------------------------

function [QroomDc,QroomDh,QroomHour] = mytfunc_newHASPrun(roomID,climateDatabase,roomClarendarNum,roomArea,OutputOptionVar,LoadMode)

% 負荷計算結果格納用変数
QroomDc   = zeros(365,length(roomID));    % 日積算冷房負荷 [MJ/day]
QroomDh   = zeros(365,length(roomID));    % 日積算暖房負荷 [MJ/day]
QroomHour = zeros(8760,length(roomID));   % 時刻別室負荷 [MJ/h]

for iROOM = 1:length(roomID)
    
    if strcmp(LoadMode,'Read') == 0
        
        % 設定ファイル（NHKsetting.txt）の生成
        eval(['NHKsetting{1} = ''newHASPinput_',roomID{iROOM},'.txt'';'])
        eval(['NHKsetting{2} = ''./weathdat/C',num2str(roomClarendarNum(iROOM)),'_',cell2mat(climateDatabase),''';'])
        NHKsetting{3} = 'out20.dat';
        NHKsetting{4} = 'newhasp\wndwtabl.dat';
        NHKsetting{5} = 'newhasp\wcontabl.dat';
        
        fid = fopen('NHKsetting.txt','w+');
        for i=1:5
            fprintf(fid,'%s\r\n',NHKsetting{i});
        end
        fclose(fid);
        
        % newHASPを実行
        system('RunHasp.bat');
        
    else
        disp('負荷計算結果を読み込みます')
    end
    
    % 結果ファイル読み込み
    % 1)年，2)月，3)日，4)曜日，5)時，6)分
    % 7)室温，8)冷房負荷(顕熱)[W/m2]，9)室除去熱量(顕熱)[W/m2]，10)装置除去熱量(顕熱)[W/m2]，11)フラグ
    % 12)湿度[g/kgDA]，13)冷房負荷(潜熱)[W/m2]，14)室除去熱量(潜熱)[W/m2]，15)装置除去熱量(潜熱)[W/m2]，16)フラグ，17)MRT'
    %     eval(['newHASPresult = xlsread(''',roomID{iROOM},'.csv'');'])
    
    % 結果ファイル名（室IDが4文字以下であればアンダーバーが入る）
    if length(roomID{iROOM}) == 1
        resFileName = strcat(roomID(iROOM),'___');
    elseif length(roomID{iROOM}) == 2
        resFileName = strcat(roomID(iROOM),'__');
    elseif length(roomID{iROOM}) == 3
        resFileName = strcat(roomID(iROOM),'_');
    elseif length(roomID{iROOM}) == 4
        resFileName = roomID(iROOM);
    else
        error('roomIDが不正です')
    end
    
    eval(['newHASPresultALL = textread(''',cell2mat(resFileName),'.csv'',''%s'',''delimiter'',''\n'',''whitespace'','''');'])
    
    newHASPresult = zeros(8760,2);
    for i=2:length(newHASPresultALL)
        conma = strfind(newHASPresultALL{i},',');
        newHASPresult(i-1,1)  = str2double(newHASPresultALL{i}(conma(8)+1:conma(9)-1));  % 顕熱負荷
        newHASPresult(i-1,2) = str2double(newHASPresultALL{i}(conma(13)+1:conma(14)-1)); % 潜熱負荷
    end
    
    if OutputOptionVar == 0
        eval(['delete ',cell2mat(resFileName),'.csv'])
        eval(['delete newHASPinput_',roomID{iROOM},'.txt'])
        delete NHKsetting.txt err.txt out20.dat
    end
    
    % 室除去熱量（全熱，毎時）[W/m2]→[MJ/h]
    newHASP_Qhour = (newHASPresult(:,1) + newHASPresult(:,2))*roomArea(iROOM).*3600./1000000;
    
    % NaNチェック(newHASPの計算結果が****となる場合がある)
    for i=1:length(newHASP_Qhour)
        if isnan(newHASP_Qhour(i))
            newHASP_Qhour(i) = 0;
            roomID(iROOM)
            disp('newHASPの計算結果に*****がある')
        end
    end
    
    % 日積算化（冷房負荷と暖房負荷に分離）
    newHASP_Qday = zeros(365,2);  % 初期化
    for i=1:365
        for j=1:24
            num = 24*(i-1)+j;
            if newHASP_Qhour(num,1)>=0
                newHASP_Qday(i,1) = newHASP_Qday(i,1) + newHASP_Qhour(num,1);  % 冷房負荷 [MJ/day]
            else
                newHASP_Qday(i,2) = newHASP_Qday(i,2) + newHASP_Qhour(num,1);  % 暖房負荷 [MJ/day]
            end
        end
        
        if newHASP_Qday(i,1) == 0
            newHASP_Qday(i,1) = 0;  % 負荷が発生しなかった日は 0 をいれる。
        end
        if newHASP_Qday(i,2) == 0
            newHASP_Qday(i,2) = 0;  % 負荷が発生しなかった日は 0 をいれる。
        end
    end
    
    % 負荷データの格納
    QroomDc(:,iROOM)   = newHASP_Qday(:,1); % 日積算冷房負荷 [MJ/day]
    QroomDh(:,iROOM)   = newHASP_Qday(:,2); % 日積算暖房負荷 [MJ/day]
    QroomHour(:,iROOM) = newHASP_Qhour;     % 時刻別負荷 [MJ/h]
    
end



