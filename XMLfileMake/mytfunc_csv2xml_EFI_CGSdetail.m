% mytfunc_csv2xml_EFI_CGSdetail.m
%                                             by Masato Miyata 2018/03/15
%------------------------------------------------------------------------
% 省エネ基準：コジェネレーションシステムのXMLファイルを作成する。
%------------------------------------------------------------------------
% 入力：
%  xmldata  : xmlデータ
%  filename : コジェネレーションシステムの算定シート(CSV)ファイル名
% 出力：
%  xmldata  : xmlデータ
%------------------------------------------------------------------------
function xmldata = mytfunc_csv2xml_EFI_CGSdetail(xmldata,filename)

% CSVファイルの読み込み
CGSDataCell = mytfunc_CSVfile2Cell(filename);

xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Name ...
    = CGSDataCell{11,1};
xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.CGUCapacity ...
    = CGSDataCell{11,2};
xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Count ...
    = CGSDataCell{11,3};
xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.PowerGenerationEfficiency100 ...
    = CGSDataCell{11,4};
xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.PowerGenerationEfficiency075 ...
    = CGSDataCell{11,5};
xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.PowerGenerationEfficiency050 ...
    = CGSDataCell{11,6};
xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.HeatRecoveryEfficiency100 ...
    = CGSDataCell{11,7};
xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.HeatRecoveryEfficiency075 ...
    = CGSDataCell{11,8};
xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.HeatRecoveryEfficiency050 ...
    = CGSDataCell{11,9};

if strcmp(CGSDataCell{11,10},'1番目')
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_cooling = '1';
elseif strcmp(CGSDataCell{11,10},'2番目')
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_cooling = '2';
elseif strcmp(CGSDataCell{11,10},'3番目')
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_cooling = '3';
else
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_cooling = '0';
end

if strcmp(CGSDataCell{11,11},'1番目')
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_heating = '1';
elseif strcmp(CGSDataCell{11,11},'2番目')
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_heating = '2';
elseif strcmp(CGSDataCell{11,11},'3番目')
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_heating = '3';
else
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_heating = '0';
end

if strcmp(CGSDataCell{11,12},'1番目')
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_hotwater = '1';
elseif strcmp(CGSDataCell{11,12},'2番目')
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_hotwater = '2';
elseif strcmp(CGSDataCell{11,12},'3番目')
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_hotwater = '3';
else
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Order_hotwater = '0';
end

if strcmp(CGSDataCell{11,12},'有')
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Operation24H = 'True';
else
    xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.Operation24H = 'False';
end

xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.REFc_name ...
    = CGSDataCell{11,14};
xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.REFh_name ...
    = CGSDataCell{11,15};
xmldata.CogenerationSystemsDetail.CogenerationUnit(1).ATTRIBUTE.HW_name ...
    = CGSDataCell{11,16};

end

