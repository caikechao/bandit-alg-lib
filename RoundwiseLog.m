classdef RoundwiseLog < handle

    properties

        % To FIX: we only consider one-time experiment.
        % run_time
        roundwise_tot_violation % total violation at t
        roundwise_idx_reward % reward of each arm
        roundwise_tot_reward % compound
    end

    methods
        function self = RoundwiseLog(P_, K_, T_)
            %             self.run_time = 0;
            % policy p at round t, each violation
            self.roundwise_tot_violation = zeros(P_, T_); % cumulative violation
            % policy p at round t, each reward of K arms (two level)
            self.roundwise_idx_reward = zeros(P_, T_, K_, 2);
            self.roundwise_tot_reward = zeros(P_, T_);
        end

        % FIX: we only consider one-time experiment.
        % policy p at round t chose arm k and received reward r
        function record_reward(self, p_, t_, l_indices, l_rewards)
            self.roundwise_idx_reward(p_, t_, l_indices, 1) = [l_rewards.l1];
            self.roundwise_idx_reward(p_, t_, l_indices, 2) = [l_rewards.l2];
            self.roundwise_tot_reward(p_, t_) = sum([l_rewards.compound]);
        end

        % policy p at round t, violation
        function record_violation(self, p_, t_, h_)
            % this func should be executed after record_reward.
            roundwise_tot_l1_reward = sum(sum(self.roundwise_idx_reward(p_, :, :, 1)));
            self.roundwise_tot_violation(p_, t_) = max(0, h_*t_-roundwise_tot_l1_reward);
        end
    end
end