% ECS_routeB_HW_run_v1.m
%                                          by Masato Miyata 2011/03/06
%----------------------------------------------------------------------
% 給湯計算プログラム
%----------------------------------------------------------------------
% function E_eqpSUMperAREA = ECS_routeB_HW_run_v1(climateAREA,buildingType,filename_HWroom,filename_HWequipment)

clear
clc
% 地域
climateAREA = 'IVa';
% 建物用途
buildingType = '病院等';
% ファイル名指定
filename_HWroom      = '省エネ基準ルートB_給湯_室シート.csv';
filename_HWequipment = '省エネ基準ルートB_給湯_機器シート.csv';

% データベースファイル
filename_calendar             = './database/CALENDAR.csv';   % カレンダー
filename_ClimateArea          = './database/AREA.csv';       % 地域区分
filename_RoomTypeList         = './database/ROOM_SPEC.csv';  % 室用途リスト
filename_roomOperateCondition = './database/ROOM_COND.csv';  % 標準室使用条件
filename_refList              = './database/REFLIST.csv';    % 熱源機器リスト
filename_performanceCurve     = './database/REFCURVE.csv';   % 熱源特性

mytscript_readDBfiles;

ULLLIST = [0.159,0.191,0.191,0.599;
    0.189,0.213,0.231,0.838;
    0.218,0.270,0.270,1.077;
    0.242,0.303,0.303,1.282;
    0.237,0.354,0.354,1.610;
    0.257,0.388,0.388,1.832;
    0.296,0.457,0.457,2.281;
    0.346,0.472,0.548,2.876;
    0.387,0.532,0.621,3.359;
    0.466,0.651,0.651,4.309;
    0.464,0.770,0.770,5.270;
    0.528,0.774,0.889,6.228];

% 気象データの読み込み
switch climateAREA
    case 'Ia'
        [OAdataAll,OAdataDay,OAdataNgt,OAdataHourly] = mytfunc_weathdataRead('weathdat/weath_Ia.dat');
        WIN = [1:120,305:365]; MID = [121:181,274:304]; SUM = [182:273];
        TWdata = 0.6639.*OAdataAll(:,1) + 3.466;
    case 'Ib'
        [OAdataAll,OAdataDay,OAdataNgt,OAdataHourly] = mytfunc_weathdataRead('weathdat/weath_Ib.dat');
        WIN = [1:120,305:365]; MID = [121:181,274:304]; SUM = [182:273];
        TWdata = 0.6639.*OAdataAll(:,1) + 3.466;
    case 'II'
        [OAdataAll,OAdataDay,OAdataNgt,OAdataHourly] = mytfunc_weathdataRead('weathdat/weath_II.dat');
        WIN = [1:90,335:365]; MID = [91:151,274:334]; SUM = [152:273];
        TWdata = 0.6054.*OAdataAll(:,1) + 4.515;
    case 'III'
        [OAdataAll,OAdataDay,OAdataNgt,OAdataHourly] = mytfunc_weathdataRead('weathdat/weath_III.dat');
        WIN = [1:90,335:365]; MID = [91:151,274:334]; SUM = [152:273];
        TWdata = 0.6054.*OAdataAll(:,1) + 4.515;
    case 'IVa'
        [OAdataAll,OAdataDay,OAdataNgt,OAdataHourly] = mytfunc_weathdataRead('weathdat/weath_IVa.dat');
        WIN = [1:90,335:365]; MID = [91:151,274:334]; SUM = [152:273];
        TWdata = 0.8660.*OAdataAll(:,1) + 1.665;
    case 'IVb'
        [OAdataAll,OAdataDay,OAdataNgt,OAdataHourly] = mytfunc_weathdataRead('weathdat/weath_IVb.dat');
        WIN = [1:90,335:365]; MID = [91:151,274:334]; SUM = [152:273];
        TWdata = 0.8516.*OAdataAll(:,1) + 2.473;
    case 'V'
        [OAdataAll,OAdataDay,OAdataNgt,OAdataHourly] = mytfunc_weathdataRead('weathdat/weath_V.dat');
        WIN = [1:90,335:365]; MID = [91:151,274:334]; SUM = [152:273];
        TWdata = 0.9223.*OAdataAll(:,1) + 2.097;
    case 'VI'
        [OAdataAll,OAdataDay,OAdataNgt,OAdataHourly] = mytfunc_weathdataRead('weathdat/weath_VI.dat');
        WIN = [1:90]; MID = [91:120,305:365]; SUM = [121:304];
        TWdata = 0.6921.*OAdataAll(:,1) + 7.167;
    otherwise
        error('地域コードが不正です')
