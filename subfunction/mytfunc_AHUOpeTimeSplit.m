% mytfunc_AHUOpeTimeSplit.m
%                                                by Masato Miyata 20120302
%-------------------------------------------------------------------------
% “ú•Ê‹ó’²‰^“]ŠÔ‚ğ—â–[‰^“]ŠÔ‚Æ’g–[‰^“]ŠÔ‚ÉU‚è•ª‚¯‚é
%-------------------------------------------------------------------------

function [Tahu_c,Tahu_h] = ...
    mytfunc_AHUOpeTimeSplit(QroomAHUc,QroomAHUh,AHUsystemT)

if AHUsystemT == 0
    % “ú‹ó’²ŠÔ‚ª0‚Å‚ ‚ê‚ÎA—â’g–[‹ó’²ŠÔ‚Í0‚Æ‚·‚éB
    Tahu_c = 0;
    Tahu_h = 0;
else
    
    if QroomAHUc==0 && QroomAHUh==0
        % ŠO’²‹@‚ğ‘z’è
        Tahu_c = AHUsystemT;    % ŠO’²‹@‚Ìê‡‚Íu—â–[‘¤v‚É‰^“]ŠÔ‚ğ‰Ÿ‚µ‚Â‚¯‚éB
        Tahu_h = 0;
        
    elseif QroomAHUc == 0
        Tahu_c = 0;
        Tahu_h = AHUsystemT;
        
    elseif QroomAHUh == 0
        Tahu_c = AHUsystemT;
        Tahu_h = 0;
        
    else
        
        if abs(QroomAHUc) <= abs(QroomAHUh)
            % ’g–[•‰‰×‚Ì•û‚ª‘å‚«‚¢ê‡
            Tahu_c = ceil(abs(QroomAHUc)./(abs(QroomAHUc)+abs(QroomAHUh)).*AHUsystemT);
            Tahu_h = AHUsystemT - Tahu_c;
        else
            % —â–[•‰‰×‚Ì•û‚ª‘å‚«‚¢ê‡
            Tahu_h = ceil(abs(QroomAHUh)./(abs(QroomAHUc)+abs(QroomAHUh)).*AHUsystemT);
            Tahu_c = AHUsystemT - Tahu_h;
        end
        
    end
end


