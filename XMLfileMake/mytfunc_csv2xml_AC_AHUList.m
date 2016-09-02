% mytfunc_csv2xml_AC_AHUList.m
%                                             by Masato Miyata 2012/10/30
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 空調機の設定ファイルを読み込む。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_AC_AHUList(xmldata,filename)

ahuListDataCell = mytfunc_CSVfile2Cell(filename);

% ahuListData = textread(filename,'%s','delimiter','\n','whitespace','');
% 
% % 空調機定義ファイルの読み込み
% for i=1:length(ahuListData)
%     conma = strfind(ahuListData{i},',');
%     for j = 1:length(conma)
%         if j == 1
%             ahuListDataCell{i,j} = ahuListData{i}(1:conma(j)-1);
%         elseif j == length(conma)
%             ahuListDataCell{i,j}   = ahuListData{i}(conma(j-1)+1:conma(j)-1);
%             ahuListDataCell{i,j+1} = ahuListData{i}(conma(j)+1:end);
%         else
%             ahuListDataCell{i,j} = ahuListData{i}(conma(j-1)+1:conma(j)-1);
%         end
%     end
% end

% 空白は直上の情報を埋める。
for iAHU = 11:size(ahuListDataCell,1)
    if isempty(ahuListDataCell{iAHU,1}) && isempty(ahuListDataCell{iAHU,3}) == 0
        if iAHU == 11
            error('最初の行は必ず空調機群名称を入力してください')
        else
            ahuListDataCell(iAHU,1) = ahuListDataCell(iAHU-1,1);         % 空調機群名称
            ahuListDataCell(iAHU,20:21) = ahuListDataCell(iAHU-1,20:21); % ポンプ群接続
            ahuListDataCell(iAHU,22:23) = ahuListDataCell(iAHU-1,22:23); % 熱源群接続
        end
    end
end


% 空調機群リストの作成
AHUListName = {};

for iAHU = 11:size(ahuListDataCell,1)
    if isempty(AHUListName)
        AHUListName = ahuListDataCell(iAHU,1);
    else
        check = 0;
        for iDB = 1:length(AHUListName)
            if strcmp(ahuListDataCell(iAHU,1),AHUListName(iDB))
                % 重複判定
                check = 1;
            end
        end
        if check == 0
            AHUListName = [AHUListName; ahuListDataCell(iAHU,1)];
        end
    end
end