end

% 季節依存変数の定義（室内設定温度）
Troom = zeros(365,1);
for iWIN = 1:length(WIN)
    Troom(WIN(iWIN),1) = 22;
end
for iMID = 1:length(MID)
    Troom(MID(iMID),1) = 24; % 中間期
end
for iSUM = 1:length(SUM)
    Troom(SUM(iSUM),1) = 26; % 夏期
end


%% CSVファイルの読み込み

% % 給湯室に関する情報
% hwRoomInfoCSV = textread(filename_HWroom,'%s','delimiter','\n','whitespace','');
% 
% hwRoomInfoCell = {};
% for i=1:length(hwRoomInfoCSV)
%     conma = strfind(hwRoomInfoCSV{i},',');
%     for j = 1:length(conma)
%         if j == 1
%             hwRoomInfoCell{i,j} = hwRoomInfoCSV{i}(1:conma(j)-1);
%         elseif j == length(conma)
%             hwRoomInfoCell{i,j}   = hwRoomInfoCSV{i}(conma(j-1)+1:conma(j)-1);
%             hwRoomInfoCell{i,j+1} = hwRoomInfoCSV{i}(conma(j)+1:end);
%         else
%             hwRoomInfoCell{i,j} = hwRoomInfoCSV{i}(conma(j-1)+1:conma(j)-1);
%         end
%     end
% end
% 
% for iROOM = 11:size(hwRoomInfoCell,1)
%     % 室名称
%     roomName{iROOM-10} = strcat(hwRoomInfoCell(iROOM,1),'_',hwRoomInfoCell(iROOM,2));
%     % 室用途
%     roomType{iROOM-10} = hwRoomInfoCell(iROOM,3);
%     % 室面積 [m2]
%     roomArea(iROOM-10) = str2double(hwRoomInfoCell(iROOM,4));
%     % 節湯器具の有無
%     if strcmp(hwRoomInfoCell(iROOM,6),'■') == 1
%         roomWsave(iROOM-10) = 1;
%     else
%         roomWsave(iROOM-10) = 0;
%     end
%     % 接続機器リスト
%     tmpHWequip = {};
%     for iEQP = 1:length(hwRoomInfoCell(iROOM,:))-7
%         if isempty(hwRoomInfoCell{iROOM,7+iEQP}) == 0
%             tmpHWequip = [tmpHWequip,hwRoomInfoCell(iROOM,7+iEQP)];
%         end
%     end
%     roomEquipSet{iROOM-10,:} =  tmpHWequip;
% end

