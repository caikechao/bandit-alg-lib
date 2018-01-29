classdef MbanditSimulator < handle

    properties
        Arms % array
        Policies % cell
        K
        L
        h
        IsTimeVarying
        nSimulations
    end

    methods
        function self = MbanditSimulator(arms_, policies_, K_, L_, h_, isTimeVarying_, nSimulations_)
            self.Arms = arms_;
            self.Policies = policies_;
            self.K = K_;
            self.L = L_;
            self.h = h_;
            self.IsTimeVarying = isTimeVarying_;
            self.nSimulations = nSimulations_;
        end

        function run_simulation(self, T_, logger_)
            if self.IsTimeVarying
                warning('Cannot run multiple simulations on time-varying policies ... !')
            end
            for isim = 1:self.nSimulations
                for p = 1:length(self.Policies)
                    name = self.Policies{p}.Name;
                    for t = 1:T_
                        if mod(t,1) == 0
                            % verbose about the policies
                            fprintf('Policy %s at round %d in %d-th simulation ...\n', name, t, isim)
                        end
                        self.run_single_round(logger_, isim, p, t);
                    end
                end
                % reset the arms, not necessary here.
                for iarm = self.Arms
                    iarm.reset();
                end
                % reset the polices
                for p = 1:length(self.Policies)
                    self.Policies{p}.reset();
                end
            end          
        end

        function run_single_round(self, logger_, s_, p_, t_)
            l_indices = self.Policies{p_}.selectNextArms();
            l_rewards = [];
            for idx = l_indices
                l_rewards = [l_rewards, self.Arms(idx).pull()];
            end
            % disp(l_indices)
            % disp([l_rewards.l1])
            % disp([l_rewards.l2])
            % disp([l_rewards.compound])
            self.Policies{p_}.updateState(l_indices, l_rewards);                        
            logger_.record_reward(s_, p_, t_, l_indices, l_rewards);
            logger_.record_violation(s_, p_, t_, self.h)
        end
    end
end