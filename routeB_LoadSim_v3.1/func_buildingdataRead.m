function [phi,longi,rhoG,alp,bet,AreaRoom,awall,Fs,AreaWall,AreaWind,seasonS,seasonM,seasonW,TroomS,TroomM,TroomW,...
    Kwall,Kwind,SCC,SCR] = func_buildingdataRead(filename,WallType,WindowType,StoryHeight,WindowRatio,roomDepth)

% 建物データ読み込み
eval(['A = textread(''./',filename,''',''%s'',''delimiter'',''\n'',''whitespace'','''');'])

for i = 2:length(A)
    if isempty(A{i})==0
        if strcmp(A{i}(1:4),'BUIL')
            phi   = str2double(A{i}(12:17));     % 緯度
            longi = str2double(A{i}(18:23));     % 経度
            rhoG  = str2double(A{i}(30:35))/100; % 地面反射率 [-]
            
        elseif strcmp(A{i}(1:4),'EXPS')
            alp   = str2double(A{i}(18:23));  % 方位角 LEXPS(2) 南を0°として西方向へ時計回り　西90°，北180°，東270°(-90°)
            bet   = str2double(A{i}(12:17));  % 傾斜角 LEXPS(1) 水平面を0°とする．垂直面は90°，プロティの床は180°
            
        elseif strcmp(A{i}(1:4),'SEAS')
            seasonW = {};
            seasonM = {};
            seasonS = {};
            for j=1:12
                tmp = str2double(A{i}(12+3*(j-1):12+3*j-1));
                if tmp == 1
                    seasonS = [seasonS,j];
                elseif tmp == 3
                    seasonM = [seasonM,j];
                elseif tmp == 2
                    seasonW = [seasonW,j];
                end
            end
            
        elseif strcmp(A{i}(1:4),'OPCO')
            TroomS = str2double(A{i}(27:29));
            TroomW = str2double(A{i}(45:47));
            TroomM = str2double(A{i}(63:65));
            
        elseif strcmp(A{i}(1:4),'SPAC')
            
            % 階高
            A{i}(26-length(num2str(StoryHeight))+1:26) = num2str(StoryHeight);
            
            % 天井高
            if StoryHeight == 3.5
                CeilHeight = 2.7;
            elseif StoryHeight == 4.5
                CeilHeight = 3.5;
            elseif StoryHeight == 5.5
                CeilHeight = 4.5;
            else
                CeilHeight = StoryHeight - 1;
            end
            A{i}(32-length(num2str(CeilHeight))+1:32) = num2str(CeilHeight);
            
            % 床面積
            AreaRoom = 10*roomDepth;     % 延床面積 [m2]
            
            A{i}(42:50) = '         ';   % 消去
            A{i}(42:42+length(num2str(AreaRoom))-1) = num2str(AreaRoom);
            
            
        elseif strcmp(A{i}(1:4),'OWAL')
            awall    = str2double(A{i}(15:17))/100;  % 日射吸収率 [-]
            Fs       = str2double(A{i}(18:20))/100;  % 長波放射率 [-]
            
            % 外壁面積
            AreaWall = 10*StoryHeight*(1-WindowRatio);
            A{i}(42:50) = '         '; % 消去
            A{i}(42:42+length(num2str(AreaWall))-1) = num2str(AreaWall);
            
            
        elseif strcmp(A{i}(1:4),'WNDW')
            
            switch WindowType
                case 'type1'
                    A{i}(6:17) = 'SNGLS      1';
                    Kwind = 6.300;   % 窓熱貫流率 [W/m2K]
                    SCC   = 0.015;   % 対流成分の日射遮蔽係数 [-]
                    SCR   = 0.985;   % 放射成分の日射遮蔽係数 [-]
                case 'type2'
                    A{i}(6:17) = 'DL06S      3';
                    Kwind = 3.500;   % 窓熱貫流率 [W/m2K]
                    SCC   = 0.056;   % 対流成分の日射遮蔽係数 [-]
                    SCR   = 0.779;   % 放射成分の日射遮蔽係数 [-]
                case 'type3'
                    A{i}(6:17) = 'DL12S      3';
                    Kwind = 3.100;   % 窓熱貫流率 [W/m2K]
                    SCC   = 0.056;   % 対流成分の日射遮蔽係数 [-]
                    SCR   = 0.779;   % 放射成分の日射遮蔽係数 [-]
            end
            
            % 窓面積
            AreaWind = 10*StoryHeight*WindowRatio; % 窓面積 [m2]
            A{i}(42:50) = '         '; % 消去
            A{i}(42:42+length(num2str(AreaWind))-1) = num2str(AreaWind);
            
        elseif strcmp(A{i}(1:4),'WCON')
            
            % 外壁仕様の書き換え
            if strcmp(A{i}(5:8),' OW1')
                switch WallType
                    case 'type1'
                        A{i}  = 'WCON OW1    22150';         % 無断熱
                        Kwall = (1/23.3+0.15/1.4+1/9.3)^-1;
                    case 'type2'
                        A{i}  = 'WCON OW1    84 15 22150';   % 標準断熱(15mm)
                        Kwall = (1/23.3+0.015/0.028+0.15/1.4+1/9.3)^-1;
                    case 'type3'
                        A{i}  = 'WCON OW1    84 50 22150';   % 高断熱(50mm)
                        Kwall =(1/23.3+0.050/0.028+0.15/1.4+1/9.3)^-1;
                end
            end
            
        end
        
    end
    
end


% 新しい建物データを出力
newfilename = 'buildingdata.txt';
eval(['fid = fopen(''',newfilename,''',''w+'');'])
for i=1:length(A)
fprintf(fid,'%s\r\n',A{i});
end
y = fclose(fid);



