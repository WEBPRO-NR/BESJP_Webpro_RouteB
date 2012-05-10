% mytfunc_csv2xml_AC_PumpList.m
%                                             by Masato Miyata 2012/02/12
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 二次ポンプの設定ファイルを読み込む。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_AC_PumpList(xmldata,filename)

pumpListData = textread(filename,'%s','delimiter','\n','whitespace','');

% ポンプ群定義ファイルの読み込み
for i=1:length(pumpListData)
    conma = strfind(pumpListData{i},',');
    for j = 1:length(conma)
        if j == 1
            pumpListDataCell{i,j} = pumpListData{i}(1:conma(j)-1);
        elseif j == length(conma)
            pumpListDataCell{i,j}   = pumpListData{i}(conma(j-1)+1:conma(j)-1);
            pumpListDataCell{i,j+1} = pumpListData{i}(conma(j)+1:end);
        else
            pumpListDataCell{i,j} = pumpListData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 情報の読み込み
for iPUMP = 11:size(pumpListDataCell,1)
       
    if isempty(pumpListDataCell{iPUMP,1})==0

        % ID
        xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.Name = pumpListDataCell(iPUMP,1);
        
        % 名称
        if isempty(pumpListDataCell{iPUMP,2})==0
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.System = pumpListDataCell(iPUMP,2);
        else
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.System = 'Null';
        end
        
        % ポンプ台数
        if isempty(pumpListDataCell{iPUMP,4})==0
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.Count = pumpListDataCell(iPUMP,4);
        else
            error('2次ポンプの台数が不正です。')
        end
        
        % 冷水流量
        if isempty(pumpListDataCell{iPUMP,5})==0
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.RatedFlow = pumpListDataCell(iPUMP,5);
        else
            error('2次ポンプの定格流量が不正です。')
        end
        
        % 定格消費電力
        if isempty(pumpListDataCell{iPUMP,6})==0
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.RatedPower = pumpListDataCell(iPUMP,6);
        else
            error('2次ポンプの定格消費電力が不正です。')
        end
        
        % 流量制御方式
        if isempty(pumpListDataCell{iPUMP,7})==0
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.FlowControl = pumpListDataCell(iPUMP,7);
        else
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.FlowControl = 'Null';
        end
        
        % 台数制御
        xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.QuantityControl = 'True';
        
        % 設計温度差
        if isempty(pumpListDataCell{iPUMP,9})==0
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.deltaTemp_Cooling = pumpListDataCell(iPUMP,9);
        else
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.deltaTemp_Cooling = 'Null';
        end
        if isempty(pumpListDataCell{iPUMP,10})==0
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.deltaTemp_Heating = pumpListDataCell(iPUMP,10);
        else
            xmldata.AirConditioningSystem.SecondaryPump(iPUMP-10).ATTRIBUTE.deltaTemp_Heating = 'Null';
        end
        
    end
    
end


