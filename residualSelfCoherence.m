function [mask, p_vals, F_vals, R_vals, R2_vals, betas] = residualSelfCoherence(residuals, varargin)

p = inputParser;
addRequired(p, 'residuals');
addOptional(p, 'FitMethod', 'OLS', @(x) any(validatestring(x, {'OLS', 'IRLS'})));

parse(p, residuals, varargin{:});
fitMethod = p.Results.RobustOpts;

n_sub = size(residuals, 1);
n_ch = size(residuals, 2);

X = ones(n_sub, 2);
Y = zeros(n_sub, 1);

F_vals = zeros(2500, 2500);
p_vals = zeros(2500, 2500);
R_vals = zeros(2500, 2500);
betas = zeros(2500, 2500, 2);
R2_vals = zeros(2500, 2500);

for i = 1:n_ch
    multiWaitbar( 'Full-Channels (i)',    i/2500, 'Color', [0.8 0.8 0.1]);
    for j = i:n_ch
        multiWaitbar( 'Full-Channels (j)',    j/2500, 'Color', [0.8 0.8 0.1]);
        Y(:, 1) = residuals(:, i);
        X(:, 1) = residuals(:, j);
        
        model = limo_glm(Y, X, 0, 0, 1, fitMethod, 'Time', 0, 1);
        F_vals(i, j) = model.F;
        p_vals(i, j) = model.p;
        R2_vals(i, j) = model.R2_univariate;
        r = corrcoef(X(:, 1), Y);
        R_vals(i, j) = r(1, 2);
        betas(i, j, :) = model.betas;

%         mdl = fitlm(X, Y, 'y ~ 1 + x1', 'RobustOpts', 'on');
%         T_vals(i, j) = mdl.Coefficients{'x1', 'tStat'};
%         p_vals(i, j) = mdl.Coefficients{'x1', 'pValue'};
%         R2_vals(i, j) = mdl.Rsquared.Ordinary;
%         r = corrcoef(X(:, 1), Y);
%         R_vals(i, j) = r(1, 2);
%         betas(i, j, :) = fliplr(mdl.Coefficients{:, 'Estimate'}');
        
        % for symmetry
        F_vals(j, i) = model.F;
        p_vals(j, i) = model.p;
        R2_vals(j, i) = model.R2_univariate;
        R_vals(j, i) = r(1, 2);
        betas(j, i, :) = model.betas;
        
    end
end

% fdr correction
[pID, ~] = limo_FDR(p_vals(:), 0.001);
mask = p_vals < pID;
