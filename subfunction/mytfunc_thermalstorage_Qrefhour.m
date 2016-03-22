% mytfunc_thermalstorage_Qrefhour
%                                                                2016/01/11
%--------------------------------------------------------------------------
% ’~”M•‰‰×ŒvZiŒn—ñŒvZ—pj
%--------------------------------------------------------------------------

function [Qref_hour,Qref_hour_discharge] = mytfunc_thermalstorage_Qrefhour(Qref_hour,REFstorage,storageEffratio,refsetStorageSize,numOfRefs,refset_Capacity,refsetID,QrefrMax)

Qref_hour_discharge = zeros(8760,numOfRefs);

% •ú”M{’ÇŠ|‚¯
for iREF = 1:numOfRefs
    if REFstorage(iREF) == -1  % Ì”M{’ÇŠ|‚¯
        
        % ˆêŠÔ‚ ‚½‚è‚ÌÌ”MÅ‘å—Êi”MŒğŠ·Ší‚Ì—e—Êj [kW]
        Qmax   = refset_Capacity(iREF,1);
        % Å‘å’~”M—Êi’~”M‘…Œø—¦‚ğ‰Á–¡‚µ‚½³–¡‚Ì—˜—p‰Â”\—Êj [MJ]
        Qlimit = storageEffratio(iREF) * refsetStorageSize(iREF);

        % ˆê“ú–ˆ‚ÉØ‚èo‚·
        for dd = 1:365
            
            % Še“ú‚Ì•Ê•‰‰×i24ŠÔ•ªj[kW]
            Qref_daily = Qref_hour(24*(dd-1)+1:24*dd,iREF);
            
            % Še“ú‚Ì•Ê‚Ì•ú”M—Ê [kW]
            Qref_discharge = zeros(24,1);
            
            if sum(Qref_daily) > 0  % •‰‰×‚ª‚ ‚ê‚Î
                
                for hh = [13:19,12:-1:8,20:22]  % ‚±‚Ì‡”Ô‚Å’~”M‘…‚©‚ç‚Ì•ú”M‚ğs‚¤
                    
                    % ’~”M‘…‚©‚ç‚Ì•ú”M—Ê[kW]
                    Qref_discharge(hh,1) = min(Qref_daily(hh), Qmax);
                    
                    if sum(Qref_discharge) > Qlimit*1000/3600
                        
                        % ƒI[ƒo[•ª‚ğ·‚µˆø‚­
                        Qref_discharge(hh,1) = Qref_discharge(hh,1) - (sum(Qref_discharge)-Qlimit*1000/3600);
                        
                        % ƒ`ƒFƒbƒN
                        if (sum(Qref_discharge) - Qlimit*1000/3600) / Qlimit > 0.01
                            error('’~”M—Ê‚Æ•ú”M—Ê‚ª‡‚¢‚Ü‚¹‚ñ')
                        end
                        break
                    end
                end
                
            end
            
            % ’ÇŠ|‚¯‰^“]‚ª•K—v‚È•‰‰× [kW]
            Qref_hour(24*(dd-1)+1:24*dd,iREF) = (Qref_daily - Qref_discharge);
            % ’~”M‘…‚©‚ç‚Ì•ú”M—Ê [kW]
            Qref_hour_discharge(24*(dd-1)+1:24*dd,iREF) = Qref_discharge;
            
        end
        
    end
end

% ’~”M
for iREF = 1:numOfRefs
    if REFstorage(iREF) == 1  % ’~”M
        
        % •ú”M•‰‰×[kW]‚ğ‹‚ß‚éi•K—v’~”M—Ê‚ğ‹‚ß‚éjB
        Qref_hour_storage = zeros(8760,1);
        for iREFdb = 1:numOfRefs
            if strcmp(refsetID(iREF),refsetID(iREFdb)) && REFstorage(iREFdb) == -1
                Qref_hour_storage = Qref_hour_discharge(:,iREFdb);
                break
            end
        end
        
        % ˆê“ú–ˆ‚ÉØ‚èo‚·
        for dd = 2:365

            % Še“ú‚Ì•Ê•‰‰×i24ŠÔ•ªA’A‚µ‘O“ú22‚©‚ç“–“ú21‚Ü‚Åj [kW]
            Qref_r_daily = Qref_hour_storage(24*(dd-1)-1:24*dd-2);
            
            % ’~”M•‰‰× [kW]
            Qref_s_daily = zeros(24,1);
            
            if sum(Qref_r_daily) > 0
                
                % •K—v’~”MŠÔ [hour]
                T_storage = (sum(Qref_r_daily)+(refsetStorageSize(iREF)*0.03*1000/3600)) / QrefrMax(iREF);
                
                % ’~”M‚Í22‚©‚ç—‚’©6‚Ü‚Å
                if T_storage > 9
                    error('•K—v’~”MŠÔ‚ª9ŠÔ‚ğ’´‚¦‚Ü‚µ‚½B')
                else
                    
                    % Še“ú‚Ì’~”M•‰‰× [kW]
                    Qref_s_daily(1:floor(T_storage)) = QrefrMax(iREF) * ones(floor(T_storage),1);
                    Qref_s_daily(floor(T_storage)+1) = QrefrMax(iREF) * (T_storage-floor(T_storage)) ;
                    
                end

            end
            
            % ’~”M•‰‰× [kW]
            Qref_hour(24*(dd-1)-1:24*dd-2,iREF) = Qref_s_daily;
            
        end
        
    end
end