% % 給湯機器に関する情報
% hwequipInfoCSV = textread(filename_HWequipment,'%s','delimiter','\n','whitespace','');
% 
% hwequipInfoCell = {};
% for i=1:length(hwequipInfoCSV)
%     conma = strfind(hwequipInfoCSV{i},',');
%     for j = 1:length(conma)
%         if j == 1
%             hwequipInfoCell{i,j} = hwequipInfoCSV{i}(1:conma(j)-1);
%         elseif j == length(conma)
%             hwequipInfoCell{i,j}   = hwequipInfoCSV{i}(conma(j-1)+1:conma(j)-1);
%             hwequipInfoCell{i,j+1} = hwequipInfoCSV{i}(conma(j)+1:end);
%         else
%             hwequipInfoCell{i,j} = hwequipInfoCSV{i}(conma(j-1)+1:conma(j)-1);
%         end
%     end
% end
% 
% for iEQP = 11:size(hwequipInfoCell,1)
%     % 機器コード
%     equipID(iEQP-10) = hwequipInfoCell(iEQP,1);
%     % 機器コード
%     equipName(iEQP-10) = strcat(hwequipInfoCell(iEQP,2),'_',hwequipInfoCell(iEQP,3));
%     % 台数
%     equipNum(iEQP-10) = str2double(hwequipInfoCell(iEQP,4));
%     % 加熱容量 [kW/台]
%     equipPower(iEQP-10) = str2double(hwequipInfoCell(iEQP,5));
%     % 熱源効率 [-]
%     equipEffi(iEQP-10) = str2double(hwequipInfoCell(iEQP,6));
%     % 保温仕様
%     if strcmp(hwequipInfoCell(iEQP,7),'保温仕様１')
%         equipInsulation(iEQP-10) = 1;
%     elseif strcmp(hwequipInfoCell(iEQP,7),'保温仕様２')
%         equipInsulation(iEQP-10) = 2;
%     elseif strcmp(hwequipInfoCell(iEQP,7),'保温仕様３')
%         equipInsulation(iEQP-10) = 3;
%     else
%         equipInsulation(iEQP-10) = 4;
%     end
%     % 接続口径
%     equipPipeSize(iEQP-10) = str2double(hwequipInfoCell(iEQP,8));
%     if equipPipeSize(iEQP-10) <= 13
%         ULLnum(iEQP-10) = 1;
%     elseif equipPipeSize(iEQP-10) <= 20
%         ULLnum(iEQP-10) = 2;
%     elseif equipPipeSize(iEQP-10) <= 25
%         ULLnum(iEQP-10) = 3;
%     elseif equipPipeSize(iEQP-10) <= 30
%         ULLnum(iEQP-10) = 4;
%     elseif equipPipeSize(iEQP-10) <= 40
%         ULLnum(iEQP-10) = 5;
%     elseif equipPipeSize(iEQP-10) <= 50
%         ULLnum(iEQP-10) = 6;
%     elseif equipPipeSize(iEQP-10) <= 60
%         ULLnum(iEQP-10) = 7;
%     elseif equipPipeSize(iEQP-10) <= 75
%         ULLnum(iEQP-10) = 8;
%     elseif equipPipeSize(iEQP-10) <= 80
%         ULLnum(iEQP-10) = 9;
%     elseif equipPipeSize(iEQP-10) <= 100
%         ULLnum(iEQP-10) = 10;
%     elseif equipPipeSize(iEQP-10) <= 125
%         ULLnum(iEQP-10) = 11;
%     else
%         ULLnum(iEQP-10) = 12;
%     end
%     
%     ULL(iEQP-10) = ULLLIST(ULLnum(iEQP-10),equipInsulation(iEQP-10));
%     
%     % 太陽熱利用
%     if strcmp(hwequipInfoCell(iEQP,9),'有')
%         equipSolar(iEQP-10) = 1;
%     else
%         equipSolar(iEQP-10) = 0;
%     end
% end


%% 各室の給湯量[L/day]を求める。

Qsr_std      = zeros(1,length(roomName));
wscType      = zeros(1,length(roomName));
calenderP2   = zeros(1,length(roomName));
calenderType = zeros(365,length(roomName));
scheduleHW   = zeros(365,length(roomName));
Qsr_daily    = zeros(365,length(roomName));
Qs_daily     = zeros(365,length(roomName));
Qs_save      = zeros(365,length(roomName));

