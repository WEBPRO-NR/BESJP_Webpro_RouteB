function [RoomID,BldgType,RoomType,RoomArea,FloorHeight,RoomHeight,RoomWidth,RoomDepth] = ...
    mytfunc_roomIDsearch(xmldata,roomFloor,roomName)

RoomID      = {};  % 室ID
BldgType    = {};  % 建物用途
RoomType    = {};  % 室用途
RoomArea    = [];  % 床面積
FloorHeight = [];  % 階高
RoomHeight  = [];  % 天井高
RoomWidth   = [];  % 間口
RoomDepth   = [];  % 奥行き

roomNum = length(xmldata.Rooms.Room);

for iDB = 1:roomNum
    
    dbFloor = xmldata.Rooms.Room(iDB).ATTRIBUTE.RoomFloor;
    dbName  = xmldata.Rooms.Room(iDB).ATTRIBUTE.RoomName;
    
    if strcmp(dbFloor,roomFloor) && strcmp(dbName,roomName)
        RoomID   = xmldata.Rooms.Room(iDB).ATTRIBUTE.ID;
        BldgType = xmldata.Rooms.Room(iDB).ATTRIBUTE.BuildingType;
        RoomType = xmldata.Rooms.Room(iDB).ATTRIBUTE.RoomType;
        RoomArea = xmldata.Rooms.Room(iDB).ATTRIBUTE.RoomArea;
        FloorHeight = xmldata.Rooms.Room(iDB).ATTRIBUTE.FloorHeight;  % 階高
        RoomHeight  = xmldata.Rooms.Room(iDB).ATTRIBUTE.RoomHeight;   % 天井高
        RoomWidth   = xmldata.Rooms.Room(iDB).ATTRIBUTE.RoomWidth;    % 間口
        RoomDepth   = xmldata.Rooms.Room(iDB).ATTRIBUTE.RoomDepth;    % 奥行き
    end
    
end

if isempty(RoomType)
    eval(['error(''mytfunc_roomIDsearch：室　',roomFloor,' : ', roomName ,'　が見つかりません'')'])
end
