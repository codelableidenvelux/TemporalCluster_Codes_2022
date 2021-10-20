% Enea Ceolini, Leiden University, 26/05/2021
% extra 
%% 1 - median(usage) = age + gender + c
% load('taps_tests_v6.mat')
outdata = extractMedianUsage(taps_tests);
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

adjusted.stats = table2array(mdl.Coefficients);

summary = anova(mdl,'summary');
adjusted.full = summary{'Model', :};

save('./Figures/v2/figure3/suppl_iii', 'adjusted')


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
load('taps_test_v6.mat')
single_jids_agestudy = extractSingleJID(taps_tests);
single_jids_otherstudies = extractSingleJID(T2);

single_jids_otherstudies.gender = single_jids_otherstudies.gender + 1;
all_single_jids_age = vertcat(single_jids_agestudy, single_jids_otherstudies);
all_single_jids_age_gender_mf = all_single_jids_age(all_single_jids_age.gender == 1 | all_single_jids_age.gender == 2, :);

all_single_jids_age_gender_mf_th = all_single_jids_age_gender_mf(all_single_jids_age_gender_mf.n_days > 7, :);

% all_single_jids_age_gender_mf = single_jids_agestudy(single_jids_agestudy.gender == 1 | single_jids_agestudy.gender == 2, :);

all_single_jids_age_gender_mf_th = all_single_jids_age_gender_mf_th(all_single_jids_age_gender_mf_th.("median(usage)")>0, :);


fitMethod = 'IRLS';
version = 'v6_IRLS';
n_boot = 1000;

all_age_gender_usage_pixel = cell(1, 4);

%%
for jid_type = 1:4
    clear res
    multiWaitbar( 'JIDs', jid_type/4, 'Color', [0.8 0.0 0.1]);
    fprintf("Doing USAGE with JID %d\n", jid_type);
    with_jid = all_single_jids_age_gender_mf_th(~cellfun('isempty', all_single_jids_age_gender_mf_th.jids(:, jid_type)), :);
%     with_jid = jids_finger_2(~cellfun('isempty', jids_finger_2.jids(:, jid_type)), :);
    regressor = double(table2array(with_jid(:, {'age', 'gender', 'median(usage)'})));
    regressor(:, 3) = log10(regressor(:, 3) + 1e-15);
    
    [res.val.mask, ...
        res.val.p_vals, ...
        res.val.mdl, ...
        res.val.A, ...
        res.val.B] = singleDayLIMO(regressor, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);


    all_age_gender_usage_pixel{1, jid_type} = res;
end

save(['all_age_gender_logusage_pixel_', version], 'all_age_gender_usage_pixel')

%% 5 - Pixel = age + gender + usage + finger1 + finger2 + years_usage

subset_finger = taps_tests_finger(:, {'partId', 'finger'});
subset_finger = subset_finger(~cellfun('isempty', subset_finger.finger), :);

taps_tests.finger = cell(height(taps_tests), 1);

for i = 1:height(subset_finger)
    idx = find(ismember(taps_tests.partId, subset_finger.partId(i)) == 1);
    taps_tests.finger(idx) = subset_finger.finger(i);
end

taps_tests_1 = taps_tests(~cellfun('isempty', taps_tests.finger), :);
taps_tests_1 = taps_tests_1(~cellfun('isempty', taps_tests_1.Phone), :);
taps_tests_1 = taps_tests_1(taps_tests_1.gender == 1 | taps_tests_1.gender == 2, :);

jids_finger = extractSingleJIDFromTestTime(taps_tests_1, "finger", 1000);

% load('taps_test_gender.mat')
% single_jids_agestudy = extractSingleJID(taps_tests);
% all_single_jids_age_gender_mf = single_jids_agestudy(single_jids_agestudy.gender == 1 | single_jids_agestudy.gender == 2, :);
%%
fitMethod = 'IRLS';
version = 'v6_IRLS';
n_boot = 1000;

all_age_gender_usage_finger_pixel = cell(1, 4);
jids_finger_2 = jids_finger;
jids_finger_2.age = double(jids_finger_2.age);
jids_finger_2.gender = double(jids_finger_2.gender);

for jid_type = 1:4
    clear res
    multiWaitbar( 'JIDs', jid_type/4, 'Color', [0.8 0.0 0.1]);
    fprintf("Doing USAGE with JID %d\n", jid_type);
    with_jid = jids_finger_2(~cellfun('isempty', jids_finger_2.jids(:, jid_type)), :);
    regressor = double(table2array(with_jid(:, {'age', 'gender', 'usage', 'vals'})));
    regressor(:, 3) = log10(regressor(:, 3) + 1e-15);
    [res.val.mask, ...
        res.val.p_vals, ...
        res.val.mdl, ...
        res.val.A, ...
        res.val.B] = singleDayLIMO(regressor, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);


    all_age_gender_usage_finger_pixel{1, jid_type} = res;
end

save(['all_age_gender_usage_finger_pixel_', version], 'all_age_gender_usage_finger_pixel')


%%