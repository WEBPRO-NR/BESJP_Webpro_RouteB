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
    
    % 冷水ポンプと温水ポンプの2台を作成する。
    
   
    if isempty(pumpListDataCell{iPUMP,1})==0

        % 運転モード
        xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.Mode = 'Cooling';
        xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.Mode = 'Heating';

         % ID
        xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.ID = strcat(pumpListDataCell(iPUMP,1),'_C');
        xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.ID = strcat(pumpListDataCell(iPUMP,1),'_H');
        
        % 名称
        if isempty(pumpListDataCell{iPUMP,2})==0
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.Name = pumpListDataCell(iPUMP,2);
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.Name = pumpListDataCell(iPUMP,2);
        else
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.Name = 'Null';
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.Name = 'Null';
        end
        
        % ポンプ台数
        if isempty(pumpListDataCell{iPUMP,3})==0
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.Count = pumpListDataCell(iPUMP,3);
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.Count = pumpListDataCell(iPUMP,3);
        else
            error('2次ポンプの台数が不正です。')
        end
        
        % 冷水流量
        if isempty(pumpListDataCell{iPUMP,4})==0
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.RatedFlow = pumpListDataCell(iPUMP,4);
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.RatedFlow = pumpListDataCell(iPUMP,4);
        else
            error('2次ポンプの定格流量が不正です。')
        end
        
        % 定格消費電力
        if isempty(pumpListDataCell{iPUMP,5})==0
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.RatedPower = pumpListDataCell(iPUMP,5);
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.RatedPower = pumpListDataCell(iPUMP,5);
        else
            error('2次ポンプの定格消費電力が不正です。')
        end
        
        % 流量制御方式
        if isempty(pumpListDataCell{iPUMP,6})==0
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.FlowControl = pumpListDataCell(iPUMP,6);
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.FlowControl = pumpListDataCell(iPUMP,6);
        else
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.FlowControl = 'CWV';
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.FlowControl = 'CWV';
        end
        
        % 台数制御
        xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.QuantityControl = 'True';
        xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.QuantityControl = 'True';
        
        % 設計温度差
        if isempty(pumpListDataCell{iPUMP,7})==0
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.deltaTemp = pumpListDataCell(iPUMP,7);
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.deltaTemp = pumpListDataCell(iPUMP,8);
        else
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+1).ATTRIBUTE.deltaTemp = '5';
            xmldata.AirConditioningSystem.SecondaryPump(2*(iPUMP-11)+2).ATTRIBUTE.deltaTemp = '5';
        end
        
        
    end
    
end


