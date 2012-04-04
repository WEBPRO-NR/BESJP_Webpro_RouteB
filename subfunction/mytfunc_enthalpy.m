% mytfunc_enthalpy.m
%                                               By Miyata Masato 2006/11/15
%--------------------------------------------------------------------------
% h     : エンタルピー [kJ/kg]
% Tdb   : 乾球温度 [℃]
% X     : 絶対湿度 [kg/kgDA]
%--------------------------------------------------------------------------
function h = mytfunc_enthalpy(Tdb,X)

Ca = 1.006;       % 乾き空気の定圧比熱 [kJ/kg･K]
Cw = 1.805;       % 水蒸気の定圧比熱 [kJ/kg･K]
Lw = 2502;        % 水の蒸発潜熱 [kJ/kg]

if length(Tdb)~=length(X)
	error(' 温度と湿度のデータ長が違います ')
else
	if size(Tdb,1)~=size(X,1)
		Tdb = Tdb';
	end
	h = (Ca.*Tdb + (Cw.*Tdb+Lw).*X);
end