% Enea Ceolini, Leiden University, 26/05/2021
% extra analys for supplementary figures

%% Load data
load('./data/all_single_jids_age_gender_mf_th_v14.mat')

%% 1 - median(usage) = age + gender + c

usage = log10(all_single_jids_age_gender_mf_th.("median(usage)"));
age = double(all_single_jids_age_gender_mf_th.age);
gender = double(all_single_jids_age_gender_mf_th.gender);

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

%% 2 - pixel = median(usage) + c
fitMethod = 'IRLS';
version = 'v13_IRLS';
n_boot = 10;

all_usage_pixel = cell(1, 4);

for jid_type = 1:4
    clear res
    multiWaitbar( 'JIDs', jid_type/4, 'Color', [0.8 0.0 0.1]);
    fprintf("Doing USAGE with JID %d\n", jid_type);
    with_jid = all_single_jids_age_gender_mf_th(~cellfun('isempty', all_single_jids_age_gender_mf_th.jids(:, jid_type)), :);
    regressor = table2array(with_jid(:, {'median(usage)'}));
   
    [res.val.mask, ...
        res.val.p_vals, ...
        res.val.mdl, ...
        res.val.A, ...
        res.val.B] = singleDayLIMO(regressor, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);


    all_usage_pixel{1, jid_type} = res;
end

save(['all_usage_pixel', version], 'all_usage_pixel')

%% 3 - Pixel = age + gender+ usage

fitMethod = 'IRLS';
version = 'v13_IRLS';
n_boot = 1000;

all_age_gender_usage_pixel = cell(1, 4);

%
for jid_type = 1:4
    clear res
    multiWaitbar( 'JIDs', jid_type/4, 'Color', [0.8 0.0 0.1]);
    fprintf("Doing USAGE with JID %d\n", jid_type);
    with_jid = all_single_jids_age_gender_mf_th(~cellfun('isempty', all_single_jids_age_gender_mf_th.jids(:, jid_type)), :);
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

%% 4 - Pixel = age + gender + usage + finger1 + finger2 + years_usage

load('./data/jids_finger_v14.mat')

fitMethod = 'IRLS';
version = 'v13_IRLS';
n_boot = 10;

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

%% 5 - Pixel = age + gender + usage + finger1 + finger2 + years_usage + screen_size

fitMethod = 'IRLS';
version = 'v13_IRLS';
n_boot = 10;

all_age_gender_usage_finger_phonemodel_pixel = cell(1, 4);
jids_finger_2 = jids_finger;
jids_finger_2.age = double(jids_finger_2.age);
jids_finger_2.gender = double(jids_finger_2.gender);

for jid_type = 1:4
    clear res
    multiWaitbar( 'JIDs', jid_type/4, 'Color', [0.8 0.0 0.1]);
    fprintf("Doing USAGE with JID %d\n", jid_type);
    with_jid = jids_finger_2(~cellfun('isempty', jids_finger_2.jids(:, jid_type)), :);
    regressor = double(table2array(with_jid(:, {'age', 'gender', 'usage', 'vals', 'phoneModel'})));
    regressor(:, 3) = log10(regressor(:, 3) + 1e-15);
    [res.val.mask, ...
        res.val.p_vals, ...
        res.val.mdl, ...
        res.val.A, ...
        res.val.B] = singleDayLIMO(regressor, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);


    all_age_gender_usage_finger_phonemodel_pixel{1, jid_type} = res;
end

save(['all_age_gender_usage_finger_phonemodel_pixel_', version], 'all_age_gender_usage_finger_phonemodel_pixel')