function [roomName,bldgType,roomType,roomArea] = mytfunc_roomIDsearch(model,roomID)

roomName = {};
roomType = {};
bldgType = {};
roomArea = [];

for iROOM = 1:length(model.Rooms.Room)
    if strcmp(model.Rooms.Room(iROOM).ATTRIBUTE.ID,roomID)
        roomName = model.Rooms.Room(iROOM).ATTRIBUTE.Name;
        roomType = model.Rooms.Room(iROOM).ATTRIBUTE.RoomType;
        bldgType = model.Rooms.Room(iROOM).ATTRIBUTE.BuildingType;
        roomArea = model.Rooms.Room(iROOM).ATTRIBUTE.Area;

    end
end

if isempty(roomArea)
    eval(['error(''mytfunc_roomIDsearchÅFé∫Å@',cell2mat(roomID),'Å@Ç™å©Ç¬Ç©ÇËÇ‹ÇπÇÒ'')'])
end
    