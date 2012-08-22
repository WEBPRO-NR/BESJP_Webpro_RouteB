% mytfunc_calcK.m
%----------------------------------------------------------------------------
% 総熱貫流率、日射取得係数などを求める
%----------------------------------------------------------------------------
function [WallNameList,WallUvalueList,WindowNameList,WindowUvalueList,WindowMyuList,WindowSCCList,WindowSCRList] = ...
    mytfunc_calcK(dumy)

% WCONデータベースの読み込み
DB_WCON = textread('./newhasp/wcontabl.dat','%s','delimiter','\n','whitespace','');

% 結果の格納 perDB_WCON(材料番号、単位、熱伝導率、容積比熱)
for i=1:length(DB_WCON)
    conma = strfind(DB_WCON{i},',');
    for j = 1:length(conma)
        if j == 1
            perDB_WCON{i,j} = str2double(DB_WCON{i}(1:conma(j)-1));
        elseif j == length(conma)
            perDB_WCON{i,j}   = str2double(DB_WCON{i}(conma(j-1)+1:conma(j)-1));
            perDB_WCON{i,j+1} = str2double(DB_WCON{i}(conma(j)+1:end));
        else
            perDB_WCON{i,j} = str2double(DB_WCON{i}(conma(j-1)+1:conma(j)-1));
        end
    end
end

% SI単位系に変更
for iDB = 1:length(perDB_WCON)
    if perDB_WCON{iDB,2} == 0 && perDB_WCON{iDB,3} ~= 0
        % kcal/mh°C から　W/(m・K)
        perDB_WCON{iDB,3} = perDB_WCON{iDB,3} * 4.2*1000/3600;
    end
end

% WINDデータベースの読み込み
DB_WIND = textread('./newhasp/wndwtabl.dat','%s','delimiter','\n','whitespace','');

% 結果の格納 perDB_WCON(材料番号、単位、熱伝導率、容積比熱)
for i=1:length(DB_WIND)
    conma = strfind(DB_WIND{i},',');
    for j = 1:length(conma)
        if j == 1
            perDB_WIND{i,j} = str2double(DB_WIND{i}(1:conma(j)-1));
        elseif j == length(conma)
            perDB_WIND{i,j}   = str2double(DB_WIND{i}(conma(j-1)+1:conma(j)-1));
            perDB_WIND{i,j+1} = str2double(DB_WIND{i}(conma(j)+1:end));
        else
            perDB_WIND{i,j} = str2double(DB_WIND{i}(conma(j-1)+1:conma(j)-1));
        end
    end
end


%% 外壁仕様の計算

% WCONファイルの読み込み
WCON = textread('./database/WCON.csv','%s','delimiter','\n','whitespace','');

% 結果の格納 perDB_WCON(材料番号、単位、熱伝導率、容積比熱)
for i=1:length(WCON)
    conma = strfind(WCON{i},',');
    for j = 1:length(conma)
        if j == 1
            perWCON{i,j} = (WCON{i}(1:conma(j)-1));
        elseif j == length(conma)
            perWCON{i,j}   = (WCON{i}(conma(j-1)+1:conma(j)-1));
            perWCON{i,j+1} = (WCON{i}(conma(j)+1:end));
        else
            perWCON{i,j} = (WCON{i}(conma(j-1)+1:conma(j)-1));
        end
    end
end
WallNameList = perWCON(2:end,1);

% 外壁のU値計算
WallUvalueList = [];
for iWALL = 1:size(perWCON,1)-1
    
    % 情報抜出
    tmp = str2double(perWCON(iWALL+1,3:end));
    
    R = 1/9 + 1/23;
    for iELE = 1:length(tmp)/2
        
        % 材料番号
        elenum = tmp(2*(iELE)-1);
        
        if isnan(elenum) == 0
            
            if elenum <= 90
                % 空気層以外
                R = R +  0.001*tmp(2*(iELE))/perDB_WCON{elenum,3};
            else
                % 空気層
                R = R +  perDB_WCON{elenum,3};
            end
        end
    end
    
    % 保存
    WallUvalueList = [WallUvalueList; 1/R];
    
end



%% 窓仕様の計算

% WINDファイルの読み込み
WIND = textread('./database/WIND.csv','%s','delimiter','\n','whitespace','');

% 結果の格納 perDB_WIND(名称、窓種、品種番号、ブラインド)
for i=1:length(WIND)
    conma = strfind(WIND{i},',');
    for j = 1:length(conma)
        if j == 1
            perWIND{i,j} = (WIND{i}(1:conma(j)-1));
        elseif j == length(conma)
            perWIND{i,j}   = (WIND{i}(conma(j-1)+1:conma(j)-1));
            perWIND{i,j+1} = (WIND{i}(conma(j)+1:end));
        else
            perWIND{i,j} = (WIND{i}(conma(j-1)+1:conma(j)-1));
        end
    end
end

WindowNameList = perWIND(2:end,1);

for iWIND = 2:size(perWIND,1)
    
    % 窓の種類
    if strcmp(perWIND(iWIND,2),'SNGL')
        startNum = 2;
    elseif strcmp(perWIND(iWIND,2),'DL06')
        startNum = 110;
    elseif strcmp(perWIND(iWIND,2),'DL12')
        startNum = 298;
    end
    
    % ブラインドの種類
    if strcmp(perWIND(iWIND,4),'0')
        blindnum = 3;
    elseif strcmp(perWIND(iWIND,4),'1')
        blindnum = 6;
    elseif strcmp(perWIND(iWIND,4),'2')
        blindnum = 9;
    elseif strcmp(perWIND(iWIND,4),'3')
        blindnum = 12;
    end
    
    % 窓のU値
    WindowUvalueList(iWIND-1) = perDB_WIND{startNum + str2double(perWIND{iWIND,3}),blindnum};
    
    % 窓の日射侵入率
    WindowMyuList(iWIND-1)    = 0.88 * (perDB_WIND{startNum + str2double(perWIND{iWIND,3}),blindnum+1} + ...
        perDB_WIND{startNum + str2double(perWIND{iWIND,3}),blindnum+2} );
    
    % 窓のSCC(遮蔽係数)
    WindowSCCList(iWIND-1)    = perDB_WIND{startNum + str2double(perWIND{iWIND,3}),blindnum+1};
    % 窓のSCR(遮蔽係数)
    WindowSCRList(iWIND-1)    = perDB_WIND{startNum + str2double(perWIND{iWIND,3}),blindnum+2};
        
end