for iROOM = 1:length(roomName)
    
    % 標準室使用条件を探索
    for iDB = 1:length(perDB_RoomType)
        if strcmp(perDB_RoomType{iDB,4},buildingType) && ...
                strcmp(perDB_RoomType{iDB,5},roomType{iROOM})
            
            % 標準日積算給湯量　Qs_std_day [L/day]
            if strcmp(perDB_RoomType{iDB,31},'[L/人日]') || strcmp(perDB_RoomType{iDB,31},'[L/床日]')
                Qsr_std(iROOM) = str2double(perDB_RoomType(iDB,10)) *...
                    str2double(perDB_RoomType(iDB,30)) * roomArea(iROOM);
            elseif strcmp(perDB_RoomType{iDB,31},'[L/㎡日]')
                Qsr_std(iROOM) = str2double(perDB_RoomType(iDB,30)) * roomArea(iROOM);
            else
                error('給湯負荷が見つかりません')
            end
            
            % カレンダーパターン
            if strcmp(perDB_RoomType(iDB,7),'A')
                calenderType(:,iROOM) = str2double(perDB_calendar(2:end,3));
            elseif strcmp(perDB_RoomType(iDB,7),'B')
                calenderType(:,iROOM) = str2double(perDB_calendar(2:end,4));
            elseif strcmp(perDB_RoomType(iDB,7),'C')
                calenderType(:,iROOM) = str2double(perDB_calendar(2:end,5));
            elseif strcmp(perDB_RoomType(iDB,7),'D')
                calenderType(:,iROOM) = str2double(perDB_calendar(2:end,6));
            elseif strcmp(perDB_RoomType(iDB,7),'E')
                calenderType(:,iROOM) = str2double(perDB_calendar(2:end,7));
            elseif strcmp(perDB_RoomType(iDB,7),'F')
                calenderType(:,iROOM) = str2double(perDB_calendar(2:end,8));
            else
                error('カレンダーパターンが不正です')
            end
            
            % パターン2の判定（稼動か停止か）
            if isempty(perDB_RoomType{iDB,18})
                calenderP2(iROOM) = 0;
            else
                calenderP2(iROOM) = 1;
            end
            
            % WSCパターン
            if strcmp(perDB_RoomType(iDB,8),'WSC1')
                wscType(iROOM) = 1;
            elseif strcmp(perDB_RoomType(iDB,8),'WSC2')
                wscType(iROOM) = 2;
            else
                error('WSCパターンが不正です')
            end
            
            % 給湯スケジュール
            for dd = 1:365
                if calenderType(dd,iROOM) == 1
                    scheduleHW(dd,iROOM) = 1;
                elseif calenderType(dd,iROOM) == 2
                    if calenderP2(iROOM) == 1
                        scheduleHW(dd,iROOM) = 1;
                    else
                        scheduleHW(dd,iROOM) = 0;
                    end
                elseif calenderType(dd,iROOM) == 3
                    if wscType(iROOM) == 2 && calenderP2(iROOM) == 1
                        scheduleHW(dd,iROOM) = 1;
                    else
                        scheduleHW(dd,iROOM) = 0;
                    end
                else
                    error('スケジュールパターンが不正です')
                end
            end
            
            % 標準日積算給湯量 [L/day]
            Qsr_daily(:,iROOM) = scheduleHW(:,iROOM).* Qsr_std(iROOM);
            
            % 節湯を考慮した日積算給湯量[L/day]
            if roomWsave(iROOM) == 1
                Qs_save(:,iROOM)  = Qsr_daily(:,iROOM).*0.25;
                Qs_daily(:,iROOM) = Qsr_daily(:,iROOM).*(1-0.25);
            else
                Qs_daily(:,iROOM) = Qsr_daily(:,iROOM);
            end
            
        end
    end
    if Qsr_std(iROOM) == 0
        iROOM
        error('給湯負荷が見つかりません')
    end
end


%% 各室熱源の容量比を求める。

for iROOM = 1:length(roomName)
    
    % 総加熱容量を求める。
    equipPowerSum(iROOM) = 0;
    equipPowerEach = [];
    for iEQPLIST = 1:length(roomEquipSet{iROOM})
        % 機器リストを探査し、加熱容量を足す。
        check = 0;
        for iEQP = 1:length(equipID)
            if strcmp(roomEquipSet{iROOM}(iEQPLIST),equipID(iEQP))
                equipPowerEach = [equipPowerEach, equipPower(iEQP)*equipNum(iEQP)];
                equipPowerSum(iROOM) = equipPowerSum(iROOM) + equipPower(iEQP)*equipNum(iEQP);
                check = 1;
            end
        end
        if check == 0
            error('機器が見つかりません')
        end
    end
    
    % 容量比
    for iEQPLIST = 1:length(roomEquipSet{iROOM})
        roomPowerRatio(iROOM,iEQPLIST) = equipPowerEach(iEQPLIST)./equipPowerSum(iROOM);
    end
    
