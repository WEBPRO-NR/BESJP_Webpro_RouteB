% mytfunc_csv2xml_HW_UnitList.m
%                                             by Masato Miyata 2012/04/02
%------------------------------------------------------------------------
% ČGlîFˇCÝčt@CđěŹˇéB
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_HW_UnitList(xmldata,filename)

% @íÉÖˇéîń
hwequipInfoCSV = textread(filename,'%s','delimiter','\n','whitespace','');

hwequipInfoCell = {};
for i=1:length(hwequipInfoCSV)
    conma = strfind(hwequipInfoCSV{i},',');
    for j = 1:length(conma)
        if j == 1
            hwequipInfoCell{i,j} = hwequipInfoCSV{i}(1:conma(j)-1);
        elseif j == length(conma)
            hwequipInfoCell{i,j}   = hwequipInfoCSV{i}(conma(j-1)+1:conma(j)-1);
            hwequipInfoCell{i,j+1} = hwequipInfoCSV{i}(conma(j)+1:end);
        else
            hwequipInfoCell{i,j} = hwequipInfoCSV{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

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
        
    % @íźĚ
    if isempty(hwequipInfoCell{iUNIT,1})
        equipName = [equipName; 'Null'];
    else
        equipName = [equipName; hwequipInfoCell{iUNIT,1}];
    end
    
    % ÁMeĘ
    equipCapacity = [equipCapacity; hwequipInfoCell{iUNIT,2}];
    
    % MšřŚ
    equipEfficiency = [equipEfficiency; hwequipInfoCell{iUNIT,3}];
    
    % Űˇdl
    if strcmp(hwequipInfoCell{iUNIT,4},'ŰˇdlP')
        equipInsulation = [equipInsulation; 'Level1'];
    elseif strcmp(hwequipInfoCell{iUNIT,4},'ŰˇdlQ')
        equipInsulation = [equipInsulation; 'Level2'];
    elseif strcmp(hwequipInfoCell{iUNIT,4},'ŰˇdlR')
        equipInsulation = [equipInsulation; 'Level3'];
    else
        equipInsulation = [equipInsulation; 'Level0'];
    end
    
    % Úąűa
    equipPipeSize = [equipPipeSize; hwequipInfoCell{iUNIT,5}];
    
    % žzMp
    if isempty(hwequipInfoCell{iUNIT,6})
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
            [SolorHeatingSurfaceArea; hwequipInfoCell{iUNIT,6}];
        SolorHeatingSurfaceAzimuth = ...
            [SolorHeatingSurfaceAzimuth; hwequipInfoCell{iUNIT,7}];
        SolorHeatingSurfaceInclination = ...
            [SolorHeatingSurfaceInclination; hwequipInfoCell{iUNIT,8}];
    end
    
    % @í\ĚL
    if isempty(hwequipInfoCell{iUNIT,9})
        equipInfo = [equipInfo; 'Null'];
    else
        equipInfo = [equipInfo; hwequipInfoCell{iUNIT,9}];
    end
    
end


% XMLt@CśŹ
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
