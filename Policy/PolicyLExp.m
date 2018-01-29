classdef PolicyLExp < Policy

    properties
        K
        L
        Gamma
        Delta
        Zeta
        h
        Lambdat
        Wvec % weight vector
        Pvec % prob vector
        S0t
        Beta
    end

    methods
        function self = PolicyLExp(K_, L_, gamma_, delta_, h_)
            self.K = K_;
            self.L = L_;
            self.Gamma = gamma_;
            self.Delta = delta_;
            self.Zeta = gamma_ * delta_ * L_ / ((delta_ + L_) * K_);
            self.h = h_;
            self.Wvec = ones(1, K_);
            self.Pvec = zeros(1, K_);            
            self.S0t = [];
            self.Beta = (1 / L_ - gamma_ / K_) / (1 - gamma_);
            self.Name = "LExp";
            self.Lambdat = 0;
            self.check_parameters();
        end

        function check_parameters(self)
            assert(self.Gamma < 1, 'LExp: illegal value for Gamma.')
            low_th = 4 * (exp(1) - 2) * self.Gamma * self.L / (1 - self.Gamma) - self.L;
            assert(self.Delta >= low_th, 'LExp: illegal value for delta.')
        end

        function selected_arms = selectNextArms(self)
            wVecSum = sum(self.Wvec);
            wVecCopy = self.Wvec;
            wVecSorted = sort(self.Wvec, 'descend');            
            th = self.Beta * wVecSum;
            if wVecSorted(1) > th % find alpha
                alpha_t = getAlpha(self.Beta, wVecSorted);                                
                self.S0t = find(self.Wvec > alpha_t);
                wVecCopy(self.S0t) = alpha_t;
            else
                self.S0t = [];
            end           
            wVecCopySum = sum(wVecCopy);
            self.Pvec = self.L * ((1 - self.Gamma) * wVecCopy ./ ...
                wVecCopySum + self.Gamma / self.K);
            if isnan(sum(self.Pvec)) % for debugging
                disp(self.Pvec)
                disp(self)
            end
            selected_arms = depRound(self.L, self.Pvec);
        end

        function updateState(self, l_indices, l_rewards)
            assert(length(l_indices) == self.L, 'LExp: L-indices do not match the number of selected arms.')
            assert(length(l_rewards) == self.L, 'LExp: L-rewards do not match the number of selected arms.')
            ahatvec = zeros(1, self.K);
            ghatvec = zeros(1, self.K);
            ahatvec(l_indices) = [l_rewards.l1]./self.Pvec(l_indices);
            ghatvec(l_indices) = [l_rewards.compound]./self.Pvec(l_indices);
            wVecCopy2 = self.Wvec;
            self.Wvec = self.Wvec .* exp(self.Zeta*(ghatvec + self.Lambdat * ahatvec));
            self.Wvec(self.S0t) = wVecCopy2(self.S0t);
            part1 = (1 - self.Delta * self.Zeta) * self.Lambdat;
            part2 = self.Zeta * (ahatvec * self.Pvec' / (1 - self.Gamma) - self.h);
            self.Lambdat = max(0, part1 - part2);
        end

        function info = getPolicyInfo(self)
            formatSpec = 'LExp policy: K = %d L = %d gamma = %0.3f delta = %0.3f h = %0.2f';
            info = sprintf(formatSpec, self.K, self.L, self.Gamma, self.Delta, self.h);
        end
       
        function reset(self)
            self.Wvec = ones(1, self.K);
            self.Pvec = zeros(1, self.K);
            self.S0t = [];
        end
    end
end