function y = func_fitting(a,x,y)

ysim = a.*x;

y = sqrt(mean((y-ysim).^2));