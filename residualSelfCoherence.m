function [mask, p_vals, F_vals, R_vals, R2_vals] = residualSelfCoherence(residuals)

n_sub = size(residuals, 1);
n_ch = size(residuals, 2);

X = ones(n_sub, 2);  % No bias;
Y = zeros(n_sub, 1);

F_vals = zeros(2500, 2500);
p_vals = zeros(2500, 2500);
R_vals = zeros(2500, 2500);
R2_vals = zeros(2500, 2500);

for i = 1:n_ch
    multiWaitbar( 'Full-Channels (i)',    i/2500, 'Color', [0.8 0.8 0.1]);
    for j = i:n_ch
        multiWaitbar( 'Full-Channels (j)',    j/2500, 'Color', [0.8 0.8 0.1]);
        Y(:, 1) = residuals(:, i);
        X(:, 1) = residuals(:, j);
        model = limo_glm(Y, X, 0, 0, 1, 'IRLS', 'Time', 0, n_time);
        F_vals(i, j) = model.F;
        p_vals(i, j) = model.p;
        R2_vals(i, j) = model.R2_univariate;
        r = corrcoef(X, Y);
        R_vals(i, j) = r(1, 2);
        
        % for symmetry
        F_vals(j, i) = model.F;
        p_vals(j, i) = model.p;
        R2_vals(j, i) = model.R2_univariate;
        R_vals(j, i) = r(1, 2);

    end
end

% fdr correction
[pID, ~] = limo_FDR(p_vals(:));
mask = all_p < pID;
