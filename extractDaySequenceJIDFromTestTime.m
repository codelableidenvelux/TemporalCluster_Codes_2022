function outdata = extractDaySequenceJIDFromTestTime(indata, testName, window)

filtered_data = indata(~cellfun('isempty', indata{:, testName}) & ...
                       ~cellfun('isempty', indata{:, 'Phone'}), :);

all_data_proc = cell2table(cell(0, 7), 'VariableNames', {'partId', 'psyId', 'testName', 'session', 'jids', 'vals', 'n_taps'});

totalDays = window * 2 + 1;
half_way = window + 1;

windows = ((0:24:24 * totalDays) - 24 * half_way + 12) * 3600 * 1000;

for id_ = 1:length(indata)
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
        all_jids = cell(totalDays, 4);
        n_taps = cell(totalDays, 1);
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
                n_taps{w} = sum(win_taps.tapsSession);
            end
        end
        fprintf('\n');
        
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