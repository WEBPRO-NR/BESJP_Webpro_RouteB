% mytfunc_convert_newHASPwalls.m
%                                               2015/09/06 by Masato Miyata
%--------------------------------------------------------------------------
% 平成25年基準の建材番号をnewHASP用の建材番号に置換するプログラム。
%--------------------------------------------------------------------------

function [Mnum] = mytfunc_convert_newHASPwalls(WNUM)

switch WNUM
    case '70'  % ロックウール化粧吸音板
        Mnum = '75';
    case '62'  % せっこうボード
        Mnum = '32';
    case '302'  % 非密閉空気層
        Mnum = '92';
    case '41'  % コンクリート
        Mnum = '22';
    case '44'  % 気泡コンクリート
        Mnum = '24';
    case '45'  % コンクリートブロック（重量）
        Mnum = '25';
    case '46'  % コンクリートブロック（軽量）
        Mnum = '26';
    case '47'  % セメント・モルタル
        Mnum = '27';
    case '103'  % アスファルト類
        Mnum = '43';
    case '181'  % 押出法ポリスチレンフォーム保温板１種
        Mnum = '82';
    case '67'  % タイル
        Mnum = '36';
    case '203'  % 吹付け硬質ウレタンフォームＡ種１
        Mnum = '85';
    case '101'  % ビニル系床材
        Mnum = '41';
    case '22'  % 土壌
        Mnum = '15';
        
    otherwise
        error('mytfunc_convert_newHASPwalls：建材が登録されていません')
end

