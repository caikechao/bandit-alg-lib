function [optx, optr] = calculateOracleOpt(arm_para_, L_, h_)
% calculateOracleOpt is to compute optimal strategy of the Oracle.
%% output
% optx: K * 1
% optr: the optimal reward

%% input
% arm_para: K * 2

%% LP setup
K = size(arm_para_,1);
g = arm_para_(:,1) .* arm_para_(:,2); % K * 1
lb = zeros(K, 1);                     % greater than 0
ub = ones(K, 1);                      % less than 1
Aeq = ones(1, K);                     % equality constraint
beq = L_;                             % need to select L arms
f = - g;                              % K * 1
A = - arm_para_(:,1)';                % 1 * K
b = - h_;

options = optimoptions('linprog','Algorithm','dual-simplex');
[optx, optr] = linprog(f, A, b, Aeq, beq, lb, ub, options);
% recover the max value
optr = - optr;

end