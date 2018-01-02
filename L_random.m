function indices = L_random(L, K)

data = 1:K;

% the indices should not be repeated.
indices = datasample(data, L, 'Replace', false);

end
