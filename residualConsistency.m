function [mask, p_vals, F_vals, R_vals, R2_vals, betas] = residualConsistency(residualsPixel, residualsTest)

n_sub = size(residualsPixel, 1);
n_ch = size(residualsPixel, 2);
n_time = 1;

B = ones(n_sub, 2);
B(:, 1) = residualsTest;

A = ones(n_subs, 1, n_ch);
A(:, 1, :) = residualsA;

F_vals = zeros(2500, 1);
p_vals = zeros(2500, 1);
R_vals = zeros(2500, 1);
R2_vals = zeros(2500, 1);
betas = zeros(2500, 2);

n_boot = 1000;
boot_data = permute(A, [3 2 1]); % zeros(n_ch, n_time, n_subs);  % channels, times, individuals
boot_table = limo_create_boot_table(boot_data, n_boot);

W = ones(n_boot, n_subs);
bootM = zeros(n_ch, n_time, n_boot); % channels, times, nboot
bootP = zeros(n_ch, n_time, n_boot); % channels, times, nboot

for i = 1:n_ch
    multiWaitbar( 'Full-Channels (i)',    i/2500, 'Color', [0.8 0.8 0.1]);
    Y = A(:, :, i);
    X = B;
    model = limo_glm(Y, X, 0, 0, 1, 'IRLS', 'Time', 0, n_time);
    F_vals(i) = model.F;
    p_vals(i) = model.p;
    R2_vals(i) = model.R2_univariate;
    betas(i, :) = model.betas;
    r = corrcoef(X, Y);
    R_vals(i) = r(1, 2);
    
    model_boot = limo_glm_boot(Y, X, W, 0, 0, 1,'IRLS','Time', boot_table{1, ch});
    
    for j = 1:n_boot
        bootM(ch, :, j) = model_boot.F{j};
        bootP(ch, :, j) = model_boot.p{j};
    end
end


nM = find_adj_matrix(50, 1);
MCC = 2;
p = 0.05;

[mask, ~] = limo_cluster_correction(F_vals, p_vals, bootM, bootP, nM, MCC, p);
