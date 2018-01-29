classdef L2Arm < Arm

    properties
        mu1
        mu2
    end

    methods
        function self = L2Arm(mu1_, mu2_)
            assert(mu1_ >= 0 && mu1_ <= 1, 'L1 mean reward should be in [0,1]')
            assert(mu2_ >= 0 && mu2_ <= 1, 'L2 mean reward should be in [0,1]')
            self.mu1 = mu1_;
            self.mu2 = mu2_;            
        end

        function reward_pull = pull(self)
            % using the Bernoulli distribution in both levels.
            l1_reward = random('bino', 1, self.mu1);
            l2_reward = random('bino', 1, self.mu2);
            reward_pull = L2Reward(l1_reward, l2_reward);
        end

        function reward_expect = getExpectReward(self)
            reward_expect = L2Reward(self.mu1, self.mu2);
        end

        function reset(self)
            % self.pulled_times = 0;
        end

        function arm_info = getArmInfo(self)
            formatSpec = 'Two-level arm with: mu1 = %0.3f mu2 = %0.3f';
            arm_info = sprintf(formatSpec, self.mu1, self.mu2);
        end
    end
end
