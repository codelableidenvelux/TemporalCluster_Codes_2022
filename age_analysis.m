% Enea Ceolini, Leiden University, 26/05/2021
%% Hyperparameters

fitMethod = 'IRLS';  % Robust options, could be OLS.
version = 'v13_IRLS'; % Just to keep track of analysis version in case of updates.
n_boot = 1000;  % Number of repetitions for bootsrap.  

%% Load data
load('all_single_jids_age_gender_mf_th_v13.mat')

%% Save extra info 
with_jid = all_single_jids_age_gender_mf_th(~cellfun('isempty', all_single_jids_age_gender_mf_th.jids(:, 1)), :);
only_info = with_jid(:, {'partId', 'age', 'n_taps', 'gender', 'n_days'});

writetable(only_info, sprintf('only_info_figure_1_%s.csv', version))

%% Age Analysis

all_age_gender = cell(1, 4);

for jid_type = 1:4
    clear res
    multiWaitbar( 'JIDs', jid_type/4, 'Color', [0.8 0.0 0.1]);
    fprintf("Doing AGE with JID %d\n", jid_type);
    % make sure we only use subjects that have a valid JID
    with_jid = all_single_jids_age_gender_mf_th(~cellfun('isempty', all_single_jids_age_gender_mf_th.jids(:, jid_type)), :);
    regressor = double(table2array(with_jid(:, {'age', 'gender'})));
    
    % LIMO regression between all pixels of a single JID and age/gender regressors
    [res.val.mask, ...
        res.val.p_vals, ...
        res.val.mdl, ...
        res.val.A, ...
        res.val.B] = singleDayLIMO(regressor, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);
    
    % multistage analysis to extract gender-corrected age regressions
    all_R_a = multistageJIDResiduals(double(regressor(:, 2)), double(regressor(:, 1)), with_jid.jids(:, jid_type), 'FitMethod', fitMethod);
    
    % Coherence of gender-corrected age regressions between couple of pixels 
    [res.residual.mask, ...
        res.residual.p_vals, ...
        res.residual.F_vals, ...
        res.residual.R_vals, ...
        res.residual.R2_vals, ...
        res.residual.betas] = residualSelfCoherence(all_R_a, 'FitMethod', fitMethod);
    res.residual.all_R = all_R_a;
    
    % saving results
    res.age = regressor(:, 1);
    res.gender = regressor(:, 2);

    all_age_gender{1, jid_type} = res;
end

save(['all_age_gender_log_', version], 'all_age_gender')


%% Autocorrelation analysis (of each couple of pixels)

all_jid_aut = cell(1, 4);

for jid_type = 1:4
    clear res
    multiWaitbar( 'JIDs', jid_type/4, 'Color', [0.8 0.0 0.1]);
    fprintf("Doing AUT with JID %d\n", jid_type);
    with_jid = all_single_jids_age_gender_mf_th(~cellfun('isempty', all_single_jids_age_gender_mf_th.jids(:, jid_type)), :);
    regressor = double(table2array(with_jid(:, {'age', 'gender'})));
    
    jj = with_jid.jids(:, jid_type);
    jj2 = cellfun(@(x) reshape(x, 1, 2500), jj, 'UniformOutput', false);
    jj3 = cell2mat(jj2);
    jj4 = log10(jj3 + 3.1463e-12);

    % We use the same residual self-coherence function as above cause it
    % implements the same idea of pixel-to-pixel regression

    [res.self.mask, ...
        res.self.p_vals, ...
        res.self.F_vals, ...
        res.self.R_vals, ...
        res.self.R2_vals, ...
        res.self.betas] = residualSelfCoherence(jj4, 'FitMethod', fitMethod);
    
    res.all_jid = jj4;
    
    all_jid_aut{1, jid_type} = res;
end

save(['all_jid_aut_log_', version], 'all_jid_aut')