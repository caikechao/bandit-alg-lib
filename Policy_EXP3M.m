classdef Policy_EXP3M < Policy

    properties
        K
        L
        gamma
        wvec % weight vector
        pvec % prob vector
        S0t
        level
        beta
    end

    methods
        function self = Policy_EXP3M(K_, L_, gamma_,level_)
            self.K = K_;
            self.L = L_;
            self.gamma = gamma_;
            self.wvec = ones(1, K_);
            self.pvec = zeros(1, K_);
            self.S0t = [];
            self.level = level_;
            self.beta = (1 / self.L - self.gamma / self.K) / (1 - self.gamma);
        end

        function selected_arms = selectNextArms(self)

            sum_w = sum(self.wvec);
            wvec_prime = self.wvec;
            sorted_w = sort(self.wvec, 'descend');

            
            th = self.beta * sum_w;

            if sorted_w(1) > th % find alpha
                alpha_t = getAlpha(self.beta, sorted_w);
                bool_idx = self.wvec > alpha_t;
                real_idx = 1:self.K;
                self.S0t = real_idx(bool_idx);
                wvec_prime(self.S0t) = alpha_t;
            else
                self.S0t = [];
            end

            sum_w_prime = sum(wvec_prime);
            for i = 1:self.K
                wi_prime = wvec_prime(i);
                self.pvec(i) = self.L * ((1 - self.gamma) * wi_prime / sum_w_prime + self.gamma / self.K);
            end
            
            selected_arms = depRound(self.L, self.pvec);

        end

        function updateState(self, l_indices, l_rewards)
            % Fix: can be simplified using matrix class op.
            assert(length(l_indices) == self.L, 'EXP3M: L-indices do not match the number of selected arms.')
            assert(length(l_rewards) == self.L, 'EXP3M: L-rewards do not match the number of selected arms.')
            xhatvec = zeros(1, self.K);                       
            % for i = 1:self.L
            %    arm_idx = l_indices(i);
            %    arm_reward = l_rewards(i);
            %    arm_prob = self.pvec(arm_idx);
            if self.level == 1
                % xhatvec(arm_idx) = arm_reward.l1 / arm_prob;
                xhatvec(l_indices) = [l_rewards.l1]./ self.pvec(l_indices);
            else
                % xhatvec(arm_idx) = arm_reward.compound / arm_prob;
                xhatvec(l_indices) = [l_rewards.compound]./ self.pvec(l_indices);
            end
            % end
            for j = 1:self.K
                if ~ismember(j, self.S0t)
                    self.wvec(j) = self.wvec(j) * exp(self.L*self.gamma*xhatvec(j)/self.K);
                end
            end
        end

        function info = getPolicyInfo(self)
            formatSpec = 'EXP3M policy: K = %d L = %d gamma = %0.3f level = %d';
            info = sprintf(formatSpec, self.K, self.L, self.gamma, self.level);
        end

        function reset(self)
            self.wvec = ones(1, self.K);
            self.pvec = zeros(1, self.K);
        end

    end

end
