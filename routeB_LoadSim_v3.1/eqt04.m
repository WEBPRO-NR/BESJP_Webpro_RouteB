% eqt04.m                                                         
%-----------------------------------------------------------------------------------
% �ώ��������߂�
%-----------------------------------------------------------------------------------
% ����  month : ��
%       day   : �� 
% �o��  e     : �ώ��� [h]
%-----------------------------------------------------------------------------------
function e = eqt04(month,day)

% �ʓ����v�Z����
n = iidn(month,day);

%% �ώ������v�Z����(HASP ���ȏ� p24)
% ��N�������Ƃ���p�x���v�Z����
w = n * 2.0 * pi / 366.0;
e = - 0.0002786409 + 0.1227715 * cos(w + 1.498311) - 0.1654575 * cos(2.0 * w - 1.261546) - 0.00535383 * cos(3.0 * w -1.1571);

%% �ώ������v�Z����(���z���H�w�i�X�k�o�Łjp136 ���@�������P�ʂ� �� �̎��ł��邱�Ƃɒ���)
w = 360*n/366;
e = (-0.0167 + 7.37*cos(deg2rad(w+85.8)) - 9.93*cos(deg2rad(2*w-72.3)) - 0.321*cos(deg2rad(3*w-66.3)))./60;


