function b = deming_kk(x, y)
    tmp = pca([x, y]);
    tmp = tmp(:, 1);
    
    % Compute regression coefficients
    b = [mean(y) - mean(x) * tmp(2) / tmp(1); tmp(2) / tmp(1)];
end
