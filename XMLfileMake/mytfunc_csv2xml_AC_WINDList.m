% mytfunc_csv2xml_AC_WINDList.m
%                                             by Masato Miyata 2012/02/12
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 窓の設定ファイルを読み込む。
%------------------------------------------------------------------------

function confG = mytfunc_csv2xml_AC_WINDList(filename)

windListData = textread(filename,'%s','delimiter','\n','whitespace','');

% 窓定義ファイルの読み込み
for i=1:length(windListData)
    conma = strfind(windListData{i},',');
    for j = 1:length(conma)
        if j == 1
            windListDataCell{i,j} = windListData{i}(1:conma(j)-1);
        elseif j == length(conma)
            windListDataCell{i,j}   = windListData{i}(conma(j-1)+1:conma(j)-1);
            windListDataCell{i,j+1} = windListData{i}(conma(j)+1:end);
        else
            windListDataCell{i,j} = windListData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 窓名称の読み込み
WINDList = {};
for iWIND = 11:size(windListDataCell,1)
    if isempty(windListDataCell(iWIND,1)) == 0
        WINDList = [WINDList;windListDataCell{iWIND,1}];
    end
end

% 仕様の読み込み
confG = {};
for iWIND = 1:size(WINDList,1)
    
    % ブラインドの種類は予め4種類作成する。
    for iBLIND = 1:4
        
        % 名称
        confG{3*(iWIND-1)+iBLIND,1} = strcat(windListDataCell{10+iWIND,1},'_',int2str(iBLIND-1));
        
        % 窓種類
        if isempty(windListDataCell{10+iWIND,2}) == 0
            confG{3*(iWIND-1)+iBLIND,2} = 'SNGL';
        elseif isempty(windListDataCell{10+iWIND,3}) == 0
            confG{3*(iWIND-1)+iBLIND,2} = 'DL06';
        elseif isempty(windListDataCell{10+iWIND,4}) == 0
            confG{3*(iWIND-1)+iBLIND,2} = 'DL12';
        else
            error('ガラスの種類が不正です')
        end
        
        % 品種番号
        confG{3*(iWIND-1)+iBLIND,3} = windListDataCell{10+iWIND,6};
        % ブラインド
        confG{3*(iWIND-1)+iBLIND,4} = int2str(iBLIND-1);
        
    end
    
end

end
