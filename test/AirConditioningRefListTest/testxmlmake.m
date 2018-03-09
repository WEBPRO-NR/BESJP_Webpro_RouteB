
for cc = 43:52
    
    if cc < 10
        
        eval(['ECS_XMLfileMake_run(''./test/AirConditioningRefListTest/Case0',int2str(cc),''',6,''testmodel_Case0',int2str(cc),'.xml'')'])
        
    else
        eval(['ECS_XMLfileMake_run(''./test/AirConditioningRefListTest/Case',int2str(cc),''',6,''testmodel_Case',int2str(cc),'.xml'')'])
        
    end
end