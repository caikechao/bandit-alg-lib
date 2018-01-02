classdef (Abstract) Policy < handle

    properties
    end

    methods
        function selected_arms = selectNextArms(self)
        end
        function updateState(self, l_indices, l_rewards)
        end
        function info = getPolicyInfo(self)
        end
    end

end
