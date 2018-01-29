function indices = LRandom(L, K)
assert(L<=K, 'LRandom: L should be no greater than K.')

data = 1:K;

% the indices should not be repeated.
indices = datasample(data, L, 'Replace', false);

end
