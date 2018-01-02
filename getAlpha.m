function alpha_exp = getAlpha(rhs, wvec_sort)

sum_weight = sum(wvec_sort);
for i = 1:length(wvec_sort)
    alpha = (rhs * sum_weight) / (1 - i * rhs);
    curr = wvec_sort(i);
    if alpha > curr
        alpha_exp = alpha;
        return
    end
    sum_weight = sum_weight - curr;
end

error('GetAlpha: no alpha is found.')

end