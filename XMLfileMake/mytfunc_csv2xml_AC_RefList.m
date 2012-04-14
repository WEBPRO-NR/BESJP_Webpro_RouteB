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

% 空白は直上の情報を埋める。
for iREF = 11:size(refListDataCell,1)
    if isempty(refListDataCell{iREF,1})
        if iREF == 11
            error('最初の行は必ず熱源群コードを入力してください')
        else
            refListDataCell(iREF,1:6) = refListDataCell(iREF-1,1:6);
        end
    end
end

% 熱源群リストを作成
RefListName = {};
RefListSupplyMode = {};
RefListThermalStorage_Cooling = {};
RefListQuantityConrol_Cooling = {};
RefListThermalStorage_Heating = {};
RefListQuantityConrol_Heating = {};

for iREF = 11:size(refListDataCell,1)
    if isempty(RefListName)
        RefListName = refListDataCell(iREF,1);
        RefListSupplyMode = refListDataCell(iREF,2);
        RefListThermalStorage_Cooling = refListDataCell(iREF,3);
        RefListQuantityConrol_Cooling = refListDataCell(iREF,4);
        RefListThermalStorage_Heating = refListDataCell(iREF,5);
        RefListQuantityConrol_Heating = refListDataCell(iREF,6);
    else
        check = 0;
        for iDB = 1:length(RefListName)
            if strcmp(refListDataCell(iREF,1),RefListName(iDB))
                % 重複判定
                check = 1;
            end
        end
        if check == 0
            % 熱源群名称追加
            RefListName = [RefListName;refListDataCell(iREF,1)];
            RefListSupplyMode = [RefListSupplyMode;refListDataCell(iREF,2)];
            RefListThermalStorage_Cooling = [RefListThermalStorage_Cooling;refListDataCell(iREF,3)];
            RefListQuantityConrol_Cooling = [RefListQuantityConrol_Cooling;refListDataCell(iREF,4)];
            RefListThermalStorage_Heating = [RefListThermalStorage_Heating;refListDataCell(iREF,5)];
            RefListQuantityConrol_Heating = [RefListQuantityConrol_Heating;refListDataCell(iREF,6)];
        end
    end
end

