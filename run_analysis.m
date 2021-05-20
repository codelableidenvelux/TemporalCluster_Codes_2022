%% data and ids from psy tests

[psyid_r_time, Data_r_time] = getpsytoolkitdata('/media/Storage/AgestudyNL/', 'R_TIME');
[psyid_2_back, Data_2_back] = getpsytoolkitdata('/media/Storage/AgestudyNL/', '2_Back');
[psyid_task_switch, Data_task_switch] = getpsytoolkitdata('/media/Storage/AgestudyNL/', 'TaskSwitch');
[psyid_corsi, Data_corsi] = getpsytoolkitdata('/media/Storage/AgestudyNL/', 'CORSI');


%% connect ids

demoinfo = readtable('/media/Storage/AgestudyNL/Psytoolkit/DemoInfo/session_info.csv', 'Delimiter', ',');
all_part_id = demoinfo.participation_id;

% ll = cellfun(@(c)strcmp(c, all_part_id), devPartIds, 'UniformOutput', false);
all_Data_ids = cell(length(all_part_id), 7);


for i = 1:length(all_part_id)
    part_id = all_part_id{i};
    psyid_ = qaid2psyid(part_id);
    
    
    id_r_time = psyid_r_time(contains(psyid_r_time, psyid_));
    id_2_back = psyid_2_back(contains(psyid_2_back, psyid_));
    id_task_switch = psyid_task_switch(contains(psyid_task_switch, psyid_));
    id_corsi = psyid_r_time(contains(psyid_corsi, psyid_));
    
    all_Data_ids{i, 1} = part_id;
    all_Data_ids{i, 2} = psyid_;
    if ~isempty(id_r_time)
        all_Data_ids{i, 3} = Data_r_time{contains(psyid_r_time, psyid_)};
    end
    if ~isempty(id_2_back)
        all_Data_ids{i, 4} = Data_2_back{contains(psyid_2_back, psyid_)};
    end
    if ~isempty(id_task_switch)
        all_Data_ids{i, 5} = Data_task_switch{contains(psyid_task_switch, psyid_)};
    end
    if ~isempty(id_corsi)
        all_Data_ids{i, 6} = Data_corsi{contains(psyid_corsi, psyid_)};
    end
    
    kk_ = all_Data_ids(i, 1:6);
    all_Data_ids{i, 7} = length(kk_(~cellfun('isempty', kk_))) - 2;
end

%% filter out
rtime = all_Data_ids(:, 3);
rtime = rtime(~cellfun('isempty', rtime));

back2 = all_Data_ids(:, 4);
back2 = back2(~cellfun('isempty', back2));

taskswitch = all_Data_ids(:, 5);
taskswitch = taskswitch(~cellfun('isempty', taskswitch));

corsi = all_Data_ids(:, 6);
corsi = corsi(~cellfun('isempty', corsi));

%% taps

for i = 1:length(all_part_id)
    fprintf("Doing %d/%d (%s)\n", i, length(all_part_id), all_part_id{i});
    SUB = getTapDataParsed(all_part_id{i}, 'Phone', 'refresh', 1);
end

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

for i = 1:height(first_attempt) % only chech normal JID for now
    sub = first_attempt.jids{i};
    jid_ = sub(:, 1);
    bin_index(i) = length(jid_(~cellfun('isempty', jid_))) == 15;   
end

with_all_days = first_attempt(bin_index, :);

A = zeros(height(with_all_days), 15, 50, 50);
B = ones(height(with_all_days), 2);
B(:, 1) = with_all_days.vals(:, 1);
for i = 1:height(with_all_days)
    for j = 1:15
        A(i, j, :, :) = with_all_days.jids{i}{j, 1};
    end
end
size(A)

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

