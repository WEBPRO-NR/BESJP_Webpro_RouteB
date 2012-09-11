function [Tref,refTime_Start,refTime_Stop] =...
    mytfunc_REFOpeTIME(Qref,PUMPsystemName,REFpumpSet,pumpTime_Start,pumpTime_Stop)

% ƒ|ƒ“ƒv‚ðŒŸõ
pumpID = [];
for i = 1:length(REFpumpSet)
    for j = 1:length(PUMPsystemName)
        if strcmp(REFpumpSet(i),PUMPsystemName(j))
            pumpID = [pumpID,j];
        end
    end
end

for dd = 1:365
    
    tmpStart = [];
    tmpStop  = [];
    
    if Qref(dd,1) > 0
        
        for iPUMP = 1:length(pumpID)
            j = pumpID(iPUMP);
            if pumpTime_Start(dd,j)==0 && pumpTime_Stop(dd,j)==0
            else
                tmpStart = [tmpStart,pumpTime_Start(dd,j)];
                tmpStop  = [tmpStop,pumpTime_Stop(dd,j)];
            end
        end
        
        refTime_Start(dd,1) = min(tmpStart);
        refTime_Stop(dd,1)  = max(tmpStop);
        
        if max(tmpStop) >= min(tmpStart)
            Tref(dd,1) = max(tmpStop)-min(tmpStart);
        else
            Tref(dd,1) = min(tmpStart)+(24-max(tmpStop));
        end
        
    else
        Tref(dd,1) = 0;
        refTime_Start(dd,1) = 0;
        refTime_Stop(dd,1) = 0;
    end
    
end
