% mytfunc_csv2xml_EnvList.m
%                                             by Masato Miyata 2012/02/12
%------------------------------------------------------------------------
% 省エネ基準：機器拾い表（csvファイル）を読みこみ、XMLファイルを吐き出す。
% 外壁の設定ファイルを読み込む。
%------------------------------------------------------------------------

function xmldata = mytfunc_csv2xml_AC_EnvList(xmldata,filename)

envListData = textread(filename,'%s','delimiter','\n','whitespace','');

% 外皮仕様定義ファイルの読み込み
for i=1:length(envListData)
    conma = strfind(envListData{i},',');
    for j = 1:length(conma)
        if j == 1
            envListDataCell{i,j} = envListData{i}(1:conma(j)-1);
        elseif j == length(conma)
            envListDataCell{i,j}   = envListData{i}(conma(j-1)+1:conma(j)-1);
            envListDataCell{i,j+1} = envListData{i}(conma(j)+1:end);
        else
            envListDataCell{i,j} = envListData{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% 情報の読み込み(CSVファイルから選択)

for iENV = 11:size(envListDataCell,1)
    
    % 外皮セットの情報
    xmldata.AirConditioningSystem.Envelope(iENV-10).ATTRIBUTE.ID = strcat(envListDataCell(iENV,1),'_',envListDataCell(iENV,2));
    
    envCount = 0;
    
    for iENVELE = 1:5
        
        if isempty(envListDataCell{iENV,5+8*(iENVELE-1)+1}) == 0  % 判定は方位で行う。
            envCount = envCount + 1;
            
            % 方位
            if strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'北')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'N';
            elseif strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'北東')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'NE';
            elseif strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'東')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'E';
            elseif strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'南東')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'SE';
            elseif strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'南')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'S';
            elseif strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'南西')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'SW';
            elseif strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'西')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'W';
            elseif strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'北西')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'NW';
            elseif strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'水平')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'Horizontal';
            elseif strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'屋根')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'Horizontal';
            elseif strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+1),'地中')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Direction   = 'Underground';
            else
                error('方位が不正です。')
            end
            
            % 庇
            if strcmp(envListDataCell(iENV,5+8*(iENVELE-1)+2),'■')
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Eaves   = 'None';
            else
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Eaves   = 'Any';
            end
            
            % 窓種類
            if isempty(envListDataCell{iENV,5+8*(iENVELE-1)+6}) == 0
                
                % 窓種類(ブラインド種類で場合分け)
                if strcmp(envListDataCell{iENV,5+8*(iENVELE-1)+8},'無')
                    xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Blind  = 'None';
                    xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.WindowType ...
                        = strcat(envListDataCell(iENV,5+8*(iENVELE-1)+6),'_0');
                elseif strcmp(envListDataCell{iENV,5+8*(iENVELE-1)+8},'明色')
                    xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Blind  = 'Bright';
                    xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.WindowType ...
                        = strcat(envListDataCell(iENV,5+8*(iENVELE-1)+6),'_1');
                elseif strcmp(envListDataCell{iENV,5+8*(iENVELE-1)+8},'中間色')
                    xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Blind  = 'Nautral';
                    xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.WindowType ...
                        = strcat(envListDataCell(iENV,5+8*(iENVELE-1)+6),'_2');
                elseif strcmp(envListDataCell{iENV,5+8*(iENVELE-1)+8},'暗色')
                    xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Blind  = 'Dark';
                    xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.WindowType ...
                        = strcat(envListDataCell(iENV,5+8*(iENVELE-1)+6),'_3');
                else
                    error('ブラインドの種類が不正です。')
                end
                
                % 窓面積
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.WindowArea    = envListDataCell(iENV,5+8*(iENVELE-1)+7);
                
            else
                % 窓タイプ(デフォルト）
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.WindowType    = 'None';
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.WindowArea    = '0';
                xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.Blind         = 'None';
                envListDataCell{iENV,5+8*(iENVELE-1)+7} = '0';
            end
            
            % 外壁タイプ
            xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.WallConfigure = envListDataCell(iENV,5+8*(iENVELE-1)+3);
            
            % 外壁面積（外皮面積ー窓面積）
            xmldata.AirConditioningSystem.Envelope(iENV-10).Wall(envCount).ATTRIBUTE.WallArea...
                = num2str( str2double(envListDataCell{iENV,5+8*(iENVELE-1)+5}) - str2double(envListDataCell{iENV,5+8*(iENVELE-1)+7}) );
            
        end
    end
end

end


