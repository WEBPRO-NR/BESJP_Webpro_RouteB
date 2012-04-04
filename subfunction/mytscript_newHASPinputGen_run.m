% mytscript_newHASPinputGen_run.m
%                                                        2012/01/01 by Masato Miyata
%-----------------------------------------------------------------------------------
% XMLファイルから情報を取得して、newHASPの実行ファイル(txt)を出力する。
% 出力するファイル名は　newHASPinput_(室ID).txt　となる。
%-----------------------------------------------------------------------------------

for iRoom = 1:numOfRoooms
    
    % テンプレートの読み込み
    OUTPUT = xml_read('./NewHASPInputGen/newHASPinput_template.xml');
    
    % 建物共通設定
    OUTPUT.ATTRIBUTE.Area   = BuildingArea;   % 延床面積 [m2]
    OUTPUT.ATTRIBUTE.Region = climateAREA;    % 地域
    OUTPUT.ATTRIBUTE.Type   = BuildingType;   % 建物用途
   
    OUTPUT.Rooms.Room.ATTRIBUTE.ID          = roomName{iRoom};    % 室ID
    OUTPUT.Rooms.Room.ATTRIBUTE.Type        = roomType{iRoom};    % 室用途
    OUTPUT.Rooms.Room.ATTRIBUTE.Area        = roomArea(iRoom);    % 室面積 [m2]
    OUTPUT.Rooms.Room.ATTRIBUTE.FloorHeight = roomFloorHeight(iRoom);  % 階高 [m]
    OUTPUT.Rooms.Room.ATTRIBUTE.Height      = roomHeight(iRoom);  % 天井高 [m]
     
    % 外皮IDから外皮仕様を探す
    for iENV = 1:numOfENVs
        if strcmp(EnvelopeRef{iRoom},envelopeID{iENV}) == 1
            break
        end
    end
    
    OUTPUT.Rooms.Room.EnvelopeRef.ATTRIBUTE.ID = EnvelopeRef{iRoom};  % 外皮仕様ID
    OUTPUT.Envelopes.Envelope.ATTRIBUTE.ID     = EnvelopeRef{iRoom};  % 外皮仕様ID
    
    % 外皮構成別に読み込む
    for iWALL = 1:numOfWalls(iENV)
        OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.WallConfigure = WallConfigure{iENV,iWALL};   % 外壁種類
        OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.WallArea      = WallArea(iENV,iWALL);        % 外皮面積 [m2]
        OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.WindowType    = WindowType{iENV,iWALL};      % 窓種類
        OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.WindowArea    = WindowArea(iENV,iWALL);      % 窓面積 [m2]
        OUTPUT.Envelopes.Envelope.Wall(iWALL).ATTRIBUTE.Direction     = Direction{iENV,iWALL};       % 方位
    end
    
    
    %% inputfileの生成
    
    eval(['OUTPUTFILENAME = ''newHASPinput_',OUTPUT.Rooms.Room.ATTRIBUTE.ID,''';'])
    
    eval(['xml_write(''',OUTPUTFILENAME,'.xml'',OUTPUT, ''Model'');'])
    eval(['system(''NewHASPInputGen\newhaspgen.exe /i ',OUTPUTFILENAME,'.xml /o ',OUTPUTFILENAME,'.txt /d database'');'])
    eval(['delete ',OUTPUTFILENAME,'.xml'])
    
end