% extra 
%% 1 - median(usage) = age + c
load('taps_test_gender.mat')
outdata = extractMedianUsage(taps_tests);
X = log10(outdata.("median(usage)"));
Y = outdata.age;
mdl = fitlm(double(Y), X, 'RobustOpts', 'on');
figure(1)
plot(mdl)

%% 2 - mass autocorrelation
% load('all_jid_aut_v4.mat')
MASS = cell(1, 4);

for kk = 1:4
   masked_r2 = all_jid_aut{1, kk}.self.mask * all_jid_aut{1, kk}.self.R2_vals;
   remodel = cell(2500, 1);
   for i = 1:2500
       remodel{i} = reshape(masked_r2(i, :), 50, 50);
   end
   MASS{kk} = cell2mat(reshape(remodel, 50, 50));
end

figure(2)
subplot(2,2,1)
imagesc(MASS{1})
set(gca, 'YDir', 'normal')
subplot(2,2,2)
imagesc(MASS{2})
set(gca, 'YDir', 'normal')
subplot(2,2,3)
imagesc(MASS{3})
set(gca, 'YDir', 'normal')
subplot(2,2,4)
imagesc(MASS{4})
set(gca, 'YDir', 'normal')

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