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

% CSVファイルの読み込み
LightDataCell = mytfunc_CSVfile2Cell(filename);

% 情報の抜出
roomFloor = {};
roomName  = {};
UnitID    = {};
LightRoomIndex = {};
LightUnitType = {};
LightUnitName = {};
LightPower = {};
LightCount = {};
LightRoomDepth = {};
LightRoomWidth = {};
LightControlFlag_C1 = {};
LightControlFlag_C2 = {};
LightControlFlag_C3 = {};
LightControlFlag_C4 = {};
LightControlFlag_C5 = {};
LightControlFlag_C6 = {};

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

    % 間口
    if isempty(LightDataCell{iUNIT,8})
        LightRoomWidth   = [LightRoomWidth;'Null'];
    else
        LightRoomWidth   = [LightRoomWidth;LightDataCell{iUNIT,8}];
    end
    
    % 奥行き
    if isempty(LightDataCell{iUNIT,9})
        LightRoomDepth   = [LightRoomDepth;'Null'];
    else
        LightRoomDepth   = [LightRoomDepth;LightDataCell{iUNIT,9}];
    end
    
    % 室指数
    if isempty(LightDataCell{iUNIT,10})
        LightRoomIndex  = [LightRoomIndex;'Null'];
    else
        LightRoomIndex  = [LightRoomIndex;LightDataCell{iUNIT,10}];
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
    
    % 在室検知制御（Ver2から選択肢変更）
    if isempty(LightDataCell{iUNIT,14}) == 0
        if strcmp(LightDataCell(iUNIT,14),'減光方式')
            LightControlFlag_C1 = [LightControlFlag_C1;'dimmer'];
        elseif strcmp(LightDataCell(iUNIT,14),'点滅方式')
            LightControlFlag_C1 = [LightControlFlag_C1;'onoff'];
        elseif strcmp(LightDataCell(iUNIT,14),'下限調光方式')
            LightControlFlag_C1 = [LightControlFlag_C1;'limitedVariable'];
        elseif strcmp(LightDataCell(iUNIT,14),'無')
            LightControlFlag_C1 = [LightControlFlag_C1;'None'];
        else
            error('照明制御C1: 不正な選択肢です')
        end
    else
        LightControlFlag_C1 = [LightControlFlag_C1;'None'];
    end
    
    % 明るさ検知制御（Ver2から選択肢変更、Ver.2.4で更に追加）
    if isempty(LightDataCell{iUNIT,15}) == 0
        if strcmp(LightDataCell(iUNIT,15),'調光方式')
            LightControlFlag_C2 = [LightControlFlag_C2;'variable'];
        elseif strcmp(LightDataCell(iUNIT,15),'調光方式(自動制御ブラインド併用)')
            LightControlFlag_C2 = [LightControlFlag_C2;'variableWithBlind'];
            
        elseif strcmp(LightDataCell(iUNIT,15),'調光方式BL')
            LightControlFlag_C2 = [LightControlFlag_C2;'variableWithBlind'];
        elseif strcmp(LightDataCell(iUNIT,15),'調光方式W15')
            LightControlFlag_C2 = [LightControlFlag_C2;'variable_W15'];
        elseif strcmp(LightDataCell(iUNIT,15),'調光方式W15BL')
            LightControlFlag_C2 = [LightControlFlag_C2;'variable_W15_WithBlind'];
        elseif strcmp(LightDataCell(iUNIT,15),'調光方式W20')
            LightControlFlag_C2 = [LightControlFlag_C2;'variable_W20'];
        elseif strcmp(LightDataCell(iUNIT,15),'調光方式W20BL')
            LightControlFlag_C2 = [LightControlFlag_C2;'variable_W20_WithBlind'];
        elseif strcmp(LightDataCell(iUNIT,15),'調光方式W25')
            LightControlFlag_C2 = [LightControlFlag_C2;'variable_W25'];
        elseif strcmp(LightDataCell(iUNIT,15),'調光方式W25BL')
            LightControlFlag_C2 = [LightControlFlag_C2;'variable_W25_WithBlind'];
            
        elseif strcmp(LightDataCell(iUNIT,15),'点滅方式')
            LightControlFlag_C2 = [LightControlFlag_C2;'onoff'];
        elseif strcmp(LightDataCell(iUNIT,15),'無')
            LightControlFlag_C2 = [LightControlFlag_C2;'None'];
            
        else
            error('照明制御C2: 不正な選択肢です')
        end
    else
        LightControlFlag_C2 = [LightControlFlag_C2;'None'];
    end
    
    
    % タイムスケジュール制御
    if isempty(LightDataCell{iUNIT,16}) == 0
        if strcmp(LightDataCell(iUNIT,16),'減光方式')
            LightControlFlag_C3 = [LightControlFlag_C3;'dimmer'];
        elseif strcmp(LightDataCell(iUNIT,16),'点滅方式')
            LightControlFlag_C3 = [LightControlFlag_C3;'onoff'];
        elseif strcmp(LightDataCell(iUNIT,16),'無')
            LightControlFlag_C3 = [LightControlFlag_C3;'None'];
        else
            error('照明制御C3: 不正な選択肢です')
        end
    else
        LightControlFlag_C3 = [LightControlFlag_C3;'None'];
    end
    
    % 初期照度補正機能
    if isempty(LightDataCell{iUNIT,17}) == 0
        if strcmp(LightDataCell(iUNIT,17),'タイマ方式(LED)')
            LightControlFlag_C4 = [LightControlFlag_C4;'timerLED'];
        elseif strcmp(LightDataCell(iUNIT,17),'タイマ方式(蛍光灯)')
            LightControlFlag_C4 = [LightControlFlag_C4;'timerFLU'];
        elseif strcmp(LightDataCell(iUNIT,17),'センサ方式(LED)')
            LightControlFlag_C4 = [LightControlFlag_C4;'sensorLED'];
        elseif strcmp(LightDataCell(iUNIT,17),'センサ方式(蛍光灯)')
            LightControlFlag_C4 = [LightControlFlag_C4;'sensorFLU'];
        elseif strcmp(LightDataCell(iUNIT,17),'無')
            LightControlFlag_C4 = [LightControlFlag_C4;'False'];
        else
            error('照明制御C4: 不正な選択肢です')
        end
    else
        LightControlFlag_C4 = [LightControlFlag_C4;'False'];
    end
    
