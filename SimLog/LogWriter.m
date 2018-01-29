classdef LogWriter < handle

    properties
        file_name
        Logger
        S
        K
        L
        h
        T
        P
        ArmParameters
        PolicyInfo % cell
        OptReward  % optimal reward in each round
    end

    methods
        function self = LogWriter(logger_, L_, h_, arm_para_, optr_, policyinfo_)
            self.Logger = logger_;
            log_size = size(self.Logger.ArmsRewards); % (S_, P_, T_, K_, 2);
            self.L = L_;
            self.h = h_;
            assert(logger_.nSimulations==log_size(1), ...
                  'LogWriter: logger should be of the same size with nSims')
            self.S = log_size(1);
            self.P = log_size(2);
            self.T = log_size(3);
            self.K = log_size(4);
            self.ArmParameters = arm_para_; % K * 2 matrix
            self.OptReward = optr_;
            self.PolicyInfo = policyinfo_;  % 1* P cell
        end

        function dump(self, filename_, verbose_)
            if nargin > 2
                verbose = verbose_;
            else
                verbose = 0;
            end
            file_id = fopen(filename_, 'w');
            fprintf(file_id, '#Reward and violation log of %d arms in each round\n', self.K);

            % policy info
            for i = 1:length(self.PolicyInfo)
                fprintf(file_id, '#policy%d %s\n', i, self.PolicyInfo{i});
            end

            fprintf(file_id, '#S: %d\n', self.S);
            fprintf(file_id, '#K: %d\n', self.K);
            fprintf(file_id, '#L: %d\n', self.L);
            fprintf(file_id, '#h: %0.2f\n', self.h);
            fprintf(file_id, '#T: %d\n', self.T);

            % arm parameter
            fprintf(file_id, '#A: ');
            for i = 1:self.K
                fprintf(file_id, '%0.2f ', self.ArmParameters(i, 1));
            end
            fprintf(file_id, '\n');

            fprintf(file_id, '#B: ');
            for i = 1:self.K
                fprintf(file_id, '%0.2f ', self.ArmParameters(i, 2));
            end
            fprintf(file_id, '\n');
            if verbose ~= 0
                fprintf(file_id, '#t: l1-l2 reward groups of %d policies ', self.P);
                % in this case, we need to output the rewards of all the arms
            end
            fprintf(file_id, '# optimal-reward ');
            for i = 1:self.P
                fprintf(file_id, 'cumreward%d ', i);
            end
            for i = 1:self.P
                fprintf(file_id, 'cumviolation%d ', i);
            end

            fprintf(file_id, '\n');
            % Output the data
            % TotalViolations SPT   % total violation at t
            % ArmsRewards     SPTK2 % reward of each arm
            % CompoundRewards SPT   % compound
            
            % avg over n simulations, and cumsum
            avg_totalViolations = cumsum(sum(self.Logger.TotalViolations,1)/self.S, 3); % 1*PT
            % avg over n simulations
            avg_armsRewards = sum(self.Logger.ArmsRewards,1)/self.S; % 1*PTK2            
            % avg and then cumreward over t            
            cum_compoundRewards = cumsum(sum(self.Logger.CompoundRewards,1)/self.S,3); %1*PT
            for t = 1:self.T
                fprintf(file_id, '%d ', t);
                if verbose ~= 0
                    for p = 1:self.P
                        for k = 1:self.K
                            % roundwise reward of each arm
                            fprintf(file_id, '%0.2f %0.2f ', ...
                                avg_armsRewards(1, p, t, k, 1), ...
                                avg_armsRewards(1, p, t, k, 2));
                        end
                    end
                end
                % optimal cum reward
                fprintf(file_id, '%0.2f ', t * self.OptReward);
                % p cum reward
                for p = 1:self.P
                    fprintf(file_id, '%0.2f ', cum_compoundRewards(1, p, t));
                end
                % p cum violation
                for p = 1:self.P
                    fprintf(file_id, '%0.2f ', avg_totalViolations(1, p, t));
                end
                fprintf(file_id, '\n');
            end
            fclose(file_id);
        end

        function dumpLambdaT(self, filename_)
            if self.Logger.IndexLExp == -1
                error('No LExp policy in this simulation. No dumping lambda.')
            end
            file_id = fopen(filename_, 'w');
            fprintf(file_id, '#Reward and violation log of %d arms in each round\n', self.K);
            % round_lambda_avgn = sum(self.Logger.roundwise_lambda, 1)/self.S;
            % the value of lambda
            % for i = 1:self.P
            %    fprintf(file_id, 'lambda%d ', i);
            % end
            % lambda_t p
            % for p = 1:self.P
            %    fprintf(file_id, '%0.2f ', round_lambda_avgn(p, t));
            % end
            fclose(file_id);
        end
    end
end