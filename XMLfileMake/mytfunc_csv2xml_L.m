% mytfunc_csv2xml_L.m
%                                             by Masato Miyata 2012/04/21
%------------------------------------------------------------------------
% 省エネ基準：照明設定ファイルを作成する。
%------------------------------------------------------------------------
% 入力：
%  xmldata  : xmlデータ
%  filename : 照明の算定シート(CSV)ファイル名
% 出力：
%  xmldata  : xmlデータ
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_L(xmldata,filename)

% clear
% clc
% filename = '../InputFiles/省エネ基準ルートB_照明_template.csv';
% inputfilename = 'routeB_XMLtemplate.xml';
% xmldata = xml_read(inputfilename);
% xmldata = mytfunc_csv2xml_CommonSetting(xmldata,'../InputFiles/省エネ基準ルートB_共通_template.csv');


% CSVファイルの読み込み
LightData = textread(filename,'%s','delimiter','\n','whitespace','');

% 照明定義ファイルの読み込み
for i=1:length(LightData)
    conma = strfind(LightData{i},',');
    for j = 1:length(conma)
        if j == 1
            LightDataCell{i,j} = LightData{i}(1:conma(j)-1);
        elseif j == length(conma)
            LightDataCell{i,j}   = LightData{i}(conma(j-1)+1:conma(j)-1);
            LightDataCell{i,j+1} = LightData{i}(conma(j)+1:end);
        else
            LightDataCell{i,j} = LightData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 情報の抜出
roomFloor = {};
roomName  = {};
UnitID    = {};
LightRoomIndex = {};
LightUnitType = {};
LightUnitName = {};
LightPower = {};
LightCount = {};
LightControlFlag_C1 = {};
LightControlFlag_C2 = {};
LightControlFlag_C3 = {};
LightControlFlag_C4 = {};
LightControlFlag_C5 = {};

