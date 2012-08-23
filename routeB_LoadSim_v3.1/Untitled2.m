clear
clc

tic

res = [];
i = 0;
for iWallType = 1:3
    if iWallType == 1
        WallType   = 'type1';
    elseif iWallType == 2
        WallType   = 'type2';
    elseif iWallType == 3
        WallType   = 'type3';
    end
    
    for iWindowType = 1:3
        if iWindowType == 1
            WindowType   = 'type1';
        elseif iWindowType == 2
            WindowType   = 'type2';
        elseif iWindowType == 3
            WindowType   = 'type3';
        end
        
        for StoryHeight = [3.5,5.5,7.5]  % äKçÇ[m]
            for WindowRatio = [0.1,0.4,0.8]; % ëãñ êœó¶[-]
                for roomDepth = [5,10,20];% é∫âúçsÇ´[m]
                    i = i+1
                    [a,R2] = func_multirun(WallType,WindowType,StoryHeight,WindowRatio,roomDepth);
                    res = [res;a,R2,iWallType,iWindowType,StoryHeight,WindowRatio,roomDepth];
                    
                end
            end
        end
    end
end

toc