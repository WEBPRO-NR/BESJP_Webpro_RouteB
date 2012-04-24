% mytfunc_csv2xml_AC_OWALList.m
%                                             by Masato Miyata 2012/02/12
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 外壁の設定ファイルを読み込む。
%------------------------------------------------------------------------

function confW = mytfunc_csv2xml_AC_OWALList(filename)

owalListData = textread(filename,'%s','delimiter','\n','whitespace','');

% 外壁定義ファイルの読み込み
for i=1:length(owalListData)
    conma = strfind(owalListData{i},',');
    for j = 1:length(conma)
        if j == 1
            owalListDataCell{i,j} = owalListData{i}(1:conma(j)-1);
        elseif j == length(conma)
            owalListDataCell{i,j}   = owalListData{i}(conma(j-1)+1:conma(j)-1);
            owalListDataCell{i,j+1} = owalListData{i}(conma(j)+1:end);
        else
            owalListDataCell{i,j} = owalListData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 外壁名称の読み込み
OWALList = {};
for iOWAL = 11:size(owalListDataCell,1)
    if isempty(owalListDataCell(iOWAL,1)) == 0
        OWALList = [OWALList;owalListDataCell{iOWAL,1}];
    end
end

confW = {};
for iOWALList = 1:size(OWALList,1)
    
    % 名称
    confW{iOWALList,1} = OWALList{iOWALList};
    % WCON名
    confW{iOWALList,2} = strcat('W',int2str(iOWALList));
    
    for iELE = 2:10
        
        num = 10+11*(iOWALList-1)+iELE;
        
        if num < size(owalListDataCell,1)
            if isempty(owalListDataCell{num,4}) == 0
                
                confW{iOWALList,2*(iELE-2)+2+1} = owalListDataCell{num,4};
                if isempty(owalListDataCell{num,7}) == 0
                    confW{iOWALList,2*(iELE-2)+2+2} = owalListDataCell{num,7};
                else
                    confW{iOWALList,2*(iELE-2)+2+2} = '0';
                end
                
            end
        end 
    end
end

% 内壁追加
confW{iOWALList+1,1} = '内壁_天井面';
confW{iOWALList+1,2} = 'CEI';
confW{iOWALList+1,3} = '75';
confW{iOWALList+1,4} = '12';
confW{iOWALList+1,5} = '32';
confW{iOWALList+1,6} = '9';
confW{iOWALList+1,7} = '92';
confW{iOWALList+1,8} = '0';
confW{iOWALList+1,9} = '22';
confW{iOWALList+1,10} = '150';
confW{iOWALList+1,11} = '41';
confW{iOWALList+1,12} = '3';

confW{iOWALList+2,1} = '内壁_床面';
confW{iOWALList+2,2} = 'FLO';
confW{iOWALList+2,3} = '41';
confW{iOWALList+2,4} = '3';
confW{iOWALList+2,5} = '22';
confW{iOWALList+2,6} = '150';
confW{iOWALList+2,7} = '92';
confW{iOWALList+2,8} = '0';
confW{iOWALList+2,9} = '32';
confW{iOWALList+2,10} = '9';
confW{iOWALList+2,11} = '75';
confW{iOWALList+2,12} = '12';


end