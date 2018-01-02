function l_indices = depRound(L_, prob)
K = length(prob);
assert(L_ < K, 'depRound: l should be less than K.')

% require a tolerance
% disp(sum(prob))
assert(abs(sum(prob) - L_) < 1e-3, 'depRound: sum of the selection probability should equal L.')

data = 1:K;

l_indices = datasample(data, L_, 'Replace', false, 'Weights', prob);

end