end


%% 機器のエネルギー消費量計算
L_eqp = zeros(length(equipID));
Qsr_eqp_daily = zeros(365,length(equipID));
Qs_eqp_daily  = zeros(365,length(equipID));
Qs_solargain  = zeros(365,length(equipID));
Qh_eqp_daily  = zeros(365,length(equipID));
Qp_eqp        = zeros(365,length(equipID));
E_eqp         = zeros(365,length(equipID));
connect_Name   = cell(length(equipID));
connect_Power  = cell(length(equipID));

for iEQP = 1:length(equipID)
    
    % 接続する室を探索
    tmpconnectName = {};
    tmpconnectPower = {};
    for iROOM = 1:length(roomName)
        for iEQPLIST = 1:length(roomEquipSet{iROOM})
            if strcmp(equipID(iEQP),roomEquipSet{iROOM}(iEQPLIST))
                % 標準日積算給湯量 [L/day]
                Qsr_eqp_daily(:,iEQP) = Qsr_eqp_daily(:,iEQP) + Qsr_daily(:,iROOM).*roomPowerRatio(iROOM,iEQPLIST);
                % 日積算給湯量 [L/day]
                Qs_eqp_daily(:,iEQP)  = Qs_eqp_daily(:,iEQP) + Qs_daily(:,iROOM).*roomPowerRatio(iROOM,iEQPLIST);
                % 室接続保存
                tmpconnectName = [tmpconnectName,roomName{iROOM}];
                tmpconnectPower = [tmpconnectPower,num2str(roomPowerRatio(iROOM,iEQPLIST))];
            end
        end
    end
    connect_Name{iEQP} = tmpconnectName;
    connect_Power{iEQP} = tmpconnectPower;
    
    % 太陽熱利用量（今後の課題）[KJ/day]
    Qs_solargain(:,iEQP) = zeros(365,1);
    
    % 給湯負荷 [kJ/day]
    Qh_eqp_daily(:,iEQP) = 4.2.*Qs_eqp_daily(:,iEQP).*(43-TWdata);
    
    % 配管長 [m]
    L_eqp(iEQP) = max(Qsr_eqp_daily(:,iEQP)).*7*0.001;
    
    % 配管熱損失 [kJ/day]
    for dd = 1:365
        if Qh_eqp_daily(dd,iEQP) > 0
            Qp_eqp(dd,iEQP) = L_eqp(iEQP).*ULL(iEQP).*(60-(OAdataAll(dd,1)+Troom(dd,1))/2)*24*3600*0.001;
        end
    end
    
    % 年間消費エネルギー消費量 [kJ/day]
    E_eqp(:,iEQP) = (Qh_eqp_daily(:,iEQP) + Qp_eqp(:,iEQP)*2.5 ) ./ equipEffi(iEQP);
    
end

% 給湯原単位 [MJ/m2年]
E_eqpSUM = sum(E_eqp)/1000;
E_eqpSUMperAREA = sum(sum(E_eqp))/sum(roomArea)/1000;



%% 結果出力

% 結果出力(仮)
RES0 = [];
for iROOM = 1:length(roomName)
    RES0 = [RES0,Qsr_daily(:,iROOM),Qs_save(:,iROOM),Qs_daily(:,iROOM)];
end
RES1 = [Troom,OAdataAll(:,1),TWdata,(OAdataAll(:,1)+Troom)/2];
RES2 = [];
for iEQP = 1:length(equipID)
    RES2 = [RES2,Qsr_eqp_daily(:,iEQP),Qs_eqp_daily(:,iEQP),Qs_solargain(:,iEQP),Qh_eqp_daily(:,iEQP),Qp_eqp(:,iEQP),E_eqp(:,iEQP),NaN*ones(365,1)];
end


