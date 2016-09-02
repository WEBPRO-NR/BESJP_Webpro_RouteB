% mytfunc_csv2xml_AC_WINDList.m
%                                             by Masato Miyata 2016/03/20
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 窓の設定ファイルを読み込む。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_AC_WINDList(xmldata, filename)

windListDataCell = mytfunc_CSVfile2Cell(filename);

% windListData = textread(filename,'%s','delimiter','\n','whitespace','');
% 
% % 窓定義ファイルの読み込み
% for i=1:length(windListData)
%     conma = strfind(windListData{i},',');
%     for j = 1:length(conma)
%         if j == 1
%             windListDataCell{i,j} = windListData{i}(1:conma(j)-1);
%         elseif j == length(conma)
%             windListDataCell{i,j}   = windListData{i}(conma(j-1)+1:conma(j)-1);
%             windListDataCell{i,j+1} = windListData{i}(conma(j)+1:end);
%         else
%             windListDataCell{i,j} = windListData{i}(conma(j-1)+1:conma(j)-1);
%         end
%     end
% end

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
    
    % 開口部名称（様式2-3 ①）
    xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Name = ...
        windListDataCell{WINDNum(iWIND),1};
    
    % 窓の熱貫流率（様式2-3 ②）
    if isempty(windListDataCell{WINDNum(iWIND),2}) == 0
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Uvalue = ...
            windListDataCell{WINDNum(iWIND),2};
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Uvalue = 'Null';
    end
    
    % 窓の日射熱取得率（様式2-3 ③）
    if isempty(windListDataCell{WINDNum(iWIND),3}) == 0
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Mvalue = ...
            windListDataCell{WINDNum(iWIND),3};
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Mvalue = 'Null';
    end
    
    % ガラスの種類（様式2-3 ⑤）
    if isempty(windListDataCell{WINDNum(iWIND),5}) == 0
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.glassTypeNumber = ...
            windListDataCell{WINDNum(iWIND),5};
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.glassTypeNumber = 'Null';
    end
    
    % 建具の種類（様式2-3 ④）
    if isempty(windListDataCell{WINDNum(iWIND),4}) == 0
        if strcmp(windListDataCell{WINDNum(iWIND),4},'樹脂')
            xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.frameType = 'resin';
        elseif strcmp(windListDataCell{WINDNum(iWIND),4},'アルミ樹脂複合')
            xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.frameType = 'complex';
        elseif strcmp(windListDataCell{WINDNum(iWIND),4},'アルミ')
            xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.frameType = 'aluminum';
        else
            error('建具の種類（様式2-3 ④）: 不正な選択肢です')
        end
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.frameType = 'Null';
    end
    
    % ガラスの熱貫流率（様式2-3 ⑥）
    if isempty(windListDataCell{WINDNum(iWIND),6}) == 0
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.glassUvalue = ...
            windListDataCell{WINDNum(iWIND),6};
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.glassUvalue = 'Null';
    end
    
    % ガラスの日射熱取得率（様式2-3 ⑦）
    if isempty(windListDataCell{WINDNum(iWIND),7}) == 0
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.glassMvalue = ...
            windListDataCell{WINDNum(iWIND),7};
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.glassMvalue = 'Null';
    end
    
    % 備考（様式2-3 ⑧）
    if size(windListDataCell,2) > 7
        if isempty(windListDataCell{WINDNum(iWIND),8}) == 0
            xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Info = ...
                windListDataCell{WINDNum(iWIND),8};
        else
            xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Info = '';
        end
    else
        xmldata.AirConditioningSystem.WindowConfigure(iWIND).ATTRIBUTE.Info = '';
    end
    
end

% lastnum = length(xmldata.AirConditioningSystem.WindowConfigure);
% 
% xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.Name = 'Null';
% xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.WindowTypeClass = 'SNGL';
% xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.WindowTypeNumber = '1';
% xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.Uvalue = 'Null';
% xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.Mvalue = 'Null';
% xmldata.AirConditioningSystem.WindowConfigure(lastnum+1).ATTRIBUTE.Info = '';

end
