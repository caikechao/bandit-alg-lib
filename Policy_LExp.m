classdef Policy_LExp < Policy

    properties
        K
        L
        gamma
        delta
        zeta
        h
        lambda_t
        wvec % weight vector
        pvec % prob vector
        S0t
        beta
        t
    end

    methods
        function self = Policy_LExp(K_, L_, gamma_, delta_, h_)
            self.K = K_;
            self.L = L_;
            self.gamma = gamma_;
            self.delta = delta_;
            self.zeta = gamma_ * delta_ * L_ / ((delta_ + L_) * K_);
            self.h = h_;
            self.wvec = ones(1, K_);
            self.pvec = zeros(1, K_);
            self.lambda_t = 0;
            self.S0t = [];
            self.beta = (1 / self.L - self.gamma / self.K) / (1 - self.gamma);
            self.t = 0;
        end

        function check_parameters(self)
            assert(self.gamma < 1, 'LExp: illegal value for gamma.')
            low_th = 4 * (exp(1) - 2) * self.gamma * self.L / (1 - self.gamma) - self.L;
            assert(self.delta >= low_th, 'LExp: illegal value for delta.')
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
            if isnan(sum(self.pvec))
                disp(self.pvec)
                disp(self)
            end
            selected_arms = depRound(self.L, self.pvec);
            self.t = self.t + 1;
        end

        function updateState(self, l_indices, l_rewards)
            % here level is not relevant in this function.
            assert(length(l_indices) == self.L, 'LExp: L-indices do not match the number of selected arms.')
            assert(length(l_rewards) == self.L, 'LExp: L-rewards do not match the number of selected arms.')
            ahatvec = zeros(1, self.K);
            ghatvec = zeros(1, self.K);
            ahatvec(l_indices) = [l_rewards.l1]./self.pvec(l_indices);
            ghatvec(l_indices) = [l_rewards.compound]./self.pvec(l_indices);
            for j = 1:self.K
                if ~ismember(j, self.S0t)
                    self.wvec(j) = self.wvec(j) * exp(self.zeta*(ghatvec(j) + self.lambda_t * ahatvec(j)));
                end
            end
            part1 = (1 - self.delta * self.zeta) * self.lambda_t;
            part2 = self.zeta * (ahatvec * self.pvec' / (1 - self.gamma) - self.h);
            self.lambda_t = max(0, part1-part2);
        end

        function info = getPolicyInfo(self)
            formatSpec = 'LExp policy: K = %d L = %d gamma = %0.3f delta = %0.3f h = %0.2f';
            info = sprintf(formatSpec, self.K, self.L, self.gamma, self.delta, self.h);
        end

        function reset(self)
            self.wvec = ones(1, self.K);
            self.pvec = zeros(1, self.K);
        end
    end
end