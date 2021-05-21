%% load data

taps_tests = fuseTapPsy();


%% CORSI
% all_data_proc_corsi = extractSingleJIDFromTestTime(taps_tests, "corsi", 10);
% first_attempt_corsi = all_data_proc_corsi(all_data_proc_corsi.session == 1, :);

all_corsi = cell(1, 4);
% make sure the JID exists
for idx_val = 1:1
    for jid_type = 1:4
        fprintf("Doing val %d with JID %d\n", idx_val, jid_type);
        with_jid = first_attempt_corsi(~cellfun('isempty', first_attempt_corsi.jids(:, jid_type)), :);
        [res.mask, res.p_vals, res.M, res.P, res.R2, res.A, res.B, res.Betas] = singleDayLIMO(with_jid.vals(:, idx_val), with_jid.jids(:, jid_type));
        all_corsi{idx_val, jid_type} = res;
    end
end
save('all_corsi_log', 'all_corsi')

% 2back

all_data_proc_2back = extractSingleJIDFromTestTime(taps_tests, "2back", 10);
first_attempt_2back = all_data_proc_2back(all_data_proc_2back.session == 1, :);

all_2back = cell(2, 4);
% make sure the JID exists
for idx_val = 1:2
    for jid_type = 1:4
        fprintf("Doing val %d with JID %d\n", idx_val, jid_type);
        with_jid = first_attempt_2back(~cellfun('isempty', first_attempt_2back.jids(:, jid_type)), :);
        [res.mask, res.p_vals, res.M, res.P, res.R2, res.A, res.B, res.Betas] = singleDayLIMO(with_jid.vals(:, idx_val), with_jid.jids(:, jid_type));
        all_2back{idx_val, jid_type} = res;
    end
end
save('all_2back_log', 'all_2back')

% rtime

all_data_proc_rtime = extractSingleJIDFromTestTime(taps_tests, "rtime", 10);
first_attempt_rtime = all_data_proc_rtime(all_data_proc_rtime.session == 1, :);

all_r_time = cell(2, 4);
% make sure the JID exists
for idx_val = 1:2
    for jid_type = 1:4
        fprintf("Doing val %d with JID %d\n", idx_val, jid_type);
        with_jid = first_attempt_rtime(~cellfun('isempty', first_attempt_rtime.jids(:, jid_type)), :);
        [res.mask, res.p_vals, res.M, res.P, res.R2, res.A, res.B, res.Betas] = singleDayLIMO(with_jid.vals(:, idx_val), with_jid.jids(:, jid_type));
        all_r_time{idx_val, jid_type} = res;
    end
end

save('all_rtime_log', 'all_r_time')
        

% TASK SWITCH 

all_data_proc_switch = extractSingleJIDFromTestTime(taps_tests, "taskswitch", 10);
first_attempt_switch = all_data_proc_switch(all_data_proc_switch.session == 1, :);

all_switch = cell(2, 4);
% make sure the JID exists
for idx_val = 1:4
    for jid_type = 1:4
        fprintf("Doing val %d with JID %d\n", idx_val, jid_type);
        with_jid = first_attempt_switch(~cellfun('isempty', first_attempt_switch.jids(:, jid_type)), :);
        [res.mask, res.p_vals, res.M, res.P, res.R2, res.A, res.B, res.Betas] = singleDayLIMO(with_jid.vals(:, idx_val), with_jid.jids(:, jid_type));
        all_switch{idx_val, jid_type} = res;
    end
end

save('all_switch_log', 'all_switch')

%% RTIME - multiDay

all_data_proc_rtime = extractDaySequenceJIDFromTestTime(taps_tests, "rtime", 7);


%% cross all single JIDS with all tests 

%% some exp rtime

all_data_proc = cell2table(cell(0, 7), 'VariableNames', {'partId', 'psyId', 'testName', 'session', 'jids', 'vals', 'n_taps'});
count = 1;

windows = ((0:24:24 * 15) - 24 * 8 + 12) * 3600 * 1000;
for id_ = 1:length(all_Data_ids)
    data_ = all_Data_ids(id_, :);
    fprintf("Doing %s\n", data_{1});
    rtime = data_{3};
    
    SUB = getTapDataParsed(data_{1}, 'Phone', 'refresh', 0);
    if isempty(SUB) || isempty(rtime)
        fprintf("\tTaps or test is empty...jump\n")
        continue
    end
    
    if ~isfield(rtime, 'session')
        fprintf("\tTest is empty...jump\n")
        continue
    end
    
    taps = double(cell2mat(SUB.taps.taps));
    fprintf("\tExtracting %d sessions\n", length(rtime.session));
    % get each session separately
    for i = 1:length(rtime.session)
        fprintf("\t\tSession %d/%d\n", i, length(rtime.session));
        start_time = posixtime(rtime.session{1, i}.TIME_start) * 1000;
        all_jids = cell(15, 5);
        n_taps = cell(15, 1);
        % need to get JID for -7 + 7
        fprintf("\t\t\tExtracting Day");
        for w = 1:length(windows) - 1
            fprintf("%d", w - 8);
            start_window = windows(w);
            stop_window = windows(w + 1);
            win_taps = SUB.taps((SUB.taps.start >= start_time + start_window) & (SUB.taps.stop <= start_time + stop_window), :);
            if sum(win_taps.tapsSession) >= 100
                all_jids{w, 1} = FullJID(win_taps.taps);
                all_jids{w, 2} = LauncherJID(win_taps, SUB.apps);
                all_jids{w, 3} = SocialJID(win_taps, SUB.apps);
                all_jids{w, 4} = TransitionJID(win_taps, SUB.apps);
                all_jids{w, 5} = FullJID(win_taps.taps, 'WithinSession', false);
                n_taps{w} = sum(win_taps.tapsSession);
            end
        end
        fprintf('\n');
        
        [sRT, cRT] = getpsytoolkitDLRT(rtime.session{1, i}.vals); 
        
        if (length(sRT) < 2) || (length(cRT)) < 2
            continue
        end
        
        all_data_proc = [all_data_proc; 
            {data_{1} ...
                                    data_{2} ...
                                    "r-time" ...
                                    i ...
                                    all_jids ...
                                    [median(sRT), median(cRT(:, 1))] ...
                                    n_taps}
            ];

        count = count + 1;
        
    end
    
