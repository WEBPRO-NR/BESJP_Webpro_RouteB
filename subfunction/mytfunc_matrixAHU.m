% mytfunc_matrixAHU.m
%                                                                                by Masato Miyata 2012/03/27
%-----------------------------------------------------------------------------------------------------------
% ‹ó’²•‰‰×ƒf[ƒ^‚ðŒ³‚ÉC•‰‰×‚ÌoŒ»•p“xƒ}ƒgƒŠƒbƒNƒX‚ðì¬‚·‚éD
%-----------------------------------------------------------------------------------------------------------
% “ü—Í
%   MODE   : ŒvŽZƒ‚[ƒhiŽžŒn—ñnewHASPC“úÏŽZnewHASPCŠÈ—ª–@j
%   Qa_c   : —â–[•‰‰×iŽžŠÔÏŽZor“úÏŽZj[kW]
%   Qar_c  : —â–[’èŠi”\—Í [kW]
%   Ta_c   : —â–[‰^“]ŽžŠÔi“úÏŽZ‚Ì‚Ýj[hour]
%   Qa_h   : ’g–[•‰‰×iŽžŠÔÏŽZor“úÏŽZj[kW]
%   Qar_h  : ’g–[’èŠi”\—Í [kW]
%   Ta_h   : ’g–[‰^“]ŽžŠÔi“úÏŽZ‚Ì‚Ýj[kW]
% o—Í
%   Mxc : •‰‰×oŒ»•p“xƒ}ƒgƒŠƒbƒNƒXi—â”Mj
%   Mxh : •‰‰×oŒ»•p“xƒ}ƒgƒŠƒbƒNƒXi‰·”Mj
%-----------------------------------------------------------------------------------------------------------

function [Mxc,Mxh] = mytfunc_matrixAHU(MODE,Qa_c,Qar_c,Ta_c,Qa_h,Qar_h,Ta_h,AHUCHmode,WIN,MID,SUM,mxL)

% ƒ}ƒgƒŠƒbƒNƒX
Mxc = zeros(1,length(mxL)); % —â–[ƒ}ƒgƒŠƒbƒNƒX
Mxh = zeros(1,length(mxL)); % ’g–[ƒ}ƒgƒŠƒbƒNƒX

switch MODE
    
    case {1}
        
        if AHUCHmode == 1  % —â’g“¯Žž‰^“]—L
            
            % Žž•Ê‚Éƒ}ƒgƒŠƒbƒNƒX‚ÉŠi”[‚µ‚Ä‚¢‚­
            for dd = 1:365
                for hh = 1:24
                    num = 24*(dd-1)+hh;
                    
                    if Qa_c(num,1) > 0  % —â–[•‰‰×
                        
                        ix = mytfunc_countMX(Qa_c(num,1)/Qar_c,mxL);
                        Mxc(1,ix) = Mxc(1,ix) + 1;
                        
                    elseif Qa_c(num,1) < 0  % ’g–[•‰‰×
                        
                        ix = mytfunc_countMX((-1)*Qa_c(num,1)/Qar_h,mxL);
                        Mxh(1,ix) = Mxh(1,ix) + 1;
                        
                    end
                end
            end
            
        elseif AHUCHmode == 0   % —â’gØ‘Öi‹Gß‚²‚Æj
            
            % ‹Gß•ÊAŽž•Ê‚Éƒ}ƒgƒŠƒbƒNƒX‚ÉŠi”[‚µ‚Ä‚¢‚­
            for iSEASON = 1:3
                
                if iSEASON == 1
                    seasonspan = WIN;
                elseif iSEASON == 2
                    seasonspan = MID;
                elseif iSEASON == 3
                    seasonspan = SUM;
                else
                    error('ƒV[ƒYƒ“”Ô†‚ª•s³‚Å‚·')
                end
                
                for dd = seasonspan
                    for hh = 1:24
                        num = 24*(dd-1)+hh;
                        
                        if Qa_c(num,1) ~= 0 && (iSEASON == 2 || iSEASON == 3) % —â–[•‰‰×
                            
                            ix = mytfunc_countMX(Qa_c(num,1)/Qar_c,mxL);
                            Mxc(1,ix) = Mxc(1,ix) + 1;
                            
                        elseif Qa_c(num,1) ~= 0 && iSEASON == 1  % ’g–[•‰‰×
                            
                            ix = mytfunc_countMX((-1)*Qa_c(num,1)/Qar_h,mxL);
                            Mxh(1,ix) = Mxh(1,ix) + 1;
                            
                        end
                    end
                end
            end
            
        else
            error('“ñŠÇŽ®^ŽlŠÇŽ®‚ÌÝ’è‚ª•s³‚Å‚·')
        end
        
        
        
    case {2,3}
        
        for ich = 1:2
            
            if ich == 1 % —â–[Šú
                La = (Qa_c./Ta_c.*1000./3600)./Qar_c;  % •‰‰×—¦ [-]
                Ta = Ta_c;
            elseif ich == 2 % ’g–[Šú
                La = (Qa_h./Ta_h.*1000./3600)./Qar_h;  % •‰‰×—¦ [-]
                Ta = Ta_h;
            end
            
            if (Qar_c > 0) || (Qar_h > 0)  % ’èŠi”\—Í„‚O@¨@AHU or FCU ‚ª‚ ‚ê‚Î
                
                if AHUCHmode == 1  % —â’g“¯Žž‰^“]—L
                    
                    for dd = 1:365
                        if isnan(La(dd,1)) == 0 % ƒ[ƒŠ„‚ÅNaN‚É‚È‚Á‚Ä‚¢‚é’l‚ð”ò‚Î‚·
                            
                            if La(dd,1) > 0 % —â–[•‰‰×‚Å‚ ‚ê‚Î
                                ix = mytfunc_countMX(La(dd,1),mxL);
                                Mxc(1,ix) = Mxc(1,ix) + Ta(dd,1);
                                
                            elseif La(dd,1) < 0 % ’g–[•‰‰×‚Å‚ ‚ê‚Î
                                ix = mytfunc_countMX((-1)*La(dd,1),mxL);
                                Mxh(1,ix) = Mxh(1,ix) + Ta(dd,1);
                                
                            end
                        end
                    end
                    
                elseif AHUCHmode == 0   % —â’gØ‘Öi‹Gß‚²‚Æj
                    
                    for iSEASON = 1:3
                        if iSEASON == 1
                            seasonspan = WIN;
                        elseif iSEASON == 2
                            seasonspan = MID;
                        elseif iSEASON == 3
                            seasonspan = SUM;
                        else
                            error('ƒV[ƒYƒ“”Ô†‚ª•s³‚Å‚·')
                        end
                        
                        for dd = seasonspan
                            if isnan(La(dd,1)) == 0 % ƒ[ƒŠ„‚ÅNaN‚É‚È‚Á‚Ä‚¢‚é’l‚ð”ò‚Î‚·
                                if La(dd,1) ~= 0  && (iSEASON == 2 || iSEASON == 3) % —â–[ŠúŠÔ‚Å‚ ‚ê‚Î
                                    ix = mytfunc_countMX(La(dd,1),mxL);
                                    Mxc(1,ix) = Mxc(1,ix) + Ta(dd,1);
                                    
                                elseif La(dd,1) ~= 0 && iSEASON == 1  % ’g–[ŠúŠÔ‚Å‚ ‚ê‚Î
                                    ix = mytfunc_countMX((-1)*La(dd,1),mxL);
                                    Mxh(1,ix) = Mxh(1,ix) + Ta(dd,1);
                                end
                            end
                        end
                    end
                    
                end
                
            end
        end
end



end



