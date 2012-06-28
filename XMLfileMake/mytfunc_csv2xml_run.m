% mytfunc_csv2xml_run.m
%                                         by Masato Miyata 2012/04/03
%--------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す
%--------------------------------------------------------------------
function y = mytfunc_csv2xml_run(inputfilename,outputfilename,Area)

tic

% 設定ファイル読み込み
CONFIG = xml_read('csv2xml_config.xml');

% XMLテンプレートの読み込み
if isempty(inputfilename)
    switch Area
        case 'Ia'
            inputfilename = 'routeB_XMLtemplate_Ia.xml';
        case 'Ib'
            inputfilename = 'routeB_XMLtemplate_Ib.xml';
        case 'IVb'
            inputfilename = 'routeB_XMLtemplate_IVb.xml';
        otherwise
            error('地域の設定が不正です')
    end
end
xmldata = xml_read(inputfilename);

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

% 外皮のファイルを読み込み
if isempty(CONFIG.AirConditioningSystem.Wall) == 0
    xmldata = mytfunc_csv2xml_AC_EnvList(xmldata,CONFIG.AirConditioningSystem.Wall);
end

% WCON,WIND.csv の出力
if isempty(CONFIG.AirConditioningSystem.WCON) == 0 && isempty(CONFIG.AirConditioningSystem.WIND) == 0
    
    % 外壁、窓の設定ファイルの生成
    confG = mytfunc_csv2xml_AC_WINDList(CONFIG.AirConditioningSystem.WIND);
    confW = mytfunc_csv2xml_AC_OWALList(CONFIG.AirConditioningSystem.WCON);
    
    % csvファイルの出力
    for iFILE=1:2
        if iFILE == 1
            tmp = confG;
            filename = 'WIND.csv';
            header = {'名称','窓種','品種番号','ブラインド'};
        else
            tmp = confW;
            filename = 'WCON.csv';
            header = {'名称','WCON名','第1層材番','第1層厚','第2層材番','第2層厚','第3層材番',...
                '第3層厚','第4層材番','第4層厚','第5層材番','第5層厚','第6層材番','第6層厚',...
                '第7層材番','第7層厚','第8層材番','第8層厚','第9層材番','第9層厚','第10層材番',...
                '第10層厚','第11層材番','第11層厚'};
        end
        
        fid = fopen(filename,'wt'); % 書き込み用にファイルオープン
        
        % ヘッダーの書き出し
        fprintf(fid, '%s,', header{1:end-1});
        fprintf(fid, '%s\n', header{end});
        
        [rows,cols] = size(tmp);
        for j = 1:rows
            for k = 1:cols
                if k < cols
                    fprintf(fid, '%s,', tmp{j,k}); % 文字列の書き出し
                else
                    fprintf(fid, '%s\n', tmp{j,k}); % 行末の文字列は、改行を含めて出力
                end
            end
        end
        
        y = fclose(fid);
        
    end
    
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

% 換気(FAN)のファイルを読み込み
if isempty(CONFIG.VentilationSystems.Fan) == 0
    xmldata = mytfunc_csv2xml_V(xmldata,CONFIG.VentilationSystems.Room,...
        CONFIG.VentilationSystems.Fan,CONFIG.VentilationSystems.AC);
end

% 昇降機のファイルを読み込み
if isempty(CONFIG.Elevators) == 0
    xmldata = mytfunc_csv2xml_EV(xmldata,CONFIG.Elevators);
end

% XMLファイル生成
xml_write(outputfilename, xmldata, 'model');

toc

