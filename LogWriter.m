classdef LogWriter < handle

    properties
        file_name
        logger
        K
        L
        h
        T
        P
        arm_paramters
        arm_names % cell
        policy_names % cell
        opt_reward % optimal reward in each round
    end

    methods
        function self = LogWriter(logger_, L_, h_,  arm_para_, optr_, arm_names_, policy_names_)
            % self.file_name = f_;
            self.logger = logger_; % (P_, T_, K_, 2);
            log_size = size(self.logger.roundwise_idx_reward);            
            self.L = L_;
            self.h = h_;
            self.P = log_size(1);
            self.T = log_size(2);
            self.K = log_size(3);
            self.arm_paramters = arm_para_; % K * 2 matrix
            self.arm_names = arm_names_;
            self.policy_names = policy_names_;            
            self.opt_reward = optr_;
        end        

        function dump(self, filename_, level_)
            if nargin > 2
                default_level = level_;
            else
                default_level = 0;
            end
            self.file_name = filename_;
            file_id = fopen(self.file_name, 'w');
            fprintf(file_id, '#Reward and violation log of %d arms in each round\n', self.K);

            % arm names
            for i = 1:self.K
                fprintf(file_id, '#arm%d %s\n', i, self.arm_names{i});
            end
            % policy names
            for i = 1:length(self.policy_names)
                fprintf(file_id, '#policy%d %s\n', i, self.policy_names{i});
            end

            fprintf(file_id, '#K: %d\n', self.K);
            fprintf(file_id, '#L: %d\n', self.L);
            fprintf(file_id, '#h: %0.2f\n', self.h);
            fprintf(file_id, '#T: %d\n', self.T);

            % arm parameter
            fprintf(file_id, '#A1: ');
            for i = 1:self.K
                fprintf(file_id, '%0.2f ', self.arm_paramters(i, 1));
            end
            fprintf(file_id, '\n');

            fprintf(file_id, '#A2: ');
            for i = 1:self.K
                fprintf(file_id, '%0.2f ', self.arm_paramters(i, 2));
            end
            fprintf(file_id, '\n');
            if default_level ~= 0
                fprintf(file_id, '#t: l1-l2 reward groups of %d policies ', self.P);
            end
            fprintf(file_id, '# optimal-reward ');
            for i = 1:self.P
                fprintf(file_id, 'cumreward%d ', i);
            end
            for i = 1:self.P
                fprintf(file_id, 'cumviolation%d ', i);
            end
            fprintf(file_id, '\n');
            % out put the data            
            round_cum_reward = cumsum(self.logger.roundwise_tot_reward, 2);
            for t = 1:self.T
                fprintf(file_id, '%d ', t);
                if default_level ~= 0
                    for p = 1:self.P
                        for k = 1:self.K
                            fprintf(file_id, '%0.2f %0.2f ', ...
                                self.logger.roundwise_idx_reward(p, t, k, 1), ...
                                self.logger.roundwise_idx_reward(p, t, k, 2));
                        end
                    end
                end
                % optimal cum reward
                fprintf(file_id, '%0.2f ', t* self.opt_reward);
                % reward p
                for p = 1:self.P
                    fprintf(file_id, '%0.2f ', round_cum_reward(p, t));
                end
                % violation p
                for p = 1:self.P
                    fprintf(file_id, '%0.2f ', self.logger.roundwise_tot_violation(p, t));
                end
                fprintf(file_id, '\n');
            end
            fclose(file_id);
        end
    end
end