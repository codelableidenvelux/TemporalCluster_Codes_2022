% figure_5_supplementary_a_i

%% load
load('../../../all_rtime_log_v8_IRLS.mat')
age = all_r_time{1,1}.age;
test_sRT = all_r_time{1,1}.vals;
gender = all_r_time{1,1}.gender;

tbl = array2table([age(:), test_sRT(:), gender(:)], 'VariableNames', {'Age', 'Test', 'Gender'});
mdl = fitlm(tbl, 'Test ~ Age + Gender', 'RobustOpts', 'on');

sRT = mdl.Coefficients('Gender', :);


age = all_r_time{2,1}.age;
test_cRT = all_r_time{2,1}.vals;
gender = all_r_time{2,1}.gender;

tbl = array2table([age(:), test_cRT(:), gender(:)], 'VariableNames', {'Age', 'Test', 'Gender'});
mdl = fitlm(tbl, 'Test ~ Age + Gender', 'RobustOpts', 'on');

cRT = mdl.Coefficients('Gender', :);

%% 
load('../../../all_corsi_log_v8_IRLS.mat')

age = all_corsi{1,1}.age;
test_corsi = all_corsi{1,1}.vals;
gender = all_corsi{1,1}.gender;

tbl = array2table([age(:), test_corsi(:), gender(:)], 'VariableNames', {'Age', 'Test', 'Gender'});
mdl = fitlm(tbl, 'Test ~ Age + Gender', 'RobustOpts', 'on');

corsi = mdl.Coefficients('Gender', :);

%%
load('../../../all_2back_log_v8_IRLS.mat')

age = all_2back{1,1}.age;
test_2back = all_2back{1,1}.vals;
gender = all_2back{1,1}.gender;

tbl = array2table([age(:), test_2back(:), gender(:)], 'VariableNames', {'Age', 'Test', 'Gender'});
mdl = fitlm(tbl, 'Test ~ Age + Gender', 'RobustOpts', 'on');

back2 = mdl.Coefficients('Gender', :);

%%
load('../../../all_switch_log_v8_IRLS.mat')

age = all_switch{1,1}.age;
test_global = all_switch{1,1}.vals;
gender = all_switch{1,1}.gender;

tbl = array2table([age(:), test_global(:), gender(:)], 'VariableNames', {'Age', 'Test', 'Gender'});
mdl = fitlm(tbl, 'Test ~ Age + Gender', 'RobustOpts', 'on');

globalSwitch = mdl.Coefficients('Gender', :);


age = all_switch{2,1}.age;
test_local = all_switch{2,1}.vals;
gender = all_switch{2,1}.gender;

tbl = array2table([age(:), test_local(:), gender(:)], 'VariableNames', {'Age', 'Test', 'Gender'});
mdl = fitlm(tbl, 'Test ~ Age + Gender', 'RobustOpts', 'on');

localSwitch = mdl.Coefficients('Gender', :);

%% join
all_tests = cell2table(cell(0, 3), 'VariableNames', {'Test', 'tStat', 'pValue'});
cRTs = cRT{'Gender', {'tStat','pValue'}};
sRTs = localSwitch{'Gender', {'tStat','pValue'}};
globals = globalSwitch{'Gender', {'tStat','pValue'}};
locals = localSwitch{'Gender', {'tStat','pValue'}};
corsis = corsi{'Gender', {'tStat','pValue'}};
back2s = back2{'Gender', {'tStat','pValue'}};
all_tests = [all_tests; {'cRT', cRTs(1), cRTs(2)}];
all_tests = [all_tests; {'sRT', sRTs(1), sRTs(2)}];
all_tests = [all_tests; {'globalSwitch', globals(1), globals(2)}];
all_tests = [all_tests; {'localSwitch', locals(1), locals(2)}];
all_tests = [all_tests; {'corsi', corsis(1), corsis(2)}];
all_tests = [all_tests; {'2back', back2s(1), back2s(2)}];

writetable(all_tests, 'figure_5_supplementary_a_i.csv')