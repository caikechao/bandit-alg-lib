classdef (Abstract) Arm < handle
    
    properties
    end
    
    methods
        function reward_pull = pull(self)
        end
        
        function reward_expect = getExpectReward(self)
        end
        
        function reset(self)
        end
        
        function arm_info = getArmInfo(self)
        end
    end
    
end
