function [optx, optr] = calculate_opt(arm_para_, L_, h_)

% compute optimal strategy
K = length(arm_para_);
g = arm_para_(:,1) .* arm_para_(:,2);
lb = zeros(K, 1); % greater than 0
ub = ones(K, 1); % less than 1
Aeq = ones(1, K);
beq = L_; % Need to select L arms
options = optimoptions('linprog','Algorithm','dual-simplex');
f = - g;
A = - arm_para_(:,1)';
b = - h_;

[optx, optr] = linprog(f, A, b, Aeq, beq, lb, ub, options);
% recover the max
optr = - optr;

end