for iREFSET = 1:length(RefListName)
    
    % 群の属性
    xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.Name = RefListName(iREFSET,1);
    
    if strcmp(RefListSupplyMode(iREFSET,1),'有')
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.SupplyMode = 'Both';
    else
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.SupplyMode = 'Each';
    end
    
    if strcmp(RefListThermalStorage_Cooling(iREFSET,1),'有')
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.ThermalStorage_Cooling = 'True';
    else
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.ThermalStorage_Cooling = 'False';
    end
    
    if strcmp(RefListQuantityConrol_Cooling(iREFSET,1),'有')
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.QuantityConrol_Cooling = 'True';
    else
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.QuantityConrol_Cooling = 'False';
    end
    
    if strcmp(RefListThermalStorage_Heating(iREFSET,1),'有')
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.ThermalStorage_Heating = 'True';
    else
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.ThermalStorage_Heating = 'False';
    end
    
    if strcmp(RefListQuantityConrol_Heating(iREFSET,1),'有')
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.QuantityConrol_Heating = 'True';
    else
        xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).ATTRIBUTE.QuantityConrol_Heating = 'False';
    end
    
    iCOUNT = 0;
    for iDB = 11:size(refListDataCell,1)
        if strcmp(RefListName(iREFSET,1),refListDataCell(iDB,1))
            iCOUNT = iCOUNT + 1;
            
            if isempty(refListDataCell{iDB,7}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Name = refListDataCell(iDB,7);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Name = 'Null';
            end
         
            if strcmp(refListDataCell(iREF,8),'ターボ冷凍機（標準，ベーン制御）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype1';
            elseif strcmp(refListDataCell(iREF,8),'ターボ冷凍機（高効率，ベーン制御）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype2';
            elseif strcmp(refListDataCell(iREF,8),'ターボ冷凍機（高効率，インバータ制御）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype3';
            elseif strcmp(refListDataCell(iREF,8),'空冷ヒートポンプ（スクリュー，スライド弁）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype4';
            elseif strcmp(refListDataCell(iREF,8),'空冷ヒートポンプ（スクリュー，インバータ）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype5';
            elseif strcmp(refListDataCell(iREF,8),'空冷ヒートポンプ（スクロール，圧縮機台数制御）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype6';
            elseif strcmp(refListDataCell(iREF,8),'水冷チラー（スクリュー，スライド弁）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype7';
            elseif strcmp(refListDataCell(iREF,8),'水冷チラー（スクリュー，インバータ）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype8';
            elseif strcmp(refListDataCell(iREF,8),'水冷チラー（スクロール，圧縮機台数制御）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype9';
            elseif strcmp(refListDataCell(iREF,8),'直焚吸収冷温水器（三重効用）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype10';
            elseif strcmp(refListDataCell(iREF,8),'直焚吸収冷温水器（ニ重効用）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype11';
            elseif strcmp(refListDataCell(iREF,8),'直焚吸収冷温水器（高期間効率）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype12';
            elseif strcmp(refListDataCell(iREF,8),'蒸気焚き吸収式冷温水器（二重効用）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype13';
            elseif strcmp(refListDataCell(iREF,8),'温水焚き吸収式冷温水器（一重効用）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype14';
            elseif strcmp(refListDataCell(iREF,8),'排熱投入型吸収式冷温水器（二重効用）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype15';
            elseif strcmp(refListDataCell(iREF,8),'ボイラ（小型貫流ボイラ）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype16';
            elseif strcmp(refListDataCell(iREF,8),'ボイラ（真空温水ヒータ）')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype17';
            elseif strcmp(refListDataCell(iREF,8),'電気式ビル用マルチ')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype18';
            elseif strcmp(refListDataCell(iREF,8),'ガス式ビル用マルチ')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Type = 'Rtype19';
            else
                refListDataCell(iREF,8)
                error('熱源種類が不正です。')
            end
            
            if isempty(refListDataCell{iDB,9}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Order_Cooling  = refListDataCell(iDB,9);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Order_Cooling  = 'Null';
            end
            
            if isempty(refListDataCell{iDB,10}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Count_Cooling  = refListDataCell(iDB,10);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Count_Cooling  = 'Null';
            end
            
            if isempty(refListDataCell{iDB,11}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Capacity_Cooling  = refListDataCell(iDB,11);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Capacity_Cooling  = 'Null';
            end
            
            if isempty(refListDataCell{iDB,12}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.MainPower_Cooling   = refListDataCell(iDB,12);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.MainPower_Cooling   = 'Null';
            end
            
            if isempty(refListDataCell{iDB,13}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.SubPower_Cooling   = refListDataCell(iDB,13);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.SubPower_Cooling   = 'Null';
            end
            
            if isempty(refListDataCell{iDB,14}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.PrimaryPumpPower_Cooling   = refListDataCell(iDB,14);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.PrimaryPumpPower_Cooling   = 'Null';
            end
            
            if isempty(refListDataCell{iDB,15}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTCapacity_Cooling   = refListDataCell(iDB,15);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTCapacity_Cooling   = 'Null';
            end
            
            if isempty(refListDataCell{iDB,16}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTFanPower_Cooling   = refListDataCell(iDB,16);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTFanPower_Cooling   = 'Null';
            end
            
            if isempty(refListDataCell{iDB,17}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTPumpPower_Cooling   = refListDataCell(iDB,17);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.CTPumpPower_Cooling   = 'Null';
            end
            
            if isempty(refListDataCell{iDB,18}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Order_Heating   = refListDataCell(iDB,18);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Order_Heating   = 'Null';
            end
            
            if isempty(refListDataCell{iDB,19}) == 0
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Count_Heating     = refListDataCell(iDB,19);
            else
                xmldata.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iCOUNT).ATTRIBUTE.Count_Heating     = 'Null';
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
            
        end
    end
    
    if iCOUNT == 0
        error('熱源群 %s に属する機器が見つかりません。',RefListName(iREFSET,1))
    end
    
end

