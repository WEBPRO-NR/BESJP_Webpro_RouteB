function y = mytfunc_countMX(X,mxL)

% 初期値
y = 1;

% % C#の処理に合わせる
% X = floor(X*10+0.00001)/10+0.05;

% 該当するマトリックスを探査
while X > mxL(y)
    y = y + 1;
    if y == length(mxL)
        break
    end
end

end

