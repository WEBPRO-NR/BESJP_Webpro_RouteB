% mytfunc_csv2xml_EV.m
%                                             by Masato Miyata 2012/04/02
%------------------------------------------------------------------------
% 省エネ基準：昇降機設定ファイルを作成する。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_EV(xmldata,filename)

% データの読み込み
EVData = textread(filename,'%s','delimiter','\n','whitespace','');

% 空調室定義ファイルの読み込み
for i=1:length(EVData)
    conma = strfind(EVData{i},',');
    for j = 1:length(conma)
        if j == 1
            EVDataCell{i,j} = EVData{i}(1:conma(j)-1);
        elseif j == length(conma)
            EVDataCell{i,j}   = EVData{i}(conma(j-1)+1:conma(j)-1);
            EVDataCell{i,j+1} = EVData{i}(conma(j)+1:end);
        else
            EVDataCell{i,j} = EVData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 情報の抜出
roomFloor     = {};
roomName      = {};
EVName        = {};
EVCount       = {};
EVLoadLimit   = {};
EVVelocity    = {};
EVControlType = {};

for iUNIT = 11:size(EVDataCell,1)
    
    % 系統名称
    if isempty(EVDataCell{iUNIT,1})
        EVName  = [EVName;'Null'];
    else
        EVName  = [EVName;EVDataCell{iUNIT,1}];
    end
    
    % 台数
    EVCount = [EVCount;EVDataCell{iUNIT,2}];
    % 積載量
    EVLoadLimit = [EVLoadLimit;EVDataCell{iUNIT,3}];
    % 速度
    EVVelocity = [EVVelocity;EVDataCell{iUNIT,4}];
    
    % 速度制御方式
    if isempty(EVDataCell{iUNIT,5}) == 0
        EVControlType = [EVControlType;'EV_CT1'];
    elseif isempty(EVDataCell{iUNIT,6}) == 0
        EVControlType = [EVControlType;'EV_CT2'];
    elseif isempty(EVDataCell{iUNIT,7}) == 0
        EVControlType = [EVControlType;'EV_CT3'];
    elseif isempty(EVDataCell{iUNIT,8}) == 0
        EVControlType = [EVControlType;'EV_CT4'];
    elseif isempty(EVDataCell{iUNIT,9}) == 0
        EVControlType = [EVControlType;'EV_CT5'];
    else
        error('エレベータ：速度制御方式が不正です。')
    end
        
    if isempty(EVDataCell{iUNIT,10})
        roomFloor  = [roomFloor;'Null'];
    else
        roomFloor  = [roomFloor;EVDataCell{iUNIT,10}];
    end
    roomName = [roomName; EVDataCell{iUNIT,11}];
        
end

% XMLファイル生成
for iUNIT = 1:size(EVCount,1)
    
    eval(['xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.ID = ''EV_',int2str(iUNIT),''';'])
    
    % 室IDリスト    
    [RoomID,BldgType,RoomType,~,~,~,~,~] = ...
    mytfunc_roomIDsearch(xmldata,roomFloor{iUNIT},roomName{iUNIT});

    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.RoomIDs      = RoomID;
    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.RoomFloor    = roomFloor{iUNIT};
    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.RoomName     = roomName{iUNIT};
    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.BldgType     = BldgType;
    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.RoomType     = RoomType;
    
    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.Name        = EVName{iUNIT};
    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.Count       = EVCount{iUNIT};
    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.LoadLimit   = EVLoadLimit{iUNIT};
    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.Velocity    = EVVelocity{iUNIT};
    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.ControlType = EVControlType{iUNIT};
    
end
