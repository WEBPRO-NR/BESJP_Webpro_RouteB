% mytscript_calcQroom.m
%                                       by Masato Miyata 2012/07/13
%------------------------------------------------------------------
% ä»ó™ïââ◊åvéZñ@
%------------------------------------------------------------------


%% ÉfÅ[É^ÉxÅ[ÉXì«Ç›çûÇ›

% ï‚ê≥åWêîÉfÅ[É^ÉxÅ[ÉXÇÃì«Ç›çûÇ›ÅiçsÇ≤Ç∆Åj
DB_COEFFI = textread('./database/QROOM_COEFFI.csv','%s','delimiter','\n','whitespace','');

% CSVÉtÉ@ÉCÉãÇÃÉfÅ[É^ì«Ç›çûÇ›Åiïœêî perDB_COEFFIÅj
for i=1:length(DB_COEFFI)
    conma = strfind(DB_COEFFI{i},',');
    for j = 1:length(conma)
        if j == 1
            perDB_COEFFI{i,j} = DB_COEFFI{i}(1:conma(j)-1);
        elseif j == length(conma)
            perDB_COEFFI{i,j}   = DB_COEFFI{i}(conma(j-1)+1:conma(j)-1);
            perDB_COEFFI{i,j+1} = DB_COEFFI{i}(conma(j)+1:end);
        else
            perDB_COEFFI{i,j} = DB_COEFFI{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% äYìñínàÊÇÃÉfÅ[É^ÇêÿÇËèoÇµ(ïœêî C_sta2dyn)
switch climateAREA
    case {'Ia'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,7:9]);
    case {'Ib'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,10:12]);
    case {'II'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,13:15]);
    case {'III'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,16:18]);
    case {'IVa'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,19:21]);
    case {'IVb'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,22:24]);
    case {'V'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,25:27]);
    case {'VI'}
        C_sta2dyn = perDB_COEFFI(:,[1:6,28:30]);
    otherwise
        error('')
end

% äeé∫ÇÃï‚ê≥åWêîÇî≤Ç´èoÇ∑
C_sta2dyn_CTC = zeros(numOfRoooms,3);
C_sta2dyn_CTH = zeros(numOfRoooms,3);
C_sta2dyn_CSR = zeros(numOfRoooms,3);
C_sta2dyn_HTC = zeros(numOfRoooms,3);
C_sta2dyn_HTH = zeros(numOfRoooms,3);
C_sta2dyn_HSR = zeros(numOfRoooms,3);
C_sta2dyn_MTC = zeros(numOfRoooms,3);
C_sta2dyn_MTH = zeros(numOfRoooms,3);
C_sta2dyn_MSR = zeros(numOfRoooms,3);
C_sta2dyn_CTC_off = zeros(numOfRoooms,3); 
C_sta2dyn_CTH_off = zeros(numOfRoooms,3); 
C_sta2dyn_CSR_off = zeros(numOfRoooms,3); 
C_sta2dyn_HTC_off = zeros(numOfRoooms,3); 
C_sta2dyn_HTH_off = zeros(numOfRoooms,3); 
C_sta2dyn_HSR_off = zeros(numOfRoooms,3); 
C_sta2dyn_MTC_off = zeros(numOfRoooms,3); 
C_sta2dyn_MTH_off = zeros(numOfRoooms,3); 
C_sta2dyn_MSR_off = zeros(numOfRoooms,3); 

