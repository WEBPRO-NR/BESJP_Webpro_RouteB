% mytfunc_REFparaSET.m
%                                          by Masato Miyata 2011/04/24
%----------------------------------------------------------------------
% 省エネ基準：熱源特性の抽出
%----------------------------------------------------------------------
% 入力
%  data : 特性データ（下限値,上限値,補正値,x4,x3,x2,x1,a）
%  x    : 特性式のxの値（外気温度、冷却水温度など）
% 出力
%  y    : xの条件下における特性（最大能力比、最大入力比等）の値
%----------------------------------------------------------------------
function y = mytfunc_REFparaSET(data,x)

% DEBUG用データ
% clear
% clc
% data = [-15	-8	0.8 0	0	0	0.0255	0.847
%     -8	4.5	0.8 0	0	0	0.0153	0.762
%     4.5	15.5	0.8 0	0	0	0.0255	0.847];
% x = -15;

if isempty(data) == 0
    
    % 特性式の数
    curveNum = size(data,1);
    
    % 下限値
    minX = data(:,1);
    % 上限値
    maxX = data(:,2);
    % パラメータ
    para = data(:,3:end);
    
    % 上限と下限を定める
    if x < minX(1)
        x = minX(1);
    elseif x > maxX(end)
        x = maxX(end);
    end
    
    % 該当するパラメータセット
    paraSET = zeros(1,6);
    
    for i=curveNum:-1:1
        if x <= maxX(i)
            paraSET = para(i,:);
        end
    end
    
    % 計算値
    y = paraSET(1).*(paraSET(2).*x^4 + paraSET(3).*x^3 + paraSET(4).*x^2 + paraSET(5).*x + paraSET(6));
    
else
    
    % data が空行列であった場合
    y = 1;
    
end