end

% 室を軸に並び替え
RoomList = {};
UnitList = {};

for iUNIT = 1:size(roomName,1)
    
    if strcmp(roomName(iUNIT),'Null') == 0
        
        if isempty(RoomList) == 1
            RoomList = [RoomList; roomFloor(iUNIT),roomName(iUNIT),...
                LightRoomIndex(iUNIT),LightRoomDepth(iUNIT),LightRoomWidth(iUNIT)];
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
                RoomList = [RoomList; roomFloor(iUNIT),roomName(iUNIT),...
                    LightRoomIndex(iUNIT),LightRoomDepth(iUNIT),LightRoomWidth(iUNIT)];
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
        [RoomID,BldgType,RoomType,RoomArea,~,RoomHeight] = ...
            mytfunc_roomIDsearch(xmldata,RoomList(iROOM,1),RoomList(iROOM,2));
        
        % 室の属性を格納
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomIDs    = RoomID;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomFloor  = RoomList(iROOM,1);
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomName   = RoomList(iROOM,2);
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.BldgType   = BldgType;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomType   = RoomType;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomArea   = RoomArea;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomHeight = RoomHeight;
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomIndex  = RoomList(iROOM,3);
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomWidth  = RoomList(iROOM,5);
        xmldata.LightingSystems.LightingRoom(iROOM).ATTRIBUTE.RoomDepth  = RoomList(iROOM,4);
        
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
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.UnitName        = LightUnitName{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.Power           = LightPower{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.Count           = LightCount{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.ControlFlag_C1  = LightControlFlag_C1{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.ControlFlag_C2  = LightControlFlag_C2{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.ControlFlag_C3  = LightControlFlag_C3{iDB};
                    xmldata.LightingSystems.LightingRoom(iROOM).LightingUnit(Count).ATTRIBUTE.ControlFlag_C4  = LightControlFlag_C4{iDB};
                    
                end
            end
        end
        
    end
end




