% AirConditioningWindowTest
%--------------------------------------------------------------------------
% 空調の総合テスト
%--------------------------------------------------------------------------
% 実行：
%　results = runtests('testAirConditioningWindow.m');
%--------------------------------------------------------------------------

function tests = testAirConditioningWindow

    tests = functiontests(localfunctions);

end

function testCase01(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case01.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [981.1407,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase02(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case02.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [959.6305,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase03(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case03.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [899.5869,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase04(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case04.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [906.3007,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase05(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case05.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [905.6665,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase06(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case06.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [979.654431403645,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase07(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case07.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1021.64386212915,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase08(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case08.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1034.3496111996,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase09(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case09.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [959.6305,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase10(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case10.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [977.525225880913,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase11(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case11.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [979.654431403645,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase12(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case12.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1003.89963125096,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase13(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case13.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1021.64386212915,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase14(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case14.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1031.7340308095,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase15(testCase)

% 実行
y = ECS_routeB_AC_run('./test/AirConditioningWindowTest/testmodel_Case15.xml','OFF','3','Read','0');

actSolution = [y(1), y(17)];
expSolution = [1034.3496111996,1173];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

