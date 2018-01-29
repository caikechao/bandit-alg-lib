function result = getRad(empiricalMean, nTime, gamma_)
% getRad is to calculate the UCB of a random variable. 
    if min(nTime) <= 0
        error('get_rad: denominator shoudl be at least 1')
    end
    result = sqrt(gamma_ * empiricalMean ./ nTime) + gamma_ ./ nTime; 
end