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

% 熱源群の名称を拾い上げる。
refNameList_C = {};
refNameList_H = {};
for iREF = 11:size(refListDataCell,1)
    if iREF == 11  % 最初だけ例外処理
        if isempty(refListDataCell{iREF,11}) == 0  % 冷熱源がある場合
            refNameList_C = refListDataCell(iREF,1);
        end
        if isempty(refListDataCell{iREF,20}) == 0 % 温熱源がある場合
            refNameList_H = refListDataCell(iREF,1);
        end
        
    else
        
        if isempty(refListDataCell{iREF,11}) == 0  % 冷熱源がある場合
            tmp = 0;
            for iREFLIST = 1:size(refNameList_C,1)
                if strcmp(refListDataCell(iREF,1),refNameList_C(iREFLIST))
                    tmp = 1; % 既にLISTにある場合
                end
            end
            if tmp == 0 % LISTにない場合は追加
                refNameList_C = [refNameList_C;refListDataCell(iREF,1)];
            end
        end
        
        if isempty(refListDataCell{iREF,20}) == 0  % 温熱源がある場合
            tmp = 0;
            for iREFLIST = 1:size(refNameList_H,1)
                if strcmp(refListDataCell(iREF,1),refNameList_H(iREFLIST))
                    tmp = 1; % 既にLISTにある場合
                end
            end
            if tmp == 0 % LISTにない場合は追加
                refNameList_H = [refNameList_H;refListDataCell(iREF,1)];
            end
        end
    end
end


% 最大設定台数
maxNum = 10;

