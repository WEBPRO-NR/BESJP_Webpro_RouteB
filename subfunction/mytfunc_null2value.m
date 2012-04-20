function y = mytfunc_null2value(data,Value)

if strcmp(data,'Null')
    y = Value;
else
    y = data;
end
