%% Hyperparams

fitMethod = 'IRLS';
version = 'v5_IRLS';
n_boot = 1000;
multiWaitbar('CLOSEALL');

%% load data

% taps_tests = fuseTapPsy();
% or load it if present 
% load('taps_test_gender.mat', 'taps_tests')

%% CORSI 
% data_proc_corsi = extractSingleJIDFromTestTime(taps_tests, "corsi", 10);
% data_proc_corsi = data_proc_corsi(data_proc_corsi.gender == 1 | data_proc_corsi.gender == 2, :);

%%
all_corsi = cell(1, 4);
th_corsi = 2;

for jid_type = 1:4
    fprintf("Doing CORSI with JID %d\n", jid_type);
    
    with_jid = data_proc_corsi(~cellfun('isempty', data_proc_corsi.jids(:, jid_type)), :);
    
    with_jid = with_jid(with_jid.n_presentations > th_corsi, :);
    res.n_presentations = with_jid.n_presentations;
    
    % pixel = test + gender :: Figure 3
    fprintf("\tTest value + gender\n");
    regressor_vals = double(table2array(with_jid(:, {'vals', 'gender'})));
    [res.val.masks, ...
     res.val.p_vals, ... 
     res.val.mdl, ...
     res.val.A, ...
     res.val.B] = singleDayLIMO(regressor_vals, with_jid.jids(:, jid_type), ...
                                'FitMethod', fitMethod, 'nBoot', n_boot);
    
    % Figure 4
    % pixel = age + gender [age residual analysis]
    regressor_age = double(table2array(with_jid(:, {'age', 'gender'})));
    res.residual.residual_pixel = multistageJIDResiduals(regressor_age(:, 2), regressor_age(:, 1), with_jid.jids(:, jid_type), 'FitMethod', fitMethod);
    % test = age + gender [age residual analysis]
    [res.residual.residual_test, ...
        res.residual.gender_corrected_residuals, ...
        res.residual.age_gender_mdl] = multistageFlatResiduals(regressor_age(:, 2), regressor_age(:, 1), regressor_vals(:, 1), 'FitMethod', fitMethod);
    [res.residual.mask, ...
        res.residual.p_vals, ...
        res.residual.F_vals, ...
        res.residual.R_vals, ...
        res.residual.R2_vals, ...
        res.residual.betas] = residualConsistency(res.residual.residual_pixel, res.residual.residual_test, 'FitMethod', fitMethod, 'nBoot', n_boot);
    
    res.age = regressor_age(:, 1);
    res.gender = regressor_age(:, 2);
    res.vals = regressor_vals(:, 1);
    all_corsi{1, jid_type} = res;
end

save(['all_corsi_log_', version], 'all_corsi')

%% 2back

% data_proc_2back = extractSingleJIDFromTestTime(taps_tests, "2back", 10);
% data_proc_2back = data_proc_2back(data_proc_2back.gender == 1 | data_proc_2back.gender == 2, :);
%%
all_2back = cell(1, 4);
th_2back = 30; % at least 1 block

for jid_type = 1:4
    fprintf("Doing 2-BACK with JID %d\n", jid_type);
    with_jid = data_proc_2back(~cellfun('isempty', data_proc_2back.jids(:, jid_type)), :);
    
    with_jid = with_jid(with_jid.n_presentations > th_2back, :);
    res.n_presentations = with_jid.n_presentations;
    
    fprintf("\tTest value + gender\n");
    % pixel = test + gender 
    regressor_vals = double(table2array(with_jid(:, {'vals', 'gender'})));
    regressor_vals = regressor_vals(:, [1, 3]);
    [res.val.masks, res.val.p_vals, res.val.mdl, res.val.A, res.val.B] = singleDayLIMO(regressor_vals, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);
    
    % Figure 4
    % pixel = age + gender [age residual analysis]
    regressor_age = double(table2array(with_jid(:, {'age', 'gender'})));
    res.residual.residual_pixel = multistageJIDResiduals(regressor_age(:, 2), regressor_age(:, 1), with_jid.jids(:, jid_type), 'FitMethod', fitMethod);
    % test = age + gender [age residual analysis]
    [res.residual.residual_test, ...
        res.residual.gender_corrected_residuals, ...
        res.residual.age_gender_mdl] = multistageFlatResiduals(regressor_age(:, 2), regressor_age(:, 1), regressor_vals(:, 1), 'FitMethod', fitMethod);
    [res.residual.mask, ...
        res.residual.p_vals, ...
        res.residual.F_vals, ...
        res.residual.R_vals, ...
        res.residual.R2_vals, ...
        res.residual.betas] = residualConsistency(res.residual.residual_pixel, res.residual.residual_test, 'FitMethod', fitMethod, 'nBoot', n_boot);
    
    res.age = regressor_age(:, 1);
    res.gender = regressor_age(:, 2);
    res.vals = regressor_vals(:, 1);
    
    all_2back{1, jid_type} = res;
end

save(['all_2back_log_', version], 'all_2back')

%% rtime

% data_proc_rtime = extractSingleJIDFromTestTime(taps_tests, "rtime", 10);
% data_proc_rtime = data_proc_rtime(data_proc_rtime.gender == 1 | data_proc_rtime.gender == 2, :);
%%
all_r_time = cell(2, 4);
th_rtime = [12, 24]; % at least 50% of the presentations 