end

%% check how many we have at first try
first_attempt = all_data_proc(all_data_proc.session == 1, :);

bin_index = logical(zeros(height(first_attempt)));
bin_atleastone = logical(zeros(height(first_attempt)));

for i = 1:height(first_attempt) % only chech normal JID for now
    sub = first_attempt.jids{i};
    jid_ = sub(:, 1);
    bin_index(i) = length(jid_(~cellfun('isempty', jid_))) == 15;  
    bin_atleastone(i) = length(jid_(~cellfun('isempty', jid_))) > 0; 
end

with_all_days = first_attempt(bin_index, :);
with_ateastone = first_attempt(bin_atleastone, :);

%% LIMO MEAN
% single JIDS each person -> all variations of JID (4) for all tests (5);

% redo JIDS with full 30 days window 
%% LIMO DAYS
n_subs = height(with_all_days);
n_ch = 2500;
n_time = 15;

A = zeros(n_subs, n_time, 50, 50);
B = ones(height(with_all_days), 2);
B(:, 1) = with_all_days.vals(:, 2);
for i = 1:height(with_all_days)
    for j = 1:n_time
        A(i, j, :, :) = with_all_days.jids{i}{j, 1};
    end
end

A = reshape(A, n_subs, n_time, n_ch);

%% LIMO
n_boot = 100;
boot_data = permute(A, [3 2 1]); % zeros(n_ch, n_time, n_subs);  % channels, times, individuals
boot_table = limo_create_boot_table(boot_data, n_boot);

M = zeros(n_ch, n_time, 1);  % channels, times, rtime  F scores
P = zeros(n_ch, n_time, 1);  %  P scores
R2 = zeros(n_ch, n_time, 1);

bootM = zeros(n_ch, n_time, n_boot); % channels, times, rtime, nboot
bootP = zeros(n_ch, n_time, n_boot); % channels, times, rtime, nboot

for ch = 1:n_ch  % all channels separately
    Y = A(:, :, ch); % zeros(163, 15);
    X = B; % ones(163, 2);
    model = limo_glm(Y, X, 0, 0, 1, 'OLS', 'Time', 0, n_time);
    
    model_boot = limo_glm_boot(Y,X, model.W,0,0,1,'OLS','Time',boot_table{1, ch});
    
    M(ch, :, :) = model.F;
    P(ch, :, :) = model.p;
    R2(ch, :, :) = model.R2_univariate;
    
    for j = 1:n_boot
        bootM(ch, :, j) = model_boot.F{j};
        bootP(ch, :, j) = model_boot.p{j};
    end
    
end

% cluster

nM = find_adj_matrix(50, 1);
MCC = 2;
p = 0.05;

% got rid of a stupid error check: whatever! line 53 of limo_cluster_correction
% [mask, p_vals] = limo_cluster_correction(M, P, bootM, bootP, nM, MCC, p);
[mask2, p_vals2] = limo_cluster_correction(M(:, 1), P(:, 1), bootM(:, 1, :), bootP(:, 1, :), nM, MCC, p);


%% PLOT

%% LASSO
S = std(X, 1);
S0 = S;
S0(S < 0.1) = 0;
X0 = X .* S0;

[B, fitInfo] = lasso(X0, y, 'CV', 10);

A = X0 * B + fitInfo.Intercept;

plot(A(:, 10), 'x')
hold on
plot(y, 'o')
    

%% LIMO

% first step
Y = zeros(163, 15);
X = ones(163, 2);
model = limo_glm(Y, X, 0, 0, 1, 'OLS', 'Time', 0, 15);

% bootstrap
data = zeros(2500, 15, 163);  % channels, times, individuals
boot_table = limo_create_boot_table(data,10);
% remember to slice the boot table
% and figure ouit the nboot
model_boot = limo_glm_boot(Y,X,model.W,0,0,1,'OLS','Time',boot_table{1, 1});

% cluster
M = zeros(2500, 15, 1);  % channels, times, rtime
P = zeros(2500, 15, 1);  % 

bootM = zeros(2500, 15, 10); % channels, times, rtime, nboot
bootP = zeros(2500, 15, 10); % channels, times, rtime, nboot
nM = zeros(2500, 2500);
MCC = 2;
p = 0.05;

% got rid of a stupid error check: whatever! line 53 of limo_cluster_correction
[mask, p_vals] = limo_cluster_correction(M, P, bootM, bootP, nM, MCC, p);

% only for thresholding and only 1 time point
[mask2, p_vals2] = limo_cluster_correction(M(:, 1), P(:, 1), bootM(:, 1, :), bootP(:, 1, :), nM, MCC, p);
th = limo_ecluster_make(bootM(:, 1, :),bootP(:, 1, :), 0.05);



