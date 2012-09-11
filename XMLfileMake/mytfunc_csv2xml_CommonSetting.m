% mytfunc_csv2xml_CommonSetting.m
%                                             by Masato Miyata 2012/04/02
%------------------------------------------------------------------------
% 省エネ基準：共通設定ファイルを作成する。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_CommonSetting(xmldata,filename)

% データの読み込み
commonData = textread(filename,'%s','delimiter','\n','whitespace','');

% 空調室定義ファイルの読み込み
for i=1:length(commonData)
    conma = strfind(commonData{i},',');
    for j = 1:length(conma)
        if j == 1
            commonDataCell{i,j} = commonData{i}(1:conma(j)-1);
        elseif j == length(conma)
            commonDataCell{i,j}   = commonData{i}(conma(j-1)+1:conma(j)-1);
            commonDataCell{i,j+1} = commonData{i}(conma(j)+1:end);
        else
            commonDataCell{i,j} = commonData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end


% 情報の抜出
roomFloor = {};
roomName  = {};
roomBuildingType = {};
roomRoomType  = {};
roomFloorHeight = {};
roomRoomHeight = {};
roomArea = {};
roomInfo = {};
roomcalcAC = {};
roomcalcL = {};
roomcalcV = {};
roomcalcHW = {};

for iRoom = 11:size(commonDataCell,1)
    
    if isempty(commonDataCell{iRoom,1}) && isempty(commonDataCell{iRoom,2})
        
%         eval(['disp(''空白行を飛ばします： ',filename,'　の ',int2str(iRoom),'行目'')'])
        
    else
        
        % 階数
        if isempty(commonDataCell{iRoom,1})
            roomFloor  = [roomFloor;'Null'];
        else
            roomFloor  = [roomFloor;commonDataCell{iRoom,1}];
        end
        
        % 室名
        roomName   = [roomName;commonDataCell{iRoom,2}];
        
        % 建物用途
        switch commonDataCell{iRoom,3}
            case '事務所等'
                roomBuildingType   = [roomBuildingType; 'Office'];
            case 'ホテル等'
                roomBuildingType   = [roomBuildingType; 'Hotel'];
            case '病院等'
                roomBuildingType   = [roomBuildingType; 'Hospital'];
            case {'物品販売業を営む店舗等','物販店舗等'}
                roomBuildingType   = [roomBuildingType; 'Store'];
            case '学校等'
                roomBuildingType   = [roomBuildingType; 'School'];
            case '飲食店等'
                roomBuildingType   = [roomBuildingType; 'Restaurant'];
            case '集会所等'
                roomBuildingType   = [roomBuildingType; 'MeetingPlace'];
            case '工場等'
                roomBuildingType   = [roomBuildingType; 'Factory'];
            otherwise
                error('建物用途 %s は無効です',commonDataCell{iRoom,3})
        end
        
        % 室用途
        roomRoomType = [roomRoomType;commonDataCell{iRoom,4}];
        
        % 室の面積
        if isempty(commonDataCell{iRoom,5})
            roomArea = [roomArea;'Null'];
        else
            roomArea = [roomArea;commonDataCell{iRoom,5}];
        end
        
        % 階高
        if isempty(commonDataCell{iRoom,6})
            roomFloorHeight = [roomFloorHeight;'Null'];
        else
            roomFloorHeight = [roomFloorHeight;commonDataCell{iRoom,6}];
        end
        
        % 天井高
        if isempty(commonDataCell{iRoom,7})
            roomRoomHeight = [roomRoomHeight;'Null'];
        else
            roomRoomHeight = [roomRoomHeight;commonDataCell{iRoom,7}];
        end
        
        % 計算対象
        if isempty(commonDataCell{iRoom,8})
            roomcalcAC = [roomcalcAC;'False'];
        else
            roomcalcAC = [roomcalcAC;'True'];
        end
        
        if isempty(commonDataCell{iRoom,9})
            roomcalcV = [roomcalcV;'False'];
        else
            roomcalcV = [roomcalcV;'True'];
        end
        
        if isempty(commonDataCell{iRoom,10})
            roomcalcL = [roomcalcL;'False'];
        else
            roomcalcL = [roomcalcL;'True'];
        end
        
        if isempty(commonDataCell{iRoom,11})
            roomcalcHW = [roomcalcHW;'False'];
        else
            roomcalcHW = [roomcalcHW;'True'];
        end
        
        % 備考
        if isempty(commonDataCell{iRoom,12})
            roomInfo = [roomInfo;'Null'];
        else
            roomInfo = [roomInfo;commonDataCell{iRoom,10}];
        end
        
    end
    
end


% XMLファイル生成
for iROOM = 1:size(roomName,1)
    
    eval(['xmldata.Rooms.Room(iROOM).ATTRIBUTE.ID = ''ROOM_',int2str(iROOM),''';'])
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.RoomFloor      = roomFloor{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.RoomName       = roomName{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.BuildingType   = roomBuildingType{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.RoomType       = roomRoomType{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.FloorHeight    = roomFloorHeight{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.RoomHeight     = roomRoomHeight{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.RoomArea       = roomArea{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.Info           = roomInfo{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.calcAC         = roomcalcAC{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.calcL          = roomcalcL{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.calcV          = roomcalcV{iROOM};
    xmldata.Rooms.Room(iROOM).ATTRIBUTE.calcHW         = roomcalcHW{iROOM};
    
end
