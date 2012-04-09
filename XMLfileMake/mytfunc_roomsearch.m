function roomUD = mytfunc_roomsearch(xmldata,roomFloor,roomName)

roomNum = length(xmldata.Rooms.Room);
roomUD = {};

for iDB = 1:roomNum
    
    dbFloor = xmldata.Rooms.Room(iDB).ATTRIBUTE.Floor;
    dbName  = xmldata.Rooms.Room(iDB).ATTRIBUTE.Name;
    
   if strcmp(dbFloor,roomFloor) && strcmp(dbName,roomName)
       roomUD = xmldata.Rooms.Room(iDB).ATTRIBUTE.ID;
   end
    
end

if isempty(roomUD)
    roomFloor
    roomName
    error('Žº‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ')
end

