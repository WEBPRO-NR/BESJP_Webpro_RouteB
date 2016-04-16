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
    
    if isempty(roomDataCell{iUNIT,7}) == 0
        
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
                
                % 換気種類
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
                
                % 換気機機名称
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

venUnitName = {};
venVolume   = {};
venPower    = {};
venControlFlag_C1 = {};
venControlFlag_C2 = {};
venControlFlag_C3 = {};

for iUNIT = 11:size(venDataCell,1)
    
    if isempty(venDataCell{iUNIT,1}) == 0
        
        % 器具名称
        venUnitName  = [venUnitName;venDataCell{iUNIT,1}];
        
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
    
end


%% 換気（空調機）の処理

% 情報の抜出
venACUnitName = {};
venACroomType = {};  % 2016/4/13 追加
venACCoolingCapacity = {};
venACCOP        = {};
venACFanPower   = {};
venACPumpPower  = {};

ACnum = 0;

for iUNIT = 11:size(venACDataCell,1)
        
    if isempty(venACDataCell{iUNIT,1}) == 0
        
        ACnum = ACnum + 1;
        
        % 器具名称
        venACUnitName{ACnum,1} = venACDataCell{iUNIT,1};
        
        % 換気対象室の用途
        if strcmp(venACDataCell{iUNIT,2},'エレベータ機械室')
            venACroomType{ACnum,1} = 'elevator';
        elseif strcmp(venACDataCell{iUNIT,2},'電気室')
            venACroomType{ACnum,1} = 'powerRoom';
        elseif strcmp(venACDataCell{iUNIT,2},'機械室')
            venACroomType{ACnum,1} = 'machineRoom';
        else
            venACroomType{ACnum,1} = 'others';
        end
        
        % 冷却能力
        if isempty(venACDataCell{iUNIT,3})
            venACCoolingCapacity{ACnum,1}  = 'Null';
        else
            venACCoolingCapacity{ACnum,1}  = venACDataCell{iUNIT,3};
        end
        
        % COP
        if isempty(venACDataCell{iUNIT,4})
            venACCOP{ACnum,1}  = 'Null';
        else
            venACCOP{ACnum,1}  = venACDataCell{iUNIT,4};
        end
        
        % ポンプ動力
        if isempty(venACDataCell{iUNIT,5})
            venACPumpPower{ACnum,1}  = 'Null';
        else
            venACPumpPower{ACnum,1}  = venACDataCell{iUNIT,5};
        end
        
        
        % ファンが何台あるかを調べる
        for iFan = 1 : size(venACDataCell,1)
            if iUNIT + iFan > size(venACDataCell,1) 
                break
            end
            if isempty(venACDataCell{iUNIT+iFan,1}) == 0
                break
            end
        end
        venACfanNUM(ACnum) = iFan;
        
        for iFan = 1:venACfanNUM(ACnum)
            
            % 送風機 の 種類
            if strcmp(venACDataCell{iUNIT+iFan-1,6},'空調')
                venACFanType{ACnum,iFan} = 'AC';
            elseif strcmp(venACDataCell{iUNIT+iFan-1,6},'給気')
                venACFanType{ACnum,iFan} = 'Supply';
            elseif strcmp(venACDataCell{iUNIT+iFan-1,6},'排気')
                venACFanType{ACnum,iFan} = 'Exist';
            elseif strcmp(venACDataCell{iUNIT+iFan-1,6},'循環')
                venACFanType{ACnum,iFan} = 'Circulation';
            else
                venACFanType{ACnum,iFan} = 'Null';
            end
            
            % 送風機 の 設計風量
            if isempty(venACDataCell{iUNIT+iFan-1,7})
                venACFanVolume{ACnum,iFan} = 'Null';
            else
                venACFanVolume{ACnum,iFan} = venACDataCell{iUNIT+iFan-1,7};
            end
            
            % 送風機 の 電動機出力
            if isempty(venACDataCell{iUNIT+iFan-1,8})
                venACFanPower{ACnum,iFan} = 'Null';
            else
                venACFanPower{ACnum,iFan} = venACDataCell{iUNIT+iFan-1,8};
            end
            
            % 送風機 の 高効率電動機の有無
            if strcmp(venACDataCell{iUNIT+iFan-1,9},'有')
                venACFanControlFlag_C1{ACnum,iFan} = 'True';
            else
                venACFanControlFlag_C1{ACnum,iFan} = 'None';
            end
            
            % 送風機 の インバータの有無
            if strcmp(venACDataCell{iUNIT+iFan-1,10},'有')
                venACFanControlFlag_C2{ACnum,iFan} = 'True';
            else
                venACFanControlFlag_C2{ACnum,iFan} = 'None';
            end
            
            % 送風機 の 送風量制御の有無
            if strcmp(venACDataCell{iUNIT+iFan-1,11},'CO濃度制御')
                venACFanControlFlag_C3{ACnum,iFan} = 'COconcentration';
            elseif strcmp(venACDataCell{iUNIT+iFan-1,11},'温度制御')
                venACFanControlFlag_C3{ACnum,iFan} = 'Temprature';
            else
                venACFanControlFlag_C3{ACnum,iFan} = 'None';
            end
            
        end
        
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
    
    for iUNIT = 1:unitNum
        if unitNum == 1
            xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationUnitRef(iUNIT).ATTRIBUTE.Name       = UnitList(iROOM,1);
            xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationUnitRef(iUNIT).ATTRIBUTE.UnitType   = UnitTypeList(iROOM,1);
        else
            xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationUnitRef(iUNIT).ATTRIBUTE.Name       = UnitList{iROOM}(iUNIT);
            xmldata.VentilationSystems.VentilationRoom(iROOM).VentilationUnitRef(iUNIT).ATTRIBUTE.UnitType   = UnitTypeList{iROOM}(iUNIT);
        end
    end
    
