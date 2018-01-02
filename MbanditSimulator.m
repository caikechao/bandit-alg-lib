classdef MbanditSimulator < handle

    properties
        arms % array
        policies % cell
        K
        L
        h
    end

    methods
        function self = MbanditSimulator(arms_, policies_, K_, L_, h_)
            self.arms = arms_;
            self.policies = policies_;
            self.K = K_;
            self.L = L_;
            self.h = h_;
        end

        function run_simulation(self, T_, logger_)
            for p = 1:length(self.policies)
                for t = 1:T_
                    if mod(t,1) == 0
                        fprintf('Policy %d at round %d ...\n', p, t)
                    end
                    self.run_single_round(logger_, p, t);
                end
            end
            % reset the arms, not necessary here.
            for iarm = self.arms
                iarm.reset();
            end
        end

        function run_single_round(self, logger_, p_, t_)
            l_indices = self.policies{p_}.selectNextArms();
            l_rewards = [];
            for idx = l_indices
                l_rewards = [l_rewards, self.arms(idx).pull()];
            end
            self.policies{p_}.updateState(l_indices, l_rewards);
            logger_.record_reward(p_, t_, l_indices, l_rewards);
            logger_.record_violation(p_, t_, self.h)
        end
    end

end