% XMLファイルに追加(冷熱源)
for iREFLIST = 1:size(refNameList_C)
    for iREF = 11:size(refListDataCell,1)
        if strcmp(refNameList_C(iREFLIST),refListDataCell(iREF,1))
            
            xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.ID  = strcat(refListDataCell(iREF,1),'_C');
            xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.Mode = 'Cooling';
            
            % 蓄熱制御
            if strcmp(refListDataCell(iREF,3),'有')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.ThermalStorage = 'True';
            elseif strcmp(refListDataCell(iREF,3),'無')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.ThermalStorage = 'False';
            else
                error('熱源の蓄熱槽の設定が不正です。')
            end
            
            % 台数制御
            if strcmp(refListDataCell(iREF,4),'有')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.QuantityControl = 'True';
            elseif strcmp(refListDataCell(iREF,4),'無')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.QuantityControl = 'False';
            else
                error('熱源の台数制御の設定が不正です。')
            end
            
            
            for iNum = 1:maxNum
                
                eval(['numName = ''',int2str(iNum),'番目'';'])
                
                if strcmp(refListDataCell{iREF,9},numName)
                    
                    % 運転順位
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Order = int2str(iNum);
                    
                    % 台数
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Count  = refListDataCell(iREF,10);
                    
                    % 機器種類
                    if strcmp(refListDataCell(iREF,8),'ターボ冷凍機（標準，ベーン制御）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype1';
                    elseif strcmp(refListDataCell(iREF,8),'ターボ冷凍機（高効率，ベーン制御）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype2';
                    elseif strcmp(refListDataCell(iREF,8),'ターボ冷凍機（高効率，インバータ制御）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype3';
                    elseif strcmp(refListDataCell(iREF,8),'空冷ヒートポンプ（スクリュー，スライド弁）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype4';
                    elseif strcmp(refListDataCell(iREF,8),'空冷ヒートポンプ（スクリュー，インバータ）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype5';
                    elseif strcmp(refListDataCell(iREF,8),'空冷ヒートポンプ（スクロール，圧縮機台数制御）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype6';
                    elseif strcmp(refListDataCell(iREF,8),'水冷チラー（スクリュー，スライド弁）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype7';
                    elseif strcmp(refListDataCell(iREF,8),'水冷チラー（スクリュー，インバータ）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype8';
                    elseif strcmp(refListDataCell(iREF,8),'水冷チラー（スクロール，圧縮機台数制御）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype9';
                    elseif strcmp(refListDataCell(iREF,8),'直焚吸収冷温水器（三重効用）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype10';
                    elseif strcmp(refListDataCell(iREF,8),'直焚吸収冷温水器（ニ重効用）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype11';
                    elseif strcmp(refListDataCell(iREF,8),'直焚吸収冷温水器（高期間効率）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype12';
                    elseif strcmp(refListDataCell(iREF,8),'蒸気焚き吸収式冷温水器（二重効用）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype13';
                    elseif strcmp(refListDataCell(iREF,8),'温水焚き吸収式冷温水器（一重効用）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype14';
                    elseif strcmp(refListDataCell(iREF,8),'排熱投入型吸収式冷温水器（二重効用）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype15';
                    elseif strcmp(refListDataCell(iREF,8),'ボイラ（小型貫流ボイラ）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype16';
                    elseif strcmp(refListDataCell(iREF,8),'ボイラ（真空温水ヒータ）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype17';
                    elseif strcmp(refListDataCell(iREF,8),'電気式ビル用マルチ')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype18';
                    elseif strcmp(refListDataCell(iREF,8),'ガス式ビル用マルチ')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype19';
                    else
                        refListDataCell(iREF,8)
                        error('熱源種類が不正です。')
                    end
                    
                    % 冷凍能力
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Capacity = refListDataCell(iREF,11);
                    % 主機エネルギー消費量
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.MainPower = refListDataCell(iREF,12);
                    
                    % 補機消費電力
                    if isempty(refListDataCell{iREF,13})
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.SubPower = '0';
                    else
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.SubPower = refListDataCell(iREF,13);
                    end
                    
                    % 一次ポンプ消費電力
                    if isempty(refListDataCell{iREF,14})
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.PrimaryPumpPower = '0';
                    else
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.PrimaryPumpPower = refListDataCell(iREF,14);
                    end
                    
                    % 冷却塔冷却能力
                    if isempty(refListDataCell{iREF,15})
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.CTCapacity = '0';
                    else
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.CTCapacity = refListDataCell(iREF,15);
                    end
                    
                    % 冷却塔ファン消費電力
                    if isempty(refListDataCell{iREF,16})
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.CTFanPower = '0';
                    else
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.CTFanPower = refListDataCell(iREF,16);
                    end
                    
                    % 冷却塔ポンプ消費電力
                    if isempty(refListDataCell{iREF,17})
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.CTPumpPower = '0';
                    else
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.CTPumpPower = refListDataCell(iREF,17);
                    end
                end
            end
            
        end
    end
end

% XMLファイルに追加(温熱源)
for iREFLISTH = 1:size(refNameList_H)
    
    iREFLIST = iREFLISTH + length(refNameList_C);
    
    for iREF = 11:size(refListDataCell,1)
        if strcmp(refNameList_H(iREFLISTH),refListDataCell(iREF,1))
            
            xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.ID  = strcat(refListDataCell(iREF,1),'_H');
            xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.Mode = 'Heating';
            
            % 蓄熱制御
            if strcmp(refListDataCell(iREF,5),'有')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.ThermalStorage = 'True';
            elseif strcmp(refListDataCell(iREF,5),'無')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.ThermalStorage = 'False';
            else
                error('熱源の蓄熱槽の設定が不正です。')
            end
            
            % 台数制御
            if strcmp(refListDataCell(iREF,6),'有')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.QuantityControl = 'True';
            elseif strcmp(refListDataCell(iREF,6),'無')
                xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).ATTRIBUTE.QuantityControl = 'False';
            else
                error('熱源の台数制御の設定が不正です。')
            end
                       
            for iNum = 1:maxNum
                
                eval(['numName = ''',int2str(iNum),'番目'';'])
                
                if strcmp(refListDataCell{iREF,18},numName)

                    % 運転順位
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Order = int2str(iNum);

                    % 台数
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Count  = refListDataCell(iREF,19);
                    
                    if strcmp(refListDataCell(iREF,8),'ターボ冷凍機（標準，ベーン制御）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype1';
                    elseif strcmp(refListDataCell(iREF,8),'ターボ冷凍機（高効率，ベーン制御）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype2';
                    elseif strcmp(refListDataCell(iREF,8),'ターボ冷凍機（高効率，インバータ制御）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype3';
                    elseif strcmp(refListDataCell(iREF,8),'空冷ヒートポンプ（スクリュー，スライド弁）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype4';
                    elseif strcmp(refListDataCell(iREF,8),'空冷ヒートポンプ（スクリュー，インバータ）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype5';
                    elseif strcmp(refListDataCell(iREF,8),'空冷ヒートポンプ（スクロール，圧縮機台数制御）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype6';
                    elseif strcmp(refListDataCell(iREF,8),'水冷チラー（スクリュー，スライド弁）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype7';
                    elseif strcmp(refListDataCell(iREF,8),'水冷チラー（スクリュー，インバータ）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype8';
                    elseif strcmp(refListDataCell(iREF,8),'水冷チラー（スクロール，圧縮機台数制御）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype9';
                    elseif strcmp(refListDataCell(iREF,8),'直焚吸収冷温水器（三重効用）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype10';
                    elseif strcmp(refListDataCell(iREF,8),'直焚吸収冷温水器（ニ重効用）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype11';
                    elseif strcmp(refListDataCell(iREF,8),'直焚吸収冷温水器（高期間効率）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype12';
                    elseif strcmp(refListDataCell(iREF,8),'蒸気焚き吸収式冷温水器（二重効用）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype13';
                    elseif strcmp(refListDataCell(iREF,8),'温水焚き吸収式冷温水器（一重効用）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype14';
                    elseif strcmp(refListDataCell(iREF,8),'排熱投入型吸収式冷温水器（二重効用）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype15';
                    elseif strcmp(refListDataCell(iREF,8),'ボイラ（小型貫流ボイラ）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype16';
                    elseif strcmp(refListDataCell(iREF,8),'ボイラ（真空温水ヒータ）')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype17';
                    elseif strcmp(refListDataCell(iREF,8),'電気式ビル用マルチ')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype18';
                    elseif strcmp(refListDataCell(iREF,8),'ガス式ビル用マルチ')
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Type = 'Rtype19';
                    else
                        refListDataCell(iREF,8)
                        error('熱源種類が不正です。')
                    end

                    % 加熱能力
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.Capacity = refListDataCell(iREF,20);
                    
                    % 主機エネルギー消費量
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.MainPower = refListDataCell(iREF,21);
                    
                    % 補機消費電力
                    if isempty(refListDataCell{iREF,22})
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.SubPower = '0';
                    else
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.SubPower = refListDataCell(iREF,22);
                    end
                    
                    % 一次ポンプ消費電力
                    if isempty(refListDataCell{iREF,23})
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.PrimaryPumpPower = '0';
                    else
                        xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.PrimaryPumpPower = refListDataCell(iREF,23);
                    end
                    
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.CTCapacity = '0';
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.CTFanPower = '0';
                    xmldata.AirConditioningSystem.HeatSourceSet(iREFLIST).HeatSource(iNum).ATTRIBUTE.CTPumpPower = '0';
                    
                end
            end
            
        end
    end
end





