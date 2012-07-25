% mytfunc_csv2xml_Vfan_UnitList.m
%                                             by Masato Miyata 2012/04/02
%------------------------------------------------------------------------
% 省エネ基準：換気設定ファイルを作成する。
%------------------------------------------------------------------------
% 入力：
%  xmldata     : xmlデータ
%  filenameRoom : 換気（室）の算定シート(CSV)ファイル名
%  filenameFAN : 換気（送風機）の算定シート(CSV)ファイル名
%  filenameAC  : 換気（冷房）の算定シート(CSV)ファイル名
% 出力：
%  xmldata  : xmlデータ
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_V(xmldata,filenameRoom,filenameFAN,filenameAC)

% CSVファイルの読み込み
roomData  = textread(filenameRoom,'%s','delimiter','\n','whitespace','');
venData   = textread(filenameFAN,'%s','delimiter','\n','whitespace','');
venACData = textread(filenameAC,'%s','delimiter','\n','whitespace','');

% 換気（室）定義ファイルの読み込み
for i=1:length(roomData)
    conma = strfind(roomData{i},',');
    for j = 1:length(conma)
        if j == 1
            roomDataCell{i,j} = roomData{i}(1:conma(j)-1);
        elseif j == length(conma)
            roomDataCell{i,j}   = roomData{i}(conma(j-1)+1:conma(j)-1);
            roomDataCell{i,j+1} = roomData{i}(conma(j)+1:end);
        else
            roomDataCell{i,j} = roomData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

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

%% 換気（室）の処理
roomFloor = {};
roomName  = {};
unitType  = {};
unitName  = {};

% 空白セルを埋める
for iUNIT = 11:size(roomDataCell,1)
    
    if isempty(roomDataCell{iUNIT,2}) == 0
        roomFloor = [roomFloor; roomDataCell{iUNIT,1}];
        roomName  = [roomName; roomDataCell{iUNIT,2}];
        
        if strcmp(roomDataCell{iUNIT,6},'給気')
            unitType  = [unitType; 'Supply'];
        elseif strcmp(roomDataCell{iUNIT,6},'排気')
            unitType  = [unitType; 'Exist'];
        elseif strcmp(roomDataCell{iUNIT,6},'循環')
            unitType  = [unitType; 'Circulation'];
        elseif strcmp(roomDataCell{iUNIT,6},'冷房')
            unitType  = [unitType; 'AC'];
        else
            unitType  = [unitType; 'Null'];
        end
        
        unitName  = [unitName; roomDataCell{iUNIT,7}];
    else
        if iUNIT > 11
            roomFloor = [roomFloor; roomFloor(end)];
            roomName  = [roomName; roomName(end)];
            
            if isempty(roomDataCell{iUNIT,6})
                unitType  = [unitType; 'Null'];
            else
                if strcmp(roomDataCell{iUNIT,6},'給気')
                    unitType  = [unitType; 'Supply'];
                elseif strcmp(roomDataCell{iUNIT,6},'排気')
                    unitType  = [unitType; 'Exist'];
                elseif strcmp(roomDataCell{iUNIT,6},'循環')
                    unitType  = [unitType; 'Circulation'];
                elseif strcmp(roomDataCell{iUNIT,6},'冷房')
                    unitType  = [unitType; 'AC'];
                else
                    unitType  = [unitType; 'Null'];
                end
            end
            if isempty(roomDataCell{iUNIT,7})
                unitName  = [unitName; 'Null'];
            else
                unitName  = [unitName; roomDataCell{iUNIT,7}];
            end
            
        else
            error('1行目は必ず室名を入力してください。')
        end
    end
    
end

% 室リスト作成
RoomList = {};
UnitList = {};
UnitTypeList = {};

for iUNIT = 1:length(roomName)

    if isempty(RoomList) == 1
        RoomList     = [RoomList; roomFloor(iUNIT),roomName(iUNIT)];
        UnitTypeList = [UnitTypeList; unitType(iUNIT)];
        UnitList     = [UnitList; unitName(iUNIT)];
    else
        check = 0;
        for iDB = 1:size(RoomList,1)
            if strcmp(RoomList(iDB,1),roomFloor(iUNIT)) &&...
                    strcmp(RoomList(iDB,2),roomName(iUNIT))
                check = 1;
                UnitTypeList{iDB} = [UnitTypeList{iDB}, unitType(iUNIT)];
                UnitList{iDB}     = [UnitList{iDB}, unitName(iUNIT)];
            end
        end
        
        % 室が見つからなければ追加
        if check == 0
            RoomList     = [RoomList; roomFloor(iUNIT),roomName(iUNIT)];
            UnitTypeList = [UnitTypeList; unitType(iUNIT)];
            UnitList     = [UnitList; unitName(iUNIT)];
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

