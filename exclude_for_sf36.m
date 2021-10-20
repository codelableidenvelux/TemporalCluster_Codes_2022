% let's score some sf36 vals
[psyid, Data]=getpsytoolkitsurvy('/media/Storage/AgestudyNL/Psytoolkit/', 'sf36');
scores_table = cell2table(cell(0, 3), 'VariableNames', {'psyid', 'PCS', 'MCS'});
for i = 1:length(Data)
    sessions = Data{i, 1}.session;
    for j = 1:length(sessions)
        response = str2num(char(sessions{1,j}.surveydata(2:37)));
        if length(response) == 36
            [PCS, MCS] = score_sf36_rand36(response);
            scores_table = [scores_table; {psyid(i), PCS, MCS}];
            continue
        end
    end
end

excluded_psyid = scores_table.psyid((scores_table.PCS < 50) | (scores_table.MCS < 50));

%% 

subplot(1,2,1)
% histogram(scores_table.PCS)
cdfplot(scores_table.PCS)
title('PCS')

subplot(1,2,2)
% histogram(scores_table.MCS)
cdfplot(scores_table.MCS)
title('MCS')

%%
prc25MCS = prctile(scores_table.MCS, 10);
prc25PCS = prctile(scores_table.PCS, 10);

length(scores_table.MCS(scores_table.PCS < 50))

%%

data_sf36_iti = extractSingleJIDFromTestTime(taps_tests, "sf36", 1000);
data_sf36_isi = extractISIJIDFromTestTime(taps_tests, "sf36", 1000);

%%
% v9  ITI JID
% v10 ISI JID
fitMethod = 'IRLS';
version = 'v10_IRLS';
n_boot = 1000;
multiWaitbar('CLOSEALL');
th_days = 7;
data_sf36_isi = data_sf36_isi(data_sf36_isi.n_days > th_days, :);

data_sf36 = data_sf36_isi(data_sf36_isi.gender == 1 | data_sf36_isi.gender == 2, :);

%%

all_sf36 = cell(1, 4);

for idx_val = 1:2
    for jid_type = 1:1
        clear res
        fprintf("Doing SF36 (%d) with JID %d\n", idx_val, jid_type);
        with_jid = data_sf36(~cellfun('isempty', data_sf36.jids(:, jid_type)), :);
        
        res.n_presentations = with_jid.n_presentations;
        
        fprintf("\tTest value + gender\n");
        % pixel = test + gender 
        regressor_vals = double(table2array(with_jid(:, {'vals', 'gender'})));
        regressor_vals = regressor_vals(:, [idx_val, 3]);
        [res.val.masks, res.val.p_vals, res.val.mdl, res.val.A, res.val.B] = singleDayLIMO(regressor_vals, with_jid.jids(:, jid_type), 'FitMethod', fitMethod, 'nBoot', n_boot);

    
        all_sf36{idx_val, jid_type} = res;
    end
end

save(['all_sf36_real_log_ISI_full_', version], 'all_sf36')
