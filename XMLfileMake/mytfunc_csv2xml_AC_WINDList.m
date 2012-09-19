% mytfunc_csv2xml_AC_WINDList.m
%                                             by Masato Miyata 2012/02/12
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 窓の設定ファイルを読み込む。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_AC_WINDList(xmldata, filename)

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
WINDNum  = [];
for iWIND = 11:size(windListDataCell,1)
    if isempty(windListDataCell{iWIND,1}) == 0
        WINDList = [WINDList;windListDataCell{iWIND,1}];
        WINDNum  = [WINDNum; iWIND];
    end
end

% 仕様の読み込み
for iWIND = 1:size(WINDList,1)
    
    % 名称
    xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Name = ...
        windListDataCell{WINDNum(iWIND),1};
    
    % 総熱貫流率
    if isempty(windListDataCell{WINDNum(iWIND),2}) == 0
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Uvalue = ...
            windListDataCell{WINDNum(iWIND),2};
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Uvalue = 'Null';
    end
    
    % 日射侵入率
    if isempty(windListDataCell{WINDNum(iWIND),3}) == 0
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Mvalue = ...
            windListDataCell{WINDNum(iWIND),3};
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Mvalue = 'Null';
    end
    
    % 品種番号
    if isempty(windListDataCell{WINDNum(iWIND),4}) == 0
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.WindowTypeNumber = ...
            windListDataCell{WINDNum(iWIND),4};
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.WindowTypeNumber = 'Null';
    end
    
    % 窓種類
    WindowTypeClass = '';
    if strcmp(windListDataCell{WINDNum(iWIND),5},'単板ガラス')
        WindowTypeClass  = 'SNGL';
    elseif strcmp(windListDataCell{WINDNum(iWIND),5},'複層ガラス（中空層6mm）') || ...
            strcmp(windListDataCell{WINDNum(iWIND),5},'複層ガラス(中空層6mm)')
        WindowTypeClass = 'DL06';
    elseif strcmp(windListDataCell{WINDNum(iWIND),5},'複層ガラス（中空層12mm）') || ...
            strcmp(windListDataCell{WINDNum(iWIND),5},'複層ガラス（中空層12mm)')
        WindowTypeClass = 'DL12';
    else
        WindowTypeClass = windListDataCell{WINDNum(iWIND),5};
    end
    xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.WindowTypeClass = ...
        WindowTypeClass;
    
    % 備考
    if isempty(windListDataCell{WINDNum(iWIND),6}) == 0
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Info = ...
            windListDataCell{WINDNum(iWIND),6};
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Info = '';
    end
    
end

lastnum = length(xmldata.AirConditioningSystem.WindowConfigure);

xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.Name = 'Null';
xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.WindowTypeClass = 'SNGL';
xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.WindowTypeNumber = '1';
xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.Uvalue = 'Null';
xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.Mvalue = 'Null';
xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.Info = '';

end
