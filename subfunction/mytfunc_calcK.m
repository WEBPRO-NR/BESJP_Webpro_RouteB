% mytfunc_calcK.m
%----------------------------------------------------------------------------
% 壁・窓について、総熱貫流率と日射熱取得率を求める。
%----------------------------------------------------------------------------
% （入力）
% DBWCONMODE    : 建材データベースモード（'newHASP' or 'Regulation'）
% confW         : 壁の層構成
% confG         : 窓の構成（名称、窓種類、窓番号、ブラインドの有無）
% WallUvalue    : 壁の熱貫流率（入力されている場合）
% WindowUvalue  : 窓の熱貫流率（入力されている場合）
% WindowMvalue  : 窓の日射熱取得率（入力されている場合）
% （出力）
% WallNameList     : 壁名称リスト
% WallUvalueList   : 壁の熱貫流率のリスト
% WindowNameList   : 開口部名称のリスト
% WindowUvalueList : 窓の熱貫流率のリスト
% WindowMyuList    : 窓の日射熱取得率のリスト
%----------------------------------------------------------------------------
function [WallNameList,WallUvalueList,WindowNameList,WindowUvalueList,WindowMyuList,...
    WindowSCCList,WindowSCRList] = ...
    mytfunc_calcK(DBWCONMODE,confW,confG,WallUvalue,WindowUvalue,WindowMvalue)


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
DB_WIND = textread('./database/WindowHeatTransferPerformance_H28.csv','%s','delimiter','\n','whitespace','');

% 結果の格納 perDB_WCON(材料番号、単位、熱伝導率、容積比熱)
for i=1:length(DB_WIND)
    conma = strfind(DB_WIND{i},',');
    for j = 1:length(conma)
        if j == 1
            perDB_WIND{i,j} = (DB_WIND{i}(1:conma(j)-1));
        elseif j == length(conma)
            perDB_WIND{i,j}   = (DB_WIND{i}(conma(j-1)+1:conma(j)-1));
            perDB_WIND{i,j+1} = (DB_WIND{i}(conma(j)+1:end));
        else
            perDB_WIND{i,j} = (DB_WIND{i}(conma(j-1)+1:conma(j)-1));
        end
    end
end


%% 壁の熱貫流率

% 外壁名称リスト
WallNameList = confW(:,1);

% 外壁のU値計算
WallUvalueList = [];
for iWALL = 1:size(confW,1)
    
    % 情報抜出
    tmp = str2double(confW(iWALL,3:end));
    
    %     R = 1/9 + 1/23;
    R = 0.11 + 0.04;
    
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


%% 窓の熱貫流率と日射熱取得率の計算

WindowNameList = confG(:,1);               % 窓名称リスト
WindowUvalueList = zeros(size(confG,1),1); % 窓の熱貫流率
WindowMyuList = zeros(size(confG,1),1);    % 窓の熱貫流率

