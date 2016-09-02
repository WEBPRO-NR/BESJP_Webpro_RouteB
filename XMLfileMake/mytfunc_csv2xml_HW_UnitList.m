% mytfunc_csv2xml_HW_UnitList.m
%                                             by Masato Miyata 2012/04/02
%------------------------------------------------------------------------
% 省エネ基準：換気設定ファイルを作成する。
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_HW_UnitList(xmldata,filename)

% 給湯機器に関する情報
hwequipInfoCell = mytfunc_CSVfile2Cell(filename);
% 
% hwequipInfoCSV = textread(filename,'%s','delimiter','\n','whitespace','');
% 
% hwequipInfoCell = {};
% for i=1:length(hwequipInfoCSV)
%     conma = strfind(hwequipInfoCSV{i},',');
%     for j = 1:length(conma)
%         if j == 1
%             hwequipInfoCell{i,j} = hwequipInfoCSV{i}(1:conma(j)-1);
%         elseif j == length(conma)
%             hwequipInfoCell{i,j}   = hwequipInfoCSV{i}(conma(j-1)+1:conma(j)-1);
%             hwequipInfoCell{i,j+1} = hwequipInfoCSV{i}(conma(j)+1:end);
%         else
%             hwequipInfoCell{i,j} = hwequipInfoCSV{i}(conma(j-1)+1:conma(j)-1);
%         end
%     end
% end

equipInfo = {};
equipName = {};
equipCapacity = {};
equipEfficiency = {};
equipInsulation = {};
equipPipeSize = {};
equipSolarSystem = {};
SolorHeatingSurfaceArea = {};
SolorHeatingSurfaceAzimuth = {};
SolorHeatingSurfaceInclination = {};


for iUNIT = 11:size(hwequipInfoCell,1)
    
    if isempty(hwequipInfoCell{iUNIT,1}) == 0
    
        % 機器名称
        equipName = [equipName; hwequipInfoCell{iUNIT,1}];
        
        % 加熱容量
        equipCapacity = [equipCapacity; hwequipInfoCell{iUNIT,3}];
        
        % 熱源効率
        equipEfficiency = [equipEfficiency; hwequipInfoCell{iUNIT,4}];
        
        % 保温仕様
        if strcmp(hwequipInfoCell{iUNIT,5},'保温仕様１') || strcmp(hwequipInfoCell{iUNIT,5},'保温仕様1') 
            equipInsulation = [equipInsulation; 'Level1'];
        elseif strcmp(hwequipInfoCell{iUNIT,5},'保温仕様２') || strcmp(hwequipInfoCell{iUNIT,5},'保温仕様2')
            equipInsulation = [equipInsulation; 'Level2'];
        elseif strcmp(hwequipInfoCell{iUNIT,5},'保温仕様３') || strcmp(hwequipInfoCell{iUNIT,5},'保温仕様3')
            equipInsulation = [equipInsulation; 'Level3'];
        else
            equipInsulation = [equipInsulation; 'Level0'];
        end
        
        % 接続口径
        equipPipeSize = [equipPipeSize; hwequipInfoCell{iUNIT,6}];
        
        % 太陽熱利用
        if isempty(hwequipInfoCell{iUNIT,7})
            equipSolarSystem = [equipSolarSystem; 'None'];
            
            SolorHeatingSurfaceArea = ...
                [SolorHeatingSurfaceArea; 'Null'];
            SolorHeatingSurfaceAzimuth = ...
                [SolorHeatingSurfaceAzimuth; 'Null'];
            SolorHeatingSurfaceInclination = ...
                [SolorHeatingSurfaceInclination; 'Null'];
            
        else
            equipSolarSystem = [equipSolarSystem; 'True'];
            
            SolorHeatingSurfaceArea = ...
                [SolorHeatingSurfaceArea; hwequipInfoCell{iUNIT,7}];
            SolorHeatingSurfaceAzimuth = ...
                [SolorHeatingSurfaceAzimuth; hwequipInfoCell{iUNIT,8}];
            SolorHeatingSurfaceInclination = ...
                [SolorHeatingSurfaceInclination; hwequipInfoCell{iUNIT,9}];
        end
        
        % 機器表の記号
        if isempty(hwequipInfoCell{iUNIT,10})
            equipInfo = [equipInfo; 'Null'];
        else
            equipInfo = [equipInfo; hwequipInfoCell{iUNIT,10}];
        end
        
    end
end


% XMLファイル生成
for iUNIT = 1:size(equipName,1)
    
    xmldata.HotwaterSystems.Boiler(iUNIT).ATTRIBUTE.Info        = equipInfo{iUNIT};
    xmldata.HotwaterSystems.Boiler(iUNIT).ATTRIBUTE.Name        = equipName{iUNIT};
    xmldata.HotwaterSystems.Boiler(iUNIT).ATTRIBUTE.Capacity    = equipCapacity{iUNIT};
    xmldata.HotwaterSystems.Boiler(iUNIT).ATTRIBUTE.Efficiency  = equipEfficiency{iUNIT};
    xmldata.HotwaterSystems.Boiler(iUNIT).ATTRIBUTE.Insulation  = equipInsulation{iUNIT};
    xmldata.HotwaterSystems.Boiler(iUNIT).ATTRIBUTE.PipeSize    = equipPipeSize{iUNIT};
    xmldata.HotwaterSystems.Boiler(iUNIT).ATTRIBUTE.SolarSystem = equipSolarSystem{iUNIT};
    
    xmldata.HotwaterSystems.Boiler(iUNIT).ATTRIBUTE.SolorHeatingSurfaceArea = ...
        SolorHeatingSurfaceArea{iUNIT};
    xmldata.HotwaterSystems.Boiler(iUNIT).ATTRIBUTE.SolorHeatingSurfaceAzimuth = ...
        SolorHeatingSurfaceAzimuth{iUNIT};
    xmldata.HotwaterSystems.Boiler(iUNIT).ATTRIBUTE.SolorHeatingSurfaceInclination = ...
        SolorHeatingSurfaceInclination{iUNIT};
    
end
