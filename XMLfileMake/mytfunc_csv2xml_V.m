% mytfunc_csv2xml_Vfan_UnitList.m
%                                             by Masato Miyata 2012/04/02
%------------------------------------------------------------------------
% 省エネ基準：換気設定ファイルを作成する。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_V_UnitList(xmldata,filenameFAN,filenameAC)

% filenameFAN = '省エネ基準ルートB_換気_送風機_template.csv';
% filenameAC  = '省エネ基準ルートB_換気_冷暖房_template.csv';

% データの読み込み（送風機）
venData   = textread(filenameFAN,'%s','delimiter','\n','whitespace','');
venACData = textread(filenameAC,'%s','delimiter','\n','whitespace','');

% 換気（送風機）定義ファイルの読み込み
for i=1:length(venData)
    conma = strfind(venData{i},',');
    for j = 1:length(conma)
        if j == 1
            venDataCell{i,j} = venData{i}(1:conma(j)-1);
        elseif j == length(conma)
            venDataCell{i,j}   = venData{i}(conma(j-1)+1:conma(j)-1);
            venDataCell{i,j+1} = venData{i}(conma(j)+1:end);
        else
            venDataCell{i,j} = venData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 換気（空調機）定義ファイルの読み込み
for i=1:length(venACData)
    conma = strfind(venACData{i},',');
    for j = 1:length(conma)
        if j == 1
            venACDataCell{i,j} = venACData{i}(1:conma(j)-1);
        elseif j == length(conma)
            venACDataCell{i,j}   = venACData{i}(conma(j-1)+1:conma(j)-1);
            venACDataCell{i,j+1} = venACData{i}(conma(j)+1:end);
        else
            venACDataCell{i,j} = venACData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end


%% 換気（送風機）の処理

venUnitID   = {};
venUnitName = {};
venUnitType = {};
venVolume   = {};
venPower    = {};
venControlFlag_C1 = {};
venControlFlag_C2 = {};
venControlFlag_C3 = {};
venCount  = {};
roomFloor = {};
roomName  = {};

numRoom = (size(venDataCell,2)-9)/2;

