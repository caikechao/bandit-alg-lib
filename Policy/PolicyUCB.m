classdef PolicyUCB < Policy
    
    properties
        K % total number of K arms
        L % number of arms that should be selected.
        Alpha % CUCB parameter
        Nvec % Nb of times each arms has been pulled
        Gvec % Cumulated reward with each action
        Level
    end
    
    methods
        function self = PolicyUCB(K_, L_, alpha_, level_)
            self.K = K_;
            self.L = L_;
            self.Alpha = alpha_;
            self.Nvec = zeros(1, K_);
            self.Gvec = zeros(1, K_);
            self.Level = level_;
            self.Name = "UCB";
        end
        
        function selected_arms = selectNextArms(self)            
            sum_Nvec = sum(self.Nvec);
            ucb_indices = (self.Gvec ./ self.Nvec) ...
                        + sqrt(self.Alpha*log(sum_Nvec)./self.Nvec);
            % init ucbs of arms with 0 pulled times            
            ucb_indices(self.Nvec == 0) = Inf;
            selected_arms = LMax(self.L, ucb_indices);
        end
        
        function updateState(self, l_indices, l_rewards)             
            self.Nvec(l_indices) = self.Nvec(l_indices) + 1;
            if self.Level == 1
                self.Gvec(l_indices) = self.Gvec(l_indices) + [l_rewards.l1];
            else
                self.Gvec(l_indices) = self.Gvec(l_indices) + [l_rewards.compound];
            end            
        end
        
        function info = getPolicyInfo(self)
            formatSpec = 'UCB policy: K = %d L = %d, Alpha = %0.3f Level = %d';
            info = sprintf(formatSpec, self.K, self.L, self.Alpha, self.Level);
        end
        
        function reset(self)
            self.Nvec = zeros(1, self.K);
            self.Gvec = zeros(1, self.K);
        end
    end
end