for idx_val = 1:2
    for jid_type = 1:4
        fprintf("Doing RTIME (%d) with JID %d\n", idx_val, jid_type);
        with_jid = data_proc_rtime(~cellfun('isempty', data_proc_rtime.jids(:, jid_type)), :);
        
        with_jid = with_jid(with_jid.n_presentations(:, idx_val) > th_rtime(idx_val), :);
        res.n_presentations = with_jid.n_presentations;
        
        fprintf("\tTest value + gender\n");
        % pixel = test + gender 
        regressor_vals = double(table2array(with_jid(:, {'vals', 'gender'})));
        regressor_vals = regressor_vals(:, [idx_val, 3]);
        [res.val.masks, res.val.p_vals, res.val.mdl, res.val.A, res.val.B] = singleDayLIMO(regressor_vals, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);

    % Figure 4
    % pixel = age + gender [age residual analysis]
    regressor_age = double(table2array(with_jid(:, {'age', 'gender'})));
    res.residual.residual_pixel = multistageJIDResiduals(regressor_age(:, 2), regressor_age(:, 1), with_jid.jids(:, jid_type), 'FitMethod', fitMethod);
    % test = age + gender [age residual analysis]
    [res.residual.residual_test, ...
        res.residual.gender_corrected_residuals, ...
        res.residual.age_gender_mdl] = multistageFlatResiduals(regressor_age(:, 2), regressor_age(:, 1), regressor_vals(:, 1), 'FitMethod', fitMethod);
    [res.residual.mask, ...
        res.residual.p_vals, ...
        res.residual.F_vals, ...
        res.residual.R_vals, ...
        res.residual.R2_vals, ...
        res.residual.betas] = residualConsistency(res.residual.residual_pixel, res.residual.residual_test, 'FitMethod', fitMethod, 'nBoot', n_boot);
    
        res.age = regressor_age(:, 1);
        res.gender = regressor_age(:, 2);
        res.vals = regressor_vals(:, 1);
        all_r_time{idx_val, jid_type} = res;
    end
end

save(['all_rtime_log_', version], 'all_r_time')
        

%% TASK SWITCH 

% data_proc_switch = extractSingleJIDFromTestTime(taps_tests, "taskswitch", 10);
% data_proc_switch = data_proc_switch(data_proc_switch.gender == 1 | data_proc_switch.gender == 2, :);
%%
all_switch = cell(2, 4);
th_ts = 12;  % avg of 3 trials per different conditions
for idx_val = 1:2
    for jid_type = 1:4
        fprintf("Doing TASK SWITCH (%d) with JID %d\n", idx_val, jid_type);
        with_jid = data_proc_switch(~cellfun('isempty', data_proc_switch.jids(:, jid_type)), :);
        
        with_jid = with_jid(with_jid.n_presentations > th_ts, :);
        res.n_presentations = with_jid.n_presentations;
        
        fprintf("\tTest value + gender\n");
        % pixel = test + gender 
        regressor_vals = double(table2array(with_jid(:, {'vals', 'gender'})));
        regressor_vals = regressor_vals(:, [idx_val, 3]);
        [res.val.masks, res.val.p_vals, res.val.mdl, res.val.A, res.val.B] = singleDayLIMO(regressor_vals, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);

    % Figure 4
    % pixel = age + gender [age residual analysis]
    regressor_age = double(table2array(with_jid(:, {'age', 'gender'})));
    res.residual.residual_pixel = multistageJIDResiduals(regressor_age(:, 2), regressor_age(:, 1), with_jid.jids(:, jid_type), 'FitMethod', fitMethod);
    % test = age + gender [age residual analysis]
    [res.residual.residual_test, ...
        res.residual.gender_corrected_residuals, ...
        res.residual.age_gender_mdl] = multistageFlatResiduals(regressor_age(:, 2), regressor_age(:, 1), regressor_vals(:, 1), 'FitMethod', fitMethod);
    [res.residual.mask, ...
        res.residual.p_vals, ...
        res.residual.F_vals, ...
        res.residual.R_vals, ...
        res.residual.R2_vals, ...
        res.residual.betas] = residualConsistency(res.residual.residual_pixel, res.residual.residual_test, 'FitMethod', fitMethod, 'nBoot', n_boot);
    
        res.age = regressor_age(:, 1);
        res.gender = regressor_age(:, 2);
        res.vals = regressor_vals(:, 1);
        
        all_switch{idx_val, jid_type} = res;
    end
end

save(['all_switch_log_', version], 'all_switch')


%% MUTLIVARIATE MODEL

% data_proc_all_tests = extractSingleJIDForAllTests(taps_tests, 10);
%%
all_multitest = cell(1, 4);

for jid_type = 1:4
    fprintf("Doing MULTI with JID %d\n", jid_type);
    with_jid = data_proc_all_tests(~cellfun('isempty', data_proc_all_tests.jids(:, jid_type)), :);
    
    with_jid = with_jid(with_jid.n_presentations(:, 1) > th_rtime(1) & ...
                        with_jid.n_presentations(:, 2) > th_rtime(2) & ... 
                        with_jid.n_presentations(:, 3) > th_2back & ...
                        with_jid.n_presentations(:, 4) > th_corsi & ...
                        with_jid.n_presentations(:, 5) > th_ts ...
                        , :);
                    
    res.n_presentations = with_jid.n_presentations;
    
    fprintf("\tTest value + gender\n");
    % pixel = tests + gender 
    regressor_vals = double(table2array(with_jid(:, {'vals', 'gender'})));
    [res.val.masks, res.val.p_vals, res.val.mdl, res.val.A, res.val.B] = singleDayLIMO(regressor_vals, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);
    
    all_multitest{1, jid_type} = res;
end

save(['all_multitest_log_', version], 'all_multitest')



