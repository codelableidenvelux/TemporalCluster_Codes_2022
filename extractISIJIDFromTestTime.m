function outdata = extractISIJIDFromTestTime(indata, testName, window)

filtered_data = indata(~cellfun('isempty', indata{:, testName}) & ...
                       ~cellfun('isempty', indata{:, 'Phone'}), :);

all_data_proc = cell2table(cell(0, 11), 'VariableNames', {'partId', 'psyId', 'testName', 'session', 'jids', 'vals', 'n_taps', 'age', 'gender', 'n_presentations', 'n_days'});

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
    birthdate = data_{1, 'birthdate'}{1};
    gender = data_{1, 'gender'}{1};
    
    if ~isfield(test_data, 'session')
        fprintf("\tTest is empty...jump\n")
        continue
    end
    
    fprintf("\tExtracting %d sessions\n", length(test_data.session));
    % get each session separately
    for i = 1:length(test_data.session)
        if strcmp(testName, 'sf36')
            response = str2num(char(test_data.session{1,i}.surveydata(2:37)));
            if length(response) ~= 36
                continue
            end
        elseif i ~= 1
            continue
        end
        fprintf("\t\tSession %d/%d\n", i, length(test_data.session));
        start_time = posixtime(test_data.session{1, i}.TIME_start) * 1000;
        all_jids = cell(1, 4);
        n_taps = 0;
        n_days = 0;

        win_taps = SUB.taps((SUB.taps.start >= start_time + begin) & (SUB.taps.stop <= start_time + ending), :);
        if height(win_taps) >= 5
            all_jids{1, 1} = InterSessionJID(win_taps, 'Norm', true);
            n_taps = sum(win_taps.tapsSession);
            last_tap = datetime(SUB.taps.stop(end) / 1000, 'ConvertFrom', 'epochtime');
            age = int32(years(last_tap - birthdate));
            n_days = double(int32((win_taps.stop(end) - win_taps.start(1)) / 1000 / 3600 / 24));
        end
        
        

    
        switch testName

            case "rtime"
                [sRT, cRT] = getpsytoolkitDLRT(test_data.session{1, i}.vals); 

                if (length(sRT) < 2) || (length(cRT)) < 2
                    continue
                end
                values = [median(sRT), median(cRT(:, 1))];
                n_presentations = [length(sRT), length(cRT(:, 1))];
                
            case "2back"
                [Dprime, pHit, pFA, Nhits, Nmiss, NfA, NCorRej, RThits, RTfalseA] = getpsytoolkit2Back(test_data.session{1, i}.vals);
                
                if ~isfield(Dprime, 'dpri') || (length(RThits)) < 2
                    continue
                end
                
                values = [Dprime.dpri, median(RThits)];
                n_presentations = [Nhits + Nmiss + NfA + NCorRej];
            case "taskswitch"
                [Same, Mixed] = getpsytoolkitswitch(test_data.session{1, i}.vals);
                
                SameRT = [median(Same.color.RT_correct(:,1))+median(Same.shape.RT_correct(:,1))]/2;
                MixedRT = median([Mixed.RT_correct_switch(:,1); Mixed.RT_correct_noswitch(:,1)]);

                GlobalCostRT_norm = [(MixedRT-SameRT)/SameRT];
                GlobalCostRT = [(MixedRT-SameRT)];

                SwitchRT = median(Mixed.RT_correct_switch(:,1));
                NonSwitchRT = median(Mixed.RT_correct_noswitch(:,1)); 

                LocalCostRT_norm = (SwitchRT-NonSwitchRT)/NonSwitchRT; 
                LocalCostRT = (SwitchRT-NonSwitchRT); 
                
%                 values = [GlobalCostRT_norm, GlobalCostRT, LocalCostRT_norm, LocalCostRT];
                values = [GlobalCostRT_norm, LocalCostRT_norm];
                n_presentations = [length(Same.color.RT_correct(:,1)) + length(Same.shape.RT_correct(:,1)) ...
                                   + length(Mixed.RT_correct_switch(:,1)) + length(Mixed.RT_correct_noswitch(:,1))];
                
            case "corsi"
                [Cspan, ~, Tpresented] = getpsytoolkitcorsi(test_data.session{1, i}.vals);
                if isempty(Cspan)
                    continue
                end
                values = Cspan;
                n_presentations = [Tpresented];
                
            case "sf36"
                response = str2num(char(test_data.session{1,i}.surveydata(2:37)));
                [PCS, MCS] = score_sf36_rand36(response);
                values = [PCS, MCS];
                n_presentations = [1];

        end
        
        all_data_proc = [all_data_proc; 
                        {data_.partId{1} ...
                        data_.psyId{1} ...
                        testName ...
                        i ...
                        all_jids ...
                        values ...
                        n_taps ...
                        age ...
                        gender...
                        n_presentations ...
                        n_days}
            ];

        
    end
    
end

outdata = all_data_proc;