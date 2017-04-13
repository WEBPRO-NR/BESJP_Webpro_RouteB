% mytfunc_convert_newHASPwindows.m
%                                               2015/09/06 by Masato Miyata
%--------------------------------------------------------------------------
% 平成25年基準のガラス番号をnewHASP用のガラス番号に置換するプログラム。
%--------------------------------------------------------------------------

function [WNDW,TYPE] = mytfunc_convert_newHASPwindows(WNUM)

switch WNUM
    
    case '104'  % 複層 8mm+ A6 + 8mm
        WNDW = 'DL06';
        TYPE = '4';
    case {'103','2FA06'}  % 複層 6mm+ A6 + 6mm
        WNDW = 'DL06';
        TYPE = '3';
    case {'1'}  % 単板 3mm
        WNDW = 'SNGL';
        TYPE = '1';
    case '2'  % 単板 5mm
        WNDW = 'SNGL';
        TYPE = '2';
    case '3'  % 単板 6mm
        WNDW = 'SNGL';
        TYPE = '3';
    case {'4','T'}  % 単板 8mm
        WNDW = 'SNGL';
        TYPE = '4';
    case '51'  % 高性能熱線反射(可視光透過率40%) 6mm
        WNDW = 'SNGL';
        TYPE = '75';
    case '141'  % 熱反シルバー+透明 6mm
        WNDW = 'DL06';
        TYPE = '47';
    case '202'  % Low-E(高日射遮蔽型)+透明 8mm
        WNDW = 'DL06';
        TYPE = '138';
    case '203'  % Low-E(高日射遮蔽型)+透明 10mm
        WNDW = 'DL06';
        TYPE = '139';
    case {'2LsA10','2LsA08'}   % 複層LowE、日射遮蔽型、空気層10mm  U=2.0、η=0.4
        WNDW = 'DL06';
        TYPE = '139';
    case {'3WsG10','2LsG10','2LgG10','2LsG12'}   % 複層LowE、日射遮蔽型、空気層10mm  U=1.0、η=0.33
        WNDW = 'DL12';
        TYPE = '186'; 
    otherwise
        WNUM
        error('mytfunc_convert_newHASPwindows：ガラスが登録されていません')
end