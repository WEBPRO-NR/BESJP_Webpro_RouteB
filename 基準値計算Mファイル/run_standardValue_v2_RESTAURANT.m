% multirun.m
%                                                         by Masato Miyata 2012/01/11
%------------------------------------------------------------------------------------
% ケーススタディ用。連続計算のインターフェイス
%------------------------------------------------------------------------------------
clear

addpath('subfunction')
tic


for iRESION = 1:8
    
    % ケースファイル読み込み
    if iRESION == 1 || iRESION == 2
        [NN,TT,RR] = xlsread('./標準仕様/基準値計算_建物モデル設定 v8入力_飲食_Ia_Ib.xlsx','計算ケース一括');
    elseif iRESION == 3 || iRESION == 4
        [NN,TT,RR] = xlsread('./標準仕様/基準値計算_建物モデル設定 v8入力_飲食_II_III.xlsx','計算ケース一括');
    elseif iRESION == 5 || iRESION == 6 || iRESION == 7
        [NN,TT,RR] = xlsread('./標準仕様/基準値計算_建物モデル設定 v8入力_飲食_IVa_IVb_V.xlsx','計算ケース一括');
    elseif iRESION == 8
        [NN,TT,RR] = xlsread('./標準仕様/基準値計算_建物モデル設定 v8入力_飲食_VI.xlsx','計算ケース一括');
    else
        error('リージョンコードが不明です')
    end
    
    % 地域
    if iRESION == 1
        resion = 'Ia';
    elseif iRESION == 2
        resion = 'Ib';
    elseif iRESION == 3
        resion = 'II';
    elseif iRESION == 4
        resion = 'III';
    elseif iRESION == 5
        resion = 'IVa';
    elseif iRESION == 6
        resion = 'IVb';
    elseif iRESION == 7
        resion = 'V';
    elseif iRESION == 8
        resion = 'VI';
    else
        error('リージョンコードが不明です')
    end
    
    % 計算ケース数
    caseNum = size(RR,2)-1;
    
    % 結果保存用
    resENERGY = [];
    resQcool  = [];
    resQheat  = [];
    resEffi   = [];
    resY      = [];
    
    % 計算実行
    for iCASE = 1:caseNum
        
        caseSet = RR(2:end,iCASE+1);
        
        eval(['disp(''',cell2mat(caseSet(1)),' : ',cell2mat(caseSet(2)),' を実行中'')'])
        
        tmpresENERGY = [];
        tmpresQcool  = [];
        tmpresQheat  = [];
        tmpresEffi   = [];
        
        for iBLDG = 1:3
            
            for iMODEL = 1:3
                
                switch iMODEL
                    case 1
                        % 床面積 [m2],
                        Sf =  50;
                    case 2
                        Sf = 100;
                    case 3
                        Sf = 200;
                    otherwise
                        error('iMODELが不正です')
                end
                
                for iDIRECTION = 1:4
                    
                    eval(['disp(''MODEL iBLDG = ',int2str(iBLDG),', iMODEL = ',int2str(iMODEL),', iDIRECTION = ',int2str(iDIRECTION),''')'])
                    
                    % 出力ファイル
                    OUTPUT = xml_read('singleRoom_template.xml');
                    
                    % 建物用途
                    OUTPUT.ATTRIBUTE.Type = caseSet(1);
                    % 地域
                    OUTPUT.ATTRIBUTE.Region = resion;
                    
                    % 室用途
                    tmpbar = strfind(caseSet{2},'_');
                    if strcmp(caseSet{2}(tmpbar(end)+1:end),'喫茶店')
                        OUTPUT.Rooms.Room.ATTRIBUTE.Type = '喫茶店';
                        Fh = 4.0; %  階高 [m]
                    elseif strcmp(caseSet{2}(tmpbar(end)+1:end),'バー')
                        OUTPUT.Rooms.Room.ATTRIBUTE.Type = 'バー';
                        Fh = 4.0; %  階高 [m]
                    elseif strcmp(caseSet{2}(tmpbar(end)+1:end),'事務室')
                        OUTPUT.Rooms.Room.ATTRIBUTE.Type = '事務室';
                        Fh = 4.0; %  階高 [m]
                    elseif strcmp(caseSet{2}(tmpbar(end)+1:end),'ロビー')
                        OUTPUT.Rooms.Room.ATTRIBUTE.Type = 'ロビー';
                        Fh = 4.25; %  階高 [m]
                    elseif strcmp(caseSet{2}(tmpbar(end)+1:end),'厨房')
                        OUTPUT.Rooms.Room.ATTRIBUTE.Type = '厨房';
                        Fh = 4.0; %  階高 [m]
                    elseif strcmp(caseSet{2}(tmpbar(end)+1:end),'倉庫')
                        OUTPUT.Rooms.Room.ATTRIBUTE.Type = '倉庫';
                        Fh = 4.0; %  階高 [m]
                    else
                        if strcmp(caseSet{2}(tmpbar(end-1)+1:end),'客席_低')
                            OUTPUT.Rooms.Room.ATTRIBUTE.Type = '客席(低)';
                            Fh = 4.0; %  階高 [m]
                        elseif strcmp(caseSet{2}(tmpbar(end-1)+1:end),'客席_高')
                            OUTPUT.Rooms.Room.ATTRIBUTE.Type = '客席(高)';
                            Fh = 4.0; %  階高 [m]
                        else
                            error('該当する室用途がありません！')
                        end
                    end
                    
                    % 外皮面積[m2]
                    St = 10*Fh;
                    
                    % 床面積
                    OUTPUT.Rooms.Room.ATTRIBUTE.Area = num2str(Sf);
                    % 階高
                    OUTPUT.Rooms.Room.ATTRIBUTE.Height = num2str(Fh);
                    % 天井高
                    OUTPUT.Rooms.Room.ATTRIBUTE.FloorHeight = num2str(Fh-1);
                    
                    
                    %% 外皮仕様
                    
                    if iBLDG == 1
                        % 外壁
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WallArea = num2str(St*(1-caseSet{4}));
                        % 窓面積
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WindowArea  = num2str(St*caseSet{4});
                        % 外壁種類
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WallConfigure = caseSet(5);
                        % 窓種類
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WindowType = caseSet(10);
                        % 方位
                        if iDIRECTION == 1
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'NTH';
                        elseif iDIRECTION == 2
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'EST';
                        elseif iDIRECTION == 3
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'STH';
                        elseif iDIRECTION == 4
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'WST';
                        end
                        
                    elseif iBLDG == 2
                        
                        % 外壁
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WallArea = num2str(St*(1-caseSet{4}));
                        % 窓面積
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WindowArea  = num2str(St*caseSet{4});
                        % 外壁種類
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WallConfigure = caseSet(5);
                        % 窓種類
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WindowType = caseSet(10);
                        % 方位
                        if iDIRECTION == 1
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'NTH';
                        elseif iDIRECTION == 2
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'EST';
                        elseif iDIRECTION == 3
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'STH';
                        elseif iDIRECTION == 4
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'WST';
                        end
                        
                        % 屋根
                        OUTPUT.AirConditioningSystem.Envelope.Wall(2).ATTRIBUTE.WallArea = num2str(Sf);
                        % 窓面積
                        OUTPUT.AirConditioningSystem.Envelope.Wall(2).ATTRIBUTE.WindowArea  = '0';
                        % 外壁種類
                        OUTPUT.AirConditioningSystem.Envelope.Wall(2).ATTRIBUTE.WallConfigure = caseSet(6);
                        % 窓種類
                        OUTPUT.AirConditioningSystem.Envelope.Wall(2).ATTRIBUTE.WindowType = caseSet(10);
                        % 方位
                        OUTPUT.AirConditioningSystem.Envelope.Wall(2).ATTRIBUTE.Direction = 'HORI';
                        
                    elseif iBLDG == 3
                        
                        % 外壁
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WallArea = '0';
                        % 窓面積
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WindowArea  = '0';
                        % 外壁種類
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WallConfigure = caseSet(5);
                        % 窓種類
                        OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.WindowType = caseSet(10);
                        % 方位
                        if iDIRECTION == 1
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'NTH';
                        elseif iDIRECTION == 2
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'EST';
                        elseif iDIRECTION == 3
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'STH';
                        elseif iDIRECTION == 4
                            OUTPUT.AirConditioningSystem.Envelope.Wall(1).ATTRIBUTE.Direction = 'WST';
                        end
                        
                    end
                    
                    
                    %% 熱源仕様
                    
                    % 冷熱（固定）
                    OUTPUT.AirConditioningSystem.HeatSourceSet(1).ATTRIBUTE.ID = 'RC';
                    OUTPUT.AirConditioningSystem.HeatSourceSet(1).ATTRIBUTE.Mode = 'Cooling';
                    
                    % 蓄熱槽
                    if strcmp(caseSet(12),'無')
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).ATTRIBUTE.ThermalStorage = 'False';
                    elseif strcmp(caseSet(12),'有')
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).ATTRIBUTE.ThermalStorage = 'True';
                    end
                    
                    % 台数制御
                    if strcmp(caseSet(13),'無')
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).ATTRIBUTE.QuantityControl = 'False';
                    elseif strcmp(caseSet(13),'有')
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).ATTRIBUTE.QuantityControl = 'True';
                    end
                    
                    OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(1).ATTRIBUTE.Order       = 'First';
                    OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(1).ATTRIBUTE.Type        = caseSet(14);
                    OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(1).ATTRIBUTE.Capacity    = num2str(caseSet{15}*Sf);
                    OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(1).ATTRIBUTE.MainPower   = num2str(caseSet{16}*Sf);
                    OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(1).ATTRIBUTE.SubPower    = num2str(caseSet{17}*Sf);
                    if caseSet{18} == 0
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(1).ATTRIBUTE.PrimaryPumpPower = '0';
                    else
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(1).ATTRIBUTE.PrimaryPumpPower = num2str(caseSet{15}*Sf/caseSet{18});
                    end
                    OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(1).ATTRIBUTE.CTCapacity  = num2str(caseSet{15}*Sf);
                    OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(1).ATTRIBUTE.CTFanPower  = num2str(caseSet{19}*Sf);
                    OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(1).ATTRIBUTE.CTPumpPower = num2str(caseSet{20}*Sf);
                    
                    if strcmp(caseSet{21},'NaN') == 0
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(2).ATTRIBUTE.Order       = 'Second';
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(2).ATTRIBUTE.Type        = caseSet(21);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(2).ATTRIBUTE.Capacity    = num2str(caseSet{22}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(2).ATTRIBUTE.MainPower   = num2str(caseSet{23}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(2).ATTRIBUTE.SubPower    = num2str(caseSet{24}*Sf);
                        if caseSet{25} == 0
                            OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(2).ATTRIBUTE.PrimaryPumpPower = '0';
                        else
                            OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(2).ATTRIBUTE.PrimaryPumpPower = num2str(caseSet{22}*Sf/caseSet{25});
                        end
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(2).ATTRIBUTE.CTCapacity  = num2str(caseSet{22}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(2).ATTRIBUTE.CTFanPower  = num2str(caseSet{26}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(2).ATTRIBUTE.CTPumpPower = num2str(caseSet{27}*Sf);
                    end
                    
                    if strcmp(caseSet{28},'NaN') == 0
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(3).ATTRIBUTE.Order       = 'Third';
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(3).ATTRIBUTE.Type        = caseSet(28);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(3).ATTRIBUTE.Capacity    = num2str(caseSet{29}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(3).ATTRIBUTE.MainPower   = num2str(caseSet{30}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(3).ATTRIBUTE.SubPower    = num2str(caseSet{31}*Sf);
                        if caseSet{32} == 0
                            OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(3).ATTRIBUTE.PrimaryPumpPower = '0';
                        else
                            OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(3).ATTRIBUTE.PrimaryPumpPower = num2str(caseSet{29}*Sf/caseSet{32});
                        end
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(3).ATTRIBUTE.CTCapacity  = num2str(caseSet{29}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(3).ATTRIBUTE.CTFanPower  = num2str(caseSet{33}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(1).HeatSource(3).ATTRIBUTE.CTPumpPower = num2str(caseSet{34}*Sf);
                    end
                    
                    
                    % 温熱（固定）
                    OUTPUT.AirConditioningSystem.HeatSourceSet(2).ATTRIBUTE.ID = 'RH';
                    OUTPUT.AirConditioningSystem.HeatSourceSet(2).ATTRIBUTE.Mode = 'Heating';
                    
                    % 蓄熱槽
                    if strcmp(caseSet(35),'無')
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).ATTRIBUTE.ThermalStorage = 'False';
                    elseif strcmp(caseSet(35),'有')
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).ATTRIBUTE.ThermalStorage = 'True';
                    end
                    
                    % 台数制御
                    if strcmp(caseSet(36),'無')
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).ATTRIBUTE.QuantityControl = 'False';
                    elseif strcmp(caseSet(36),'有')
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).ATTRIBUTE.QuantityControl = 'True';
                    end
                    
                    OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(1).ATTRIBUTE.Order       = 'First';
                    OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(1).ATTRIBUTE.Type        = caseSet(37);
                    OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(1).ATTRIBUTE.Capacity    = num2str(caseSet{38}*Sf);
                    OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(1).ATTRIBUTE.MainPower   = num2str(caseSet{39}*Sf);
                    OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(1).ATTRIBUTE.SubPower    = num2str(caseSet{40}*Sf);
                    if caseSet{41} == 0
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(1).ATTRIBUTE.PrimaryPumpPower = '0';
                    else
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(1).ATTRIBUTE.PrimaryPumpPower = num2str(caseSet{38}*Sf/caseSet{41});
                    end
                    OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(1).ATTRIBUTE.CTCapacity  = num2str(caseSet{38}*Sf);
                    OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(1).ATTRIBUTE.CTFanPower  = num2str(caseSet{42}*Sf);
                    OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(1).ATTRIBUTE.CTPumpPower = num2str(caseSet{43}*Sf);
                    
                    if strcmp(caseSet{44},'NaN') == 0
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(2).ATTRIBUTE.Order       = 'Second';
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(2).ATTRIBUTE.Type        = caseSet(44);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(2).ATTRIBUTE.Capacity    = num2str(caseSet{45}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(2).ATTRIBUTE.MainPower   = num2str(caseSet{46}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(2).ATTRIBUTE.SubPower    = num2str(caseSet{47}*Sf);
                        if caseSet{48} == 0
                            OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(2).ATTRIBUTE.PrimaryPumpPower = '0';
                        else
                            OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(2).ATTRIBUTE.PrimaryPumpPower = num2str(caseSet{45}*Sf/caseSet{48});
                        end
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(2).ATTRIBUTE.CTCapacity  = num2str(caseSet{45}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(2).ATTRIBUTE.CTFanPower  = num2str(caseSet{49}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(2).ATTRIBUTE.CTPumpPower = num2str(caseSet{50}*Sf);
                    end
                    
                    if strcmp(caseSet{51},'NaN') == 0
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(3).ATTRIBUTE.Order       = 'Third';
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(3).ATTRIBUTE.Type        = caseSet(51);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(3).ATTRIBUTE.Capacity    = num2str(caseSet{52}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(3).ATTRIBUTE.MainPower   = num2str(caseSet{53}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(3).ATTRIBUTE.SubPower    = num2str(caseSet{54}*Sf);
                        
                        if caseSet{55} == 0
                            OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(3).ATTRIBUTE.PrimaryPumpPower = '0';
                        else
                            OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(3).ATTRIBUTE.PrimaryPumpPower = num2str(caseSet{52}*Sf/caseSet{55});
                        end
                        
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(3).ATTRIBUTE.CTCapacity  = num2str(caseSet{52}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(3).ATTRIBUTE.CTFanPower  = num2str(caseSet{56}*Sf);
                        OUTPUT.AirConditioningSystem.HeatSourceSet(2).HeatSource(3).ATTRIBUTE.CTPumpPower = num2str(caseSet{57}*Sf);
                    end
                    
                    
                    % 冷房側合計熱源容量
                    if strcmp(caseSet{21},'NaN') == 0
                        Qrtotal = caseSet{15}*Sf;
                    elseif strcmp(caseSet{28},'NaN') == 0
                        Qrtotal = caseSet{15}*Sf + caseSet{22}*Sf;
                    else
                        Qrtotal = caseSet{15}*Sf + caseSet{22}*Sf + caseSet{29}*Sf;
                    end
                    
                    
                    
                    %% 二次ポンプ
                    if caseSet{58} > 0
                        OUTPUT.AirConditioningSystem.SecondaryPump(1).ATTRIBUTE.ID              = 'PSC';
                        OUTPUT.AirConditioningSystem.SecondaryPump(1).ATTRIBUTE.Mode            = 'Cooling';
                        OUTPUT.AirConditioningSystem.SecondaryPump(1).ATTRIBUTE.Count           = num2str(caseSet{58});
                        OUTPUT.AirConditioningSystem.SecondaryPump(1).ATTRIBUTE.RatedFlow       = num2str(3600*Qrtotal/(4200*caseSet{59})/caseSet{58});
                        OUTPUT.AirConditioningSystem.SecondaryPump(1).ATTRIBUTE.RatedPower      = num2str(Qrtotal/caseSet{60}/caseSet{58});
                        OUTPUT.AirConditioningSystem.SecondaryPump(1).ATTRIBUTE.FlowControl     = caseSet(61);
                        if strcmp(caseSet(62),'有')
                            OUTPUT.AirConditioningSystem.SecondaryPump(1).ATTRIBUTE.QuantityControl = 'True';
                        else
                            OUTPUT.AirConditioningSystem.SecondaryPump(1).ATTRIBUTE.QuantityControl = 'False';
                        end
                    end
                    
                    if caseSet{63} > 0
                        OUTPUT.AirConditioningSystem.SecondaryPump(2).ATTRIBUTE.ID              = 'PSH';
                        OUTPUT.AirConditioningSystem.SecondaryPump(2).ATTRIBUTE.Mode            = 'Heating';
                        OUTPUT.AirConditioningSystem.SecondaryPump(2).ATTRIBUTE.Count           = num2str(caseSet{63});
                        OUTPUT.AirConditioningSystem.SecondaryPump(2).ATTRIBUTE.RatedFlow       = num2str(3600*Qrtotal/(4200*caseSet{64})/caseSet{63});
                        OUTPUT.AirConditioningSystem.SecondaryPump(2).ATTRIBUTE.RatedPower      = num2str(Qrtotal/caseSet{65}/caseSet{63});
                        OUTPUT.AirConditioningSystem.SecondaryPump(2).ATTRIBUTE.FlowControl     = caseSet(66);
                        if strcmp(caseSet(67),'有')
                            OUTPUT.AirConditioningSystem.SecondaryPump(2).ATTRIBUTE.QuantityControl = 'True';
                        else
                            OUTPUT.AirConditioningSystem.SecondaryPump(2).ATTRIBUTE.QuantityControl = 'False';
                        end
                    end
                    
                    
                    %% 空調機
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.ID                 = 'AHUE';
                    if strcmp(caseSet(68),'空調機')
                        OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.Type           = 'AHU';
                    elseif strcmp(caseSet(68),'FCU')
                        OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.Type           = 'FCU';
                    elseif strcmp(caseSet(68),'室内機')
                        OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.Type           = 'UNIT';
                    end
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.CoolingCapacity    = num2str(caseSet{69}*Sf);
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.HeatingCapacity    = num2str(caseSet{70}*Sf);
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.SupplyAirVolume    = num2str(caseSet{71}*Sf);
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.SupplyFanPower     = num2str(caseSet{69}*Sf/caseSet{72});
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.ReturnFanPower     = '0';
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.OutsideAirFanPower = '0';
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.FlowControl        = caseSet(73);
                    %                 OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.MinDamperOpening   = num2str(caseSet{74}/100);
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.MinDamperOpening   = num2str(40/100);
                    
                    if strcmp(caseSet(75),'有')
                        OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.OutsideAirCutControl = 'True';
                    else
                        OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.OutsideAirCutControl = 'False';
                    end
                    
                    if strcmp(caseSet(76),'有')
                        OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.FreeCoolingControl = 'True';
                    else
                        OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.FreeCoolingControl = 'False';
                    end
                    
                    if strcmp(caseSet(86),'有')
                        OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.HeatExchanger      = 'True';
                    else
                        OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.HeatExchanger      = 'False';
                    end
                    
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.HeatExchangerEfficiency = num2str(caseSet{87});
                    OUTPUT.AirConditioningSystem.AirHandlingUnit.ATTRIBUTE.HeatExchangerPower = num2str(caseSet{88}*Sf);
                    
                    % 熱源名称の置き換え
                    for iREFSET = 1:length(OUTPUT.AirConditioningSystem.HeatSourceSet)
                        for iREFSETSUB = 1:length(OUTPUT.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource)
                            tmprefname = OUTPUT.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iREFSETSUB).ATTRIBUTE.Type;
                            
                            refNo = '';
                            if strcmp(tmprefname, 'ターボ冷凍機（標準，ベーン制御）')
                                refNo = 'Rtype1';
                            elseif strcmp(tmprefname, 'ターボ冷凍機（高効率，ベーン制御）')
                                refNo = 'Rtype2';
                            elseif strcmp(tmprefname, 'ターボ冷凍機（高効率，インバータ制御）')
                                refNo = 'Rtype3';
                            elseif strcmp(tmprefname, '空冷ヒートポンプ（スクリュー，スライド弁）')
                                refNo = 'Rtype4';
                            elseif strcmp(tmprefname, '空冷ヒートポンプ（スクリュー，インバータ）')
                                refNo = 'Rtype5';
                            elseif strcmp(tmprefname, '空冷ヒートポンプ（スクロール，圧縮機台数制御）')
                                refNo = 'Rtype6';
                            elseif strcmp(tmprefname, '水冷チラー（スクリュー，スライド弁）')
                                refNo = 'Rtype7';
                            elseif strcmp(tmprefname, '水冷チラー（スクリュー，インバータ）')
                                refNo = 'Rtype8';
                            elseif strcmp(tmprefname, '水冷チラー（スクロール，圧縮機台数制御）')
                                refNo = 'Rtype9';
                            elseif strcmp(tmprefname, '直焚吸収冷温水器（三重効用）')
                                refNo = 'Rtype10';
                            elseif strcmp(tmprefname, '直焚吸収冷温水器（ニ重効用）')
                                refNo = 'Rtype11';
                            elseif strcmp(tmprefname, '直焚吸収冷温水器（高期間効率）')
                                refNo = 'Rtype12';
                            elseif strcmp(tmprefname, '蒸気焚き吸収式冷温水器（二重効用）')
                                refNo = 'Rtype13';
                            elseif strcmp(tmprefname, '温水焚き吸収式冷温水器（一重効用）')
                                refNo = 'Rtype14';
                            elseif strcmp(tmprefname, '排熱投入型吸収式冷温水器（二重効用）')
                                refNo = 'Rtype15';
                            elseif strcmp(tmprefname, 'ボイラ（小型貫流ボイラ）')
                                refNo = 'Rtype16';
                            elseif strcmp(tmprefname, 'ボイラ（真空温水ヒータ）')
                                refNo = 'Rtype17';
                            elseif strcmp(tmprefname, '電気式ビル用マルチ')
                                refNo = 'Rtype18';
                            elseif strcmp(tmprefname, 'ガス式ビル用マルチ')
                                refNo = 'Rtype19';
                            else
                                error('熱源名称が不正です。')
                            end
                            OUTPUT.AirConditioningSystem.HeatSourceSet(iREFSET).HeatSource(iREFSETSUB).ATTRIBUTE.Type = refNo;
                        end
                    end
                    
                    %% 計算実行
                    OUTPUTFILENAME = 'test';
                    eval(['xml_write(''',OUTPUTFILENAME,'.xml'',OUTPUT, ''Model'');'])
                    
                    if iBLDG == 3
                        if iMODEL == 1 && iDIRECTION == 1
                            y = ECS_routeB_run_v10('test.xml','OFF');
                            delete test.xml
                            tmpresENERGY = [tmpresENERGY,y(1)];
                            tmpresQcool  = [tmpresQcool, y(2)];
                            tmpresQheat  = [tmpresQheat, y(3)];
                            tmpresEffi   = [tmpresEffi, y(14)];
                        end
                    else
                        y = ECS_routeB_run_v10('test.xml','OFF');
                        delete test.xml
                        tmpresENERGY = [tmpresENERGY,y(1)];
                        tmpresQcool  = [tmpresQcool, y(2)];
                        tmpresQheat  = [tmpresQheat, y(3)];
                        tmpresEffi   = [tmpresEffi, y(14)];
                    end
                    
                end
            end
        end
        
        resENERGY = [resENERGY; tmpresENERGY];
        resQcool  = [resQcool;  tmpresQcool];
        resQheat  = [resQheat;  tmpresQheat];
        resEffi   = [resEffi;   tmpresEffi];
        resY      = [resY; y];
        
        save temp.mat resENERGY resQcool resQheat resEffi resY
        
    end
    
    % 結果出力
    RES = {};
    for iCASE = 1:caseNum
        RES{iCASE,1} = RR{1,1+iCASE};
        RES{iCASE,2} = RR{3,1+iCASE};
        RES{iCASE,3} = resion;
        for iLINE = 1:length(resENERGY(iCASE,:))
            RES{iCASE,3+iLINE} = resENERGY(iCASE,iLINE);
        end
    end
    eval(['xlswrite(''RESULT_',caseSet{1},'_',resion,'.xls'', RES,''エネルギー'')'])
    
    RES = {};
    for iCASE = 1:caseNum
        RES{iCASE,1} = RR{1,1+iCASE};
        RES{iCASE,2} = RR{3,1+iCASE};
        RES{iCASE,3} = resion;
        for iLINE = 1:length(resQcool(iCASE,:))
            RES{iCASE,3+iLINE} = resQcool(iCASE,iLINE);
        end
    end
    eval(['xlswrite(''RESULT_',caseSet{1},'_',resion,'.xls'', RES,''冷房負荷'')'])
    
    RES = {};
    for iCASE = 1:caseNum
        RES{iCASE,1} = RR{1,1+iCASE};
        RES{iCASE,2} = RR{3,1+iCASE};
        RES{iCASE,3} = resion;
        for iLINE = 1:length(resQheat(iCASE,:))
            RES{iCASE,3+iLINE} = resQheat(iCASE,iLINE);
        end
    end
    eval(['xlswrite(''RESULT_',caseSet{1},'_',resion,'.xls'', RES,''暖房負荷'')'])
    
    RES = {};
    for iCASE = 1:caseNum
        RES{iCASE,1} = RR{1,1+iCASE};
        RES{iCASE,2} = RR{3,1+iCASE};
        RES{iCASE,3} = resion;
        for iLINE = 1:length(resEffi(iCASE,:))
            RES{iCASE,3+iLINE} = resEffi(iCASE,iLINE);
        end
    end
    
    eval(['xlswrite(''RESULT_',caseSet{1},'_',resion,'.xls'', RES,''効率'')'])
    
end


toc
% パス消去
rmpath('subfunction')



