% ECS_XMLfileMake_run.m
%                                         by Masato Miyata 2015/11/21
%--------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す
% ディレクトリを一括して指定できるように変更
% 
% 実行例：
% ECS_XMLfileMake_run('./InputFiles/1005_コジェネテスト/Case00/',6,'model_CGS_case00.xml')
%--------------------------------------------------------------------
function y = ECS_XMLfileMake_run(directry,Area,outputfilename)


addpath('./XMLfileMake/')  % コンパイル時には消す


%% 設定ファイル読み込み

eval(['L = dir(''',directry,'/*様式*.csv'');'])

for i = 1:length(L)
    
    if strfind(L(i).name,'様式1')
        CONFIG.Rooms = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式2-1')
        CONFIG.AirConditioningSystem.Room = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式2-2')
        CONFIG.AirConditioningSystem.WCON = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式2-3')
        CONFIG.AirConditioningSystem.WIND = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式2-4')
        CONFIG.AirConditioningSystem.Wall = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式2-5')
        CONFIG.AirConditioningSystem.Ref = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式2-6')
        CONFIG.AirConditioningSystem.Pump = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式2-7')
        CONFIG.AirConditioningSystem.AHU = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式3-1')
        CONFIG.VentilationSystems.Room = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式3-2')
        CONFIG.VentilationSystems.Fan = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式3-3')
        CONFIG.VentilationSystems.AC = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式4')
        CONFIG.LightingSystems = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式5-1')
        CONFIG.HotwaterSystems.Room = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式5-2')
        CONFIG.HotwaterSystems.Boiler = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式6')
        CONFIG.Elevators = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式7-1')
        CONFIG.PhotovoltaicGenerationSystems = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式7-2')
        CONFIG.CogenerationSystems = strcat(directry,'/',L(i).name);
    elseif strfind(L(i).name,'様式7-3')
        CONFIG.CogenerationSystemsDetail = strcat(directry,'/',L(i).name);
    end
    
end


%% XMLテンプレートの読み込み
xmldata = xml_read('routeB_XMLtemplate.xml');

% 地域の設定
Area = num2str(Area);
switch Area
    case {'Ia','Ib','II','III','IVa','IVb','V','VI'}
    case {'1','2','3','4','5','6','7','8'}
    otherwise
        error('地域 %s は無効です',Area)
end
xmldata.ATTRIBUTE.Region = Area;

%-----------------------------------------
%% 設定ファイルの読み込み

% 共通設定ファイルの読み込み
if isfield(CONFIG,'Rooms')
    if isempty(CONFIG.Rooms) == 0
        xmldata = mytfunc_csv2xml_CommonSetting(xmldata,CONFIG.Rooms);
    end
end

% 空調のファイルを読み込み
if isfield(CONFIG,'AirConditioningSystem')
    
    % 空調室のファイルを読み込み
    if isempty(CONFIG.AirConditioningSystem.Room) == 0
        xmldata = mytfunc_csv2xml_AC_RoomList(xmldata,CONFIG.AirConditioningSystem.Room);
    end
    
    % 外壁の設定ファイルの生成
    if isempty(CONFIG.AirConditioningSystem.WCON) == 0
        xmldata = mytfunc_csv2xml_AC_OWALList(xmldata,CONFIG.AirConditioningSystem.WCON);
    end
    
    % 窓の設定ファイルの生成
    if isempty(CONFIG.AirConditioningSystem.WIND) == 0
        xmldata = mytfunc_csv2xml_AC_WINDList(xmldata,CONFIG.AirConditioningSystem.WIND);
    end
    
    % 外皮のファイルを読み込み
    if isempty(CONFIG.AirConditioningSystem.Wall) == 0
        xmldata = mytfunc_csv2xml_AC_EnvList(xmldata,CONFIG.AirConditioningSystem.Wall);
    end
    
    % 空調機のファイルを読み込む
    if isempty(CONFIG.AirConditioningSystem.AHU) == 0
        xmldata = mytfunc_csv2xml_AC_AHUList(xmldata,CONFIG.AirConditioningSystem.AHU);
    end
    
    % ポンプのファイルを読み込む
    if isempty(CONFIG.AirConditioningSystem.Pump) == 0
        xmldata = mytfunc_csv2xml_AC_PumpList(xmldata,CONFIG.AirConditioningSystem.Pump);
    end
    
    % 熱源のファイルを読み込む
    if isempty(CONFIG.AirConditioningSystem.Ref) == 0
        xmldata = mytfunc_csv2xml_AC_RefList(xmldata,CONFIG.AirConditioningSystem.Ref);
    end
    
end

% 換気のファイルを読み込み
if isfield(CONFIG,'VentilationSystems')
    if isempty(CONFIG.VentilationSystems.Fan) == 0
        xmldata = mytfunc_csv2xml_V(xmldata,CONFIG.VentilationSystems.Room,...
            CONFIG.VentilationSystems.Fan,CONFIG.VentilationSystems.AC);
    end
end


% 照明のファイルを読み込み
if isfield(CONFIG,'LightingSystems')
    if isempty(CONFIG.LightingSystems) == 0
        xmldata = mytfunc_csv2xml_L(xmldata,CONFIG.LightingSystems);
    end
end


% 給湯(室)のファイルを読み込み
if isfield(CONFIG,'HotwaterSystems')
    
    % 給湯(室)のファイルを読み込み
    if isempty(CONFIG.HotwaterSystems.Room) == 0
        xmldata = mytfunc_csv2xml_HW_RoomList(xmldata,CONFIG.HotwaterSystems.Room);
    end
    
    % 給湯(機器)のファイルを読み込み
    if isempty(CONFIG.HotwaterSystems.Boiler) == 0
        xmldata = mytfunc_csv2xml_HW_UnitList(xmldata,CONFIG.HotwaterSystems.Boiler);
    end
    
end


% 昇降機のファイルを読み込み
if isfield(CONFIG,'Elevators')
    if isempty(CONFIG.Elevators) == 0
        xmldata = mytfunc_csv2xml_EV(xmldata,CONFIG.Elevators);
    end
end


% 太陽光発電システムのファイルを読み込み
if isfield(CONFIG,'PhotovoltaicGenerationSystems')
    if isempty(CONFIG.PhotovoltaicGenerationSystems) == 0
        xmldata = mytfunc_csv2xml_EFI_PV(xmldata,CONFIG.PhotovoltaicGenerationSystems);
    end
end

% コジェネレーションシステムのファイルを読み込み
if isfield(CONFIG,'CogenerationSystems')
    if isempty(CONFIG.CogenerationSystems) == 0
        xmldata = mytfunc_csv2xml_EFI_CGS(xmldata,CONFIG.CogenerationSystems);
    end
end

% コジェネレーションシステムのファイルを読み込み
if isfield(CONFIG,'CogenerationSystemsDetail')
    if isempty(CONFIG.CogenerationSystemsDetail) == 0
        xmldata = mytfunc_csv2xml_EFI_CGSdetail(xmldata,CONFIG.CogenerationSystemsDetail);
    end
end



% XMLファイル生成
xml_write(outputfilename, xmldata, 'model');

rmpath('./XMLfileMake/')

y = 0;

