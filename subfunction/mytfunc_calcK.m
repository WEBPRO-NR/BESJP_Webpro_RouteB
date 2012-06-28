function [WallNameList,WallUvalueList,WindowNameList,WindowUvalueList,WindowMyuList] = ...
    mytfunc_calcK(dumy)


% WCONf[^x[XΜΗέέ
DB_WCON = textread('./newhasp/wcontabl.dat','%s','delimiter','\n','whitespace','');

% ΚΜi[ perDB_WCON(ήΏΤAPΚAM`±¦AeΟδM)
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

% SIPΚnΙΟX
for iDB = 1:length(perDB_WCON)
    if perDB_WCON{iDB,2} == 0 && perDB_WCON{iDB,3} ~= 0
        % kcal/mhC ©η@W/(mEK)
        perDB_WCON{iDB,3} = perDB_WCON{iDB,3} * 4.2*1000/3600;
    end
end

% WINDf[^x[XΜΗέέ
DB_WIND = textread('./newhasp/wndwtabl.dat','%s','delimiter','\n','whitespace','');

% ΚΜi[ perDB_WCON(ήΏΤAPΚAM`±¦AeΟδM)
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


%% OΗdlΜvZ

% WCONt@CΜΗέέ
WCON = textread('./database/WCON.csv','%s','delimiter','\n','whitespace','');

% ΚΜi[ perDB_WCON(ήΏΤAPΚAM`±¦AeΟδM)
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

% OΗΜUlvZ
WallUvalueList = [];
for iWALL = 1:size(perWCON,1)-1
    
    % ξρ²o
    tmp = str2double(perWCON(iWALL+1,3:end));
    
    R = 1/9 + 1/23;
    for iELE = 1:length(tmp)/2
        
        % ήΏΤ
        elenum = tmp(2*(iELE)-1);
        
        if isnan(elenum) == 0
            
            if elenum <= 90
                % σCwΘO
                R = R +  0.001*tmp(2*(iELE))/perDB_WCON{elenum,3};
            else
                % σCw
                R = R +  perDB_WCON{elenum,3};
            end
        end
    end
    
    % ΫΆ
    WallUvalueList = [WallUvalueList; 1/R];
    
end



%% dlΜvZ

% WINDt@CΜΗέέ
WIND = textread('./database/WIND.csv','%s','delimiter','\n','whitespace','');

% ΚΜi[ perDB_WIND(ΌΜAνAiνΤAuCh)
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
    
    if strcmp(perWIND(iWIND,2),'SNGL')
        startNum = 2;
    elseif strcmp(perWIND(iWIND,2),'DL06')
        startNum = 110;
    elseif strcmp(perWIND(iWIND,2),'DL12')
        startNum = 298;
    end
    
    if strcmp(perWIND(iWIND,4),'0')
        blindnum = 3;
    elseif strcmp(perWIND(iWIND,4),'1')
        blindnum = 6;
    elseif strcmp(perWIND(iWIND,4),'2')
        blindnum = 9;
    elseif strcmp(perWIND(iWIND,4),'3')
        blindnum = 12;
    end
    
    WindowUvalueList(iWIND-1) = perDB_WIND{startNum + str2double(perWIND{iWIND,3}),blindnum};
    WindowMyuList(iWIND-1)    = 0.88 * (perDB_WIND{startNum + str2double(perWIND{iWIND,3}),blindnum+1} + ...
        perDB_WIND{startNum + str2double(perWIND{iWIND,3}),blindnum+2} );
    
end








