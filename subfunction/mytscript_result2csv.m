% mytscript_result2csv.m
%                                                  2012/04/25 by Masato Miyata
%------------------------------------------------------------------------------
% 省エネ基準ルートB：計算結果をcsvファイルに保存する。
%------------------------------------------------------------------------------

% 出力するファイル名
if isempty(strfind(INPUTFILENAME,'/'))
    eval(['resfilenameD = ''calcRESdetail_',INPUTFILENAME(1:end-4),'_',datestr(now,30),'.csv'';'])
else
    tmp = strfind(INPUTFILENAME,'/');
    eval(['resfilenameD = ''calcRESdetail_',INPUTFILENAME(tmp(end)+1:end-4),'_',datestr(now,30),'.csv'';'])
end

% 結果格納用変数
rfc = {};


%% 二次エネルギー消費量計算結果
rfc = [rfc;'TOP(二次エネルギー),'];
rfc = mytfunc_oneLinecCell(rfc,E2nd_total);


%% 一次エネルギー消費量計算結果
rfc = [rfc;'TOP(一次エネルギー),'];
rfc = mytfunc_oneLinecCell(rfc,E1st_total);


%% 日積算室負荷
rfc = [rfc;'室負荷,'];

for iROOM = 1:numOfRoooms
    rfc = [rfc;strcat(strcat(roomID{iROOM},' (',roomFloor{iROOM},'_',roomName{iROOM}),'),',buildingType{iROOM},',',roomType{iROOM})];
    rfc = mytfunc_oneLinecCell(rfc,NaN.*ones(1,365) );
    rfc = mytfunc_oneLinecCell(rfc,QroomDc(:,iROOM)' );
    rfc = mytfunc_oneLinecCell(rfc,QroomDh(:,iROOM)' );
end


%% 季節区分
WIN = [1:120,305:365]; MID = [121:181,274:304]; SUM = [182:273];
season = {};
for iDATE = WIN
    season{1,iDATE} = '冬';
end
for iDATE = MID
    season{1,iDATE} = '中';
end
for iDATE = SUM
    season{1,iDATE} = '夏';
end


%% 空調負荷
qroomAHUc = zeros(365,numOfAHUs);
qroomAHUh = zeros(365,numOfAHUs);

rfc = [rfc;'空調負荷,'];
for iAHU = 1:numOfAHUs
    
    % 空調機コード
    rfc = [rfc;strcat(ahuID{iAHU},',',ahuType{iAHU})];
    
    % 接続室情報（手間なので簡略化）
    tmp = 0; % カウンタ（5まで）
    for iROOM = 1:length(ahuQroomSet{iAHU,:})
        tmp = tmp + 1;
        rfc = [rfc;strcat(ahuQroomSet{iAHU,1}(iROOM),',NaN,室負荷,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN')];
        if tmp == 5
            break
        end
    end
    if tmp < 5
        for iROOM = 1:length(ahuQoaSet{iAHU,:})
            tmp = tmp + 1;
            rfc = [rfc;strcat(ahuQoaSet{iAHU,1}(iROOM),',NaN,外気負荷,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN')];
            if tmp == 5
                break
            end
        end
    end
    while tmp < 5
        rfc = [rfc;'NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN'];
        tmp = tmp + 1;
    end
    
    % 外気処理制御の仕様
    rfc = [rfc;strcat(ahuOACutCtrl{iAHU},',',ahuFreeCoolingCtrl{iAHU},',',...
        ahuHeatExchangeCtrl{iAHU},',',num2str(ahuaexE(iAHU)),',',...
        num2str(ahuaexV(iAHU)),',',...
        num2str(ahuaexeff(iAHU)))];
    
    rfc = mytfunc_oneLinecCell(rfc,season);             % 季節区分
    rfc = mytfunc_oneLinecCell(rfc,OAdataAll(:,1)');    % 外気温
    rfc = mytfunc_oneLinecCell(rfc,QroomAHUc(:,iAHU)'); % 室負荷（冷房） MJ/day
    rfc = mytfunc_oneLinecCell(rfc,QroomAHUh(:,iAHU)'); % 室負荷（暖房） MJ/day
    rfc = mytfunc_oneLinecCell(rfc,Tahu_c(:,iAHU)');    % 空調時間（冷房）
    rfc = mytfunc_oneLinecCell(rfc,Tahu_h(:,iAHU)');    % 空調時間（暖房）
    
    
    for dd = 1:365
        if Tahu_c(dd,iAHU) == 0
            qroomAHUc(dd,iAHU) = 0;
        else
            qroomAHUc(dd,iAHU) = QroomAHUc(dd,iAHU)./Tahu_c(dd,iAHU)./3600*1000;
        end
        if Tahu_h(dd,iAHU) == 0
            qroomAHUh(dd,iAHU) = 0;
        else
            qroomAHUh(dd,iAHU) = QroomAHUh(dd,iAHU)./Tahu_h(dd,iAHU)./3600*1000;
        end
    end
    
    rfc = mytfunc_oneLinecCell(rfc,qroomAHUc(:,iAHU)');
    rfc = mytfunc_oneLinecCell(rfc,qroomAHUh(:,iAHU)');
    rfc = mytfunc_oneLinecCell(rfc,qoaAHU(:,iAHU)');     % 外気負荷 [kW]
    rfc = mytfunc_oneLinecCell(rfc,Qahu_c(:,iAHU)');
    rfc = mytfunc_oneLinecCell(rfc,Qahu_h(:,iAHU)');
    rfc = mytfunc_oneLinecCell(rfc,0.*ones(1,365));
    rfc = mytfunc_oneLinecCell(rfc,Qahu_oac(:,iAHU)');
    
end


%% 空調機エネルギー消費量
rfc = [rfc;'空調機E,'];
for iAHU = 1:numOfAHUs
    
    rfc = [rfc; strcat(ahuID{iAHU},',',ahuType{iAHU},',',num2str(ahuQcmax(iAHU)),',',...
        num2str(ahuQhmax(iAHU)),',',num2str(ahuEfan(iAHU)),',',num2str(0),',',...
        num2str(0),',',ahuFlowControl{iAHU},',',num2str(ahuFanVAVmin(iAHU)))];
    
    rfc = mytfunc_oneLinecCell(rfc,[MxAHUc(iAHU,:),sum(MxAHUc(iAHU,:))]);
    rfc = mytfunc_oneLinecCell(rfc,ahuEfan(iAHU).*AHUvavfac(iAHU,:));
    rfc = mytfunc_oneLinecCell(rfc,[MxAHUcE(iAHU,:),sum(MxAHUcE(iAHU,:))]);
    rfc = mytfunc_oneLinecCell(rfc,[MxAHUh(iAHU,:),sum(MxAHUh(iAHU,:))]);
    rfc = mytfunc_oneLinecCell(rfc,ahuEfan(iAHU).*AHUvavfac(iAHU,:));
    rfc = mytfunc_oneLinecCell(rfc,[MxAHUhE(iAHU,:),sum(MxAHUhE(iAHU,:))]);
end


%% ポンプエネルギー消費量
rfc = [rfc;'ポンプE,'];
for iPUMP = 1:numOfPumps
    
    rfc = [rfc; strcat(pumpName{iPUMP},',',pumpMode{iPUMP},',',...
        num2str(pumpCount(iPUMP)),',',num2str(pumpFlow(iPUMP)),',',...
        num2str(pumpPower(iPUMP)),',',pumpFlowCtrl{iPUMP},',',...
        '有',',',num2str(Qpsr(iPUMP)))];
    
    rfc = mytfunc_oneLinecCell(rfc,[MxPUMP(iPUMP,:),sum(MxPUMP(iPUMP,:))]);
    rfc = mytfunc_oneLinecCell(rfc,MxPUMPNum(iPUMP,:));
    rfc = mytfunc_oneLinecCell(rfc,pumpPower(iPUMP).*PUMPvwvfac(iPUMP,:));
    rfc = mytfunc_oneLinecCell(rfc,[MxPUMPE(iPUMP,:),sum(MxPUMPE(iPUMP,:))]);
    
end


%% 熱源エネルギー消費量
rfc = [rfc;'熱源E,'];
for iREF = 1:numOfRefs
  
    rfc = [rfc; refsetID{iREF},',',refsetMode{iREF},',',...
        refsetStorage{iREF},',',refsetQuantityCtrl{iREF}];
    
    for iREFSUB = 1:3
        if iREFSUB > refsetRnum(iREF)
            rfc = [rfc; 'NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN'];
        else
            
            tmpname = '';
            if strcmp(refset_Type{iREF,iREFSUB},'AirSourceHP')
                tmpname = '空冷ヒートポンプ（スクリュー，スライド弁）';
            elseif strcmp(refset_Type{iREF,iREFSUB},'AirSourceHP_INV')
                tmpname = '空冷ヒートポンプ（スクロール，圧縮機台数制御）';
            elseif strcmp(refset_Type{iREF,iREFSUB},'EHP')
                tmpname = '電気式ビル用マルチ';
            elseif strcmp(refset_Type{iREF,iREFSUB},'GHP')
                tmpname = 'ガス式ビル用マルチ';
            elseif strcmp(refset_Type{iREF,iREFSUB},'WaterCoolingChiller')
                tmpname = '水冷チラー（スクリュー，スライド弁）';
            elseif strcmp(refset_Type{iREF,iREFSUB},'TurboREF')
                tmpname = 'ターボ冷凍機（標準，ベーン制御）';
            elseif strcmp(refset_Type{iREF,iREFSUB},'TurboREF_HighEffi')
                tmpname = 'ターボ冷凍機（高効率，ベーン制御）';
            elseif strcmp(refset_Type{iREF,iREFSUB},'TurboREF_INV')
                tmpname = 'ターボ冷凍機（高効率，インバータ制御）';
            elseif strcmp(refset_Type{iREF,iREFSUB},'TurboREF_Brine_Storage')
                tmpname = 'ブラインターボ冷凍機（標準，蓄熱時）';
            elseif strcmp(refset_Type{iREF,iREFSUB},'TurboREF_Brine')
                tmpname = 'ブラインターボ冷凍機（標準，追掛時）';
            elseif strcmp(refset_Type{iREF,iREFSUB},'AbsorptionWCB_DF')
                tmpname = '直焚吸収冷温水機';
            elseif strcmp(refset_Type{iREF,iREFSUB},'AbsorptionChiller_S')
                tmpname = '蒸気吸収冷凍機';
            elseif strcmp(refset_Type{iREF,iREFSUB},'AbsorptionChiller_HW')
                tmpname = '温水焚吸収冷凍機';
            elseif strcmp(refset_Type{iREF,iREFSUB},'OnePassBoiler')
                tmpname = 'ボイラ（小型貫流ボイラ）';
            elseif strcmp(refset_Type{iREF,iREFSUB},'VacuumBoiler')
                tmpname = 'ボイラ（真空温水ヒータ）';
            else
                error('熱源種類が不正です。')
            end
            
            
            rfc = [rfc;strcat(tmpname,',',...
                num2str(refset_Capacity(iREF,iREFSUB)),',',...
                num2str(refset_MainPowerELE(iREF,iREFSUB)),',',...
                num2str(refset_SubPower(iREF,iREFSUB)),',',...
                '0',',',...
                num2str(refset_PrimaryPumpPower(iREF,iREFSUB)),',',...
                num2str(refset_CTCapacity(iREF,iREFSUB)),',',...
                num2str(refset_CTFanPower(iREF,iREFSUB)),',',...
                num2str(refset_CTPumpPower(iREF,iREFSUB)))];
        end
    end
    
    % 出現時間
    for ioa = 1:6
        rfc = mytfunc_oneLinecCell(rfc,MxREF(ioa,:,iREF));
    end
    % 運転台数
    for ioa = 1:6
        if refsetRnum(iREF) == 1
            rfc = mytfunc_oneLinecCell(rfc,[xqsave(iREF,ioa),Qrefr_mod(iREF,1,ioa),NaN,NaN,MxREFnum(ioa,:,iREF)]);
        elseif refsetRnum(iREF) == 2
            rfc = mytfunc_oneLinecCell(rfc,[xqsave(iREF,ioa),Qrefr_mod(iREF,1,ioa),Qrefr_mod(iREF,2,ioa),NaN,MxREFnum(ioa,:,iREF)]);
        elseif refsetRnum(iREF) == 3
            rfc = mytfunc_oneLinecCell(rfc,[xqsave(iREF,ioa),Qrefr_mod(iREF,1,ioa),Qrefr_mod(iREF,2,ioa),Qrefr_mod(iREF,3,ioa),MxREFnum(ioa,:,iREF)]);
        end
    end
    
    % 部分負荷率
    for ioa = 1:6
        if refsetRnum(iREF) == 1
            rfc = mytfunc_oneLinecCell(rfc,[xqsave(iREF,ioa),Qrefr_mod(iREF,1,ioa),NaN,NaN,MxREFxL(ioa,:,iREF)]);
        elseif refsetRnum(iREF) == 2
            rfc = mytfunc_oneLinecCell(rfc,[xqsave(iREF,ioa),Qrefr_mod(iREF,1,ioa),Qrefr_mod(iREF,2,ioa),NaN,MxREFxL(ioa,:,iREF)]);
        elseif refsetRnum(iREF) == 3
            rfc = mytfunc_oneLinecCell(rfc,[xqsave(iREF,ioa),Qrefr_mod(iREF,1,ioa),Qrefr_mod(iREF,2,ioa),Qrefr_mod(iREF,3,ioa),MxREFxL(ioa,:,iREF)]);
        end
    end
    % エネルギー消費量
    for ioa = 1:6
        if refsetRnum(iREF) == 1
            rfc = mytfunc_oneLinecCell(rfc,[xpsave(iREF,ioa),Erefr_mod(iREF,1,ioa),NaN,NaN,MxREFperE(ioa,:,iREF)]);
        elseif refsetRnum(iREF) == 2
            rfc = mytfunc_oneLinecCell(rfc,[xpsave(iREF,ioa),Erefr_mod(iREF,1,ioa),Erefr_mod(iREF,2,ioa),NaN,MxREFperE(ioa,:,iREF)]);
        elseif refsetRnum(iREF) == 3
            rfc = mytfunc_oneLinecCell(rfc,[xpsave(iREF,ioa),Erefr_mod(iREF,1,ioa),Erefr_mod(iREF,2,ioa),Erefr_mod(iREF,3,ioa),MxREFperE(ioa,:,iREF)]);
        end
    end
    
    rfc = mytfunc_oneLinecCell(rfc,[MxREF_E(iREF,:),sum(MxREF_E(iREF,:))]);
    rfc = mytfunc_oneLinecCell(rfc,[MxREFACcE(iREF,:),sum(MxREFACcE(iREF,:))]);
    rfc = mytfunc_oneLinecCell(rfc,zeros(1,7));
    rfc = mytfunc_oneLinecCell(rfc,[MxPPcE(iREF,:),sum(MxPPcE(iREF,:))]);
    rfc = mytfunc_oneLinecCell(rfc,[MxCTfan(iREF,:),sum(MxCTfan(iREF,:))]);
    rfc = mytfunc_oneLinecCell(rfc,[MxCTpump(iREF,:),sum(MxCTpump(iREF,:))]);
end


%% 出力
fid = fopen(resfilenameD,'w+');
for i=1:size(rfc,1)
    fprintf(fid,'%s\r\n',rfc{i});
end
fclose(fid);




