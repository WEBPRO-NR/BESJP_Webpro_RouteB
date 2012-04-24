% 基準値を求めるプログラム

function y = mytfunc_calcStandardValue(bldgType,roomType,roomArea,lineNum)

y = 0;

% データベースファイル読込み（基準値）
DB_standardValue = textread('./database/ROOM_STANDARDVALUE.csv','%s','delimiter','\n','whitespace','');

%----------------------------------
% 基準値ファイルの読み込み
for i=1:length(DB_standardValue)
    conma = strfind(DB_standardValue{i},',');
    for j = 1:length(conma)
        if j == 1
            perDB_standardValue{i,j} = DB_standardValue{i}(1:conma(j)-1);
        elseif j == length(conma)
            perDB_standardValue{i,j}   = DB_standardValue{i}(conma(j-1)+1:conma(j)-1);
            perDB_standardValue{i,j+1} = DB_standardValue{i}(conma(j)+1:end);
        else
            perDB_standardValue{i,j} = DB_standardValue{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

numOfRoom = length(roomType);

for iROOM = 1:numOfRoom
    check = 0;
    for iDB = 2:size(perDB_standardValue,1)
        if strcmp(bldgType(iROOM),perDB_standardValue(iDB,2)) && ...
                strcmp(roomType(iROOM),perDB_standardValue(iDB,5))
            check = 1;
            y = y + str2double(perDB_standardValue(iDB,5+lineNum))*roomArea(iROOM);
        end
    end
    if check == 0
        error('室用途が見つかりません')
    end
end


