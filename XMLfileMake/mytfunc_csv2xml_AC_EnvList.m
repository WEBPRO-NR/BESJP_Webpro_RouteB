% mytfunc_csv2xml_EnvList.m
%                                             by Masato Miyata 2012/02/12
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 外壁の設定ファイルを読み込む。
%------------------------------------------------------------------------

function xmldata = mytfunc_csv2xml_AC_EnvList(xmldata,filename)

envListData = textread(filename,'%s','delimiter','\n','whitespace','');

% 外皮仕様定義ファイルの読み込み
for i=1:length(envListData)
    conma = strfind(envListData{i},',');
    for j = 1:length(conma)
        if j == 1
            envListDataCell{i,j} = envListData{i}(1:conma(j)-1);
        elseif j == length(conma)
            envListDataCell{i,j}   = envListData{i}(conma(j-1)+1:conma(j)-1);
            envListDataCell{i,j+1} = envListData{i}(conma(j)+1:end);
        else
            envListDataCell{i,j} = envListData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 空白は直上の情報を埋める。
for iENV = 11:size(envListDataCell,1)
    if isempty(envListDataCell{iENV,3}) == 0  % 判定は方位で行う。
        if isempty(envListDataCell{iENV,1}) && isempty(envListDataCell{iENV,2})
            if iENV == 11
                error('最初の行は必ず空調ゾーン名称を入力してください')
            else
                envListDataCell(iENV,1:2) = envListDataCell(iENV-1,1:2);
            end
        end
    end
end

% 外皮リストの作成
EnvList_Floor    = {};
EnvList_RoomName = {};

for iENV = 11:size(envListDataCell,1)
    if isempty(EnvList_Floor)
        EnvList_Floor = envListDataCell(iENV,1);
        EnvList_RoomName = envListDataCell(iENV,2);
    else
        
        check = 0;
        for iDB = 1:length(EnvList_Floor)
            if strcmp(envListDataCell(iENV,1),EnvList_Floor(iDB)) && ...
                    strcmp(envListDataCell(iENV,2),EnvList_RoomName(iDB))
                % 重複判定
                check = 1;
            end
        end
        
        if check == 0
            EnvList_Floor    = [EnvList_Floor; envListDataCell(iENV,1)];
            EnvList_RoomName = [EnvList_RoomName; envListDataCell(iENV,2)];
        end
        
    end
end

% ゾーンIDを探す
EnvList_ZoneID = cell(length(EnvList_RoomName),1);
for iENV = 1:length(EnvList_RoomName)
    
    if isempty(EnvList_RoomName{iENV}) == 0
        
        check = 0;
        for iDB = 1:length(xmldata.AirConditioningSystem.AirConditioningZone)
            tmpFloor = xmldata.AirConditioningSystem.AirConditioningZone(iDB).ATTRIBUTE.ACZoneFloor;
            tmpName  = xmldata.AirConditioningSystem.AirConditioningZone(iDB).ATTRIBUTE.ACZoneName;
            tmpID    = xmldata.AirConditioningSystem.AirConditioningZone(iDB).ATTRIBUTE.ID;
            if strcmp(tmpFloor,EnvList_Floor(iENV,1)) && strcmp(tmpName,EnvList_RoomName(iENV,1))
                check = 1;
                EnvList_ZoneID{iENV} = tmpID;
            end
        end
        if check == 0
            EnvList_Floor(iENV,1)
            EnvList_RoomName(iENV,1)
            error('ゾーンIDが見つかりません')
        end
    end
    
end


% 情報の読み込み(CSVファイルから選択)
for iENVSET = 1:length(EnvList_Floor)
    
    % 外皮セットの情報
    xmldata.AirConditioningSystem.Envelope(iENVSET).ATTRIBUTE.ACZoneID    = EnvList_ZoneID(iENVSET,1);
    xmldata.AirConditioningSystem.Envelope(iENVSET).ATTRIBUTE.ACZoneFloor = EnvList_Floor(iENVSET,1);
    xmldata.AirConditioningSystem.Envelope(iENVSET).ATTRIBUTE.ACZoneName  = EnvList_RoomName(iENVSET,1);
    
    iCOUNT = 0;
    
    for iDB = 11:size(envListDataCell,1)
        if strcmp(EnvList_Floor(iENVSET,1),envListDataCell(iDB,1)) && ...
                strcmp(EnvList_RoomName(iENVSET,1),envListDataCell(iDB,2))
            
            if isempty(envListDataCell{iDB,3}) == 0
                
                iCOUNT = iCOUNT + 1;
                
                % 方位
                if strcmp(envListDataCell(iDB,3),'北')
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Direction   = 'N';
                elseif strcmp(envListDataCell(iDB,3),'北東')
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Direction   = 'NE';
                elseif strcmp(envListDataCell(iDB,3),'東')
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Direction   = 'E';
                elseif strcmp(envListDataCell(iDB,3),'南東')
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Direction   = 'SE';
                elseif strcmp(envListDataCell(iDB,3),'南')
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Direction   = 'S';
                elseif strcmp(envListDataCell(iDB,3),'南西')
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Direction   = 'SW';
                elseif strcmp(envListDataCell(iDB,3),'西')
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Direction   = 'W';
                elseif strcmp(envListDataCell(iDB,3),'北西')
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Direction   = 'NW';
                elseif strcmp(envListDataCell(iDB,3),'水平') || strcmp(envListDataCell(iDB,3),'屋根')
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Direction   = 'Horizontal';
                elseif strcmp(envListDataCell(iDB,3),'日陰') || strcmp(envListDataCell(iDB,3),'地中')
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Direction   = 'Shade';
                else
                    error('方位　%s　は不正です。', envListDataCell{iDB,3})
                end
                
                % 庇（日よけ効果係数）
                if isempty(envListDataCell{iDB,4}) == 0
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Eaves_Cooling = envListDataCell(iDB,4);
                else
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Eaves_Cooling = 'Null';
                end
                if isempty(envListDataCell{iDB,5}) == 0
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Eaves_Heating = envListDataCell(iDB,5);
                else
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Eaves_Heating = 'Null';
                end
                
                % 外壁タイプ
                xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.WallConfigure = envListDataCell(iDB,6);
                
                % 外皮面積（窓面積＋外壁面積）
                xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.WallArea = envListDataCell(iDB,7);
                
                % 窓種類
                if isempty(envListDataCell{iDB,8}) == 0
                    
                    % 窓種類
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.WindowType = envListDataCell(iDB,8);
                    
                    % 窓面積
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.WindowArea = envListDataCell(iDB,9);
                    
                    % 窓種類(ブラインド種類で場合分け)
                    if strcmp(envListDataCell{iDB,10},'有')
                        xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Blind  = 'True';
                    else
                        xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Blind  = 'False';
                    end
                    
                else
                    % 窓タイプ(デフォルト）
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.WindowType    = 'Null';
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.WindowArea    = '0';
                    xmldata.AirConditioningSystem.Envelope(iENVSET).Wall(iCOUNT).ATTRIBUTE.Blind         = 'False';
                end
            end
        end
    end
end