% 出力するファイル名
if isempty(strfind(filename_HWroom,'/'))
    eval(['resfilenameD = ''calcRESdetail_',filename_HWroom(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(filename_HWroom,'/');
    eval(['resfilenameD = ''calcRESdetail_',filename_HWroom(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
end

% 結果格納用変数
rfc = {};

% 室別の給湯負荷
rfc = [rfc;'一次エネルギー消費量,'];
rfc = mytfunc_oneLinecCell(rfc,equipName);
rfc = mytfunc_oneLinecCell(rfc,E_eqpSUM);
rfc = mytfunc_oneLinecCell(rfc,sum(E_eqpSUM));
rfc = mytfunc_oneLinecCell(rfc,E_eqpSUMperAREA);

rfc = [rfc;'給湯負荷計算,'];

for iROOM = 1:length(roomName)
    
    tmproomWsave = {};
    if roomWsave(iROOM) == 1
        tmproomWsave = '有';
    else
        tmproomWsave = '無';
    end
    rfc = [rfc; strcat(roomName{iROOM},',',roomType{iROOM},',',num2str(roomArea(iROOM)),',',tmproomWsave)];
    
    rfc = mytfunc_oneLinecCell(rfc,Qsr_daily(:,iROOM)');
    rfc = mytfunc_oneLinecCell(rfc,Qs_save(:,iROOM)');
    rfc = mytfunc_oneLinecCell(rfc,Qs_daily(:,iROOM)');
end

rfc = [rfc;'エネルギー計算シート,'];

for iEQP = 1:length(equipID)
    
    rfc = [rfc; strcat(equipID{iEQP},',',equipName{iEQP})];
    
    % 室接続
    roomlist = [];
    for iROOM = 1:length(connect_Name{iEQP})
        roomlist = strcat(roomlist,connect_Name{iEQP}(iROOM),',');
    end
    rfc = [rfc;roomlist];
    
    ratiolist = [];
    for iROOM = 1:length(connect_Power{iEQP})
        ratiolist = strcat(ratiolist,connect_Power{iEQP}(iROOM),',');
    end
    rfc = [rfc;ratiolist];
    
    tmpequipInsulation = {};
    if equipInsulation(iEQP) == 1
        tmpequipInsulation = '保温仕様１';
    elseif equipInsulation(iEQP) == 2
        tmpequipInsulation = '保温仕様２';
    elseif equipInsulation(iEQP) == 3
        tmpequipInsulation = '保温仕様３';
    elseif equipInsulation(iEQP) == 4
        tmpequipInsulation = '裸管';
    end
    tmpequipSolar = {};
    if equipSolar(iEQP) == 1
        tmpequipSolar = '有';
    elseif equipSolar(iEQP) == 0
        tmpequipSolar = '無';
    end
    
    rfc = [rfc; strcat(num2str(equipNum(iEQP)),',',num2str(equipPower(iEQP)),',',num2str(equipEffi(iEQP)),...
        ',',num2str(equipPipeSize(iEQP)),',SUS,',tmpequipInsulation,',',tmpequipSolar)];
    rfc = mytfunc_oneLinecCell(rfc,Troom');
    rfc = mytfunc_oneLinecCell(rfc,OAdataAll(:,1)');
    rfc = mytfunc_oneLinecCell(rfc,TWdata');
    rfc = mytfunc_oneLinecCell(rfc,(OAdataAll(:,1)+Troom)'./2);
    rfc = mytfunc_oneLinecCell(rfc,Qsr_eqp_daily(:,iEQP)');
    rfc = mytfunc_oneLinecCell(rfc,Qs_eqp_daily(:,iEQP)');
    rfc = mytfunc_oneLinecCell(rfc,Qs_solargain(:,iEQP)');
    rfc = mytfunc_oneLinecCell(rfc,Qh_eqp_daily(:,iEQP)');
    rfc = mytfunc_oneLinecCell(rfc,Qp_eqp(:,iEQP)');
    rfc = mytfunc_oneLinecCell(rfc,E_eqp(:,iEQP)');
    
end

%% 出力
fid = fopen(resfilenameD,'w+');
for i=1:size(rfc,1)
    fprintf(fid,'%s\r\n',rfc{i});
end
fclose(fid);

