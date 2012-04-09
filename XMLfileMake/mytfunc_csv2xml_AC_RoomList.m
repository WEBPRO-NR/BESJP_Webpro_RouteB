% mytfunc_csv2xml_AC_RoomList.m
%                                             by Masato Miyata 2012/02/12
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 室の設定ファイルを読み込む。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_AC_RoomList(xmldata,filename)

roomDefData = textread(filename,'%s','delimiter','\n','whitespace','');

% 空調室定義ファイルの読み込み
for i=1:length(roomDefData)
    conma = strfind(roomDefData{i},',');
    for j = 1:length(conma)
        if j == 1
            roomDefDataCell{i,j} = roomDefData{i}(1:conma(j)-1);
        elseif j == length(conma)
            roomDefDataCell{i,j}   = roomDefData{i}(conma(j-1)+1:conma(j)-1);
            roomDefDataCell{i,j+1} = roomDefData{i}(conma(j)+1:end);
        else
            roomDefDataCell{i,j} = roomDefData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 情報の抜出(まずは単純に抜き出す。空白行は直上の情報をコピーする)
ahuZoneName = {};
ahuZoneType = {};
ahuZoneFH   = [];
ahuZoneRH   = [];
ahuZoneArea = [];
ahuZoneQroom = {};
ahuZoneQoa   = {};

roomFloor = {};
roomName  = {};

count = 0;
for iRoom = 11:size(roomDefDataCell,1)
    
    % 空欄の場合は、直上をコピー(室の統合)
    if isempty(roomDefDataCell{iRoom,8}) && isempty(roomDefDataCell{iRoom,9})
        if iRoom == 11
            error('空調室定義：一番最初の空調ゾーンが空白です')
        else
            roomFloor{count,end+1} = roomDefDataCell{iRoom,1};
            roomName{count,end+1}  = roomDefDataCell{iRoom,2};
        end
    else
        
        count = count + 1;
        
        % 空調ゾーン名 (階数_室名)
        eval(['tmpname = ''',roomDefDataCell{iRoom,8},'_',roomDefDataCell{iRoom,9},''';'])
        ahuZoneName  = [ahuZoneName;tmpname];
        
        % 室負荷を処理する空調機
        ahuZoneQroom = [ahuZoneQroom; roomDefDataCell{iRoom,12}];
        % 外気負荷を処理する空調機
        ahuZoneQoa   = [ahuZoneQoa; roomDefDataCell{iRoom,13}];
        
        roomFloor{count,1} = roomDefDataCell{iRoom,1};
        roomName{count,1}  = roomDefDataCell{iRoom,2};
        
    end
end

% XMLファイル生成
for iZone = 1:size(ahuZoneName,1)
    
    % ID
    eval(['xmldata.AirConditioningSystem.AirConditioningRoom(iZone).ATTRIBUTE.ID  = ''Zone',int2str(iZone),''';'])
    
    tmpIDs = {};
    for iROOM = 1:length(roomName(iZone,:))
        if isempty(roomName{iZone,iROOM}) == 0
            tmpID = mytfunc_roomsearch(xmldata,roomFloor{iZone,iROOM},roomName{iZone,iROOM});
            if isempty(tmpIDs)
                tmpIDs = tmpID;
            else
                tmpIDs = strcat(tmpIDs,',',tmpID);
            end
        end
    end
    xmldata.AirConditioningSystem.AirConditioningRoom(iZone).ATTRIBUTE.RoomIDs         = tmpIDs;
    
    % 外皮ID（ゾーン名を入れる）
    xmldata.AirConditioningSystem.AirConditioningRoom(iZone).ATTRIBUTE.EnvelopeID  = ahuZoneName{iZone};
    
    % 空調機参照（室内負荷処理用）
    xmldata.AirConditioningSystem.AirConditioningRoom(iZone).AirHandlingUnitRef(1).ATTRIBUTE.Load = 'Room';
    xmldata.AirConditioningSystem.AirConditioningRoom(iZone).AirHandlingUnitRef(1).ATTRIBUTE.ID = ahuZoneQroom(iZone);
    % 空調機参照（外気処理用）
    xmldata.AirConditioningSystem.AirConditioningRoom(iZone).AirHandlingUnitRef(2).ATTRIBUTE.Load = 'OutsideAir';
    xmldata.AirConditioningSystem.AirConditioningRoom(iZone).AirHandlingUnitRef(2).ATTRIBUTE.ID = ahuZoneQoa(iZone);
    
end

