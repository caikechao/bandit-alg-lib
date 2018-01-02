classdef Policy_UCB < Policy

    properties
        K % total number of K arms
        L % number of arms that should be selected.
        alpha % CUCB parameter
        Nvec % Nb of times each arms has been pulled
        Gvec % Cumulated reward with each action
        level
    end

    methods
        function self = Policy_UCB(K_, L_, alpha_,level_)
            self.K = K_;
            self.L = L_;
            self.alpha = alpha_;
            self.Nvec = zeros(1, K_);
            self.Gvec = zeros(1, K_);
            self.level = level_;
        end

        function selected_arms = selectNextArms(self)
            ucb_indices = zeros(1, self.K);
            sum_Nvec = sum(self.Nvec);
            for i = 1:self.K
                if self.Nvec(i) == 0
                    ucb_indices(i) = Inf;
                else
                    ucb_indices(i) = (self.Gvec(i) / self.Nvec(i)) + sqrt(self.alpha*log(sum_Nvec)/self.Nvec(i));
                end
            end
            selected_arms = L_max(self.L, ucb_indices);
        end

        function updateState(self, l_indices, l_rewards)
            % make l_indices as a length l vec
            % make l_rewards as a vec of L2Rewards objects
            for i = 1:length(l_indices)
                arm_idx = l_indices(i);
                arm_rewards = l_rewards(i);
                self.Nvec(arm_idx) = self.Nvec(arm_idx) + 1;
                if self.level == 1
                    self.Gvec(arm_idx) = self.Gvec(arm_idx) + arm_rewards.l1;
                else
                    self.Gvec(arm_idx) = self.Gvec(arm_idx) + arm_rewards.compound;
                end
            end
        end

        function info = getPolicyInfo(self)
            formatSpec = 'UCB policy: K = %d L = %d, alpha = %0.3f level = %d';
            info = sprintf(formatSpec, self.K, self.L, self.alpha, self.level);
        end

        function reset(self)
            self.Nvec = zeros(1, self.K);
            self.Gvec = zeros(1, self.K);
        end
    end

end
