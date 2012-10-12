% mytfunc_csv2xml_run.m
%                                         by Masato Miyata 2012/04/03
%--------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す
%--------------------------------------------------------------------
function y = mytfunc_csv2xml_run(outputfilename,Area)

tic

% 設定ファイル読み込み
CONFIG = xml_read('csv2xml_config.xml');
    
% XMLテンプレートの読み込み
xmldata = xml_read('routeB_XMLtemplate.xml');

% 地域の設定
switch Area
    case {'Ia','Ib','II','III','IVa','IVb','V','VI'}
    otherwise
        error('地域 %s は無効です',Area)
end
xmldata.ATTRIBUTE.Region = Area;

%-----------------------------------------
%% 設定ファイルの読み込み

% 共通設定ファイルの読み込み
if isempty(CONFIG.Rooms) == 0
    xmldata = mytfunc_csv2xml_CommonSetting(xmldata,CONFIG.Rooms);
end

% 空調室のファイルを読み込み
if isempty(CONFIG.AirConditioningSystem.Room) == 0
    xmldata = mytfunc_csv2xml_AC_RoomList(xmldata,CONFIG.AirConditioningSystem.Room);
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

% 給湯(機器)のファイルを読み込み
if isempty(CONFIG.HotwaterSystems.Boiler) == 0
    xmldata = mytfunc_csv2xml_HW_UnitList(xmldata,CONFIG.HotwaterSystems.Boiler);
end

% 給湯(室)のファイルを読み込み
if isempty(CONFIG.HotwaterSystems.Room) == 0
    xmldata = mytfunc_csv2xml_HW_RoomList(xmldata,CONFIG.HotwaterSystems.Room);
end

% 照明のファイルを読み込み
if isempty(CONFIG.LightingSystems) == 0
    xmldata = mytfunc_csv2xml_L(xmldata,CONFIG.LightingSystems);
end

% 換気のファイルを読み込み
if isempty(CONFIG.VentilationSystems.Fan) == 0
    xmldata = mytfunc_csv2xml_V(xmldata,CONFIG.VentilationSystems.Room,...
        CONFIG.VentilationSystems.Fan,CONFIG.VentilationSystems.AC);
end

% 昇降機のファイルを読み込み
if isempty(CONFIG.Elevators) == 0
    xmldata = mytfunc_csv2xml_EV(xmldata,CONFIG.Elevators);
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

% XMLファイル生成
xml_write(outputfilename, xmldata, 'model');

y = 0;

toc

