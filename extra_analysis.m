% Enea Ceolini, Leiden University, 26/05/2021
% extra analys for supplementary figures

%% Data preparation

% other studies

opts = detectImportOptions('MASS_Subject_list.xlsx','NumHeaderLines', 3);
T = readtable('MASS_Subject_list.xlsx',opts);

T = T(:, {'Var4', 'Var5', 'Var9'});
T.Properties.VariableNames = {'birthdate', 'gender', 'partId'};

T2 = T(~isnat(T.birthdate), :);
T2.Phone = cell(height(T2), 1);

for i = 1:height(T2)
    SUB = getTapDataParsed(T2.partId{i}, 'refresh', 0);
    if ~isempty(SUB)
       T2.Phone{i} = SUB; 
    end
end

% Excluding curfew data

load('Curfew_list.mat')
n_curfew_subs = length(Curfew_list);

T3 = T2;

for i = 1:n_curfew_subs
   idx = find(ismember(T3.partId, Curfew_list(i).ID) == 1);
   tsc = Curfew_list(i).utc;
   SUB_ = T3.Phone{idx};
   SUB_.taps = SUB_.taps(SUB_.taps.start < tsc * 1000, :);
   T3.Phone{idx} = SUB_;
end

% T3 should be 168
%%

% load('taps_tests_v12.mat')
single_jids_agestudy = extractSingleJID(taps_tests);
single_jids_otherstudies = extractSingleJID(T3);

single_jids_otherstudies.gender = single_jids_otherstudies.gender + 1;
all_single_jids_age = vertcat(single_jids_agestudy, single_jids_otherstudies);
all_single_jids_age_gender_mf = all_single_jids_age(all_single_jids_age.gender == 1 | all_single_jids_age.gender == 2, :);

all_single_jids_age_gender_mf_th = all_single_jids_age_gender_mf(all_single_jids_age_gender_mf.n_days > 7, :);

all_single_jids_age_gender_mf_th = all_single_jids_age_gender_mf_th(all_single_jids_age_gender_mf_th.("median(usage)")>0, :);

all_single_jids_age_gender_mf_th.age = double(all_single_jids_age_gender_mf_th.age);
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

save('./Figures/v2/figure3/suppl_iii_v13', 'adjusted')


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

%% 5 - Pixel = age + gender + usage + finger1 + finger2 + years_usage

% subset_finger = taps_tests(:, {'partId', 'finger'});
% subset_finger = subset_finger(~cellfun('isempty', subset_finger.finger), :);
% 
% taps_tests.finger = cell(height(taps_tests), 1);
% 
% for i = 1:height(subset_finger)
%     idx = find(ismember(taps_tests.partId, subset_finger.partId(i)) == 1);
%     taps_tests.finger(idx) = subset_finger.finger(i);
% end

taps_tests_1 = taps_tests(~cellfun('isempty', taps_tests.finger), :);
taps_tests_1 = taps_tests_1(~cellfun('isempty', taps_tests_1.Phone), :);
taps_tests_1 = taps_tests_1(taps_tests_1.gender == 1 | taps_tests_1.gender == 2, :);

jids_finger = extractSingleJIDFromTestTime(taps_tests_1, "finger", 1000);

% load('taps_test_gender.mat')
% single_jids_agestudy = extractSingleJID(taps_tests);
% all_single_jids_age_gender_mf = single_jids_agestudy(single_jids_agestudy.gender == 1 | single_jids_agestudy.gender == 2, :);
%
fitMethod = 'IRLS';
version = 'v13_IRLS';
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

%% 6 - Pixel = age + gender + usage + finger1 + finger2 + years_usage + screen_size


phonemodel = readtable('Age_ML_smartphones_update_14_02_22.csv');


taps_tests_1 = taps_tests(~cellfun('isempty', taps_tests.finger), :);
taps_tests_1 = taps_tests_1(~cellfun('isempty', taps_tests_1.Phone), :);
taps_tests_1 = taps_tests_1(taps_tests_1.gender == 1 | taps_tests_1.gender == 2, :);

for i = 1:height(phonemodel)
    idx = find(ismember(taps_tests_1.partId, phonemodel.partId(i)) == 1);
    taps_tests_1.phoneModel(idx) = phonemodel.screen_i(i);
end

% remove tablets if any
taps_tests_2 = taps_tests_1((taps_tests_1.phoneModel > 0) & (taps_tests_1.phoneModel < 7), :);


jids_finger = extractSingleJIDFromTestTime(taps_tests_2, "finger", 1000);

% load('taps_test_gender.mat')
% single_jids_agestudy = extractSingleJID(taps_tests);
% all_single_jids_age_gender_mf = single_jids_agestudy(single_jids_agestudy.gender == 1 | single_jids_agestudy.gender == 2, :);
%
fitMethod = 'IRLS';
version = 'v13_IRLS';
n_boot = 1000;

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



%%

finger1 = jids_finger.vals(:, 1);
finger2 = jids_finger.vals(:, 2);
yearsuse = jids_finger.vals(:, 3);

age = double(jids_finger.age);
gender = double(jids_finger.gender);

tbl = array2table([finger1(:), age(:), gender(:)], 'VariableNames', {'Finger1', 'Age', 'Gender'});
mdl = fitlm(tbl, 'Finger1 ~ Age + Gender', 'RobustOpts', 'on');

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
adjusted.finger1 = finger1;
adjusted.age = age;
adjusted.gender = gender;
adjusted.mdl = mdl;
adjusted.R2 = mdl.Rsquared.Ordinary;
adjusted.pval = mdl.Coefficients{'Age', 'pValue'};

adjusted.stats = table2array(mdl.Coefficients);

summary = anova(mdl,'summary');
adjusted.full = summary{'Model', :};

save('./Figures/v2/figure3/finger1_age_gender', 'adjusted')