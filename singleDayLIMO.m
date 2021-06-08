function [masks, p_vals, models, A, B] = singleDayLIMO(test_values, jids, varargin)

%% LIMO DAYS
side = size(jids{1}, 1);
n_subs = length(jids);
n_ch = side * side;
n_time = 1;
n_values = size(test_values, 2);

A = zeros(n_subs, n_time, side, side);
B = ones(n_subs, n_values + 1);
B(:, 1:n_values) = test_values;

for i = 1:n_subs
    A(i, 1, :, :) = jids{i};
end

A = log10(reshape(A, n_subs, n_time, n_ch) + 1e-15);

%% NaN guard
A = A(~isnan(B(:, 1)), :, :);
B = B(~isnan(B(:, 1)), :);
%% LIMO
n_boot = 1000;
boot_data = permute(A, [3 2 1]); % zeros(n_ch, n_time, n_subs);  % channels, times, individuals
boot_table = limo_create_boot_table(boot_data, n_boot);

M = zeros(n_ch, n_time, 1, n_values);  % channels, times, rtime  F scores
P = zeros(n_ch, n_time, 1, n_values);  %  P scores

bootM = zeros(n_ch, n_time, n_boot, n_values); % channels, times, rtime, nboot, n_regressor
bootP = zeros(n_ch, n_time, n_boot, n_values); % channels, times, rtime, nboot, n_regressor
W = ones(n_subs, n_boot);
models = cell(n_ch, 1);

for ch = 1:n_ch  % all channels separately
    Y = A(:, :, ch); % zeros(163, 15);
    X = B; % ones(163, 2);
    model = limo_glm(Y, X, 0, 0, n_values, 'IRLS', 'Time', 0, n_time);
    
    for m = 1:n_values
        M(ch, :, :, m) = model.continuous.F(m);
        P(ch, :, :, m) = model.continuous.p(m);
    end
    models{ch, 1} = model;
    
    model_boot = limo_glm_boot(Y,X, W,0,0,n_values,'IRLS','Time',boot_table{1, ch});
    
    for j = 1:n_boot
        for m = 1:n_values
            bootM(ch, :, j, m) = model_boot.continuous.F{j}(m);
            bootP(ch, :, j, m) = model_boot.continuous.p{j}(m);
        end
    end
    
end

% cluster

nM = find_adj_matrix(50, 1);
MCC = 2;
p = 0.05;

% got rid of a stupid error check: whatever! line 53 of limo_cluster_correction
masks = cell(n_values, 1) ;
p_vals = cell(n_values, 1);

for m = 1:n_values
    [masks{m}, p_vals{m}] = limo_cluster_correction(M(:, :, :, m), ...
                                                    P(:, :, :, m), ...
                                                    bootM(:, :, :, m), ...
                                                    bootP(:, :, :, m), nM, MCC, p);
end



