% Enea Ceolini, Leiden University, 26/05/2021
% extra 
%% 1 - median(usage) = age + gender + c
% load('taps_test_gender.mat')
% outdata = extractMedianUsage(taps_tests);
usage = log10(outdata.("median(usage)"));
age = double(outdata.age);
gender = double(outdata.gender);

tbl = array2table([age(:), usage(:), gender(:)], 'VariableNames', {'Age', 'Usage', 'Gender'});
mdl = fitlm(tbl, 'Usage ~ Age + Gender', 'RobustOpts', 'on');

figure(1)
h = plotAdjustedResponse(mdl, 'Age');
adjusted_data = zeros(2, size(h(1,1).XData, 2));
adjusted_fit = zeros(2, size(h(2,1).XData, 2));
adjusted_data(1, :) = h(1,1).XData;
adjusted_data(2, :) = h(1,1).YData;
adjusted_fit(1, :) = h(2,1).XData;
adjusted_fit(2, :) = h(2,1).YData;

adjusted.adjusted_fit = adjusted_fit;
adjusted.adjusted_data = adjusted_data;
adjusted.usage = usage;
adjusted.age = age;
adjusted.gender = gender;
adjusted.mdl = mdl;
adjusted.R2 = mdl.Rsquared.Ordinary;
adjusted.pval = mdl.Coefficients{'Age', 'pValue'};

save('suppl_iii', 'adjusted')

%% 2 - mass autocorrelation
% load('all_jid_aut_v5_IRLS.mat')
MASS = cell(1, 4);

for kk = 1:4
   masked_r2 = all_jid_aut{1, kk}.self.mask .* all_jid_aut{1, kk}.self.R2_vals;
   remodel = cell(2500, 1);
   for i = 1:2500
       remodel{i} = reshape(masked_r2(i, :), 50, 50);
   end
   MASS{kk} = cell2mat(reshape(remodel, 50, 50));
end

save('mass_extra_2', 'MASS')

% figure(2)
% subplot(2,2,1)
% imagesc(MASS{1})
% set(gca, 'YDir', 'normal')
% subplot(2,2,2)
% imagesc(MASS{2})
% set(gca, 'YDir', 'normal')
% subplot(2,2,3)
% imagesc(MASS{3})
% set(gca, 'YDir', 'normal')
% subplot(2,2,4)
% imagesc(MASS{4})
% set(gca, 'YDir', 'normal')

%% 3 - pixel = median(usage) + c
load('taps_test_gender.mat')
single_jids_agestudy = extractSingleJID(taps_tests);
all_single_jids_age_gender_mf = single_jids_agestudy(single_jids_agestudy.gender == 1 | single_jids_agestudy.gender == 2, :);
fitMethod = 'IRLS';
version = 'v5_IRLS';
n_boot = 1000;

all_usage_pixel = cell(1, 4);

for jid_type = 1:4
    clear res
    multiWaitbar( 'JIDs', jid_type/4, 'Color', [0.8 0.0 0.1]);
    fprintf("Doing USAGE with JID %d\n", jid_type);
    with_jid = all_single_jids_age_gender_mf(~cellfun('isempty', all_single_jids_age_gender_mf.jids(:, jid_type)), :);
    regressor = table2array(with_jid(:, {'median(usage)'}));
   
    [res.val.mask, ...
        res.val.p_vals, ...
        res.val.mdl, ...
        res.val.A, ...
        res.val.B] = singleDayLIMO(regressor, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);


    all_usage_pixel{1, jid_type} = res;
end

save(['all_usage_pixel', version], 'all_usage_pixel')

%% 4 - Pixel = age + gender+ usage
% load('taps_test_gender.mat')
% single_jids_agestudy = extractSingleJID(taps_tests);
% all_single_jids_age_gender_mf = single_jids_agestudy(single_jids_agestudy.gender == 1 | single_jids_agestudy.gender == 2, :);
fitMethod = 'IRLS';
version = 'v5_IRLS';
n_boot = 1000;

all_age_gender_usage_pixel = cell(1, 4);

for jid_type = 1:4
    clear res
    multiWaitbar( 'JIDs', jid_type/4, 'Color', [0.8 0.0 0.1]);
    fprintf("Doing USAGE with JID %d\n", jid_type);
    with_jid = all_single_jids_age_gender_mf(~cellfun('isempty', all_single_jids_age_gender_mf.jids(:, jid_type)), :);
    regressor = table2array(with_jid(:, {'age', 'gender', 'median(usage)'}));
   
    [res.val.mask, ...
        res.val.p_vals, ...
        res.val.mdl, ...
        res.val.A, ...
        res.val.B] = singleDayLIMO(regressor, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);


    all_age_gender_usage_pixel{1, jid_type} = res;
end

save(['all_age_gender_usage_pixel_', version], 'all_age_gender_usage_pixel')