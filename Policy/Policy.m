classdef (Abstract) Policy < handle

    properties 
        Name
    end

    methods
        function selected_arms = selectNextArms(self)
        end
        function updateState(self, LIndices, LRewards)
        end
        function info = getPolicyInfo(self)
        end

    end

end
