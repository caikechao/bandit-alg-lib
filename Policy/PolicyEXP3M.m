classdef PolicyEXP3M < Policy
    
    properties
        K
        L
        Gamma
        Wvec
        Pvec
        S0t
        Level
        Beta
    end
    
    methods
        function self = PolicyEXP3M(K_, L_, gamma_, level_)
            self.K = K_;
            self.L = L_;
            self.Gamma = gamma_;
            self.Wvec = ones(1, K_);
            self.Pvec = zeros(1, K_);
            self.S0t = [];
            self.Level = level_;
            self.Beta = (1 / self.L - self.Gamma / self.K) / (1 - self.Gamma);
            self.Name = "EXP3M";
        end
        
        function selected_arms = selectNextArms(self)            
            wVecSum = sum(self.Wvec);
            wVecCopy = self.Wvec;
            wVecSorted = sort(self.Wvec, 'descend');
            th = self.Beta * wVecSum;
            if wVecSorted(1) > th
                alpha_t = getAlpha(self.Beta, wVecSorted);                
                self.S0t = find(self.Wvec > alpha_t);
                wVecCopy(self.S0t) = alpha_t;
            else
                self.S0t = [];
            end            
            sumWCopy = sum(wVecCopy);
            self.Pvec = self.L * ((1 - self.Gamma) * wVecCopy ./ sumWCopy + self.Gamma / self.K);            
            selected_arms = depRound(self.L, self.Pvec);
        end
        
        function updateState(self, l_indices, l_rewards)            
            assert(length(l_indices) == self.L, 'EXP3M: L-indices do not match the number of selected arms.')
            assert(length(l_rewards) == self.L, 'EXP3M: L-rewards do not match the number of selected arms.')
            xhatvec = zeros(1, self.K);            
            if self.Level == 1
                xhatvec(l_indices) = [l_rewards.l1] ./ self.Pvec(l_indices);
            else
                xhatvec(l_indices) = [l_rewards.compound] ./ self.Pvec(l_indices);
            end  
            wVecCopy2 = self.Wvec;
            self.Wvec = self.Wvec .* exp(self.L * self.Gamma .* xhatvec/self.K);
            self.Wvec(self.S0t) = wVecCopy2(self.S0t);
        end
        
        function info = getPolicyInfo(self)
            formatSpec = 'EXP3M policy: K = %d L = %d gamma = %0.3f level = %d';
            info = sprintf(formatSpec, self.K, self.L, self.Gamma, self.Level);
        end
        
        function reset(self)
            self.Wvec = ones(1, self.K);
            self.Pvec = zeros(1, self.K);
            self.S0t = [];
        end
    end
end