numRoom = (size(venDataCell,2)-9)/2;

for iUNIT = 11:size(venDataCell,1)
    
    eval(['venUnitID = [venUnitID; ''VfanUnit_',int2str(iUNIT-10),'''];'])
    
    % 器具名称
    if isempty(venDataCell{iUNIT,1})
        venUnitName  = [venUnitName;'Null'];
    else
        venUnitName  = [venUnitName;venDataCell{iUNIT,1}];
    end
    
    % 風量
    if isempty(venDataCell{iUNIT,2})
        venVolume  = [venVolume;'Null'];
    else
        venVolume  = [venVolume;venDataCell{iUNIT,2}];
    end
    
    % 消費電力
    venPower = [venPower;venDataCell{iUNIT,3}];
    
    % 高効率電動機採用
    if strcmp(venDataCell{iUNIT,4},'有')
        venControlFlag_C1 = [venControlFlag_C1;'True'];
    else
        venControlFlag_C1 = [venControlFlag_C1;'None'];
    end
    
    % インバータ採用
    if strcmp(venDataCell{iUNIT,5},'有')
        venControlFlag_C2 = [venControlFlag_C2;'True'];
    else
        venControlFlag_C2 = [venControlFlag_C2;'None'];
    end
    
    % 送風量制御
    if strcmp(venDataCell{iUNIT,6},'CO濃度制御')
        venControlFlag_C3 = [venControlFlag_C3;'COconcentration'];
    elseif strcmp(venDataCell{iUNIT,6},'温度制御')
        venControlFlag_C3 = [venControlFlag_C3;'Temprature'];
    else
        venControlFlag_C3 = [venControlFlag_C3;'None'];
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
    if isempty(venACDataCell{iUNIT,4})
        venACFanPower  = [venACFanPower;'0'];
    else
        venACFanPower  = [venACFanPower;venACDataCell{iUNIT,4}];
    end
    
    % ポンプ動力
    if isempty(venACDataCell{iUNIT,5})
        venACPumpPower  = [venACPumpPower;'0'];
    else
        venACPumpPower  = [venACPumpPower;venACDataCell{iUNIT,5}];
    end    

end



%% XMLファイル生成
for iROOM = 1:size(RoomList,1)
    
    % 室を検索
    [RoomID,BldgType,RoomType,RoomArea,~,~] = ...
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
            tmpUnitID   = UnitList(iROOM);
            tmpUnitType = UnitTypeList(iROOM);
        else
            tmpUnitID = UnitList{iROOM}(iUNIT);
            tmpUnitType = UnitTypeList{iROOM}(iUNIT);
        end
        
        % ユニットの情報を検索
        check = 0;
        for iDB = 1:length(venUnitName)
            if strcmp(venUnitName(iDB),tmpUnitID)
                
                check = 1;
                Fcount = Fcount + 1;
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.ID              = venUnitID{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.UnitName        = venUnitName{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.UnitType        = tmpUnitType;
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.FanVolume       = venVolume{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.FanPower        = venPower{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.ControlFlag_C1  = venControlFlag_C1{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.ControlFlag_C2  = venControlFlag_C2{iDB};
                xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationFANUnit(Fcount).ATTRIBUTE.ControlFlag_C3  = venControlFlag_C3{iDB};
                
            end
        end
        if check == 0
            for iDB = 1:length(venACUnitName)
                if strcmp(venACUnitName(iDB),tmpUnitID)
                    
                    check = 1;
                    Acount = Acount + 1;
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.ID               = venACUnitID{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.UnitName         = venACUnitName{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.CoolingCapacity  = venACCoolingCapacity{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.COP              = venACCOP{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.FanPower         = venACFanPower{iDB};
                    xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationACUnit(Acount).ATTRIBUTE.PumpPower        = venACPumpPower{iDB};

                end
            end

            if check == 0
                error('ユニット %s が見つかりません', tmpUnitID)
            end
        end
    end
end

