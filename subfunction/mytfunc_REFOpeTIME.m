function [Tref,refsystemOpeTime] =...
    mytfunc_REFOpeTIME(Qref,PUMPsystemName,REFpumpSet,pumpsystemOpeTime)

% ƒ|ƒ“ƒv‚ðŒŸõ
pumpID = [];
for i = 1:length(REFpumpSet)
    for j = 1:length(PUMPsystemName)
        if strcmp(REFpumpSet(i),PUMPsystemName(j))
            pumpID = [pumpID,j];
        end
    end
end

% Še“ú‚Ì”MŒ¹‰^“]ŽžŠÔ
Tref = zeros(365,1);
% ”MŒ¹‚Ì‰^“]ŽžŠÔƒ}ƒgƒŠƒbƒNƒX
refsystemOpeTime = zeros(365,24);

for dd = 1:365
    
    %     tmpStart = [];
    %     tmpStop  = [];
    
    if Qref(dd,1) > 0
        
        % ‰^“]ŽžŠÔƒ}ƒgƒŠƒbƒNƒX
        tmp = zeros(1,1,24);
        
        for iPUMP = 1:length(pumpID)
            % ‰^“]ŽžŠÔƒ}ƒgƒŠƒbƒNƒX‚ÉApumpsystemOpeTimei‰^“]‚È‚ç1A’âŽ~‚È‚ç0j‚ð‘«‚µ‚±‚ÞB
            tmp = tmp + pumpsystemOpeTime(pumpID(iPUMP),dd,:);
        end
        
        for hh = 1:24
            if tmp(1,1,hh) > 0
                refsystemOpeTime(dd,hh) = 1;
            end
        end
        
        % Še“ú‚Ì”MŒ¹‰^“]ŽžŠÔ
        Tref(dd,1) = sum(refsystemOpeTime(dd,:));
        
        
        %         for iPUMP = 1:length(pumpID)
        %             j = pumpID(iPUMP);
        %             if pumpTime_Start(dd,j)==0 && pumpTime_Stop(dd,j)==0
        %             else
        %                 tmpStart = [tmpStart,pumpTime_Start(dd,j)];
        %                 tmpStop  = [tmpStop,pumpTime_Stop(dd,j)];
        %             end
        %         end
        %
        %         refTime_Start(dd,1) = min(tmpStart);
        %         refTime_Stop(dd,1)  = max(tmpStop);
        %
        %         if max(tmpStop) >= min(tmpStart)
        %             Tref(dd,1) = max(tmpStop)-min(tmpStart);
        %         else
        %             Tref(dd,1) = min(tmpStart)+(24-max(tmpStop));
        %         end
        %
        %     else
        %         Tref(dd,1) = 0;
        %         refTime_Start(dd,1) = 0;
        %         refTime_Stop(dd,1) = 0;
        %     end
        
    end
end
