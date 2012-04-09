% mytfunc_csv2xml_Vfan_UnitList.m
%                                             by Masato Miyata 2012/04/02
%------------------------------------------------------------------------
% 省エネ基準：換気設定ファイルを作成する。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_Vfan_UnitList(xmldata,filename)

% データの読み込み
venData = textread(filename,'%s','delimiter','\n','whitespace','');

% 空調室定義ファイルの読み込み
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

% 情報の抜出
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

for iUNIT = 11:size(venDataCell,1)
    
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
    
    numRoom = (length(venDataCell(iUNIT,:))-9)/2;
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
    
    roomFloor(iUNIT-10,:) = tmpFloor;
    roomName(iUNIT-10,:)  = tmpName;
    
end

% XMLファイル生成
for iUNIT = 1:size(venPower,1)
    
    eval(['xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.ID = ''VfanUnit_',int2str(iUNIT),''';'])
    
    tmpIDs = {};
    for iROOM = 1:numRoom
        if strcmp(roomName{iUNIT,iROOM},'Null') == 0
            tmpID = mytfunc_roomsearch(xmldata,roomFloor{iUNIT,iROOM},roomName{iUNIT,iROOM});
            if isempty(tmpIDs)
                tmpIDs = tmpID;
            else
            tmpIDs = strcat(tmpIDs,',',tmpID);
            end
        end
    end
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.roomIDs         = tmpIDs;
    
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.UnitName        = venUnitName{iUNIT};
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.UnitType        = venUnitType{iUNIT};
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.FanVolume       = venVolume{iUNIT};
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.FanPower        = venPower{iUNIT};
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.ControlFlag_C1  = venControlFlag_C1{iUNIT};
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.ControlFlag_C2  = venControlFlag_C2{iUNIT};
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.ControlFlag_C3  = venControlFlag_C3{iUNIT};
    xmldata.VentilationSystems.VentilationFANUnit(iUNIT).ATTRIBUTE.Count           = venCount{iUNIT};
    
end
