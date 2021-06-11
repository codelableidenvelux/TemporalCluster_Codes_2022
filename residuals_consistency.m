% Look at residuals consistency 

load('all_age_516_log_NORM.mat')


[newR2, ord] = sort(all_age{1, 1}.R2);

n_subs = size(all_age{1, 1}.A, 1);

all_residuals = zeros(n_subs, 2500);

Y = squeeze(all_age{1, 1}.A);
X = all_age{1, 1}.B; % X = [age, gender]
Betas = squeeze(all_age{1, 1}.Betas(:, :, :));

% only project on Age for the residual 

Y_hat = X(:, 1) * Betas(:, 1) + Betas(:, 3);
residual = Y - Y_hat;


%%
% all_R_res2 = zeros(2500, 2500);
color = zeros(2500);
for i = 1:2500
    fprintf("%d/2500\n", i)
    for j = i:2500
%         c = corrcoef(residual(:, i), residual(:, j));
%         all_R_res2(i, j) = c(1, 2);
        color(i, j) = sign(Betas(j, 1)) ~= sign(Betas(i, 1));
    end
end

%% 
all_R_res = zeros(2500, 2500, 4);  % R, R2, t, p
multiWaitbar( 'CloseAll' );

for i = 1:2500
    multiWaitbar( 'Outside',    i/2500, 'Color', [0.8 0.0 0.1]);
    for j = i:2500
        multiWaitbar( 'Inside', j/2500, 'Color', [1.0 0.4 0.0]);
        c = fitlm(residual(:, i), residual(:, j));
        kk = corrcoef(residual(:, i), residual(:, j));
        all_R_res(j, i, 1) = kk(1, 2);
        all_R_res(j, i, 2) = c.Rsquared.Ordinary;
        all_R_res(j, i, 3) = c.Coefficients.tStat(2);
        all_R_res(j, i, 4) = c.Coefficients.pValue(2);
    end
end

% 
mask_validity = all_R_res(:, :, 4) > 0;

all_valid_p = all_R_res(mask_validity);

[pID,pN] = limo_FDR(all_valid_p, 0.05);

mask_validity = all_R_res(:, :, 4) < pID;



%% 
%presence = presence';

K = cell(50, 50);
for j = 1:50
    for i = 1:50
        K{i, j} = reshape(all_R_res2(i + 50 * (j - 1) , :), 50, 50);
    end
end

AA = cell2mat(K);
imagesc(AA)
set(gca, 'YDir', 'normal')
