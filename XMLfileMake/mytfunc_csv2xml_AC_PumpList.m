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

% 空白は直上の情報を埋める。
for iPUMP = 11:size(pumpListDataCell,1)
    if isempty(pumpListDataCell{iPUMP,1}) && isempty(pumpListDataCell{iPUMP,5}) == 0
        if iPUMP == 11
            error('最初の行は必ずポンプ群コードを入力してください')
        else
            pumpListDataCell(iPUMP,1:4) = pumpListDataCell(iPUMP-1,1:4);
        end
    end
end

% ポンプ群リストの作成
PumpListName = {};
PumpListQcontrol = {};
PumpListdTc  = {};
PumpListdTh  = {};

for iPUMP = 11:size(pumpListDataCell,1)
    if isempty(PumpListName)
        PumpListName = pumpListDataCell(iPUMP,1);
        PumpListQcontrol = pumpListDataCell(iPUMP,2);
        PumpListdTc  = pumpListDataCell(iPUMP,3);
        PumpListdTh  = pumpListDataCell(iPUMP,4);
    else
        check = 0;
        for iDB = 1:length(PumpListName)
            if strcmp(pumpListDataCell(iPUMP,1),PumpListName(iDB))
                % 重複判定
                check = 1;
            end
        end
        if check == 0
            PumpListName = [PumpListName; pumpListDataCell(iPUMP,1)];
            PumpListQcontrol = [PumpListQcontrol; pumpListDataCell(iPUMP,2)];
            PumpListdTc  = [PumpListdTc; pumpListDataCell(iPUMP,3)];
            PumpListdTh  = [PumpListdTh; pumpListDataCell(iPUMP,4)];
        end
    end
end


% 情報の読み込み
for iPUMPSET = 1:length(PumpListName)
    
    if isempty(PumpListName{iPUMPSET})==0
        
        % ID
        xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).ATTRIBUTE.Name = PumpListName(iPUMPSET,1);
        
        % 台数制御
        if strcmp(PumpListQcontrol(iPUMPSET,1),'有')
            xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).ATTRIBUTE.QuantityControl = 'True';
        else
            xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).ATTRIBUTE.QuantityControl = 'False';
        end
        
        % 設計温度差
        if isempty(PumpListdTc{iPUMPSET,1})==0
            xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).ATTRIBUTE.deltaTemp_Cooling = PumpListdTc(iPUMPSET,1);
        else
            xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).ATTRIBUTE.deltaTemp_Cooling = 'Null';
        end
        if isempty(PumpListdTh{iPUMPSET,1})==0
            xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).ATTRIBUTE.deltaTemp_Heating = PumpListdTh(iPUMPSET,1);
        else
            xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).ATTRIBUTE.deltaTemp_Heating = 'Null';
        end
        
        iCOUNT = 0;
        
        for iDB = 11:size(pumpListDataCell,1)
            if strcmp(PumpListName(iPUMPSET,1),pumpListDataCell(iDB,1))
                iCOUNT = iCOUNT + 1;
                
                % 運転順位                
                if isempty(pumpListDataCell{iDB,5}) == 0
                    if length(pumpListDataCell{iDB,5}) > 1 && strcmp(pumpListDataCell{iDB,5}(end-1:end),'番目')
                        xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.Order  = pumpListDataCell{iDB,5}(1:end-2);
                    else
                        xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.Order  = pumpListDataCell{iDB,5};
                    end
                else
                    xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.Order  = 'Null';
                end
                
                % ポンプ台数
                if isempty(pumpListDataCell{iDB,6})==0
                    xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.Count = pumpListDataCell(iDB,6);
                else
                    error('2次ポンプの台数 %s は不正です。', pumpListDataCell{iDB,6})
                end
                
                % 冷水流量
                if isempty(pumpListDataCell{iDB,7})==0
                    xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.RatedFlow = pumpListDataCell(iDB,7);
                else
                    error('2次ポンプの定格流量が不正です。')
                end
                
                % 定格消費電力
                if isempty(pumpListDataCell{iDB,8})==0
                    xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.RatedPower = pumpListDataCell(iDB,8);
                else
                    error('2次ポンプの定格消費電力が不正です。')
                end
                
                % 流量制御方式
                if isempty(pumpListDataCell{iDB,9})==0
                    xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.FlowControl = pumpListDataCell(iDB,9);
                else
                    xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.FlowControl = 'Null';
                end
                
                % 変流量時最小流量
                if isempty(pumpListDataCell{iDB,10})==0
                    xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.MinValveOpening = pumpListDataCell(iDB,10);
                else
                    xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.MinValveOpening = 'Null';
                end
                
                % 備考
                if isempty(pumpListDataCell{iDB,11})==0
                    xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.Info = pumpListDataCell(iDB,11);
                else
                    xmldata.AirConditioningSystem.SecondaryPumpSet(iPUMPSET).SecondaryPump(iCOUNT).ATTRIBUTE.Info = 'Null';
                end
                
            end
        end
        
        if iCOUNT == 0
            error('二次ポンプ群 %s に属する機器が見つかりません。',PumpListName{iPUMPSET,1})
        end
        
    end
    
end
