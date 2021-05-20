function outdata = extractSingleJIDFromTestTime(indata, testName, window)

filtered_data = indata(~cellfun('isempty', indata{:, testName}) & ...
                       ~cellfun('isempty', indata{:, 'Phone'}), :);

all_data_proc = cell2table(cell(0, 7), 'VariableNames', {'partId', 'psyId', 'testName', 'session', 'jids', 'vals', 'n_taps'});

totalDays = window * 2 + 1;
half_way = window + 1;

windows = ((0:24:24 * totalDays) - 24 * half_way + 12) * 3600 * 1000;

begin = windows(1);
ending = windows(end);

for id_ = 1:height(filtered_data)
    data_ = filtered_data(id_, :);
    fprintf("Doing %d/%d (%s)\n", id_, height(filtered_data), data_.partId{1});
    test_data = data_{1, testName}{1};
    
    SUB = data_{1, 'Phone'}{1};
    
    if ~isfield(test_data, 'session')
        fprintf("\tTest is empty...jump\n")
        continue
    end
    
    fprintf("\tExtracting %d sessions\n", length(test_data.session));
    % get each session separately
    for i = 1:length(test_data.session)
        fprintf("\t\tSession %d/%d\n", i, length(test_data.session));
        start_time = posixtime(test_data.session{1, i}.TIME_start) * 1000;
        all_jids = cell(1, 4);
        n_taps = 0;

        win_taps = SUB.taps((SUB.taps.start >= start_time + begin) & (SUB.taps.stop <= start_time + ending), :);
        if sum(win_taps.tapsSession) >= 100
            all_jids{1, 1} = FullJID(win_taps.taps);
            all_jids{1, 2} = LauncherJID(win_taps, SUB.apps);
            all_jids{1, 3} = SocialJID(win_taps, SUB.apps);
            all_jids{1, 4} = TransitionJID(win_taps, SUB.apps);
            n_taps = sum(win_taps.tapsSession);
        end

    
        switch testName

            case "rtime"
                [sRT, cRT] = getpsytoolkitDLRT(test_data.session{1, i}.vals); 

                if (length(sRT) < 2) || (length(cRT)) < 2
                    continue
                end
                values = [median(sRT), median(cRT(:, 1))];
                
            case "2back"
            case "taskswitch"
            case "corsi"

        end
        
        all_data_proc = [all_data_proc; 
                        {data_.partId{1} ...
                        data_.psyId{1} ...
                        testName ...
                        i ...
                        all_jids ...
                        values ...
                        n_taps}
            ];

        
    end
    
end

outdata = all_data_proc;