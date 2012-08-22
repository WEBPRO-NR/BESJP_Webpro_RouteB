% mytscript_newHASPinputGen_run.m
%                                                        2012/01/01 by Masato Miyata
%-----------------------------------------------------------------------------------
% XMLファイルから情報を取得して、newHASPの実行ファイル(txt)を出力する。
% 出力するファイル名は　newHASPinput_(室ID).txt　となる。
%-----------------------------------------------------------------------------------

for iROOM = 1:numOfRoooms
    
    % テンプレートの読み込み
    OUTPUT = xml_read('./NewHASPInputGen/newHASPinput_template.xml');
    
    % 建物共通設定
    OUTPUT.ATTRIBUTE.Area   = BuildingArea;   % 延床面積 [m2]
    OUTPUT.ATTRIBUTE.Region = climateAREA;    % 地域
    
    switch buildingType{iROOM}
        case 'Office'
            OUTPUT.ATTRIBUTE.Type   = '事務所等';
        case 'Hotel'
            OUTPUT.ATTRIBUTE.Type   = 'ホテル等';
        case 'Hospital'
            OUTPUT.ATTRIBUTE.Type   = '病院等';
        case 'Store'
            OUTPUT.ATTRIBUTE.Type   = '物品販売業を営む店舗等';
        case 'School'
            OUTPUT.ATTRIBUTE.Type   = '学校等';
        case 'Restaurant'
            OUTPUT.ATTRIBUTE.Type   = '飲食店等';
        case 'MeetingPlace'
            OUTPUT.ATTRIBUTE.Type   = '集会所等';
        case 'Factory'
            OUTPUT.ATTRIBUTE.Type   = '工場等';
    end
    
    OUTPUT.Rooms.Room.ATTRIBUTE.ID          = roomID{iROOM};      % 室ID
    OUTPUT.Rooms.Room.ATTRIBUTE.Type        = roomType{iROOM};    % 室用途
    OUTPUT.Rooms.Room.ATTRIBUTE.Area        = roomArea(iROOM);    % 室面積 [m2]
    OUTPUT.Rooms.Room.ATTRIBUTE.FloorHeight = roomFloorHeight(iROOM);  % 階高 [m]
    OUTPUT.Rooms.Room.ATTRIBUTE.Height      = roomHeight(iROOM);  % 天井高 [m]
    
    % 外皮IDから外皮仕様を探す
    for iENV = 1:numOfENVs
        if strcmp(EnvelopeRef{iROOM},envelopeID{iENV}) == 1
            break
        end
    end
    
    OUTPUT.Rooms.Room.EnvelopeRef.ATTRIBUTE.ID = EnvelopeRef{iROOM};  % 外皮仕様ID
    OUTPUT.Envelopes.Envelope.ATTRIBUTE.ID     = EnvelopeRef{iROOM};  % 外皮仕様ID
    
    % 外皮構成別に読み込む
    for iWALL = 1:numOfWalls(iENV)
        OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.WallConfigure  = WallConfigure{iENV,iWALL};   % 外壁種類
        OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.WallArea       = WallArea(iENV,iWALL) - WindowArea(iENV,iWALL);  % 外皮面積 [m2]
        if strcmp(WindowType{iENV,iWALL},'Null')
            OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.WindowType = 'Null_0';      % 窓種類
        else
            OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.WindowType = WindowType{iENV,iWALL};      % 窓種類
        end
        OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.WindowArea     = WindowArea(iENV,iWALL);      % 窓面積 [m2]
        OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.Direction      = EXPSdata{iENV,iWALL};       % 方位
        
        
        % 方位係数
        if strcmp(Direction{iENV,iWALL},'N')
            directionV = 0.24;
        elseif strcmp(Direction{iENV,iWALL},'E') || strcmp(Direction{iENV,iWALL},'W')
            directionV = 0.45;
        elseif strcmp(Direction{iENV,iWALL},'S')
            directionV = 0.39;
        elseif strcmp(Direction{iENV,iWALL},'SE') || strcmp(Direction{iENV,iWALL},'SW')
            directionV = 0.45;
        elseif strcmp(Direction{iENV,iWALL},'NE') || strcmp(Direction{iENV,iWALL},'NW')
            directionV = 0.34;
        elseif strcmp(Direction{iENV,iWALL},'Horizontal')
            directionV = 1;
        elseif strcmp(Direction{iENV,iWALL},'Underground')
            directionV = 0;
        else
            directionV = 0.5;
        end

        % 総熱貫流率計算(壁) + 日射侵入率計算（壁）
        for iDB = 1:length(WallNameList)
            if strcmp(WallNameList{iDB},WallConfigure{iENV,iWALL})
                UAlist(iROOM) = UAlist(iROOM) + WallUvalueList(iDB)*(WallArea(iENV,iWALL) - WindowArea(iENV,iWALL));
                MAlist(iROOM) = MAlist(iROOM) + directionV*0.04*0.8*WallUvalueList(iDB)*(WallArea(iENV,iWALL) - WindowArea(iENV,iWALL));
            end
        end
        % 総熱貫流率計算(窓) + 日射侵入率計算（窓）
        for iDB = 1:length(WindowNameList)
            if strcmp(WindowNameList{iDB},WindowType{iENV,iWALL})
                UAlist(iROOM) = UAlist(iROOM) + WindowUvalueList(iDB)*WindowArea(iENV,iWALL);
                MAlist(iROOM) = MAlist(iROOM) + directionV * WindowMyuList(iDB)*WindowArea(iENV,iWALL);             
            end
        end
        
    end
    
    
    %% inputfileの生成
    
    eval(['OUTPUTFILENAME = ''newHASPinput_',OUTPUT.Rooms.Room.ATTRIBUTE.ID,''';'])
    
    eval(['xml_write(''',OUTPUTFILENAME,'.xml'',OUTPUT, ''Model'');'])
    eval(['system(''NewHASPInputGen\newhaspgen.exe /i ',OUTPUTFILENAME,'.xml /o ',OUTPUTFILENAME,'.txt /d database'');'])
    eval(['delete ',OUTPUTFILENAME,'.xml'])
    
end