for iUNIT = 11:size(venDataCell,1)
    
    eval(['venUnitID = [venUnitID; ''VfanUnit_',int2str(iUNIT-10),'''];'])
    
    % 器具名称
    if isempty(venDataCell{iUNIT,1})
        venUnitName  = [venUnitName;'Null'];
    else
        venUnitName  = [venUnitName;venDataCell{iUNIT,1}];
    end
    
    % 方式
    if strcmp(venDataCell{iUNIT,2},'給気')
        venUnitType  = [venUnitType;'Supply'];
    elseif strcmp(venDataCell{iUNIT,2},'排気')
        venUnitType  = [venUnitType;'Exist'];
    else
        venDataCell{iUNIT,2}
        error('換気種類が不正です')
    end
    
    % 風量
    if isempty(venDataCell{iUNIT,8})
        venVolume  = [venVolume;'Null'];
    else
        venVolume  = [venVolume;venDataCell{iUNIT,3}];
    end
    
    % 消費電力
    venPower = [venPower;venDataCell{iUNIT,4}];
    
    % 台数
    venCount = [venCount;venDataCell{iUNIT,9}];
    
    % 高効率電動機採用
    if isempty(venDataCell{iUNIT,5}) == 0
        venControlFlag_C1 = [venControlFlag_C1;'True'];
    else
        venControlFlag_C1 = [venControlFlag_C1;'None'];
    end
    
    % インバータ採用
    if isempty(venDataCell{iUNIT,6}) == 0
        venControlFlag_C2 = [venControlFlag_C2;'True'];
    else
        venControlFlag_C2 = [venControlFlag_C2;'None'];
    end
    
    % 送風量制御
    if isempty(venDataCell{iUNIT,7}) == 0
        venControlFlag_C3 = [venControlFlag_C3;'COconcentration'];
    elseif isempty(venDataCell{iUNIT,8}) == 0
        venControlFlag_C3 = [venControlFlag_C3;'Temprature'];
    else
        venControlFlag_C3 = [venControlFlag_C3;'None'];
    end
    
    tmpFloor = {};
    tmpName = {};
    for iROOM = 1:numRoom
        n1 = 9 + 2*(iROOM-1) + 1;
        n2 = 9 + 2*(iROOM-1) + 2;
        if isempty(venDataCell{iUNIT,n2})
            tmpFloor = [tmpFloor, 'Null'];
            tmpName  = [tmpName, 'Null'];
        else
            tmpFloor = [tmpFloor, venDataCell{iUNIT,n1}];
            tmpName  = [tmpName, venDataCell{iUNIT,n2}];
        end
    end
    
    % 接続室
    roomFloor(iUNIT-10,:) = tmpFloor;
    roomName(iUNIT-10,:)  = tmpName;
    
end

% 室を軸に並び替え
RoomList = {};
UnitList = {};

for iUNIT = 1:size(roomName,1)
    for iROOMy = 1:size(roomName,2)
        
        % 検索する室の「階」と「名称」
        tmpRoomFloor = roomFloor(iUNIT,iROOMy);
        tmpRoomName  = roomName(iUNIT,iROOMy);
        
        if strcmp(tmpRoomName,'Null') == 0
            
            if isempty(RoomList) == 1
                RoomList = [RoomList; tmpRoomFloor,tmpRoomName];
                UnitList = [UnitList; venUnitID(iUNIT)];
            else
                check = 0;
                for iDB = 1:size(RoomList,1)
                    if strcmp(RoomList(iDB,1),tmpRoomFloor) && ...
                            strcmp(RoomList(iDB,2),tmpRoomName)
                        
                        check = 1;
                        UnitList{iDB} = [UnitList{iDB},venUnitID(iUNIT)];
                        
                    end
                end
                
                % 室が見つからなければ新規追加
                if check == 0
                    RoomList = [RoomList; tmpRoomFloor,tmpRoomName];
                    UnitList = [UnitList; venUnitID(iUNIT)];
                end
                
            end
        end
        
    end
end


%% 換気（空調機）の処理

% 情報の抜出
venACUnitID   = {};
venACUnitName = {};
venACCoolingCapacity = {};
venACCOP        = {};
venACFanPower   = {};
venACPumpPower  = {};
venACCount  = {};
roomFloorAC = {};
roomNameAC  = {};

numRoomAC = (size(venACDataCell,2)-7)/2;

for iUNIT = 11:size(venACDataCell,1)
    
    eval(['venACUnitID = [venACUnitID; ''VacUnit_',int2str(iUNIT-10),'''];'])
    
    % 器具名称
    if isempty(venACDataCell{iUNIT,1})
        venACUnitName  = [venACUnitName;'Null'];
    else
        venACUnitName  = [venACUnitName;venACDataCell{iUNIT,1}];
    end
    
    % 冷却能力
    if isempty(venACDataCell{iUNIT,2})
        venACCoolingCapacity  = [venACCoolingCapacity;'Null'];
    else
        venACCoolingCapacity  = [venACCoolingCapacity;venACDataCell{iUNIT,2}];
    end
    
    % COP
    if isempty(venACDataCell{iUNIT,3})
        venACCOP  = [venACCOP;'Null'];
    else
        venACCOP  = [venACCOP;venACDataCell{iUNIT,3}];
    end
    
    % 送風機動力
    if isempty(venACDataCell{iUNIT,5})
        venACFanPower  = [venACFanPower;'0'];
    else
        venACFanPower  = [venACFanPower;venACDataCell{iUNIT,5}];
    end
    
    % ポンプ動力
    if isempty(venACDataCell{iUNIT,6})
        venACPumpPower  = [venACPumpPower;'0'];
    else
        venACPumpPower  = [venACPumpPower;venACDataCell{iUNIT,6}];
    end
    
    % 台数
    venACCount = [venACCount;venACDataCell{iUNIT,7}];
    
    tmpFloor = {};
    tmpName = {};
    for iROOM = 1:numRoomAC
        n1 = 7 + 2*(iROOM-1) + 1;
        n2 = 7 + 2*(iROOM-1) + 2;
        if isempty(venACDataCell{iUNIT,n2})
            tmpFloor = [tmpFloor, 'Null'];
            tmpName  = [tmpName, 'Null'];
        else
            tmpFloor = [tmpFloor, venACDataCell{iUNIT,n1}];
            tmpName  = [tmpName, venACDataCell{iUNIT,n2}];
        end
    end
    
    roomFloorAC(iUNIT-10,:) = tmpFloor;
    roomNameAC(iUNIT-10,:)  = tmpName;
    
end

% 室を軸に並び替え
RoomListAC = {};
UnitListAC = {};

for iUNIT = 1:size(roomNameAC,1)
    for iROOMy = 1:size(roomNameAC,2)
        
        % 検索する室の「階」と「名称」
        tmpRoomFloor = roomFloorAC(iUNIT,iROOMy);
        tmpRoomName  = roomNameAC(iUNIT,iROOMy);
        
        if strcmp(tmpRoomName,'Null') == 0
            
            if isempty(RoomList) == 1
                RoomList = [RoomList; tmpRoomFloor,tmpRoomName];
                UnitList = [UnitList; venACUnitID(iUNIT)];
            else
                check = 0;
                for iDB = 1:size(RoomList,1)
                    if strcmp(RoomList(iDB,1),tmpRoomFloor) && ...
                            strcmp(RoomList(iDB,2),tmpRoomName)
                        
                        check = 1;
                        UnitList{iDB} = [UnitList{iDB},venACUnitID(iUNIT)];
                        
                    end
                end
                
                % 室が見つからなければ新規追加
                if check == 0
                    RoomList = [RoomList; tmpRoomFloor,tmpRoomName];
                    UnitList = [UnitList; venACUnitID(iUNIT)];
                end
                
            end
        end
    end
end


%% XMLファイル生成
for iROOM = 1:size(RoomList,1)
    
    % 室を検索
    [RoomID,BldgType,RoomType,RoomArea,~,~,~,~] = ...
        mytfunc_roomIDsearch(xmldata,RoomList{iROOM,1},RoomList{iROOM,2});
    
    % 室の属性を格納
    xmldata.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.RoomIDs      = RoomID;
    xmldata.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.RoomFloor    = RoomList{iROOM,1};
    xmldata.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.RoomName     = RoomList{iROOM,2};
    xmldata.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.BuildingType = BldgType;
    xmldata.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.RoomType     = RoomType;
    xmldata.VentilationSystems.VentilationRoom(iROOM).ATTRIBUTE.RoomArea     = RoomArea;
    
    % ユニット数をカウント
    if iscell(UnitList{iROOM}) == 1
        unitNum = length(UnitList{iROOM});
    else
        unitNum = 1;
    end
    
    Fcount = 0;
    Acount = 0;
    
    for iUNIT = 1:unitNum
        if unitNum == 1
            tmpUnitID = UnitList(iROOM);
        else
            tmpUnitID = UnitList{iROOM}(iUNIT);
        end
        
        % ユニットの情報を検索
        check = 0;
        for iDB = 1:length(venUnitID)
            if strcmp(venUnitID(iDB),tmpUnitID)
                
                check = 1;
                Fcount = Fcount + 1;
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.ID              = venUnitID{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.UnitName        = venUnitName{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.UnitType        = venUnitType{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.FanVolume       = venVolume{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.FanPower        = venPower{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.ControlFlag_C1  = venControlFlag_C1{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.ControlFlag_C2  = venControlFlag_C2{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.ControlFlag_C3  = venControlFlag_C3{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.Count           = venCount{iDB};
                
            end
        end
        if check == 0
            for iDB = 1:length(venACUnitID)
                if strcmp(venACUnitID(iDB),tmpUnitID)
                    
                    check = 1;
                    Acount = Acount + 1;
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.ID               = venACUnitID{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.UnitName         = venACUnitName{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.CoolingCapacity  = venACCoolingCapacity{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.COP              = venACCOP{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.FanPower         = venACFanPower{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.PumpPower        = venACPumpPower{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.Count            = venACCount{iDB};

                end
            end

            if check == 0
                error('ユニットが見つかりません')
            end
        end
    end
end