for iUNIT = 11:size(LightDataCell,1)
    
    % 器具ID
    eval(['UnitID = [UnitID; ''LUnit_',int2str(iUNIT-10),'''];'])
    
    % 階数と室名
    if isempty(LightDataCell{iUNIT,2})
        if iUNIT > 11
            roomFloor  = [roomFloor;roomFloor(end)];
            roomName   = [roomName;roomName(end)];
        else
            error('一つめの室名が空白です。')
        end
    else
        roomFloor = [roomFloor;LightDataCell{iUNIT,1}];
        roomName  = [roomName;LightDataCell{iUNIT,2}];
    end
    
    % 室指数
    if isempty(LightDataCell{iUNIT,9})
        LightRoomIndex  = [LightRoomIndex;'Null'];
    else
        LightRoomIndex  = [LightRoomIndex;LightDataCell{iUNIT,9}];
    end
    
    % 照明器具形式
    if isempty(LightDataCell{iUNIT,10})
        LightUnitType   = [LightUnitType;'Null'];
    else
        LightUnitType   = [LightUnitType;LightDataCell{iUNIT,10}];
    end
    
    % 照明器具名称
    if isempty(LightDataCell{iUNIT,11})
        LightUnitName   = [LightUnitName;'Null'];
    else
        LightUnitName   = [LightUnitName;LightDataCell(iUNIT,11)];
    end
    
    % 消費電力
    LightPower = [LightPower;str2double(LightDataCell(iUNIT,12))];
    
    % 台数
    LightCount = [LightCount;str2double(LightDataCell(iUNIT,13))];
    
    % 在室検知制御
    if strcmp(LightDataCell(iUNIT,14),'減光')
        LightControlFlag_C1 = [LightControlFlag_C1;'dimmer'];
    elseif strcmp(LightDataCell(iUNIT,14),'一括点滅')
        LightControlFlag_C1 = [LightControlFlag_C1;'onoff'];
    elseif strcmp(LightDataCell(iUNIT,14),'6.4m角点滅')
        LightControlFlag_C1 = [LightControlFlag_C1;'sensing64'];
    elseif strcmp(LightDataCell(iUNIT,14),'3.2m角点滅）')
        LightControlFlag_C1 = [LightControlFlag_C1;'sensing32'];
    elseif strcmp(LightDataCell(iUNIT,14),'器具毎点滅')
        LightControlFlag_C1 = [LightControlFlag_C1;'eachunit'];
    else
        LightControlFlag_C1 = [LightControlFlag_C1;'None'];
    end
    
    % タイムスケジュール制御
    if strcmp(LightDataCell(iUNIT,15),'減光')
        LightControlFlag_C2 = [LightControlFlag_C2;'dimmer'];
    elseif strcmp(LightDataCell(iUNIT,15),'消灯')
        LightControlFlag_C2 = [LightControlFlag_C2;'onoff'];
    else
        LightControlFlag_C2 = [LightControlFlag_C2;'None'];
    end
    
    % 初期照度補正
    if strcmp(LightDataCell(iUNIT,16),'タイマー')
        LightControlFlag_C3 = [LightControlFlag_C3;'Timer'];
    elseif strcmp(LightDataCell(iUNIT,16),'明るさセンサー')
        LightControlFlag_C3 = [LightControlFlag_C3;'Sensor'];
    else
        LightControlFlag_C3 = [LightControlFlag_C3;'None'];
    end
    
    % 昼光利用制御
    if strcmp(LightDataCell(iUNIT,17),'片側採光、ブラインド自動制御なし')
        LightControlFlag_C4 = [LightControlFlag_C4;'eachSideWithBlind'];
    elseif strcmp(LightDataCell(iUNIT,17),'片側採光、ブラインド自動制御あり')
        LightControlFlag_C4 = [LightControlFlag_C4;'eachSideWithoutBlind'];
    elseif strcmp(LightDataCell(iUNIT,17),'両側採光、ブラインド自動制御なし')
        LightControlFlag_C4 = [LightControlFlag_C4;'bothSidesWithBlind'];
    elseif strcmp(LightDataCell(iUNIT,17),'両側採光、ブラインド自動制御あり')
        LightControlFlag_C4 = [LightControlFlag_C4;'bothSidesWithoutBlind'];
    else
        LightControlFlag_C4 = [LightControlFlag_C4;'None'];
    end
    
    % 明るさ感知制御
    if strcmp(LightDataCell(iUNIT,18),'オンオフ制御')
        LightControlFlag_C5 = [LightControlFlag_C5;'dimmer'];
    else
        LightControlFlag_C5 = [LightControlFlag_C5;'None'];
    end
    
end

% 室を軸に並び替え
RoomList = {};
UnitList = {};

for iUNIT = 1:size(roomName,1)
    
    if strcmp(roomName(iUNIT),'Null') == 0
        
        if isempty(RoomList) == 1
            RoomList = [RoomList; roomFloor(iUNIT),roomName(iUNIT),LightRoomIndex(iUNIT)];
            UnitList = [UnitList; UnitID(iUNIT)];
        else
            check = 0;
            for iDB = 1:size(RoomList,1)
                if strcmp(RoomList(iDB,1),roomFloor(iUNIT)) &&...
                        strcmp(RoomList(iDB,2),roomName(iUNIT))
                    check = 1;
                    UnitList{iDB} = [UnitList{iDB}, UnitID(iUNIT)];
                end
            end
            
            % 室が見つからなければ追加
            if check == 0
                RoomList = [RoomList; roomFloor(iUNIT),roomName(iUNIT),LightRoomIndex(iUNIT)];
                UnitList = [UnitList; UnitID(iUNIT)];
            end
        end
        
    else
        error('室名称が不正です。')
    end
end

% XMLファイル生成

numOfRoom = size(RoomList,1);

for iROOM = 1:numOfRoom
    
    if strcmp(RoomList(iROOM,2),'Null') == 0
        
        % 室を検索
        [RoomID,BldgType,RoomType,RoomArea,~,RoomHeight,RoomWidth,RoomDepth] = ...
            mytfunc_roomIDsearch(xmldata,RoomList(iROOM,1),RoomList(iROOM,2));
        
        % 室の属性を格納
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomIDs    = RoomID;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomFloor  = RoomList(iROOM,1);
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomName   = RoomList(iROOM,2);
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.BldgType   = BldgType;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomType   = RoomType;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomArea   = RoomArea;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomHeight = RoomHeight;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomWidth  = RoomWidth;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomDepth  = RoomDepth;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomIndex  = RoomList(iROOM,3);
        
        % ユニット情報
        if iscell(UnitList{iROOM}) == 1
            unitNum = length(UnitList{iROOM});
        else
            unitNum = 1;
        end
        
        Count = 0;
        
        for iUNIT = 1:unitNum
            
            if unitNum == 1
                tmpUnitID = UnitList(iROOM);
            else
                tmpUnitID = UnitList{iROOM}(iUNIT);
            end
            
            % ユニットの情報を検索
            for iDB = 1:length(UnitID)
                if strcmp(UnitID(iDB),tmpUnitID)
 
                    Count = Count + 1;
       
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.ID              = UnitID(iDB);
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.UnitType        = LightUnitType{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.UnitName        = LightUnitName{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.Power           = LightPower{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.Count           = LightCount{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.ControlFlag_C1  = LightControlFlag_C1{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.ControlFlag_C2  = LightControlFlag_C2{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.ControlFlag_C3  = LightControlFlag_C3{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.ControlFlag_C4  = LightControlFlag_C4{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.ControlFlag_C5  = LightControlFlag_C5{iDB};
                    
                end
            end
        end
        
    end
end




