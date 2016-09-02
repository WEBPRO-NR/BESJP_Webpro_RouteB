% mytfunc_csv2xml_EV.m
%                                             by Masato Miyata 2012/04/02
%------------------------------------------------------------------------
% 省エネ基準：昇降機設定ファイルを作成する。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_EV(xmldata,filename)

% データの読み込み
EVDataCell = mytfunc_CSVfile2Cell(filename);

% EVData = textread(filename,'%s','delimiter','\n','whitespace','');
% 
% % 空調室定義ファイルの読み込み
% for i=1:length(EVData)
%     conma = strfind(EVData{i},',');
%     for j = 1:length(conma)
%         if j == 1
%             EVDataCell{i,j} = EVData{i}(1:conma(j)-1);
%         elseif j == length(conma)
%             EVDataCell{i,j}   = EVData{i}(conma(j-1)+1:conma(j)-1);
%             EVDataCell{i,j+1} = EVData{i}(conma(j)+1:end);
%         else
%             EVDataCell{i,j} = EVData{i}(conma(j-1)+1:conma(j)-1);
%         end
%     end
% end

% 情報の抜出
roomFloor     = {};
roomName      = {};
BldgType      = {};
RoomType      = {};
EVName        = {};
EVCount       = {};
EVLoadLimit   = {};
EVVelocity    = {};
EVControlType = {};
TransportCapacityFactor = {};

for iUNIT = 11:size(EVDataCell,1)
    
    if isempty(EVDataCell{iUNIT,2}) == 0
        
        % 系統名称
        if isempty(EVDataCell{iUNIT,5})
            EVName  = [EVName;'Null'];
        else
            EVName  = [EVName;EVDataCell{iUNIT,5}];
        end
        
        % 台数
        EVCount = [EVCount;EVDataCell{iUNIT,6}];
        % 積載量
        EVLoadLimit = [EVLoadLimit;EVDataCell{iUNIT,7}];
        % 速度
        EVVelocity = [EVVelocity;EVDataCell{iUNIT,8}];
        
        % 輸送能力係数
        if isempty(EVDataCell{iUNIT,9})
            TransportCapacityFactor = [TransportCapacityFactor; 'Null'];
        else
            TransportCapacityFactor = [TransportCapacityFactor; EVDataCell{iUNIT,9}];
        end
                
        % 速度制御方式
        if strcmp(EVDataCell(iUNIT,10),'VVVF(電力回生あり、ギアレス)') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF（電力回生あり、ギアレス）') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF(電力回生あり、ギアレス）') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF（電力回生あり、ギアレス)')
            EVControlType = [EVControlType;'VVVF_Regene_GearLess'];
        elseif strcmp(EVDataCell(iUNIT,10),'VVVF(電力回生あり)') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF（電力回生あり）') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF(電力回生あり）') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF（電力回生あり)')
            EVControlType = [EVControlType;'VVVF_Regene'];
        elseif strcmp(EVDataCell(iUNIT,10),'VVVF(電力回生なし、ギアレス)') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF（電力回生なし、ギアレス）') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF(電力回生なし、ギアレス、ギアレス）') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF（電力回生あり)')
            EVControlType = [EVControlType;'VVVF_GearLess'];
        elseif strcmp(EVDataCell(iUNIT,10),'VVVF(電力回生なし)') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF（電力回生なし）') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF(電力回生なし）') || ...
                strcmp(EVDataCell(iUNIT,10),'VVVF（電力回生なし)')
            EVControlType = [EVControlType;'VVVF'];
        elseif strcmp(EVDataCell(iUNIT,10),'交流帰還制御方式') || ...
                strcmp(EVDataCell(iUNIT,10),'交流帰還制御')
            EVControlType = [EVControlType;'AC_FeedbackControl'];
        else
            error('エレベータ：速度制御方式 %s は不正です。',EVDataCell{iUNIT,10})
        end
        
        
        if isempty(EVDataCell{iUNIT,1})
            roomFloor  = [roomFloor;'Null'];
        else
            roomFloor  = [roomFloor; EVDataCell{iUNIT,1}];
        end
        
        roomName = [roomName; EVDataCell{iUNIT,2}];
        
    end
end

% XMLファイル生成
for iUNIT = 1:size(EVCount,1)
    
    % 室IDリスト
    [RoomID,BldgType,RoomType,~,~,~] = ...
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
    xmldata.Elevators.Elevator(iUNIT).ATTRIBUTE.TransportCapacityFactor = TransportCapacityFactor{iUNIT};
    
end
