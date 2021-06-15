%% Hyperparams

fitMethod = 'OLS';
version = 'v4';

%% Age analysis 

opts = detectImportOptions('MASS_Subject_list.xlsx','NumHeaderLines', 3);
T = readtable('MASS_Subject_list.xlsx',opts);

T = T(:, {'Var4', 'Var5', 'Var9'});
T.Properties.VariableNames = {'birthdate', 'gender', 'partId'};

%%
T2 = T(~isnat(T.birthdate), :);
T2.Phone = cell(height(T2), 1);

for i = 1:height(T2)
    SUB = getTapDataParsed(T2.partId{i}, 'refresh', 0);
    if ~isempty(SUB)
       T2.Phone{i} = SUB; 
    end
end

%% JIDS

single_jids_otherstudies = extractSingleJID(T2);

%% age study 

% taps_tests = fuseTapPsy();
single_jids_agestudy = extractSingleJID(taps_tests);


%% including gender
all_single_jids_age = vertcat(single_jids_agestudy, single_jids_otherstudies);
all_single_jids_age_gender_mf = all_single_jids_age(all_single_jids_age.gender == 1 | all_single_jids_age.gender == 2, :);

all_age_gender = cell(1, 4);
%%
for jid_type = 1:4
    multiWaitbar( 'JIDs', jid_type/4, 'Color', [0.8 0.0 0.1]);
    fprintf("Doing AGE with JID %d\n", jid_type);
    with_jid = all_single_jids_age_gender_mf(~cellfun('isempty', all_single_jids_age_gender_mf.jids(:, jid_type)), :);
    regressor = table2array(with_jid(:, {'age', 'gender'}));
   
    [res.val.mask, ...
        res.val.p_vals, ...
        res.val.mdl, ...
        res.val.A, ...
        res.val.B] = singleDayLIMO(regressor, with_jid.jids(:, jid_type), 'FitMethod', fitMethod);
    
    all_R_a = multistageJIDResiduals(double(regressor(:, 2)), double(regressor(:, 1)), with_jid.jids(:, jid_type), 'FitMethod', fitMethod);
    [res.residual.mask, ...
        res.residual.p_vals, ...
        res.residual.F_vals, ...
        res.residual.R_vals, ...
        res.residual.R2_vals, ...
        res.residual.betas] = residualSelfCoherence(all_R_a, 'FitMethod', fitMethod);
    res.residual.all_R = all_R_a;
    
    res.age = regressor(:, 1);
    res.gender = regressor(:, 2);

    all_age_gender{1, jid_type} = res;
end

save(['all_age_gender_log_', version], 'all_age_gender')


