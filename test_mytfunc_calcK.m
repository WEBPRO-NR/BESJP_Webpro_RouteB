% test_mytfunc_calcK
%--------------------------------------------------------------------------
% 空調の総合テスト
%--------------------------------------------------------------------------
% 実行：
% results = runtests('test_mytfunc_calcK.m');
%--------------------------------------------------------------------------

function tests = test_mytfunc_calcK

    tests = functiontests(localfunctions);

end

function testCase01(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','aluminum_single','3WgG06','0','0','0'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [2.6400, 0.4300];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase02(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','complex_double','3WgG06','1','0','0'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [2.09, 0.3300];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end


function testCase10(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin_single','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.25636817204301, 0.59832];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase10BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin_single','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [3.83204340243534,  0.427914814248];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end




function testCase11(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin_double','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.47555096774194, 0.59832];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase11BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin_double','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.00879571842358, 0.427914814248];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end



function testCase12(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin_aluminum_complex_single','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [ 5.05717652136383, 0.6648];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase12BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin_aluminum_complex_single','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.46919198805488, 0.47546090472];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end



function testCase13(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin_aluminum_complex_double','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [ 5.33063357790246,  0.6648];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase13BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin_aluminum_complex_double','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.68142312407016,  0.47546090472];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end


function testCase14(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','aluminum_single','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [5.62988022404136, 0.6648];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase14BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','aluminum_single','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [ 4.9106514659168,  0.47546090472];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end



function testCase15(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','aluminum_double','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [5.75051788022404,  0.6648];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase15BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','aluminum_double','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [5.00218401401843,   0.47546090472];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end



function testCase06(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.47555096774194,  0.59832];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase06BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.00879571842358, 0.427914814248];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end



function testCase07(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','complex','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [ 5.33063357790246,  0.6648];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase07BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','complex','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [ 4.68142312407016,  0.47546090472];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end



function testCase08(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','aluminum','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [5.75051788022404,  0.6648];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end


function testCase08BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','aluminum','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [5.00218401401843,  0.47546090472];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end


function testCase16(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','wood_single','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.25636817204301, 0.59832];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase16BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','wood_single','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [3.83204340243534,  0.427914814248];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end


function testCase17(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','wood_double','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.47555096774194, 0.59832];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase17BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','wood_double','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.00879571842358, 0.427914814248];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end



function testCase18(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','wood_aluminum_complex_single','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [ 5.05717652136383, 0.6648];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase18BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','wood_aluminum_complex_single','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.46919198805488, 0.47546090472];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end



function testCase19(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','wood_aluminum_complex_double','Null','0','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [ 5.33063357790246,  0.6648];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase19BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','wood_aluminum_complex_double','Null','1','5.23','0.831'};
WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.68142312407016,  0.47546090472];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase20(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','complex_double','S','0','0','0'};

WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [2.63,  0.0842];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase21(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin_single','T','0','0','0'};

WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.76,  0.63];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end

function testCase21BL(testCase)

load ./test/AirConditioningWindowTest/perDB_WCON.mat
load ./test/AirConditioningWindowTest/perDB_WIND.mat

confW = {'OW1','W1','302','8'};
confG = {'WIND1_0','resin_single','T','1','0','0'};

WallUvalue = 1.0;
WindowUvalue = NaN;
WindowMvalue = NaN;
    
% 実行
[~,~,~,WindowUvalueList,WindowMyuList,~,~]...
    = mytfunc_calcK('Regulation',perDB_WCON,perDB_WIND,confW,confG,WallUvalue,WindowUvalue,WindowMvalue);

actSolution = [WindowUvalueList, WindowMyuList];
expSolution = [4.25,  0.45];

% 検証
verifyEqual(testCase,actSolution,expSolution,'RelTol',0.0001)

end