% AirConditioningComprehensiveTest
%--------------------------------------------------------------------------
% 空調の総合テスト
%--------------------------------------------------------------------------
% 実行：
%　results = runtests('testAirConditioningComprehensive.m');
%--------------------------------------------------------------------------

function tests = testAirConditioningComprehensive

    tests = functiontests(localfunctions);

end

function testCase01(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningComprehensiveTest/testmodel_Case01.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1117.24552,1172.469469];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase02(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningComprehensiveTest/testmodel_Case02.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1102.110321,1172.469469];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase03(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningComprehensiveTest/testmodel_Case03.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1100.901866,1172.469469];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase04(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningComprehensiveTest/testmodel_Case04.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [939.393568,1172.469469];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase05(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningComprehensiveTest/testmodel_Case05.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [804.846544,1172.469469];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase06(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningComprehensiveTest/testmodel_Case06.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1116.553177,1172.469469];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase07(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningComprehensiveTest/testmodel_Case07.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1008.332351,1172.469469];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase08(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningComprehensiveTest/testmodel_Case08.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1100.434489,1172.469469];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end
