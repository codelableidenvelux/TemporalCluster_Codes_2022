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

taps_tests = fuseTapPsy();
single_jids_agestudy = extractSingleJID(taps_tests);

%% unite

all_single_jids_age = vertcat(single_jids_agestudy, single_jids_otherstudies);

%% age 
% all_age = cell(1, 4);

for jid_type = 4:4
    fprintf("Doing AGE with JID %d\n", jid_type);
    with_jid = all_single_jids_age(~cellfun('isempty', all_single_jids_age.jids(:, jid_type)), :);
    [res.mask, res.p_vals, res.M, res.P, res.R2, res.A, res.B, res.Betas] = singleDayLIMO(with_jid.age(:, 1), with_jid.jids(:, jid_type));
    all_age{1, jid_type} = res;
end

save('all_age_log_NORM_v2', 'all_age')

%% including gender

all_single_jids_age_gender = vertcat(single_jids_agestudy_mf, single_jids_otherstudies_mf);
all_single_jids_age_gender_mf = all_single_jids_age_gender(all_single_jids_age_gender.gender == 1 | all_single_jids_age_gender.gender == 2, :);


all_age_gender = cell(1, 4);

for jid_type = 1:4
    fprintf("Doing AGE with JID %d\n", jid_type);
    with_jid = all_single_jids_age_gender_mf(~cellfun('isempty', all_single_jids_age_gender_mf.jids(:, jid_type)), :);
    regressor = table2array(with_jid(:, {'age', 'gender'}));
   
    [res.mask, res.p_vals, res.mdl] = singleDayLIMO(regressor, with_jid.jids(:, jid_type));
    all_age{1, jid_type} = res;
end

save('all_age_gender_log_NORM', 'all_age_gender')
