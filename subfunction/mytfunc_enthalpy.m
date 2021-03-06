% mytfunc_enthalpy.m
%                                               By Miyata Masato 2006/11/15
%--------------------------------------------------------------------------
% h     : G^s[ [kJ/kg]
% Tdb   : Łˇx []
% X     : âÎźx [kg/kgDA]
%--------------------------------------------------------------------------
function h = mytfunc_enthalpy(Tdb,X)

Ca = 1.006;       % ŁŤóCĚčłäM [kJ/kgĽK]
Cw = 1.805;       % öCĚčłäM [kJ/kgĽK]
Lw = 2502;        % Ěö­öM [kJ/kg]

if length(Tdb)~=length(X)
	error(' ˇxĆźxĚf[^ˇŞá˘Üˇ ')
else
	if size(Tdb,1)~=size(X,1)
		Tdb = Tdb';
	end
	h = (Ca.*Tdb + (Cw.*Tdb+Lw).*X);
end