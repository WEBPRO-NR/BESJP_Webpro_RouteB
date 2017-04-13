% mytfunc_csv2xml_EFF_PV.m
%                                             by Masato Miyata 2012/10/12
%------------------------------------------------------------------------
% 省エネ基準：太陽光発電システムのXMLファイルを作成する。
%------------------------------------------------------------------------
% 入力：
%  xmldata  : xmlデータ
%  filename : 太陽光発電システムの算定シート(CSV)ファイル名
% 出力：
%  xmldata  : xmlデータ
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_EFI_PV(xmldata,filename)

% XMLテンプレートの読み込み
% clear
% clc
% xmldata = xml_read('routeB_XMLtemplate.xml');
% filename = '太陽光発電シート.csv';


% CSVファイルの読み込み
PVDataCell = mytfunc_CSVfile2Cell(filename);

% PVData = textread(filename,'%s','delimiter','\n','whitespace','');
% 
% % 照明定義ファイルの読み込み
% for i=1:length(PVData)
%     conma = strfind(PVData{i},',');
%     for j = 1:length(conma)
%         if j == 1
%             PVDataCell{i,j} = PVData{i}(1:conma(j)-1);
%         elseif j == length(conma)
%             PVDataCell{i,j}   = PVData{i}(conma(j-1)+1:conma(j)-1);
%             PVDataCell{i,j+1} = PVData{i}(conma(j)+1:end);
%         else
%             PVDataCell{i,j} = PVData{i}(conma(j-1)+1:conma(j)-1);
%         end
%     end
% end

% 情報の抽出
PV_Name = {};
PV_Type = {};
PV_InstallationMode = {};
PV_Capacity = {};
PV_PanelDirection = {};
PV_PanelAngle = {};
PV_SolorIrradiationRegion = {};
PV_Info = {};

for iUNIT = 11:size(PVDataCell,1)
    
    % 名称と発電効率が空欄の場合はスキップ
    if isempty(PVDataCell{iUNIT,1}) == 0 && isempty(PVDataCell{iUNIT,5}) == 0
        
        % 太陽光発電システム名称
        if isempty(PVDataCell{iUNIT,1})
            PV_Name   = [PV_Name;'Null'];
        else
            PV_Name   = [PV_Name;PVDataCell{iUNIT,1}];
        end
        
        % 太陽電池の種類
        if isempty(PVDataCell{iUNIT,3}) == 0
            if strcmp(PVDataCell(iUNIT,3),'結晶系')
                PV_Type = [PV_Type;'Crystalline'];
            elseif strcmp(PVDataCell(iUNIT,3),'結晶系以外')
                PV_Type = [PV_Type;'NonCrystalline'];
            else
                error('太陽光発電: 太陽電池の種類の選択肢が不正です')
            end
        else
            error('太陽光発電：太陽電池の種類が空欄です')
        end
        
        % アレイ設置方式
        if isempty(PVDataCell{iUNIT,4}) == 0
            if strcmp(PVDataCell(iUNIT,4),'架台設置形')
                PV_InstallationMode = [PV_InstallationMode;'RackMountType'];
            elseif strcmp(PVDataCell(iUNIT,4),'屋根置き形')
                PV_InstallationMode = [PV_InstallationMode;'RoomMountType'];
            elseif strcmp(PVDataCell(iUNIT,4),'その他')
                PV_InstallationMode = [PV_InstallationMode;'Others'];
            else
                error('太陽光発電: アレイ設置方式の選択肢が不正です')
            end
        else
            error('太陽光発電：アレイ設置方式が空欄です')
        end
        
        % アレイのシステム容量
        if isempty(PVDataCell{iUNIT,5}) == 0
            PV_Capacity = [PV_Capacity; PVDataCell{iUNIT,5}];
        else
            error('太陽光発電：アレイのシステム容量が空欄です')
        end
        
        % パネルの方位角
        if isempty(PVDataCell{iUNIT,6}) == 0
            PV_PanelDirection = [PV_PanelDirection; PVDataCell{iUNIT,6}];
        else
            error('太陽光発電：パネルの方位角が空欄です')
        end
        
        % パネルの傾斜角
        if isempty(PVDataCell{iUNIT,7}) == 0
            PV_PanelAngle = [PV_PanelAngle; PVDataCell{iUNIT,7}];
        else
            error('太陽光発電：パネルの傾斜角が空欄です')
        end
        
        % 年間日射量地域区分
        if isempty(PVDataCell{iUNIT,8}) == 0
            if strcmp(PVDataCell(iUNIT,8),'A地域')
                PV_SolorIrradiationRegion = [PV_SolorIrradiationRegion;'A'];
            elseif strcmp(PVDataCell(iUNIT,8),'B地域')
                PV_SolorIrradiationRegion = [PV_SolorIrradiationRegion;'B'];
            elseif strcmp(PVDataCell(iUNIT,8),'C地域')
                PV_SolorIrradiationRegion = [PV_SolorIrradiationRegion;'C'];
            elseif strcmp(PVDataCell(iUNIT,8),'D地域')
                PV_SolorIrradiationRegion = [PV_SolorIrradiationRegion;'D'];
            elseif strcmp(PVDataCell(iUNIT,8),'E地域')
                PV_SolorIrradiationRegion = [PV_SolorIrradiationRegion;'E'];
            else
                error('太陽光発電: 年間日射量地域区分の選択肢が不正です')
            end
        else
            error('太陽光発電：年間日射量地域区分が空欄です')
        end
        
        % 備考
        if isempty(PVDataCell{iUNIT,9})
            PV_Info   = [PV_Info;'Null'];
        else
            PV_Info   = [PV_Info;PVDataCell{iUNIT,9}];
        end
        
    end
    
end

% XMLファイル生成
numOfUnit = size(PV_Name,1);

for iUNIT = 1:numOfUnit
    
    xmldata.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.Name    = PV_Name{iUNIT};
    xmldata.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.Type    = PV_Type{iUNIT};
    xmldata.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.InstallationMode    = PV_InstallationMode{iUNIT};
    xmldata.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.Capacity    = PV_Capacity{iUNIT};
    xmldata.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.PanelDirection    = PV_PanelDirection{iUNIT};
    xmldata.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.PanelAngle    = PV_PanelAngle{iUNIT};
    xmldata.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.SolorIrradiationRegion    = PV_SolorIrradiationRegion{iUNIT};
    xmldata.PhotovoltaicGenerationSystems.PhotovoltaicGeneration(iUNIT).ATTRIBUTE.Info    = PV_Info{iUNIT};
    
end

