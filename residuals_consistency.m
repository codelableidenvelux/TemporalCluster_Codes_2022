% Look at residuals consistency 

load('all_age_516_log_NORM.mat')


[newR2, ord] = sort(all_age{1, 1}.R2);

n_subs = size(all_age{1, 1}.A, 1);

all_residuals = zeros(n_subs, 2500);

Y = squeeze(all_age{1, 1}.A);
X = all_age{1, 1}.B;
Betas = squeeze(all_age{1, 1}.Betas(:, :, :));

Y_hat = X * Betas';
residual = Y - Y_hat;

%% 
all_R_res = cell(2500, 2500);

for i = 1:2500
    for j = i:2500
        c = fitlm(residual(:, i), residual(:, j));
%         all_R_res{j, i}.R2 = c.Rsquared.Ordinary;
        all_R_res{j, i}.p = c.Coefficients.pValue(2);
        all_R_res{j, i}.invert = sign(Betas(j, 1)) ~= sign(Betas(i, 1));
        
    end
end

%% 

K = cell(50, 50);
for i = 1:50
    for j = 1:50
        K{i, j} = reshape(all_R_res(i + 50 * (j - 1) , :), 50, 50);
    end
end

AA = cell2mat(K);
imagesc(AA)
set(gca, 'YDir', 'normal')
