% csvファイルを読み込む
% 区切りはコンマ
% ダブルクォーテーションは削除

function celldata = mytfunc_CSVfile2Cell(filename)

csvdata = textread(filename,'%s','delimiter','\n','whitespace','');

for i=1:length(csvdata)
    conma = strfind(csvdata{i},',');
    for j = 1:length(conma)
        if j == 1
            celldata{i,j} = strrep(csvdata{i}(1:conma(j)-1),'"','');
        elseif j == length(conma)
            celldata{i,j}   = strrep(csvdata{i}(conma(j-1)+1:conma(j)-1),'"','');
            celldata{i,j+1} = strrep(csvdata{i}(conma(j)+1:end),'"','');
        else
            celldata{i,j} = strrep(csvdata{i}(conma(j-1)+1:conma(j)-1),'"','');
        end
    end
end

