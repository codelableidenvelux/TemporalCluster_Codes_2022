function data = fuseTapPsy(varargin)

% Enea Ceolini, Leiden University, 26/05/2021

p = inputParser;
addOptional(p, 'Refresh', false);

parse(p, varargin{:});

refresh = p.Results.Refresh;


[psyid_r_time, Data_r_time] = getpsytoolkitdata('/media/Storage/AgestudyNL/', 'R_TIME');
[psyid_2_back, Data_2_back] = getpsytoolkitdata('/media/Storage/AgestudyNL/', '2_Back');
[psyid_task_switch, Data_task_switch] = getpsytoolkitdata('/media/Storage/AgestudyNL/', 'TaskSwitch');
[psyid_corsi, Data_corsi] = getpsytoolkitdata('/media/Storage/AgestudyNL/', 'CORSI');

demoinfo = readtable('/media/Storage/AgestudyNL/Psytoolkit/DemoInfo/session_info.csv', 'Delimiter', ',');
all_part_id = demoinfo.participation_id;
all_birth = demoinfo.birthyear;
all_gender = demoinfo.gender;

all_Data_ids = cell(length(all_part_id), 10);

if refresh
    for i = 1:length(all_part_id)
        fprintf("Doing %d/%d (%s)\n", i, length(all_part_id), all_part_id{i});
        SUB = getTapDataParsed(all_part_id{i}, 'Phone', 'refresh', 1);
    end
end


for i = 1:length(all_part_id)
    part_id = all_part_id{i};
    birthdate = datetime(all_birth{i}(1:end-3), 'InputFormat', 'eee, dd MMM yyyy HH:mm:ss');
    gender = all_gender(i);
    
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
    
    SUB = getTapDataParsed(part_id, 'Phone', 'refresh', 0);
    all_Data_ids{i, 8} = SUB;
    all_Data_ids{i, 9} = birthdate;
    all_Data_ids{i, 10} = gender;
end

data = cell2table(all_Data_ids, 'VariableNames', {'partId', 'psyId', 'rtime', '2back', 'taskswitch', 'corsi', 'n_tests', 'Phone', 'birthdate', 'gender'});
