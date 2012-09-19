% mytfunc_calcK.m
%----------------------------------------------------------------------------
% 総熱貫流率、日射取得係数などを求める
%----------------------------------------------------------------------------
function [WallNameList,WallUvalueList,WindowNameList,WindowUvalueList,WindowMyuList,...
    WindowSCCList,WindowSCRList] = ...
    mytfunc_calcK(DBWCONMODE,confW,confG,WallUvalue,WindowUvalue,WindowMvalue)


switch DBWCONMODE
    
    case {'newHASP'}  % newHASPのデータファイルを使用する場合
        
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
        
    case {'Regulation'}
        
        % WCONデータベースの読み込み（HeatThermalConductivity.csv）
        DB_WCON = textread('./database/HeatThermalConductivity.csv','%s','delimiter','\n','whitespace','');
        
        % 結果の格納 perDB_WCON(材料番号、材料名、熱伝導率、容積比熱、比熱、密度)
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
        
        
        % WINDデータベースの読み込み
        DB_WIND = textread('./database/WindowHeatTransferPerformance.csv','%s','delimiter','\n','whitespace','');
        
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
        
        
    otherwise
        error('WCON, WINDデータベースファイルの指定が不正です')
end



%% 外壁仕様の計算

% 外壁名称リスト
WallNameList = confW(:,1);

% 外壁のU値計算
WallUvalueList = [];
for iWALL = 1:size(confW,1)
    
    % 情報抜出
    tmp = str2double(confW(iWALL,3:end));
    
    R = 1/9 + 1/23;
    for iELE = 1:length(tmp)/2
        
        % 材料番号
        elenum = tmp(2*(iELE)-1);
        
        if isnan(elenum) == 0
            
            % 物性値が空であればエラー
            if isnan(perDB_WCON{elenum,3})
                error('建材番号が不正です')
            end
            
            switch DBWCONMODE
                case {'newHASP'}
                    if elenum <= 90
                        % 空気層以外
                        R = R +  0.001*tmp(2*(iELE))/perDB_WCON{elenum,3};
                    else
                        % 空気層
                        R = R +  perDB_WCON{elenum,3};
                    end
                case {'Regulation'}
                    if elenum <= 300
                        % 空気層以外
                        R = R +  0.001*tmp(2*(iELE))/perDB_WCON{elenum,3};
                    else
                        % 空気層
                        R = R +  perDB_WCON{elenum,3};
                    end
            end
            
        end
    end
    
    % もしU値が直接入力されていれば、その値を優先する。
    if isnan(WallUvalue(iWALL))
        WallUvalueList = [WallUvalueList; 1/R];
    else
        WallUvalueList = [WallUvalueList; WallUvalue(iWALL)];
    end
    
end


%% 窓仕様の計算

% 窓名称リスト
WindowNameList = confG(:,1);

for iWIND = 1:size(confG,1)
    
    switch DBWCONMODE
        case {'newHASP'}
            
            % 窓の種類
            if strcmp(confG(iWIND,2),'SNGL')
                startNum = 2;
            elseif strcmp(confG(iWIND,2),'DL06')
                startNum = 110;
            elseif strcmp(confG(iWIND,2),'DL12')
                startNum = 298;
            end
            
            % ブラインドの種類
            if strcmp(confG(iWIND,4),'0')
                blindnum = 3;
            elseif strcmp(confG(iWIND,4),'1')
                blindnum = 6;
            elseif strcmp(confG(iWIND,4),'2')
                blindnum = 9;
            elseif strcmp(confG(iWIND,4),'3')
                blindnum = 12;
            end
            
            % 窓のU値
            WindowUvalueList(iWIND) = perDB_WIND{startNum + str2double(confG{iWIND,3}),blindnum};
            
            % 窓の日射侵入率
            WindowMyuList(iWIND)    = 0.88 * (perDB_WIND{startNum + str2double(confG{iWIND,3}),blindnum+1} + ...
                perDB_WIND{startNum + str2double(confG{iWIND,3}),blindnum+2} );
            
            % 窓のSCC(遮蔽係数)
            WindowSCCList(iWIND)    = perDB_WIND{startNum + str2double(confG{iWIND,3}),blindnum+1};
            % 窓のSCR(遮蔽係数)
            WindowSCRList(iWIND)    = perDB_WIND{startNum + str2double(confG{iWIND,3}),blindnum+2};
            
            
        case {'Regulation'}
            
            % 窓番号が空であればエラー
            if isnan(confG{iWIND,3})
                error('窓番号が不正です')
            end
            
            % U値
            if isnan(WindowUvalue(iWIND))
                % データベースを参照
                if strcmp(confG(iWIND,4),'0')  % ブラインドなし
                    % 窓のU値
                    WindowUvalueList(iWIND) = perDB_WIND{str2double(confG(iWIND,3)),5};
                elseif strcmp(confG(iWIND,4),'1')  % ブラインドあり
                    % 窓のU値
                    WindowUvalueList(iWIND) = perDB_WIND{str2double(confG(iWIND,3)),6};
                end
            else
                % もしU値が直接入力されていれば、その値を優先する。
                WindowUvalueList(iWIND) = WindowUvalue(iWIND);
            end
            
            % μ値
            if isnan(WindowMvalue(iWIND))
                % データベースを参照
                if strcmp(confG(iWIND,4),'0')  % ブラインドなし
                    % 窓の日射侵入率
                    WindowMyuList(iWIND) = perDB_WIND{str2double(confG(iWIND,3)),7};
                elseif strcmp(confG(iWIND,4),'1')  % ブラインドあり
                    % 窓の日射侵入率
                    WindowMyuList(iWIND) = perDB_WIND{str2double(confG(iWIND,3)),8};
                end
            else
                % もしM値が直接入力されていれば、その値を優先する。
                WindowMyuList(iWIND) = WindowMvalue(iWIND);
            end
            
            % 遮蔽係数（SCCに押し込む）
            WindowSCCList(iWIND) = WindowMyuList(iWIND)./0.88;
            WindowSCRList(iWIND) = 0;
            
    end
end

