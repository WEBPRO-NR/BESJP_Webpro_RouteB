% mytfunc_csv2xml_HW_UnitList.m
%                                             by Masato Miyata 2012/08/24
%------------------------------------------------------------------------
% 省エネ基準：換気設定ファイルを作成する。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_HW_RoomList(xmldata,filename)

% 給湯室に関する情報
hwRoomInfoCell = mytfunc_CSVfile2Cell(filename);
% 
% hwRoomInfoCSV = textread(filename,'%s','delimiter','\n','whitespace','');
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

% 室名が空白であれば、ひとつ上の情報を埋める。
for iUNIT = 11:size(hwRoomInfoCell,1)
    if isempty(hwRoomInfoCell{iUNIT,2})
        if iUNIT ~= 1
            hwRoomInfoCell(iUNIT,1:5) = hwRoomInfoCell(iUNIT-1,1:5);
        else
            error('一つめの室名が空白です。')
        end
    end
end


%% 情報の抽出

roomFloor = {};
roomName  = {};
equipWaterSaving = {};
equipSet = {};
equipLocation = {};

for iUNIT = 11:size(hwRoomInfoCell,1)
    
    if isempty(hwRoomInfoCell{iUNIT,8}) == 0
        
        % 室名称
        roomFloor = [roomFloor; hwRoomInfoCell(iUNIT,1)];
        roomName  = [roomName; hwRoomInfoCell(iUNIT,2)];
        
        % 給湯箇所
        if isempty(hwRoomInfoCell{iUNIT,6}) == 0
            equipLocation = [equipLocation; hwRoomInfoCell(iUNIT,6)];
        else
            equipLocation = [equipLocation; 'Null'];
        end
        
        % 節湯器具の有無
        if isempty(hwRoomInfoCell{iUNIT,7}) == 0
            if strcmp(hwRoomInfoCell(iUNIT,7),'自動給湯栓')
                equipWaterSaving = [equipWaterSaving; 'MixingTap'];
            elseif strcmp(hwRoomInfoCell(iUNIT,7),'節湯B1')
                equipWaterSaving = [equipWaterSaving; 'B1'];
            elseif strcmp(hwRoomInfoCell(iUNIT,7),'無')
                equipWaterSaving = [equipWaterSaving; 'None'];
            else
                error('節湯器具の選択肢が不正です')
            end
        else
            equipWaterSaving = [equipWaterSaving; 'None'];
        end
        
        % 接続機器リスト
        equipSet = [equipSet;hwRoomInfoCell(iUNIT,8)];
        
    end
end

% 室を軸に並び替え
RoomList = {};
UnitNameList = {};
UnitLocationList = {};
UnitWSList = {};

for iUNIT = 1:size(roomName,1)
    
    if isempty(RoomList)
        
        RoomList = [RoomList; roomFloor(iUNIT),roomName(iUNIT)];
        UnitNameList = [UnitNameList; equipSet(iUNIT)];
        UnitLocationList = [UnitLocationList; equipLocation(iUNIT)];
        UnitWSList = [UnitWSList; equipWaterSaving(iUNIT)];
        
    else
        check = 0;
        for iDB = 1:size(RoomList,1)
            if strcmp(RoomList(iDB,1),roomFloor(iUNIT)) && ...
                    strcmp(RoomList(iDB,2),roomName(iUNIT))
                check = 1;
                
                UnitNameList{iDB} = [UnitNameList{iDB}, equipSet(iUNIT)];
                UnitLocationList{iDB} = [UnitLocationList{iDB}, equipLocation(iUNIT)];
                UnitWSList{iDB} = [UnitWSList{iDB}, equipWaterSaving(iUNIT)];
            end
        end
        
        % 室が見つからなければ追加
        if check == 0
            RoomList = [RoomList; roomFloor(iUNIT),roomName(iUNIT)];
            UnitNameList = [UnitNameList; equipSet(iUNIT)];
            UnitLocationList = [UnitLocationList; equipLocation(iUNIT)];
            UnitWSList = [UnitWSList; equipWaterSaving(iUNIT)];
        end
        
    end
end


% XMLファイル生成

numOfRoom = size(RoomList,1);

for iROOM = 1:numOfRoom
    
    [RoomID,BldgType,RoomType,RoomArea,~,~] = ...
        mytfunc_roomIDsearch(xmldata,RoomList(iROOM,1),RoomList(iROOM,2));
    
    xmldata.HotwaterSystems.HotwaterRoom(iROOM).ATTRIBUTE.RoomIDs      = RoomID;
    xmldata.HotwaterSystems.HotwaterRoom(iROOM).ATTRIBUTE.RoomFloor    = RoomList(iROOM,1);
    xmldata.HotwaterSystems.HotwaterRoom(iROOM).ATTRIBUTE.RoomName     = RoomList(iROOM,2);
    xmldata.HotwaterSystems.HotwaterRoom(iROOM).ATTRIBUTE.BuildingType = BldgType;
    xmldata.HotwaterSystems.HotwaterRoom(iROOM).ATTRIBUTE.RoomType     = RoomType;
    xmldata.HotwaterSystems.HotwaterRoom(iROOM).ATTRIBUTE.RoomArea     = RoomArea;
    
    % ユニット情報
    if iscell(UnitNameList{iROOM}) == 1
        unitNum = length(UnitNameList{iROOM});
    else
        unitNum = 1;
    end
       
    for iUNIT = 1:unitNum
        
        if unitNum == 1
            tmpUnitID = UnitNameList(iROOM,1);
            tmpUnitLO = UnitLocationList(iROOM,1);
            tmpUnitWS = UnitWSList(iROOM,1);
        else
            tmpUnitID = UnitNameList{iROOM}(iUNIT);
            tmpUnitLO = UnitLocationList{iROOM}(iUNIT);
            tmpUnitWS = UnitWSList{iROOM}(iUNIT);
        end
        
        xmldata.HotwaterSystems.HotwaterRoom(iROOM).BoilerRef(iUNIT).ATTRIBUTE.Name        = tmpUnitID;  % 機器名称
        xmldata.HotwaterSystems.HotwaterRoom(iROOM).BoilerRef(iUNIT).ATTRIBUTE.Location    = tmpUnitLO;  % 設置場所
        xmldata.HotwaterSystems.HotwaterRoom(iROOM).BoilerRef(iUNIT).ATTRIBUTE.WaterSaving = tmpUnitWS;  % 節水器具
    end
    
end



