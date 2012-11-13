% mytfunc_csv2xml_AC_RefList.m
%                                             by Masato Miyata 2012/02/12
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 熱源の設定ファイルを読み込む。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_AC_RefList(xmldata,filename)

refListData = textread(filename,'%s','delimiter','\n','whitespace','');

% 熱源群定義ファイルの読み込み
for i=1:length(refListData)
    conma = strfind(refListData{i},',');
    for j = 1:length(conma)
        if j == 1
            refListDataCell{i,j} = refListData{i}(1:conma(j)-1);
        elseif j == length(conma)
            refListDataCell{i,j}   = refListData{i}(conma(j-1)+1:conma(j)-1);
            refListDataCell{i,j+1} = refListData{i}(conma(j)+1:end);
        else
            refListDataCell{i,j} = refListData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% （最初の3列の）空白は直上の情報を埋める。
for iREF = 11:size(refListDataCell,1)
    if isempty(refListDataCell{iREF,1})
        if iREF == 11
            error('最初の行は必ず熱源群コードを入力してください')
        else
            refListDataCell(iREF,1:3) = refListDataCell(iREF-1,1:3);
        end
    end
end

% （蓄熱関連）空白は直上の情報を埋める。
for iREF = 11:size(refListDataCell,1)
    if isempty(refListDataCell{iREF,4})
        if iREF == 11
            refListDataCell{iREF,4} = 'None';
        else
            refListDataCell(iREF,4) = refListDataCell(iREF-1,4);
        end
        
    else
        
        if strcmp(refListDataCell(iREF,4),'蓄熱')
            refListDataCell{iREF,4} = 'Charge';
        elseif strcmp(refListDataCell(iREF,4),'放熱')
            refListDataCell{iREF,4} = 'Discharge';
        else
            refListDataCell{iREF,4} = 'None';
        end
        
    end
end


%% 熱源群リスト(蓄熱モード別)を作成
RefListName = {};
RefListCHmode = {};
RefListQuantityConrol = {};
RefListThermalStorage_Mode = {};
RefListThermalStorage_StorageSize = {};

for iREF = 11:size(refListDataCell,1)
    
    if isempty(RefListName)
        RefListName                       = refListDataCell(iREF,1);
        RefListCHmode                     = refListDataCell(iREF,2);
        RefListQuantityConrol             = refListDataCell(iREF,3);
        RefListThermalStorage_Mode        = refListDataCell(iREF,4);
        RefListThermalStorage_StorageSize = refListDataCell(iREF,5);
    else
        check = 0;
        for iDB = 1:length(RefListName)
            if strcmp(refListDataCell(iREF,1),RefListName(iDB)) && strcmp(refListDataCell(iREF,4),RefListThermalStorage_Mode(iDB))
                % 重複判定
                check = 1;
            end
        end
        if check == 0
            % 熱源群名称追加
            RefListName                       = [RefListName; refListDataCell(iREF,1)];
            RefListCHmode                     = [RefListCHmode; refListDataCell(iREF,2)];
            RefListQuantityConrol             = [RefListQuantityConrol; refListDataCell(iREF,3)];
            RefListThermalStorage_Mode        = [RefListThermalStorage_Mode; refListDataCell(iREF,4)];
            RefListThermalStorage_StorageSize = [RefListThermalStorage_StorageSize; refListDataCell(iREF,5)];
        end
    end
    
end

