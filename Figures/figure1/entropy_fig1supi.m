%% ENTROPY vs AGE
load('../../all_age_gender_log_v5_IRLS.mat')
%%
all_adjusted = cell(1, 4);
for jj = 1:4
    n_sub = size(all_age_gender{1, jj}.val.A, 1);
    allJIDs = squeeze(all_age_gender{1, jj}.val.A);
    entropy = zeros(n_sub, 1);
    age = squeeze(all_age_gender{1, jj}.val.B(:, 1));
    gender = squeeze(all_age_gender{1, jj}.val.B(:, 2));
    
    for i = 1:n_sub
        entropy(i) = JID_entropy(10 .^ reshape(allJIDs(i, :), 50, 50));
    end
    
    [~, id_e] = sort(entropy);
    
    x = age(entropy > 5);
    y = entropy(entropy > 5);
    z = gender(entropy > 5);
    tbl = array2table([age(:), entropy(:), gender(:)], 'VariableNames', {'Age', 'Entropy', 'Gender'});
    mdl = fitlm(tbl, 'Entropy ~ Age + Gender', 'RobustOpts', 'on');
    figure(jj)
    h = plotAdjustedResponse(mdl, 'Age');
    adjusted_data = zeros(2, size(h(1,1).XData, 2));
    adjusted_fit = zeros(2, size(h(2,1).XData, 2));
    adjusted_data(1, :) = h(1,1).XData;
    adjusted_data(2, :) = h(1,1).YData;
    adjusted_fit(1, :) = h(2,1).XData;
    adjusted_fit(2, :) = h(2,1).YData;
    
    adjusted.adjusted_fit = adjusted_fit;
    adjusted.adjusted_data = adjusted_data;
    adjusted.entropy = entropy;
    adjusted.age = age;
    adjusted.gender = gender;
    adjusted.JIDs = allJIDs;
    adjusted.mdl = mdl;
    adjusted.R2 = mdl.Rsquared.Ordinary;
    adjusted.pval = mdl.Coefficients{'Age', 'pValue'};
    
    all_adjusted{1, jj} = adjusted;
end
save('adjusted_entropy_response', 'all_adjusted');
