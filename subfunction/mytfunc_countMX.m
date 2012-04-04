function y = mytfunc_countMX(X,mxL)

% 初期値
y = 1;

% 該当するマトリックスを探査
while X > mxL(y)
    y = y + 1;
    if y == length(mxL)
        break
    end
end

end