% 熱源群のループ
for iREFSET = 1:length(RefListName)
    
    % 群の属性
    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.Name = RefListName(iREFSET,1);
    
    if strcmp(RefListCHmode(iREFSET,1),'有')
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.CHmode = 'True';
    else
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.CHmode = 'False';
    end
    
    if strcmp(RefListQuantityConrol(iREFSET,1),'有')
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.QuantityControl = 'True';
    else
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.QuantityControl = 'False';
    end
    
    % 蓄熱モード
    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.StorageMode = RefListThermalStorage_Mode(iREFSET,1);
    
    if isempty(RefListThermalStorage_StorageSize{iREFSET,1}) == 0
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.StorageSize = RefListThermalStorage_StorageSize(iREFSET,1);
    else
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.StorageSize = 'Null';
    end
    
    
    iCOUNT = 0;
    for iDB = 11:size(refListDataCell,1)
        
        % 空白行を飛ばす
        if isempty(refListDataCell{iDB,6}) == 0
            
            if strcmp(RefListName(iREFSET,1),refListDataCell(iDB,1)) && strcmp(RefListThermalStorage_Mode(iREFSET,1),refListDataCell(iDB,4))
                
                iCOUNT = iCOUNT + 1;
                
                if strcmp(refListDataCell(iDB,6),'空冷ヒートポンプ')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'AirSourceHP';
                elseif strcmp(refListDataCell(iDB,6),'空冷ヒートポンプ(圧縮機台数制御)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'AirSourceHP_MultiCompressor';
                elseif strcmp(refListDataCell(iDB,6),'水冷式スクリューチラー')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'WaterCoolingChiller_Screw';
                elseif strcmp(refListDataCell(iDB,6),'水冷式スクロールチラー')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'WaterCoolingChiller_Scroll';
                elseif strcmp(refListDataCell(iDB,6),'ターボ冷凍機')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'TurboREF';
                elseif strcmp(refListDataCell(iDB,6),'インバータターボ冷凍機')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'TurboREF_INV';
                elseif strcmp(refListDataCell(iDB,6),'ブラインターボ冷凍機(蓄熱時)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'TurboREF_Brine_Storage';
                elseif strcmp(refListDataCell(iDB,6),'ブラインターボ冷凍機(追掛時)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'TurboREF_Brine_nonStorage';
                elseif strcmp(refListDataCell(iDB,6),'氷蓄熱用空冷式ヒートポンプ')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'AirSourceHP_ICE';
                elseif strcmp(refListDataCell(iDB,6),'氷蓄熱用空冷式ヒートポンプ(圧縮機台数制御)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'AirSourceHP_MultiCompresor_ICE';
                elseif strcmp(refListDataCell(iDB,6),'氷蓄熱用水冷式スクリューチラー')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'WaterCoolingChiller_Screw_ICE';
                elseif strcmp(refListDataCell(iDB,6),'氷蓄熱用水冷式スクロールチラー')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'WaterCoolingChiller_Scroll_ICE';
                elseif strcmp(refListDataCell(iDB,6),'直焚吸収冷温水機(都市ガス)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'AbsorptionWCB_DF_CityGas';
                elseif strcmp(refListDataCell(iDB,6),'直焚吸収冷温水機(LPG)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'AbsorptionWCB_DF_LPG';
                elseif strcmp(refListDataCell(iDB,6),'直焚吸収冷温水機(重油)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'AbsorptionWCB_DF_Oil';
                elseif strcmp(refListDataCell(iDB,6),'直焚吸収冷温水機(灯油)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'AbsorptionWCB_DF_Kerosene';
                elseif strcmp(refListDataCell(iDB,6),'蒸気吸収冷凍機')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'AbsorptionChiller_Steam';
                elseif strcmp(refListDataCell(iDB,6),'温水焚吸収冷凍機')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'AbsorptionChiller_HotWater';
                elseif strcmp(refListDataCell(iDB,6),'小型貫流ボイラ(都市ガス)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'OnePassBoiler_CityGas';
                elseif strcmp(refListDataCell(iDB,6),'小型貫流ボイラ(LPG)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'OnePassBoiler_LPG';
                elseif strcmp(refListDataCell(iDB,6),'小型貫流ボイラ(重油)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'OnePassBoiler_Oil';
                elseif strcmp(refListDataCell(iDB,6),'小型貫流ボイラ(灯油)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'OnePassBoiler_Kerosene';
                elseif strcmp(refListDataCell(iDB,6),'真空温水ヒータ(都市ガス)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'VacuumBoiler_CityGas';
                elseif strcmp(refListDataCell(iDB,6),'真空温水ヒータ(LPG)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'VacuumBoiler_LPG';
                elseif strcmp(refListDataCell(iDB,6),'真空温水ヒータ(重油)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'VacuumBoiler_Oil';
                elseif strcmp(refListDataCell(iDB,6),'真空温水ヒータ(灯油)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'VacuumBoiler_Kerosene';
                elseif strcmp(refListDataCell(iDB,6),'ビル用マルチエアコン(電気式)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'EHP';
                elseif strcmp(refListDataCell(iDB,6),'ビル用マルチエアコン(都市ガス式)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'GHP_CityGas';
                elseif strcmp(refListDataCell(iDB,6),'ビル用マルチエアコン(LPG)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'GHP_LPG';
                elseif strcmp(refListDataCell(iDB,6),'ルームエアコン')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'RoomAirConditioner';
                elseif strcmp(refListDataCell(iDB,6),'FF式暖房機(都市ガス)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'FFtypeHeater_CityGas';
                elseif strcmp(refListDataCell(iDB,6),'FF式暖房機(LPG)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'FFtypeHeater_LPG';
                elseif strcmp(refListDataCell(iDB,6),'FF式暖房機(灯油)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'FFtypeHeater_Kerosene';
                elseif strcmp(refListDataCell(iDB,6),'地域熱供給(冷水)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'DHC_CoolingWater';
                elseif strcmp(refListDataCell(iDB,6),'地域熱供給(温水)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'DHC_HeatingWater';
                elseif strcmp(refListDataCell(iDB,6),'地域熱供給(蒸気)')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'DHC_Steam';
                elseif strcmp(refListDataCell(iDB,6),'熱交換器')
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'HEX';
                else
                    refListDataCell(iDB,6)
                    error('熱源種類が不正です。')
                end
                
                if isempty(refListDataCell{iDB,7}) == 0
                    if length(refListDataCell{iDB,7}) > 1 && strcmp(refListDataCell{iDB,7}(end-1:end),'番目')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Order_Cooling  = refListDataCell{iDB,7}(1:end-2);
                    else
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Order_Cooling  = refListDataCell{iDB,7};
                    end
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Order_Cooling  = 'Null';
                end
                
                if isempty(refListDataCell{iDB,8}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Count_Cooling  = refListDataCell(iDB,8);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Count_Cooling  = 'Null';
                end
                
                if isempty(refListDataCell{iDB,9}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.SupplyWaterTemp_Cooling  = refListDataCell(iDB,9);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.SupplyWaterTemp_Cooling  = 'Null';
                end
                
                if isempty(refListDataCell{iDB,10}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Capacity_Cooling  = refListDataCell(iDB,10);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Capacity_Cooling  = 'Null';
                end
                
                if isempty(refListDataCell{iDB,11}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.MainPower_Cooling   = refListDataCell(iDB,11);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.MainPower_Cooling   = 'Null';
                end
                
                if isempty(refListDataCell{iDB,12}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.SubPower_Cooling   = refListDataCell(iDB,12);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.SubPower_Cooling   = 'Null';
                end
                
                if isempty(refListDataCell{iDB,13}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.PrimaryPumpPower_Cooling   = refListDataCell(iDB,13);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.PrimaryPumpPower_Cooling   = 'Null';
                end
                
                if isempty(refListDataCell{iDB,14}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTCapacity_Cooling   = refListDataCell(iDB,14);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTCapacity_Cooling   = 'Null';
                end
                
                if isempty(refListDataCell{iDB,15}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTFanPower_Cooling   = refListDataCell(iDB,15);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTFanPower_Cooling   = 'Null';
                end
                
                if isempty(refListDataCell{iDB,16}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTPumpPower_Cooling   = refListDataCell(iDB,16);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTPumpPower_Cooling   = 'Null';
                end
                
                if isempty(refListDataCell{iDB,17}) == 0
                    if length(refListDataCell{iDB,17}) > 1 && strcmp(refListDataCell{iDB,17}(end-1:end),'番目')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Order_Heating   = refListDataCell{iDB,17}(1:end-2);
                    else
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Order_Heating   = refListDataCell{iDB,17};
                    end
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Order_Heating   = 'Null';
                end
                
                if isempty(refListDataCell{iDB,18}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Count_Heating     = refListDataCell(iDB,18);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Count_Heating     = 'Null';
                end
                
                if isempty(refListDataCell{iDB,19}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.SupplyWaterTemp_Heating     = refListDataCell(iDB,19);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.SupplyWaterTemp_Heating     = 'Null';
                end
                
                if isempty(refListDataCell{iDB,20}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Capacity_Heating   = refListDataCell(iDB,20);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Capacity_Heating   = 'Null';
                end
                
                if isempty(refListDataCell{iDB,21}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.MainPower_Heating    = refListDataCell(iDB,21);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.MainPower_Heating    = 'Null';
                end
                
                if isempty(refListDataCell{iDB,22}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.SubPower_Heating   = refListDataCell(iDB,22);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.SubPower_Heating   = 'Null';
                end
                
                if isempty(refListDataCell{iDB,23}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.PrimaryPumpPower_Heating   = refListDataCell(iDB,23);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.PrimaryPumpPower_Heating   = 'Null';
                end
                
                if isempty(refListDataCell{iDB,24}) == 0
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Info = refListDataCell(iDB,24);
                else
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Info = 'Null';
                end
                
            end
        end
    end
    
    if iCOUNT == 0
        error('熱源群 %s に属する機器が見つかりません。',RefListName{iREFSET,1})
    end
    
end





