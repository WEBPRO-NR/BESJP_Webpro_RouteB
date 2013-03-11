% ‰^“]ŠÔ‚Ì˜aW‡‚ğ‚Æ‚é
%------------------------------------------------------
% “ü—ÍF
%  start  ŠeŒn“‚É‘®‚·‚é‹@Ší^º‚Ì‰^“]ŠJnŠÔi365~Œn“”j
%  stop   ŠeŒn“‚É‘®‚·‚é‹@Ší^º‚Ì‰^“]ŠJnŠÔi365~Œn“”j
% o—ÍF
%  systemOpeTime : 24ŠÔ‚Ì‰^“]ŠÔi365~24j
%------------------------------------------------------

function systemOpeTime = mytfunc_calcOpeTime(start,stop)

% Ú‘±‚³‚ê‚Ä‚¢‚éƒVƒXƒeƒ€‚Ì”
numsys = size(start,2);

systemOpeTime = zeros(365,24);

for dd = 1:365
    
    % Œ‹‰ÊŠi”[—p
    tmp = zeros(numsys,24);
    
    for i=1:numsys
        
        if start(dd,1) == 0 && stop(dd,i) == 0
            tmp(i,:) = zeros(1,24);

        elseif start(dd,i) < stop(dd,i)  % “ú‚ğŒ×‚ª‚È‚¢ê‡
            for hh = 1:24
                if hh > start(dd,i) && hh <= stop(dd,i)
                    tmp(i,hh) = 1;
                end
            end
        else   % “ú‚ğŒ×‚®ê‡
            for hh = 1:24
                if hh > start(dd,i) || hh <= stop(dd,i)
                    tmp(i,hh) = 1;
                end
            end
        end
        
    end
    
    % ˜aW‡‚ğ‚Æ‚é
    sumtmp = sum(tmp,1);
    
    for hh=1:24
        if sumtmp(hh) > 0
            systemOpeTime(dd,hh) = 1;
        end
    end
    
end