% 情報の読み込み
for iAHUSET = 1:length(AHUListName)
    
    if isempty(AHUListName{iAHUSET}) == 0  % 名称が空白でなければ
        
        % 空調機群名称
        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).ATTRIBUTE.Name = AHUListName(iAHUSET,1);
        
        iCOUNT = 0;
        
        % 全行を検索
        for iDB = 11:size(ahuListDataCell,1)
            if strcmp(AHUListName(iAHUSET,1),ahuListDataCell(iDB,1))
                iCOUNT = iCOUNT + 1;
                
                % 空調機台数
                if isempty(ahuListDataCell{iDB,2}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Count = ahuListDataCell(iDB,2);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Count = 'Null';
                end
                
                % 空調機種類
                if isempty(ahuListDataCell{iDB,3}) == 0
                    if strcmp(ahuListDataCell(iDB,3),'空調機') || strcmp(ahuListDataCell(iDB,3),'AHU') || ...
                            strcmp(ahuListDataCell(iDB,3),'ＡＨＵ') || strcmp(ahuListDataCell(iDB,3),'空気調和機') || strcmp(ahuListDataCell(iDB,3),'外気処理空調機')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Type = 'AHU';
                    elseif strcmp(ahuListDataCell(iDB,3),'FCU') || strcmp(ahuListDataCell(iDB,3),'ＦＣＵ')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Type = 'FCU';
                    elseif strcmp(ahuListDataCell(iDB,3),'室内機') || strcmp(ahuListDataCell(iDB,3),'UNIT') || strcmp(ahuListDataCell(iDB,3),'ＵＮＩＴ')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Type = 'UNIT';
                    elseif strcmp(ahuListDataCell(iDB,3),'全熱交ユニット') || strcmp(ahuListDataCell(iDB,3),'AEX') || strcmp(ahuListDataCell(iDB,3),'ＡＥＸ')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Type = 'AEX';
                    elseif strcmp(ahuListDataCell(iDB,3),'送風機')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Type = 'FAN';
                    elseif strcmp(ahuListDataCell(iDB,3),'放熱器')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Type = 'RADIATOR';
                    else
                        error('空調機タイプ %s は不正です',ahuListDataCell{iDB,3})
                    end
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Type = 'Null';
                end
                
                % 冷房能力
                if isempty(ahuListDataCell{iDB,4}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.CoolingCapacity = ahuListDataCell(iDB,4);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.CoolingCapacity = 'Null';
                end
                
                % 暖房能力
                if isempty(ahuListDataCell{iDB,5}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatingCapacity = ahuListDataCell(iDB,5);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatingCapacity = 'Null';
                end
                
                % 給気風量
                if isempty(ahuListDataCell{iDB,6}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.SupplyAirVolume = ahuListDataCell(iDB,6);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.SupplyAirVolume = 'Null';
                end
                
                % 給気ファン消費電力
                if isempty(ahuListDataCell{iDB,7}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.SupplyFanPower  = ahuListDataCell(iDB,7);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.SupplyFanPower = 'Null';
                end
                
                % 還気ファン消費電力
                if isempty(ahuListDataCell{iDB,8}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.ReturnFanPower  = ahuListDataCell(iDB,8);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.ReturnFanPower = 'Null';
                end
                
                % 外気ファン消費電力
                if isempty(ahuListDataCell{iDB,9}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.OutsideAirFanPower  = ahuListDataCell(iDB,9);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.OutsideAirFanPower = 'Null';
                end
                
                % 排気ファン消費電力
                if isempty(ahuListDataCell{iDB,10}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.ExitFanPower = ahuListDataCell(iDB,10);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.ExitFanPower = 'Null';
                end
                
                % 風量制御
                if isempty(ahuListDataCell{iDB,11}) == 0
                    if strcmp(ahuListDataCell(iDB,11),'定風量制御')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.FlowControl = 'CAV';
                    elseif strcmp(ahuListDataCell(iDB,11),'ダンパー制御')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.FlowControl = 'VAV_Damper';
                    elseif strcmp(ahuListDataCell(iDB,11),'サクションベーン制御')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.FlowControl = 'VAV_Vane';
                    elseif strcmp(ahuListDataCell(iDB,11),'可変ピッチ制御')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.FlowControl = 'VAV_Pitch';
                    elseif strcmp(ahuListDataCell(iDB,11),'回転数制御')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.FlowControl = 'VAV_INV';
                    else
                        error('送風量制御の設定が不正です。')
                    end
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.FlowControl = 'Null';
                end
                
                % VAV最小開度 [-]
                if isempty(ahuListDataCell{iDB,12}) == 0
                    % [%]から[-]へ
                    if str2double(ahuListDataCell(iDB,12)) > 1 && str2double(ahuListDataCell(iDB,12)) < 100
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.MinDamperOpening = num2str(str2double(ahuListDataCell(iDB,12))/100);
                    elseif str2double(ahuListDataCell(iDB,12)) == 0
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.MinDamperOpening = '0';
                    else
                        error('VAV最小開度 %s は無効です。',ahuListDataCell{iDB,12})
                    end
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.MinDamperOpening = 'Null';
                end
                
                % 外気カット制御
                if isempty(ahuListDataCell{iDB,13}) == 0
                    if strcmp(ahuListDataCell(iDB,13),'有')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.OutsideAirCutControl = 'True';
                    elseif strcmp(ahuListDataCell(iDB,13),'無')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.OutsideAirCutControl = 'False';
                    else
                        error('外気カット制御の設定が不正です。「有」か「無」で指定してください。')
                    end
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.OutsideAirCutControl = 'Null';
                end
                
                % 外気冷房制御
                if isempty(ahuListDataCell{iDB,14}) == 0
                    if strcmp(ahuListDataCell(iDB,14),'有')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.FreeCoolingControl = 'True';
                    elseif strcmp(ahuListDataCell(iDB,14),'無')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.FreeCoolingControl = 'False';
                    else
                        error('外気冷房の設定が不正です。「有」か「無」で指定してください。')
                    end
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.FreeCoolingControl = 'Null';
                end
                
                % 全熱交制御
                if isempty(ahuListDataCell{iDB,15}) == 0
                    if strcmp(ahuListDataCell(iDB,15),'有')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchanger = 'True';
                    elseif strcmp(ahuListDataCell(iDB,15),'無')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchanger = 'False';
                    else
                        error('全熱交換機の設定が不正です。「有」か「無」で指定してください。')
                    end
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchanger = 'Null';
                end
                
                % 全熱交換風量
                if isempty(ahuListDataCell{iDB,16}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchangerVolume = ahuListDataCell(iDB,16);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchangerVolume = 'Null';
                end
                
                % 全熱交換機効率
                if isempty(ahuListDataCell{iDB,17}) == 0
                    % [%]から[-]へ
                    if str2double(ahuListDataCell(iDB,17)) > 1 && str2double(ahuListDataCell(iDB,17)) < 100
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchangerEfficiency = num2str(str2double(ahuListDataCell(iDB,17))/100);
                    elseif str2double(ahuListDataCell(iDB,17)) == 0
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchangerEfficiency = '0';
                    else
                        error('全熱交換効率は％で指定してください。')
                    end
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchangerEfficiency = 'Null';
                end
                
                % 全熱交バイパス
                if isempty(ahuListDataCell{iDB,18}) == 0
                    if strcmp(ahuListDataCell(iDB,18),'有')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchangerBypass = 'True';
                    elseif strcmp(ahuListDataCell(iDB,18),'無')
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchangerBypass = 'False';
                    else
                        error('全熱交換機のバイパスの有無は「有」か「無」で指定してください。')
                    end
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchangerBypass = 'Null';
                end
                
                % 全熱交換機ロータ消費電力
                if isempty(ahuListDataCell{iDB,19}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchangerPower = ahuListDataCell(iDB,19);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.HeatExchangerPower = 'Null';
                end
                
                % 備考（機器表の記号）
                if isempty(ahuListDataCell{iDB,24}) == 0
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Info = ahuListDataCell(iDB,24);
                else
                    xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).AirHandlingUnit(iCOUNT).ATTRIBUTE.Info = 'Null';
                end
                
                
                % ポンプ接続　と　熱源接続
                % 最初のif文は暫定措置。ポンプ接続と熱源接続をシートの左端へ移動し、一番上の行に入力するルールを作ればこのif文は不要。
                if strcmp(ahuListDataCell(iDB,3),'空調機') || strcmp(ahuListDataCell(iDB,3),'FCU') || strcmp(ahuListDataCell(iDB,3),'室内機')
                    
                    % ポンプ接続（冷）
                    if isempty(ahuListDataCell{iDB,20}) == 0
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).SecondaryPumpRef.ATTRIBUTE.Cooling = ...
                            strcat(ahuListDataCell(iDB,20));
                    else
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).SecondaryPumpRef.ATTRIBUTE.Cooling = 'Null';
                    end
                    
                    % ポンプ接続（温）
                    if isempty(ahuListDataCell{iDB,21}) == 0
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).SecondaryPumpRef.ATTRIBUTE.Heating = ...
                            strcat(ahuListDataCell(iDB,21));
                    else
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).SecondaryPumpRef.ATTRIBUTE.Heating = 'Null';
                    end
                    
                    % 熱源接続（冷）
                    if isempty(ahuListDataCell{iDB,22}) == 0
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).HeatSourceSetRef.ATTRIBUTE.Cooling = ...
                            strcat(ahuListDataCell(iDB,22));
                    else
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).HeatSourceSetRef.ATTRIBUTE.Cooling = 'Null';
                    end
                    
                    % 熱源接続（温）
                    if isempty(ahuListDataCell{iDB,23}) == 0
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).HeatSourceSetRef.ATTRIBUTE.Heating = ...
                            strcat(ahuListDataCell(iDB,23));
                    else
                        xmldata.AirConditioningSystem.AirHandlingUnitSet(iAHUSET).HeatSourceSetRef.ATTRIBUTE.Heating = 'Null';
                    end
                    
                end

            end
        end
        
        if iCOUNT == 0
            error('該当する空調機がありません');
        end
    end
end


