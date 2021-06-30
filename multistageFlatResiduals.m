function [R_a, R_g, model_a] = multistageFlatResiduals(control_value, regression_value, output_value, varargin)
% Enea Ceolini, Leiden University, 26/05/2021
p = inputParser;
addRequired(p, 'control_value');
addRequired(p, 'regression_value');
addRequired(p, 'output_value');
addOptional(p, 'FitMethod', 'OLS', @(x) any(validatestring(x, {'OLS', 'IRLS'})));

parse(p, control_value, regression_value, output_value, varargin{:});
fitMethod = p.Results.FitMethod;

%% LIMO DAYS
n_subs = length(output_value);
n_time = 1;

A = zeros(n_subs, n_time, 1);
B1 = ones(n_subs, 2);
B1(:, 1) = control_value;
B2 = ones(n_subs, 2);
B2(:, 1) = regression_value;

A(:, 1, :) = output_value;

%% LIMO
Y = A;
model_g = limo_glm(Y, B1, 0, 0, 1, fitMethod, 'Time', 0, n_time);
Y_hat_g = B1 * model_g.betas;
R_g = Y - Y_hat_g;

model_a = limo_glm(R_g, B2, 0, 0, 1, fitMethod, 'Time', 0, n_time);
R_hat_g = B2 * model_a.betas;

R_a = R_g - R_hat_g;
