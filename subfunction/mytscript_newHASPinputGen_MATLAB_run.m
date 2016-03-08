% mytscript_newHASPinputGen_run.m
%                                                        2015/02/07 by Masato Miyata
%-----------------------------------------------------------------------------------
% XMLファイルから情報を取得して、newHASPの実行ファイル(txt)を出力する。
% 出力するファイル名は　newHASPinput_(室ID).txt　となる。
%-----------------------------------------------------------------------------------

for iROOM = 1:numOfRoooms
    
    
    % 建物用途
    switch buildingType{iROOM}
        case 'Office'
            TypeOfBuilding   = '事務所等';
        case 'Hotel'
            TypeOfBuilding   = 'ホテル等';
        case 'Hospital'
            TypeOfBuilding   = '病院等';
        case 'Store'
            TypeOfBuilding   = '物品販売業を営む店舗等';
        case 'School'
            TypeOfBuilding   = '学校等';
        case 'Restaurant'
            TypeOfBuilding   = '飲食店等';
        case 'MeetingPlace'
            TypeOfBuilding   = '集会所等';
        case 'Factory'
            TypeOfBuilding   = '工場等';
        case 'ApartmentHouse'
            TypeOfBuilding   = '共同住宅';
    end
    
    % 外皮IDから該当する外皮仕様（iENV）を探す
    for iENV = 1:numOfENVs
        if strcmp(EnvelopeRef{iROOM},envelopeID{iENV}) == 1
            break
        end
    end
    
    % 外皮構成別に読み込む
    conf_wall = [];
    conf_window = [];
    
    for iWALL = 1:numOfWalls(iENV)
        
        if isempty(WallConfigure{iENV,iWALL}) == 0
            
            % 外皮構成リスト（confW）から該当する外皮仕様を探す
            for iDB = 1:size(confW,1)
                if strcmp(confW(iDB,1),WallConfigure{iENV,iWALL})
                    
                    % newHASPのWCON生成
                    tmp = 'WCON X     ';
                    tmp(6:6+length(confW{iDB,2})-1) = confW{iDB,2};  % WCON名
                    
                    for iWCON = 1:9
                        if  isempty(confW{iDB,2+2*iWCON-1}) == 0
                            
                            % 平成25年基準の窓番号から、newHASPの窓仕様を選択
                            Mnum = mytfunc_convert_newHASPwalls(confW{iDB,2+2*iWCON-1});
                            Mthi = confW{iDB,2+2*iWCON};    % 厚さ
                            tmp2 = '  X  X';
                            tmp2(3-length(Mnum)+1:3) =  Mnum;
                            tmp2(6-length(Mthi)+1:6) =  Mthi;
                            tmp = [tmp,tmp2];  % 文字列結合
                        end
                    end
                    
                    conf_wall(iWALL).WCON = tmp;   % 外壁種類
                end
            end
            
            switch EXPSdata{iENV,iWALL}
                case 'Horizontal'
                    conf_wall(iWALL).EXPS = 'HOR';
                case 'Shade'
                    conf_wall(iWALL).EXPS = 'SHD';
                otherwise
                    conf_wall(iWALL).EXPS = EXPSdata{iENV,iWALL};       % 方位
            end
            conf_wall(iWALL).AREA = WallArea(iENV,iWALL) - WindowArea(iENV,iWALL);  % 外皮面積 [m2]
            
        end
        
        % 窓構成リスト（confG）から該当する窓仕様を探す
        for iDB = 1:size(confG,1)
            if strcmp(confG(iDB,1),WindowType{iENV,iWALL})
                
                if WindowArea(iENV,iWALL) > 0
                    
                    % 平成25年基準の窓番号から、newHASPの窓仕様を選択
                    [conf_window(iWALL).WNDW,conf_window(iWALL).TYPE] = mytfunc_convert_newHASPwindows(confG{iDB,3});
                    
                    conf_window(iWALL).BLND = confG{iDB,4};      % ブラインド有無
                    switch EXPSdata{iENV,iWALL}
                        case 'Horizontal'
                            conf_window(iWALL).EXPS = 'HOR';
                        case 'Shade'
                            conf_window(iWALL).EXPS = 'SHD';
                        otherwise
                            conf_window(iWALL).EXPS = EXPSdata{iENV,iWALL};       % 方位
                    end
                else
                    conf_window(iWALL).WNUM = [];      % 窓番号
                    conf_window(iWALL).BLND = [];      % ブラインド有無
                    conf_window(iWALL).EXPS = [];      % 方位
                end
                
                conf_window(iWALL).AREA = WindowArea(iENV,iWALL);      % 窓面積 [m2]
                
            end
        end
        
    end
    
    
    %% inputfileの生成
    
    y = mytfunc_newHASPinputFilemake(roomID{iROOM},climateAREA,TypeOfBuilding,roomType{iROOM},roomArea(iROOM),...
        roomFloorHeight(iROOM),roomHeight(iROOM),conf_wall,conf_window,perDB_RoomType,perDB_RoomOpeCondition);
    
    
    
end