end

% 換気ファン
for iUNIT = 1:length(venUnitName)
    
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.Name      = venUnitName(iUNIT);
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.FanVolume = venVolume(iUNIT);
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.FanPower  = venPower(iUNIT);
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.ControlFlag_C1 = venControlFlag_C1(iUNIT);
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.ControlFlag_C2 = venControlFlag_C2(iUNIT);
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.ControlFlag_C3 = venControlFlag_C3(iUNIT);
    
end

% 換気代替空調機
for iUNIT = 1:length(venACUnitName)
    
    xmldata.VentilationSystems.VentilationACUnit(iUNIT).ATTRIBUTE.Name             = venACUnitName{iUNIT};
    xmldata.VentilationSystems.VentilationACUnit(iUNIT).ATTRIBUTE.roomType         = venACroomType{iUNIT};
    xmldata.VentilationSystems.VentilationACUnit(iUNIT).ATTRIBUTE.CoolingCapacity  = venACCoolingCapacity{iUNIT};
    xmldata.VentilationSystems.VentilationACUnit(iUNIT).ATTRIBUTE.COP              = venACCOP{iUNIT};
    xmldata.VentilationSystems.VentilationACUnit(iUNIT).ATTRIBUTE.PumpPower        = venACPumpPower{iUNIT};
    
    for iFan = 1:venACfanNUM(iUNIT)
        
        xmldata.VentilationSystems.VentilationACUnit(iUNIT).Fan(iFan).ATTRIBUTE.FanType = venACFanType{iUNIT,iFan};
        xmldata.VentilationSystems.VentilationACUnit(iUNIT).Fan(iFan).ATTRIBUTE.FanVolume = venACFanVolume{iUNIT,iFan};
        xmldata.VentilationSystems.VentilationACUnit(iUNIT).Fan(iFan).ATTRIBUTE.FanPower = venACFanPower{iUNIT,iFan};
        xmldata.VentilationSystems.VentilationACUnit(iUNIT).Fan(iFan).ATTRIBUTE.ControlFlag_C1 = venACFanControlFlag_C1{iUNIT,iFan};
        xmldata.VentilationSystems.VentilationACUnit(iUNIT).Fan(iFan).ATTRIBUTE.ControlFlag_C2 = venACFanControlFlag_C2{iUNIT,iFan};
        xmldata.VentilationSystems.VentilationACUnit(iUNIT).Fan(iFan).ATTRIBUTE.ControlFlag_C3 = venACFanControlFlag_C3{iUNIT,iFan};
        
    end
end