for iWIND = 1:size(confG,1)
    
    % 窓の熱貫流率と日射熱取得率が入力されている場合（ルート３、４）
    if isnan(WindowUvalue(iWIND)) == 0  && isnan(WindowMvalue(iWIND)) == 0
        
        if strcmp(confG(iWIND,4),'0')  % ブラインド無
            
            WindowUvalueList(iWIND) = WindowUvalue(iWIND);
            WindowMyuList(iWIND) = WindowMvalue(iWIND);
            
        elseif strcmp(confG(iWIND,4),'1')
            
            % ガラスの熱貫流率と日射熱取得率が入力されている場合は、ブラインドの効果を見込む
            if strcmp(confG(iWIND,5),'Null') == 0 && strcmp(confG(iWIND,6),'Null') == 0
                
                Ug = str2double(confG(iWIND,5));
                Mg = str2double(confG(iWIND,6));
                Ufg = WindowUvalue(iWIND);
                Mfg = WindowMvalue(iWIND);
                
                dR   = 0.021/Ug + 0.022;  % ブラインド
                WindowUvalueList(iWIND) = 1/(1/Ufg + dR);  % ブラインド ＋ 建具
                
                Mgs = -0.1331 * Mg^2 + 0.8258 * Mg;  % ブラインド
                WindowMyuList(iWIND) = (Mfg/Mg) * Mgs;   % ブラインド ＋ 建具
                
            else
                WindowUvalueList(iWIND) = WindowUvalue(iWIND);
                WindowMyuList(iWIND) = WindowMvalue(iWIND);
            end
            
        end
        
    else
        
        % ガラス記号が入力されている場合（ルート１）
        if strcmp(confG(iWIND,3),'Null') == 0
            
            % データベースを検索
            iDBfind = NaN;
            for iDB = 3:size(perDB_WIND,1)
                if strcmp(perDB_WIND(iDB,1),confG(iWIND,3))
                    iDBfind  = iDB;
                end
            end
            
            if isnan(iDBfind)
                error('ガラス記号が不正です')
            else
                
                if strcmp(confG(iWIND,2),'resin') && strcmp(confG(iWIND,4),'0')  % 樹脂、ブラインド無
                    WindowUvalueList(iWIND) = str2double(perDB_WIND(iDBfind,3));
                    WindowMyuList(iWIND)    = str2double(perDB_WIND(iDBfind,5));
                elseif strcmp(confG(iWIND,2),'resin') && strcmp(confG(iWIND,4),'1')  % 樹脂、ブラインド有
                    WindowUvalueList(iWIND) = str2double(perDB_WIND(iDBfind,4));
                    WindowMyuList(iWIND)    = str2double(perDB_WIND(iDBfind,6));
                elseif strcmp(confG(iWIND,2),'complex') && strcmp(confG(iWIND,4),'0')  % 複合、ブラインド無
                    WindowUvalueList(iWIND) = str2double(perDB_WIND(iDBfind,7));
                    WindowMyuList(iWIND)    = str2double(perDB_WIND(iDBfind,9));
                elseif strcmp(confG(iWIND,2),'complex') && strcmp(confG(iWIND,4),'1')  % 複合、ブラインド有
                    WindowUvalueList(iWIND) = str2double(perDB_WIND(iDBfind,8));
                    WindowMyuList(iWIND)    = str2double(perDB_WIND(iDBfind,10));
                elseif strcmp(confG(iWIND,2),'aluminum') && strcmp(confG(iWIND,4),'0')  % アルミ、ブラインド無
                    WindowUvalueList(iWIND) = str2double(perDB_WIND(iDBfind,11));
                    WindowMyuList(iWIND)    = str2double(perDB_WIND(iDBfind,13));
                elseif strcmp(confG(iWIND,2),'aluminum') && strcmp(confG(iWIND,4),'1')  % アルミ、ブラインド有
                    WindowUvalueList(iWIND) = str2double(perDB_WIND(iDBfind,12));
                    WindowMyuList(iWIND)    = str2double(perDB_WIND(iDBfind,14));
                else
                    error('建具種類の入力が不正です')
                end
                
            end
            
        else
            
            % ガラスの熱貫流率と日射熱取得率が入力されている場合（ルート２）
            if strcmp(confG(iWIND,5),'Null') == 0 && strcmp(confG(iWIND,6),'Null') == 0
                
                Ug = str2double(confG(iWIND,5));
                Mg = str2double(confG(iWIND,6));
                
                if strcmp(confG(iWIND,2),'resin') && strcmp(confG(iWIND,4),'0')  % 樹脂、ブラインド無
                    
                    dR   = 0;  % ブラインド
                    Ufg  = 0.6435 * Ug + 1.0577;  % 建具（樹脂）
                    WindowUvalueList(iWIND) = 1/(1/Ufg + dR);  % ブラインド ＋ 建具（樹脂）
                    
                    Mgs =  Mg;  % ブラインド
                    WindowMyuList(iWIND) = 0.72 * Mgs;   % ブラインド ＋ 建具（樹脂）

                   
                elseif strcmp(confG(iWIND,2),'resin') && strcmp(confG(iWIND,4),'1')  % 樹脂、ブラインド有
                    
                    dR   = 0.021/Ug + 0.022;  % ブラインド
                    Ufg  = 0.6435 * Ug + 1.0577;  % 建具（樹脂）
                    WindowUvalueList(iWIND) = 1/(1/Ufg + dR);  % ブラインド ＋ 建具（樹脂）
                    
                    Mgs = -0.1331 * Mg^2 + 0.8258 * Mg;  % ブラインド
                    WindowMyuList(iWIND) = 0.72 * Mgs;   % ブラインド ＋ 建具（樹脂）
                    
                elseif strcmp(confG(iWIND,2),'complex') && strcmp(confG(iWIND,4),'0')  % 複合、ブラインド無

                    dR   = 0;  % ブラインド
                    Ufg  = 0.7623 * Ug + 1.2363;  % 建具（複合）
                    WindowUvalueList(iWIND) = 1/(1/Ufg + dR);  % ブラインド ＋ 建具（複合）
                    
                    Mgs =  Mg;  % ブラインド
                    WindowMyuList(iWIND) = 0.80 * Mgs;   % ブラインド ＋ 建具
                    
                elseif strcmp(confG(iWIND,2),'complex') && strcmp(confG(iWIND,4),'1')  % 複合、ブラインド有

                    dR   = 0.021/Ug + 0.022;  % ブラインド
                    Ufg  = 0.7623 * Ug + 1.2363;  % 建具（複合）
                    WindowUvalueList(iWIND) = 1/(1/Ufg + dR);  % ブラインド ＋ 建具（複合）
                    
                    Mgs = -0.1331 * Mg^2 + 0.8258 * Mg;  % ブラインド
                    WindowMyuList(iWIND) = 0.80 * Mgs;   % ブラインド ＋ 建具（複合）
                    
                elseif strcmp(confG(iWIND,2),'aluminum') && strcmp(confG(iWIND,4),'0')  % アルミ、ブラインド無

                    dR   = 0;  % ブラインド
                    Ufg  = 0.7699 * Ug + 1.5782;  % 建具（アルミ）
                    WindowUvalueList(iWIND) = 1/(1/Ufg + dR);  % ブラインド ＋ 建具（アルミ）
                    
                    Mgs =  Mg;  % ブラインド
                    WindowMyuList(iWIND) = 0.80 * Mgs;   % ブラインド ＋ 建具（アルミ）
                    
                elseif strcmp(confG(iWIND,2),'aluminum') && strcmp(confG(iWIND,4),'1')  % アルミ、ブラインド有

                    dR   = 0.021/Ug + 0.022;  % ブラインド
                    Ufg  = 0.7699 * Ug + 1.5782;  % 建具（アルミ）
                    WindowUvalueList(iWIND) = 1/(1/Ufg + dR);  % ブラインド ＋ 建具（アルミ）
                    
                    Mgs = -0.1331 * Mg^2 + 0.8258 * Mg;  % ブラインド
                    WindowMyuList(iWIND) = 0.80 * Mgs;   % ブラインド ＋ 建具（アルミ）
                    
                else
                    error('建具種類の入力が不正です')
                end
                
            else
                error('ガラスの物性値の入力が不正です')
            end
            
        end
    end

% 遮蔽係数（SCCに押し込む）
WindowSCCList(iWIND) = WindowMyuList(iWIND)./0.88;
WindowSCRList(iWIND) = 0;

end

