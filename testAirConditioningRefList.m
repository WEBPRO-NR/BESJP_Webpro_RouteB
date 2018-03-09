% AirConditioningWindowTest
%--------------------------------------------------------------------------
% 空調・開口部計算のテスト
%--------------------------------------------------------------------------
% 実行：
% results = runtests('testAirConditioningRefList.m');
%--------------------------------------------------------------------------

function tests = testAirConditioningRefList

global expSolutionALL

%% 期待値の読み込み
res = textread('./test/AirConditioningRefListTest/Results.csv','%s','delimiter','\n','whitespace','');

for i=1:length(res)
    conma = strfind(res{i},',');
    for j = 1:length(conma)
        if j == 1
            resall{i,j} = res{i}(1:conma(j)-1);
        elseif j == length(conma)
            resall{i,j}   = res{i}(conma(j-1)+1:conma(j)-1);
            resall{i,j+1} = res{i}(conma(j)+1:end);
        else
            resall{i,j} = res{i}(conma(j-1)+1:conma(j)-1);
        end
    end
end

expSolutionALL = str2double(resall(2:end,4:5));

tests = functiontests(localfunctions);

end

% 2017年度
function testCase01(testCase)

global expSolutionALL

actSolution = [];
expSolution = [];

for caseNum = 1:42
    
    if caseNum < 10
        % 実行
        eval(['y = ECS_routeB_AC_run(''./test/AirConditioningRefListTest/testmodel_Case0',int2str(caseNum),'.xml'',''OFF'',''3'',''Read'',''0'');'])
    else
        eval(['y = ECS_routeB_AC_run(''./test/AirConditioningRefListTest/testmodel_Case',int2str(caseNum),'.xml'',''OFF'',''3'',''Read'',''0'');'])
    end
    
    actSolution = [actSolution, y(1), y(17)];
    expSolution = [expSolution, expSolutionALL(caseNum,:)];
    
end

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

% 排熱吸収式など追加
function testCase02(testCase)

global expSolutionALL

actSolution = [];
expSolution = [];

for caseNum = 43:52
    
    if caseNum < 10
        % 実行
        eval(['y = ECS_routeB_AC_run(''./test/AirConditioningRefListTest/testmodel_Case0',int2str(caseNum),'.xml'',''OFF'',''3'',''Read'',''0'');'])
    else
        eval(['y = ECS_routeB_AC_run(''./test/AirConditioningRefListTest/testmodel_Case',int2str(caseNum),'.xml'',''OFF'',''3'',''Read'',''0'');'])
    end
    
    actSolution = [actSolution, y(1), y(17)];
    expSolution = [expSolution, expSolutionALL(caseNum,:)];
    
end

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end