for iROOM = 1:numOfRoooms
    
    % äeé∫ÇÃåöï®ópìr
    switch buildingType{iROOM}
        case 'Office'
            BTname = 'éññ±èäìô';
        case 'Hotel'
            BTname = 'ÉzÉeÉãìô';
        case 'Hospital'
            BTname = 'ïaâ@ìô';
        case 'Store'
            BTname = 'ìXï‹ìô';
        case 'School'
            BTname = 'äwçZìô';
        case 'Restaurant'
            BTname = 'à˘êHìXìô';
        case 'MeetingPlace'
            BTname = 'èWâÔèäìô';
        otherwise
            error('åöï®ópìrÇ™ïsê≥Ç≈Ç∑')
    end
    
    % ÉfÅ[É^ÉxÅ[ÉX C_sta2dyn åüçı
    check = 0; % É`ÉFÉbÉNóp
    for iDB = 5:length(C_sta2dyn)
        
        if strcmp(C_sta2dyn(iDB,1),BTname) && strcmp(C_sta2dyn(iDB,2),roomType{iROOM}) % åöï®ópìrÇ∆é∫ópìrÇåüçı
            
            % ó‚ñ[ä˙ÅEä—ó¨îMÅEó‚ñ[
            C_sta2dyn_CTC(iROOM,1:3) = str2double(C_sta2dyn(iDB,7:9));
            % ó‚ñ[ä˙ÅEä—ó¨îMÅEígñ[
            C_sta2dyn_CTH(iROOM,1:3) = str2double(C_sta2dyn(iDB+1,7:9));
            % ó‚ñ[ä˙ÅEì˙éÀîM
            C_sta2dyn_CSR(iROOM,1:3) = str2double(C_sta2dyn(iDB+2,7:9));
            
            % ígñ[ä˙ÅEä—ó¨îMÅEó‚ñ[
            C_sta2dyn_HTC(iROOM,1:3) = str2double(C_sta2dyn(iDB+3,7:9));
            % ígñ[ä˙ÅEä—ó¨îMÅEígñ[
            C_sta2dyn_HTH(iROOM,1:3) = str2double(C_sta2dyn(iDB+4,7:9));
            % ígñ[ä˙ÅEì˙éÀîM
            C_sta2dyn_HSR(iROOM,1:3) = str2double(C_sta2dyn(iDB+5,7:9));
            
            % íÜä‘ä˙ÅEä—ó¨îMÅEó‚ñ[
            C_sta2dyn_MTC(iROOM,1:3) = str2double(C_sta2dyn(iDB+6,7:9));
            % íÜä‘ä˙ÅEä—ó¨îMÅEígñ[
            C_sta2dyn_MTH(iROOM,1:3) = str2double(C_sta2dyn(iDB+7,7:9));
            % íÜä‘ä˙ÅEì˙éÀîM
            C_sta2dyn_MSR(iROOM,1:3) = str2double(C_sta2dyn(iDB+8,7:9));
            
            % ëOì˙ãxÇ›ÇÃèÍçáÇÃåWêî
            if isempty(C_sta2dyn{iDB+9,1})  % ÅiiDB+9Åjçsñ⁄Ç™ãÛÇ≈Ç†ÇÍÇŒëOì˙ãxÇ›ÇÃèÍçáÇÃåWêîÇ†ÇËÇ∆Ç›Ç»Ç∑
                % ó‚ñ[ä˙ÅEä—ó¨îMÅEó‚ñ[
                C_sta2dyn_CTC_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+9,7:9));
                % ó‚ñ[ä˙ÅEä—ó¨îMÅEígñ[
                C_sta2dyn_CTH_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+10,7:9));
                % ó‚ñ[ä˙ÅEì˙éÀîM
                C_sta2dyn_CSR_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+11,7:9));
                
                % ígñ[ä˙ÅEä—ó¨îMÅEó‚ñ[
                C_sta2dyn_HTC_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+12,7:9));
                % ígñ[ä˙ÅEä—ó¨îMÅEígñ[
                C_sta2dyn_HTH_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+13,7:9));
                % ígñ[ä˙ÅEì˙éÀîM
                C_sta2dyn_HSR_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+14,7:9));
                
                % íÜä‘ä˙ÅEä—ó¨îMÅEó‚ñ[
                C_sta2dyn_MTC_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+15,7:9));
                % íÜä‘ä˙ÅEä—ó¨îMÅEígñ[
                C_sta2dyn_MTH_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+16,7:9));
                % íÜä‘ä˙ÅEì˙éÀîM
                C_sta2dyn_MSR_off(iROOM,1:3) = str2double(C_sta2dyn(iDB+17,7:9));
            end
            
            check = 1;
        end
        
    end
    
    % åüçıåãâ ÇÃîªíË
    if check == 0
        error('é∫ópìr %s Ç™å©Ç¬Ç©ÇËÇ‹ÇπÇÒ', roomType{iROOM})
    end
    
end


% ãCè€ÉfÅ[É^ÇÃì«Ç›çûÇ›ÅiçsÇ≤Ç∆Åj
DB_WEATHER = textread(cell2mat(strcat('./weathdat/',strrep(climateDatabase,'.has','_NM1D.csv'))),...
    '%s','delimiter','\n','whitespace','');

% CSVÉtÉ@ÉCÉãÇÃÉfÅ[É^ì«Ç›çûÇ›Åiïœêî perDB_WEATHERÅj
for i=1:length(DB_WEATHER)
    conma = strfind(DB_WEATHER{i},',');
    for j = 1:length(conma)
        if j == 1
            perDB_WEATHER{i,j} = DB_WEATHER{i}(1:conma(j)-1);
        elseif j == length(conma)
            perDB_WEATHER{i,j}   = DB_WEATHER{i}(conma(j-1)+1:conma(j)-1);
            perDB_WEATHER{i,j+1} = DB_WEATHER{i}(conma(j)+1:end);
        else
            perDB_WEATHER{i,j} = DB_WEATHER{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

% äOãCâ∑ [Åé]
Toa_ave = str2double(perDB_WEATHER(3:end,4));
Toa_day = str2double(perDB_WEATHER(3:end,5));
Toa_ngt = str2double(perDB_WEATHER(3:end,6));
% éºìx [kg/kgDA]
Xoa_ave = str2double(perDB_WEATHER(3:end,7))./1000;
Xoa_day = str2double(perDB_WEATHER(3:end,8))./1000;
Xoa_ngt = str2double(perDB_WEATHER(3:end,9))./1000;
% íºíBì˙éÀó [Wh/m2](ÉKÉâÉXì¸éÀäpîΩâfÅE0.89Ç≈èúÇµÇƒäÓèÄâªçœÇ›)
DSR_S   = str2double(perDB_WEATHER(3:end,10));
DSR_SW  = str2double(perDB_WEATHER(3:end,11));
DSR_W   = str2double(perDB_WEATHER(3:end,12));
DSR_NW  = str2double(perDB_WEATHER(3:end,13));
DSR_N   = str2double(perDB_WEATHER(3:end,14));
DSR_NE  = str2double(perDB_WEATHER(3:end,15));
DSR_E   = str2double(perDB_WEATHER(3:end,16));
DSR_SE  = str2double(perDB_WEATHER(3:end,17));
DSR_H   = str2double(perDB_WEATHER(3:end,18));
% ìVãÛÅEîΩéÀì˙éÀó [Wh/m2](ÉKÉâÉXì¸éÀäpîΩâfÇΩÇæÇµ0.808ÇÕèÊÇ∂ÇƒÇ¢Ç»Ç¢)
ISR_V   = str2double(perDB_WEATHER(3:end,19));  % âîíº
ISR_H   = str2double(perDB_WEATHER(3:end,20));  % êÖïΩ
% ñÈä‘ï˙éÀ[Wh/m2]
NSR_V   = str2double(perDB_WEATHER(3:end,21));  % âîíº
NSR_H   = str2double(perDB_WEATHER(3:end,22));  % êÖïΩ

% èoóÕóp
OAdataAll = [Toa_ave,Xoa_ave,mytfunc_enthalpy(Toa_ave,Xoa_ave)];
OAdataDay = [Toa_day,Xoa_day,mytfunc_enthalpy(Toa_day,Xoa_day)];
OAdataNgt = [Toa_ngt,Xoa_ngt,mytfunc_enthalpy(Toa_ngt,Xoa_ngt)];



%% ï«Ç‚ëãÇÃîMê´î\ÇÃì«Ç›çûÇ›

% ïœêîíËã`
Qwall_T  = zeros(365,numOfRoooms);
Qwall_S  = zeros(365,numOfRoooms);
Qwall_N  = zeros(365,numOfRoooms);
Qwind_T  = zeros(365,numOfRoooms);
Qwind_S  = zeros(365,numOfRoooms);
Qwind_N  = zeros(365,numOfRoooms);
Qroom_CTC  = zeros(365,numOfRoooms);
Qroom_CTH  = zeros(365,numOfRoooms);
Qroom_CSR  = zeros(365,numOfRoooms);
AHUonoff   = zeros(365,numOfRoooms);
Qcool     = zeros(365,numOfRoooms);
Qheat     = zeros(365,numOfRoooms);
QroomDc   = zeros(365,numOfRoooms);
QroomDh   = zeros(365,numOfRoooms);


% é∫íPà ÇÃÉãÅ[Év
for iROOM = 1:numOfRoooms
    
    % äOîÁIDÅiEnvelopeRefÅjÇ©ÇÁäOîÁédólID(envelopeID ÇÃ iENV)ÇíTÇ∑
    for iENV = 1:numOfENVs
        if strcmp(EnvelopeRef{iROOM},envelopeID{iENV}) == 1
            break
        end
    end
    
    % äOï«ÅEëãÇÃèÓïÒÇì«Ç›çûÇﬁ
    for iWALL = 1:numOfWalls(iENV)
        
        % ï˚à åWêîÅiï˚à ÅFDirection{iENV,iWALL}ÅjÅièZëÓÇÃï˚à åWêîÇåpè≥Åj
        if strcmp(Direction{iENV,iWALL},'N')
            directionV = 0.24;
        elseif strcmp(Direction{iENV,iWALL},'E') || strcmp(Direction{iENV,iWALL},'W')
            directionV = 0.45;
        elseif strcmp(Direction{iENV,iWALL},'S')
            directionV = 0.39;
        elseif strcmp(Direction{iENV,iWALL},'SE') || strcmp(Direction{iENV,iWALL},'SW')
            directionV = 0.45;
        elseif strcmp(Direction{iENV,iWALL},'NE') || strcmp(Direction{iENV,iWALL},'NW')
            directionV = 0.34;
        elseif strcmp(Direction{iENV,iWALL},'Horizontal')
            directionV = 1;
        elseif strcmp(Direction{iENV,iWALL},'Underground')
            directionV = 0;
        else
            directionV = 0.5;
        end
        
        % äOï«Ç™Ç†ÇÍÇŒÅiäOï«ñºèÃ WallConfigure Ç≈íTç∏Åj
        if isempty(WallConfigure{iENV,iWALL}) == 0
            
            % äOï«ç\ê¨ÉäÉXÉg WallNameList ÇÃåüçı
            for iDB = 1:length(WallNameList)
                if strcmp(WallNameList{iDB},WallConfigure{iENV,iWALL})
                    % UílÅ~äOï«ñ êœ
                    WallUA = WallUvalueList(iDB)*(WallArea(iENV,iWALL) - WindowArea(iENV,iWALL));
                    
                    % UA,MAï€ë∂
                    UAlist(iROOM) = UAlist(iROOM) + WallUA;
                    MAlist(iROOM) = MAlist(iROOM) + directionV*(0.8*0.04)*WallUA;
                    
                    switch Direction{iENV,iWALL}
                        
                        case 'Horizontal'
                        
                            if WallTypeNum(iENV,iWALL) == 1  % äOãCÇ…ê⁄Ç∑ÇÈï«
                                Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(Toa_ave-TroomSP).*24;      % ä—ó¨îMéÊìæ(365ì˙ï™)                            
                            elseif WallTypeNum(iENV,iWALL) == 2  % ê⁄ínï«
                                Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(mean(Toa_ave)*ones(365,1)-TroomSP).*24;      % ä—ó¨îMéÊìæ(365ì˙ï™)
                            else
                                error('äOï«É^ÉCÉvÇ™ïsê≥Ç≈Ç∑')
                            end
                            Qwall_S(:,iROOM) = Qwall_S(:,iROOM) + WallUA.*(0.8/23.3).*(DSR_H+ISR_H);  % ì˙éÀîMéÊìæ(365ì˙ï™)
                            Qwall_N(:,iROOM) = Qwall_N(:,iROOM) - WallUA.*(0.9/23.3).*NSR_H;          % ñÈä‘ï˙éÀ(365ì˙ï™)
                            
                        case 'Shade'
                            
                            if WallTypeNum(iENV,iWALL) == 1  % äOãCÇ…ê⁄Ç∑ÇÈï«
                                Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(Toa_ave-TroomSP).*24;   % ä—ó¨îMéÊìæ(365ì˙ï™)
                            elseif WallTypeNum(iENV,iWALL) == 2  % ê⁄ínï«
                                Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(mean(Toa_ave)*ones(365,1)-TroomSP).*24;      % ä—ó¨îMéÊìæ(365ì˙ï™)
                            else
                                error('äOï«É^ÉCÉvÇ™ïsê≥Ç≈Ç∑')
                            end
                            
                            % ì˙éÀÇÕâΩÇ‡ë´Ç≥Ç»Ç¢
                            
                        otherwise
                            
                            if WallTypeNum(iENV,iWALL) == 1  % äOãCÇ…ê⁄Ç∑ÇÈï«
                                Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(Toa_ave-TroomSP).*24;      % ä—ó¨îMéÊìæ(365ì˙ï™)
                            elseif WallTypeNum(iENV,iWALL) == 2  % ê⁄ínï«
                                Qwall_T(:,iROOM) = Qwall_T(:,iROOM) + WallUA.*(mean(Toa_ave)*ones(365,1)-TroomSP).*24;      % ä—ó¨îMéÊìæ(365ì˙ï™)
                            else
                                error('äOï«É^ÉCÉvÇ™ïsê≥Ç≈Ç∑')
                            end 
                            
                            eval(['Qwall_S(:,iROOM) = Qwall_S(:,iROOM) + WallUA.*(0.8/23.3).*(DSR_',Direction{iENV,iWALL},'+ISR_V);']);  % ì˙éÀîMéÊìæ(365ì˙ï™)
                            Qwall_N(:,iROOM) = Qwall_N(:,iROOM) - WallUA.*(0.9/23.3).*NSR_V;  % ñÈä‘ï˙éÀ(365ì˙ï™)
                    end
                end
            end
        end
        
        % ëãÇ™Ç†ÇÍÇŒÅiëãñºèÃ WindowType Ç≈íTç∏Åj
        if isempty(WindowType{iENV,iWALL}) == 0 && strcmp(WindowType{iENV,iWALL},'Null') == 0
            
            % ëãÉäÉXÉg WindowNameList ÇÃåüçı
            for iDB = 1:length(WindowNameList)
                if strcmp(WindowNameList{iDB},WindowType{iENV,iWALL})
                    
                    % UílÅ~ëãñ êœ
                    WindowUA = WindowUvalueList(iDB)*WindowArea(iENV,iWALL);
                    % (SCCÅASCR)Å~ëãñ êœ
                    WindowSCC = WindowSCCList(iDB)*WindowArea(iENV,iWALL);
                    WindowSCR = WindowSCRList(iDB)*WindowArea(iENV,iWALL);
                    
                    % ì˙ÇÊÇØå¯â åWêîÅió‚ñ[Åj 
                    WindowEavesC = Eaves_Cooling{iENV,iWALL};
                    if strcmp(WindowEavesC,'Null') || isnan(WindowEavesC) || isempty(WindowEavesC) || WindowEavesC > 1
                        WindowEavesC = 1;
                    elseif WindowEavesC < 0
                        WindowEavesC = 0;
                    end

                    % ì˙ÇÊÇØå¯â åWêîÅiígñ[Åj
                    WindowEavesH = Eaves_Heating{iENV,iWALL};
                    if strcmp(WindowEavesH,'Null') || isnan(WindowEavesH) || isempty(WindowEavesH) || WindowEavesH > 1
                        WindowEavesH = 1;
                    elseif WindowEavesH < 0
                        WindowEavesH = 0;
                    end
                                                            
                    % UA,MAï€ë∂
                    UAlist(iROOM) = UAlist(iROOM) + WindowUA;
                    MAlist(iROOM) = MAlist(iROOM) + WindowEavesC * directionV * WindowMyuList(iDB)*WindowArea(iENV,iWALL);  
                    
                    switch Direction{iENV,iWALL}
                        case 'Horizontal'
                            
                            Qwind_T(:,iROOM) = Qwind_T(:,iROOM) + WindowUA.*(Toa_ave-TroomSP).*24;   % ä—ó¨îMéÊìæ(365ì˙ï™)
                          
                            for dd = 1:365
                                if SeasonMode(dd) == -1  % ígñ[
                                    Qwind_S(dd,iROOM) = Qwind_S(dd,iROOM) + WindowEavesH.* (WindowSCC+WindowSCR).*(DSR_H(dd)*0.89+ISR_H(dd)*0.808); % ì˙éÀîMéÊìæ(365ì˙ï™)
                                else
                                    Qwind_S(dd,iROOM) = Qwind_S(dd,iROOM) + WindowEavesC.* (WindowSCC+WindowSCR).*(DSR_H(dd)*0.89+ISR_H(dd)*0.808); % ì˙éÀîMéÊìæ(365ì˙ï™)
                                end
                            end
                            
                            Qwind_N(:,iROOM) = Qwind_N(:,iROOM) - WindowUA.*(0.9/23.3).*NSR_H;  % ñÈä‘ï˙éÀ(365ì˙ï™)
                            
                        case 'Shade'
                            % âΩÇ‡ÇµÇ»Ç¢
                            
                        otherwise
                            Qwind_T(:,iROOM) = Qwind_T(:,iROOM) + WindowUA.*(Toa_ave-TroomSP).*24;   % ä—ó¨îMéÊìæ(365ì˙ï™)
                            
                            for dd = 1:365
                                if SeasonMode(dd) == -1  % ígñ[
                                    eval(['Qwind_S(dd,iROOM) = Qwind_S(dd,iROOM) + WindowEavesH.*(WindowSCC+WindowSCR).*(DSR_',Direction{iENV,iWALL},'(dd)*0.89+ISR_V(dd)*0.808);']) % ì˙éÀîMéÊìæ(365ì˙ï™)
                                else
                                    eval(['Qwind_S(dd,iROOM) = Qwind_S(dd,iROOM) + WindowEavesC.*(WindowSCC+WindowSCR).*(DSR_',Direction{iENV,iWALL},'(dd)*0.89+ISR_V(dd)*0.808);']) % ì˙éÀîMéÊìæ(365ì˙ï™)
                                end
                            end
                            
                            Qwind_N(:,iROOM) = Qwind_N(:,iROOM) - WindowUA.*(0.9/23.3).*NSR_V;  % ñÈä‘ï˙éÀ(365ì˙ï™)
                    end
                    
                end
            end
        end

    end
    
    % é∫ñ êœÇ†ÇΩÇËÇÃîMó Ç…ïœä∑ [Wh/m2/ì˙]
    Qwall_T(:,iROOM) = Qwall_T(:,iROOM)./roomArea(iROOM);
    Qwall_S(:,iROOM) = Qwall_S(:,iROOM)./roomArea(iROOM);
    Qwall_N(:,iROOM) = Qwall_N(:,iROOM)./roomArea(iROOM);
    Qwind_T(:,iROOM) = Qwind_T(:,iROOM)./roomArea(iROOM);
    Qwind_S(:,iROOM) = Qwind_S(:,iROOM)./roomArea(iROOM);
    Qwind_N(:,iROOM) = Qwind_N(:,iROOM)./roomArea(iROOM);
    
    
    % ì˙íPà Ç≈ïââ◊åvéZÇé¿çs
    for dd = 1:365
        
        % ÉXÉPÉWÉÖÅ[ÉãÉpÉ^Å[ÉìÅiÇPÅCÇQÅCÇRÅj
        Sptn = roomDailyOpePattern(dd,iROOM);
        
        % ì‡ïîî≠îMó  [Wh/m2]
        W1(dd,iROOM) = sum(roomScheduleOAapp(iROOM,Sptn,:)) .*roomEnergyOAappUnit(iROOM);  % ã@äÌ
        W2(dd,iROOM) = sum(roomScheduleLight(iROOM,Sptn,:)) .*roomEnergyLight(iROOM);      % è∆ñæ
        W3(dd,iROOM) = sum(roomSchedulePerson(iROOM,Sptn,:)).*roomEnergyPerson(iROOM);     % êlëÃ
        
        % ãÛí≤ONOFF (ãÛí≤äJénéûçèÇ∆èIóπéûçèÇ™àŸÇ»ÇÍÇŒ ON Ç∆Ç∑ÇÈ)
        if roomTime_start(dd,iROOM) ~= roomTime_stop(dd,iROOM)
            AHUonoff(dd,iROOM) = 1;
        end
        
        if AHUonoff(dd,iROOM) > 0
            
            if SeasonMode(dd) == 1   % ó‚ñ[ä˙
                
                if dd > 1 && AHUonoff(dd-1)==1
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_CTC(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_CTC(3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_CTH(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_CTH(3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_CSR(1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_CSR(3);
                else
                    % ëOì˙Ç™îÒãÛí≤ÇÃèÍçá
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_CTC_off(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_CTC_off(3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_CTH_off(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_CTH_off(3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_CSR_off(1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_CSR_off(3);
                end
                
            elseif SeasonMode(dd) == -1 % ígñ[ä˙
                
                if dd > 1 && AHUonoff(dd-1)==1
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_HTC(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_HTC(3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_HTH(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_HTH(3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_HSR(1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_HSR(3);
                else
                    % ëOì˙Ç™îÒãÛí≤ÇÃèÍçá
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_HTC_off(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_HTC_off(3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_HTH_off(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_HTH_off(3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_HSR_off(1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_HSR_off(3);
                end
                
            elseif SeasonMode(dd) == 0  % íÜä‘ä˙
                
                if dd > 1 && AHUonoff(dd-1)==1
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_MTC(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_MTC(3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_MTH(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_MTH(3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_MSR(1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_MSR(3);
                else
                    % ëOì˙Ç™îÒãÛí≤ÇÃèÍçá
                    Qroom_CTC(dd,iROOM) = C_sta2dyn_MTC_off(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_MTC_off(3);
                    Qroom_CTH(dd,iROOM) = C_sta2dyn_MTH_off(1) * (Qwall_T(dd,iROOM) + Qwall_N(dd,iROOM) + Qwind_T(dd,iROOM) + Qwind_N(dd,iROOM)) + C_sta2dyn_MTH_off(3);
                    Qroom_CSR(dd,iROOM) = C_sta2dyn_MSR_off(1) * (Qwall_S(dd,iROOM) + Qwind_S(dd,iROOM)) +  C_sta2dyn_MSR_off(3);
                end
                
            else
                error('ãGêﬂãÊï™Ç™ïsê≥Ç≈Ç∑')
            end
            
            if Qroom_CTC(dd,iROOM) < 0
                Qroom_CTC(dd,iROOM) = 0;
            end
            if Qroom_CTH(dd,iROOM) > 0
                Qroom_CTH(dd,iROOM) = 0;
            end
            if Qroom_CSR(dd,iROOM) < 0
                Qroom_CSR(dd,iROOM) = 0;
            end
            
            % ì˙éÀïââ◊ Qroom_CSR Çígñ[ïââ◊ Qroom_CTH Ç…ë´Ç∑
            Qcool(dd,iROOM) = Qroom_CTC(dd,iROOM);
            Qheat(dd,iROOM) = Qroom_CTH(dd,iROOM) + Qroom_CSR(dd,iROOM);
            
            % ì˙éÀïââ◊Ç…ÇÊÇ¡Çƒígñ[ïââ◊Ç™ÉvÉâÉXÇ…Ç»Ç¡ÇΩèÍçáÇÕÅAí¥âﬂï™Çó‚ñ[ïââ◊Ç…â¡éZ
            if Qheat(dd,iROOM) > 0
                Qcool(dd,iROOM) = Qcool(dd,iROOM) + Qheat(dd,iROOM);
                Qheat(dd,iROOM) = 0;
            end
            
            % ì‡ïîî≠îM W1,W2,W3 Çígñ[ïââ◊ Qheat Ç…ë´Ç∑
            Qheat(dd,iROOM) = Qheat(dd,iROOM) + (W1(dd,iROOM) + W2(dd,iROOM) + W3(dd,iROOM));
            
            % ì‡ïîî≠îMÇ…ÇÊÇ¡Çƒígñ[ïââ◊Ç™ÉvÉâÉXÇ…Ç»Ç¡ÇΩèÍçáÇÕÅAí¥âﬂï™Çó‚ñ[ïââ◊Ç…â¡éZ
            if Qheat(dd,iROOM) > 0
                Qcool(dd,iROOM) = Qcool(dd,iROOM) + Qheat(dd,iROOM);
                Qheat(dd,iROOM) = 0;
            end
            
        else
            % ãÛí≤OFFéûÇÕ 0 Ç∆Ç∑ÇÈ
             Qcool(dd,iROOM) = 0;
             Qheat(dd,iROOM) = 0;
        end

    end
    
    % èoóÕ [Wh/m2/ì˙] Å® [MJ/day]
    QroomDc(:,iROOM) = Qcool(:,iROOM) .* (3600/1000000) .* roomArea(iROOM);
    QroomDh(:,iROOM) = Qheat(:,iROOM) .* (3600/1000000) .* roomArea(iROOM);
    
end
