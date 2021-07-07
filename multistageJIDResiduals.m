function [all_R_a, models_gender, models_age] = multistageJIDResiduals(control_value, regression_value, jids, varargin)
% Enea Ceolini, Leiden University, 26/05/2021
p = inputParser;
addRequired(p, 'control_value');
addRequired(p, 'regression_value');
addRequired(p, 'jids');
addOptional(p, 'FitMethod', 'OLS', @(x) any(validatestring(x, {'OLS', 'IRLS'})));

parse(p, control_value, regression_value, jids, varargin{:});
fitMethod = p.Results.FitMethod;

%% LIMO DAYS
side = size(jids{1}, 1);
n_subs = length(jids);
n_ch = side * side;
n_time = 1;

A = zeros(n_subs, n_time, side, side);
B1 = ones(n_subs, 2);
B1(:, 1) = control_value;
B2 = ones(n_subs, 2);
B2(:, 1) = regression_value;

for i = 1:n_subs
    A(i, 1, :, :) = jids{i};
end

A = log10(reshape(A, n_subs, n_time, n_ch) + 1e-15);

%% NaN guard
% A = A(~isnan(B(:, 1)), :, :);
% B = B(~isnan(B(:, 1)), :);

%% LIMO
all_R_a = zeros(n_subs, n_ch);
models_gender = cell(n_ch, 1);
models_age = cell(n_ch, 1);

for ch = 1:n_ch 
    multiWaitbar( 'Channels',    ch/2500, 'Color', [0.8 0.8 0.1]);
    Y = A(:, :, ch);

    model_g = limo_glm(Y, B1, 0, 0, 1, fitMethod, 'Time', 0, n_time);
    Y_hat_g = B1 * model_g.betas;
    R_g = Y - Y_hat_g;
    
    models_gender{ch} = model_g;
    
    model_a = limo_glm(R_g, B2, 0, 0, 1, fitMethod, 'Time', 0, n_time);
    R_hat_g = B2 * model_a.betas;
    
    models_age{ch} = model_a;
    
    R_a = R_g - R_hat_g;
    
    all_R_a(:, ch) = R_a;
end

