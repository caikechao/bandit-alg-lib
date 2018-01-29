classdef L2Reward

    properties
        l1
        l2
        compound
    end

    methods
        function self = L2Reward(l1_, l2_)
            self.l1 = l1_;
            self.l2 = l2_;            
            self.compound = l1_ * l2_;
        end
    end
end
