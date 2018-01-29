function [optx, exitflag] = calculateUCBOpt(ucbg_, ucba_, L_, h_)
% calculateUCBOpt: compute optimal strategy of Con-UCB.
% optx: K * 1 
% exitflag: success lp or not

K = length(ucbg_);
lb = zeros(K, 1); % greater than 0
ub = ones(K, 1);  % less than 1
Aeq = ones(1, K); % equality constraint
beq = L_;         % need to select L arms
options = optimoptions('linprog','Algorithm','dual-simplex');

f = - transpose(ucbg_); % K * 1
A = - ucba_;            % 1 * K
b = - h_;

[optx, ~, exitflag] = linprog(f, A, b, Aeq, beq, lb, ub, options);

end