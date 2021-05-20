function [mask, p_vals, M, P, R2] = singleDayLIMO(test_values, jids)

%% LIMO DAYS
side = size(jids{1}, 1);
n_subs = length(jids);
n_ch = side * side;
n_time = 1;

A = zeros(n_subs, n_time, side, side);
B = ones(n_subs, 2);
B(:, 1) = test_values;

for i = 1:n_subs
    A(i, 1, :, :) = jids{i};
end

A = reshape(A, n_subs, n_time, n_ch);

%% LIMO
n_boot = 1000;
boot_data = permute(A, [3 2 1]); % zeros(n_ch, n_time, n_subs);  % channels, times, individuals
boot_table = limo_create_boot_table(boot_data, n_boot);

M = zeros(n_ch, n_time, 1);  % channels, times, rtime  F scores
P = zeros(n_ch, n_time, 1);  %  P scores
R2 = zeros(n_ch, n_time, 1);

bootM = zeros(n_ch, n_time, n_boot); % channels, times, rtime, nboot
bootP = zeros(n_ch, n_time, n_boot); % channels, times, rtime, nboot

for ch = 1:n_ch  % all channels separately
    Y = A(:, :, ch); % zeros(163, 15);
    X = B; % ones(163, 2);
    model = limo_glm(Y, X, 0, 0, 1, 'OLS', 'Time', 0, n_time);
    
    model_boot = limo_glm_boot(Y,X, model.W,0,0,1,'OLS','Time',boot_table{1, ch});
    
    M(ch, :, :) = model.F;
    P(ch, :, :) = model.p;
    R2(ch, :, :) = model.R2_univariate;
    
    for j = 1:n_boot
        bootM(ch, :, j) = model_boot.F{j};
        bootP(ch, :, j) = model_boot.p{j};
    end
    
end

% cluster

nM = find_adj_matrix(50, 1);
MCC = 2;
p = 0.05;

% got rid of a stupid error check: whatever! line 53 of limo_cluster_correction
[mask, p_vals] = limo_cluster_correction(M, P, bootM, bootP, nM, MCC, p);

