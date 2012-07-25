% mytfunc_csv2xml_AC_AHUList.m
%                                             by Masato Miyata 2012/02/12
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 空調機の設定ファイルを読み込む。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_AC_AHUList(xmldata,filename)

ahuListData = textread(filename,'%s','delimiter','\n','whitespace','');

% 空調機定義ファイルの読み込み
for i=1:length(ahuListData)
    conma = strfind(ahuListData{i},',');
    for j = 1:length(conma)
        if j == 1
            ahuListDataCell{i,j} = ahuListData{i}(1:conma(j)-1);
        elseif j == length(conma)
            ahuListDataCell{i,j}   = ahuListData{i}(conma(j-1)+1:conma(j)-1);
            ahuListDataCell{i,j+1} = ahuListData{i}(conma(j)+1:end);
        else
            ahuListDataCell{i,j} = ahuListData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 情報の読み込み(CSVファイルから選択)

for iAHU = 11:size(ahuListDataCell,1)
    
    if isempty(ahuListDataCell(iAHU,1))
        
        eval(['disp(''空白行を飛ばします： ',filename,'　の ',int2str(iAHU),'行目'')'])
        
    else
        
        % 空調機名称
        xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.Name = ahuListDataCell(iAHU,1);
                
        % 空調機台数
        if isempty(ahuListDataCell{iAHU,2}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.Count = ahuListDataCell(iAHU,2);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.Count = 'Null';
        end
        
        % 空調機種類
        if isempty(ahuListDataCell{iAHU,3}) == 0
            if strcmp(ahuListDataCell(iAHU,3),'空調機') || strcmp(ahuListDataCell(iAHU,3),'AHU') || ...
                    strcmp(ahuListDataCell(iAHU,3),'ＡＨＵ') || strcmp(ahuListDataCell(iAHU,3),'空気調和機') || strcmp(ahuListDataCell(iAHU,3),'外気処理空調機')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.Type = 'AHU';
            elseif strcmp(ahuListDataCell(iAHU,3),'FCU') || strcmp(ahuListDataCell(iAHU,3),'ＦＣＵ')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.Type = 'FCU';
            elseif strcmp(ahuListDataCell(iAHU,3),'室内機') || strcmp(ahuListDataCell(iAHU,3),'UNIT') || strcmp(ahuListDataCell(iAHU,3),'ＵＮＩＴ')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.Type = 'UNIT';
            elseif strcmp(ahuListDataCell(iAHU,3),'全熱交ユニット') || strcmp(ahuListDataCell(iAHU,3),'AEX') || strcmp(ahuListDataCell(iAHU,3),'ＡＥＸ')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.Type = 'AEX';
            else
                error('空調機タイプ %s は不正です',ahuListDataCell{iAHU,3})
            end
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.Type = 'Null';
        end
        
        % 冷房能力
        if isempty(ahuListDataCell{iAHU,4}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.CoolingCapacity = ahuListDataCell(iAHU,4);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.CoolingCapacity = 'Null';
        end
        
        % 暖房能力
        if isempty(ahuListDataCell{iAHU,5}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatingCapacity = ahuListDataCell(iAHU,5);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatingCapacity = 'Null';
        end
        
        % 給気風量
        if isempty(ahuListDataCell{iAHU,6}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.SupplyAirVolume = ahuListDataCell(iAHU,6);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.SupplyAirVolume = 'Null';
        end
        
        % 給気ファン消費電力
        if isempty(ahuListDataCell{iAHU,7}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.SupplyFanPower  = ahuListDataCell(iAHU,7);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.SupplyFanPower = 'Null';
        end
        
        % 還気ファン消費電力
        if isempty(ahuListDataCell{iAHU,8}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.ReturnFanPower  = ahuListDataCell(iAHU,8);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.ReturnFanPower = 'Null';
        end
        
        % 外気ファン消費電力
        if isempty(ahuListDataCell{iAHU,9}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.OutsideAirFanPower  = ahuListDataCell(iAHU,9);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.OutsideAirFanPower = 'Null';
        end
        
        % 排気ファン消費電力
        if isempty(ahuListDataCell{iAHU,10}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.ExitFanPower = ahuListDataCell(iAHU,10);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.ExitFanPower = 'Null';
        end
        
        % 風量制御
        if isempty(ahuListDataCell{iAHU,11}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.FlowControl = ahuListDataCell(iAHU,11);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.FlowControl = 'Null';
        end
        
        % VAV最小開度 [-]
        if isempty(ahuListDataCell{iAHU,12}) == 0
            % [%]から[-]へ
            if str2double(ahuListDataCell(iAHU,12)) > 1 && str2double(ahuListDataCell(iAHU,12)) < 100
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.MinDamperOpening = num2str(str2double(ahuListDataCell(iAHU,12))/100);
            elseif str2double(ahuListDataCell(iAHU,12)) == 0
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.MinDamperOpening = '0';
            else
                error('VAV最小開度 %s は無効です。',ahuListDataCell{iAHU,12})
            end
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.MinDamperOpening = 'Null';
        end
        
        % 外気カット制御
        if isempty(ahuListDataCell{iAHU,13}) == 0
            if strcmp(ahuListDataCell(iAHU,13),'有')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.OutsideAirCutControl = 'True';
            elseif strcmp(ahuListDataCell(iAHU,13),'無')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.OutsideAirCutControl = 'False';
            else
                error('外気カット制御の設定が不正です。「有」か「無」で指定してください。')
            end
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.OutsideAirCutControl = 'Null';
        end
        
        % 外気冷房制御
        if isempty(ahuListDataCell{iAHU,14}) == 0
            if strcmp(ahuListDataCell(iAHU,14),'有')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.FreeCoolingControl = 'True';
            elseif strcmp(ahuListDataCell(iAHU,14),'無')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.FreeCoolingControl = 'False';
            else
                error('外気冷房の設定が不正です。「有」か「無」で指定してください。')
            end
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.FreeCoolingControl = 'Null';
        end
        
        % 全熱交制御
        if isempty(ahuListDataCell{iAHU,15}) == 0
            if strcmp(ahuListDataCell(iAHU,15),'有')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchanger = 'True';
            elseif strcmp(ahuListDataCell(iAHU,15),'無')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchanger = 'False';
            else
                error('全熱交換機の設定が不正です。「有」か「無」で指定してください。')
            end
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchanger = 'Null';
        end
        
        % 全熱交換風量
        if isempty(ahuListDataCell{iAHU,16}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchangerVolume = ahuListDataCell(iAHU,16);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchangerVolume = 'Null';
        end
        
        % 全熱交換機効率
        if isempty(ahuListDataCell{iAHU,17}) == 0
            % [%]から[-]へ
            if str2double(ahuListDataCell(iAHU,17)) > 1 && str2double(ahuListDataCell(iAHU,17)) < 100
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchangerEfficiency = num2str(str2double(ahuListDataCell(iAHU,17))/100);
            elseif str2double(ahuListDataCell(iAHU,17)) == 0
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchangerEfficiency = '0';
            else
                error('全熱交換効率は％で指定してください。')
            end
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchangerEfficiency = 'Null';
        end
        
        % 全熱交バイパス
        if isempty(ahuListDataCell{iAHU,18}) == 0
            if strcmp(ahuListDataCell(iAHU,18),'有')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchangerBypass = 'True';
            elseif strcmp(ahuListDataCell(iAHU,18),'無')
                xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchangerBypass = 'False';
            else
                error('全熱交換機のバイパスの有無は「有」か「無」で指定してください。')
            end
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchangerBypass = 'Null';
        end
        
        % 全熱交換機ロータ消費電力
        if isempty(ahuListDataCell{iAHU,19}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchangerPower = ahuListDataCell(iAHU,19);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.HeatExchangerPower = 'Null';
        end
        
        % ポンプ接続（冷）
        if isempty(ahuListDataCell{iAHU,20}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).SecondaryPumpRef.ATTRIBUTE.CoolingID = ...
                strcat(ahuListDataCell(iAHU,20));
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).SecondaryPumpRef.ATTRIBUTE.CoolingID = 'Null';
        end
        
        % ポンプ接続（温）
        if isempty(ahuListDataCell{iAHU,21}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).SecondaryPumpRef.ATTRIBUTE.HeatingID = ...
                strcat(ahuListDataCell(iAHU,21));
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).SecondaryPumpRef.ATTRIBUTE.HeatingID = 'Null';
        end
        
        % 熱源接続（冷）
        if isempty(ahuListDataCell{iAHU,22}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).HeatSourceSetRef.ATTRIBUTE.CoolingID = ...
                strcat(ahuListDataCell(iAHU,22));
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).HeatSourceSetRef.ATTRIBUTE.CoolingID = 'Null';
        end
        
        % 熱源接続（温）
        if isempty(ahuListDataCell{iAHU,23}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).HeatSourceSetRef.ATTRIBUTE.HeatingID = ...
                strcat(ahuListDataCell(iAHU,23));
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).HeatSourceSetRef.ATTRIBUTE.HeatingID = 'Null';
        end
       
        % 機器表の記号
        if isempty(ahuListDataCell{iAHU,24}) == 0
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.Info = ahuListDataCell(iAHU,24);
        else
            xmldata.AirConditioningSystem.AirHandlingUnit(iAHU-10).ATTRIBUTE.Info = 'Null';
        end
        
    end
end



