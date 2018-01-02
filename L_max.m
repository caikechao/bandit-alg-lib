function indices = L_max(l, vec)
%
% Find the indices of the largest l elements in vec.
assert(l < length(vec), 'L should be less than the vector length')
[~, sortIndex] = sort(vec, 'descend');
indices = sortIndex(1:l);
end

