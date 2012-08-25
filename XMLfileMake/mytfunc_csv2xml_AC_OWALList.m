% mytfunc_csv2xml_AC_OWALList.m
%                                             by Masato Miyata 2012/02/12
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 外壁の設定ファイルを読み込む。
%------------------------------------------------------------------------

function xmldata = mytfunc_csv2xml_AC_OWALList(xmldata,filename)

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
OWALNum  = [];
for iOWAL = 11:size(owalListDataCell,1)
    if isempty(owalListDataCell{iOWAL,1}) == 0
        OWALList = [OWALList;owalListDataCell{iOWAL,1}];
        OWALNum  = [OWALNum; iOWAL];
    end
end

% 仕様の読み込み
for iOWALList = 1:size(OWALList,1)
    
    % 名称
    xmldata.AirConditioningSystem.WallConfigure(iOWALList).ATTRIBUTE.Name = OWALList{iOWALList};
    
    % 外壁か設置壁か
    if strcmp(owalListDataCell{OWALNum(iOWALList),2},'外壁')
        xmldata.AirConditioningSystem.WallConfigure(iOWALList).ATTRIBUTE.WallType   = 'Air';
    elseif strcmp(owalListDataCell{OWALNum(iOWALList),2},'接地壁')
        xmldata.AirConditioningSystem.WallConfigure(iOWALList).ATTRIBUTE.WallType   = 'Ground';
    end
    
    % 熱貫流率
    if isempty(owalListDataCell{OWALNum(iOWALList),3}) == 0
        xmldata.AirConditioningSystem.WallConfigure(iOWALList).ATTRIBUTE.Uvalue   = owalListDataCell(OWALNum(iOWALList),3);
    else
        xmldata.AirConditioningSystem.WallConfigure(iOWALList).ATTRIBUTE.Uvalue   = 'Null';
    end
    
    
    % 各レイヤー
    count = 0;
    for iELE = 1:10
        
        num = OWALNum(iOWALList)+iELE;
        
        if num < size(owalListDataCell,1)
            if isempty(owalListDataCell{num,4}) == 0
                
                count = count + 1;
                
                % 層番号
                xmldata.AirConditioningSystem.WallConfigure(iOWALList).MaterialRef(count).ATTRIBUTE.Layer = int2str(count);
                
                % 材料番号
                xmldata.AirConditioningSystem.WallConfigure(iOWALList).MaterialRef(count).ATTRIBUTE.MaterialNumber = ...
                    owalListDataCell{num,4};
                
                % 材料名
                if isempty(owalListDataCell{num,5}) == 0
                    xmldata.AirConditioningSystem.WallConfigure(iOWALList).MaterialRef(count).ATTRIBUTE.MaterialName   = ...
                        owalListDataCell{num,5};
                else
                    xmldata.AirConditioningSystem.WallConfigure(iOWALList).MaterialRef(count).ATTRIBUTE.MaterialName   = '';
                end
                
                % 厚み
                if isempty(owalListDataCell{num,6}) == 0
                    xmldata.AirConditioningSystem.WallConfigure(iOWALList).MaterialRef(count).ATTRIBUTE.WallThickness  = ...
                        owalListDataCell{num,6};
                else
                    xmldata.AirConditioningSystem.WallConfigure(iOWALList).MaterialRef(count).ATTRIBUTE.WallThickness  = '0';
                end
                
                % 備考
                if isempty(owalListDataCell{num,7}) == 0
                    xmldata.AirConditioningSystem.WallConfigure(iOWALList).MaterialRef(count).ATTRIBUTE.Info  = ...
                        owalListDataCell{num,7};
                else
                    xmldata.AirConditioningSystem.WallConfigure(iOWALList).MaterialRef(count).ATTRIBUTE.Info  = 'Null';
                end
                
            end
        end
    end
end


% 内壁追加
lastnum = length(xmldata.AirConditioningSystem.WallConfigure);

xmldata.AirConditioningSystem.WallConfigure(lastnum+1).ATTRIBUTE.Name = '内壁_天井面';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).ATTRIBUTE.WallType = 'Internal';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).ATTRIBUTE.Uvalue   = '0.00';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(1).ATTRIBUTE.Layer = '1';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(1).ATTRIBUTE.MaterialNumber = '75';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(1).ATTRIBUTE.MaterialName = '';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(1).ATTRIBUTE.WallThickness = '12';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(2).ATTRIBUTE.Layer = '2';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(2).ATTRIBUTE.MaterialNumber = '32';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(2).ATTRIBUTE.MaterialName = '';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(2).ATTRIBUTE.WallThickness = '9';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(3).ATTRIBUTE.Layer = '3';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(3).ATTRIBUTE.MaterialNumber = '92';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(3).ATTRIBUTE.MaterialName = '';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(3).ATTRIBUTE.WallThickness = '0';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(4).ATTRIBUTE.Layer = '4';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(4).ATTRIBUTE.MaterialNumber = '22';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(4).ATTRIBUTE.MaterialName = '';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(4).ATTRIBUTE.WallThickness = '150';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(5).ATTRIBUTE.Layer = '5';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(5).ATTRIBUTE.MaterialNumber = '41';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(5).ATTRIBUTE.MaterialName = '';
xmldata.AirConditioningSystem.WallConfigure(lastnum+1).MaterialRef(5).ATTRIBUTE.WallThickness = '3';

xmldata.AirConditioningSystem.WallConfigure(lastnum+2).ATTRIBUTE.Name = '内壁_床面';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).ATTRIBUTE.WallType = 'Internal';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).ATTRIBUTE.Uvalue   = '0.00';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(1).ATTRIBUTE.Layer = '1';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(1).ATTRIBUTE.MaterialNumber = '41';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(1).ATTRIBUTE.MaterialName = '';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(1).ATTRIBUTE.WallThickness = '3';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(2).ATTRIBUTE.Layer = '2';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(2).ATTRIBUTE.MaterialNumber = '22';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(2).ATTRIBUTE.MaterialName = '';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(2).ATTRIBUTE.WallThickness = '150';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(3).ATTRIBUTE.Layer = '3';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(3).ATTRIBUTE.MaterialNumber = '92';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(3).ATTRIBUTE.MaterialName = '';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(3).ATTRIBUTE.WallThickness = '0';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(4).ATTRIBUTE.Layer = '4';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(4).ATTRIBUTE.MaterialNumber = '32';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(4).ATTRIBUTE.MaterialName = '';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(4).ATTRIBUTE.WallThickness = '9';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(5).ATTRIBUTE.Layer = '5';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(5).ATTRIBUTE.MaterialNumber = '75';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(5).ATTRIBUTE.MaterialName = '';
xmldata.AirConditioningSystem.WallConfigure(lastnum+2).MaterialRef(5).ATTRIBUTE.WallThickness = '12';


end