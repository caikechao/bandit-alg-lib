classdef RoundwiseLogger < handle

    properties
        Policies
        nSimulations
        TotalViolations % total violation at t % SPT
        ArmsRewards     % reward of each arm   % SPTK2
        CompoundRewards % compound             % SPT
        IndexLExp
        LambdaTs
    end

    methods
        function self = RoundwiseLogger(Policies_, S_, K_, T_)            
            self.Policies = Policies_;
            self.nSimulations = S_;
            P_ = length(Policies_);
            % At s sim, policy p at round t, each violation
            self.TotalViolations = zeros(S_, P_, T_); % cumulative violation
            % At s sim, policy p at round t, each reward of K arms (two level)
            self.ArmsRewards = zeros(S_, P_, T_, K_, 2);
            % At s sim, policy p at round t, compound reward
            self.CompoundRewards = zeros(S_, P_, T_);
            for iP = 1:length(Policies_)
                if Policies_{iP}.Name == "LExp"
                    % At s sim, lambda_t of LExp at round t (log S simulations)
                    self.LambdaTs = zeros(S_, T_);
                    self.IndexLExp = iP;
                else
                    % other policies do not need this variable
                    self.LambdaTs = -1;
                    self.IndexLExp = -1;
                end
            end
        end

        function record_reward(self, s_, p_, t_, l_indices, l_rewards)
            % pulled arms' level 1 rewards
            self.ArmsRewards(s_, p_, t_, l_indices, 1) ...
                = self.ArmsRewards(s_, p_, t_, l_indices, 1) ...
                + reshape([l_rewards.l1], 1, 1, 1,length(l_indices));
            % pulled arms' level 2 rewards
            self.ArmsRewards(s_, p_, t_, l_indices, 2) ...
                = self.ArmsRewards(s_, p_, t_, l_indices, 2) ...
                + reshape([l_rewards.l2], 1, 1, 1,length(l_indices));
            % pulled arms' compound rewards
            self.CompoundRewards(s_, p_, t_) ...
                = self.CompoundRewards(s_, p_, t_) + sum([l_rewards.compound]);
            % log lambda for LExp
            if self.IndexLExp ~= -1
                self.LambdaTs(s_, t_) = self.Policies{self.IndexLExp}.Lambdat;
            end
        end
        
        % this function should be executed after record_reward.
        % at sim s, policy p at round t, violation
        function record_violation(self, s_, p_, t_, h_)
            roundwise_tot_l1_reward = sum(self.ArmsRewards(s_, p_, t_, :, 1));
            self.TotalViolations(s_, p_, t_) = self.TotalViolations(s_, p_, t_) ...
                                             + max(0, h_- roundwise_tot_l1_reward);
        end
    end
end