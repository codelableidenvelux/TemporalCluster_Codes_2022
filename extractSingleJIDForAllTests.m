function outdata = extractSingleJIDForAllTests(indata, window)

filtered_data = indata(~cellfun('isempty', indata{:, 'rtime'}) & ...
    ~cellfun('isempty', indata{:, '2back'}) & ...
    ~cellfun('isempty', indata{:, 'corsi'}) & ...
    ~cellfun('isempty', indata{:, 'taskswitch'}) & ...
    ~cellfun('isempty', indata{:, 'Phone'}), :);

all_data_proc = cell2table(cell(0, 9), 'VariableNames', {'partId', 'psyId', 'jids', 'vals', 'n_taps', 'age', 'gender', 'n_presentations', 'n_days'});

totalDays = window * 2 + 1;
half_way = window + 1;

windows = ((0:24:24 * totalDays) - 24 * half_way + 12) * 3600 * 1000;

begin = windows(1);
ending = windows(end);

for id_ = 1:height(filtered_data)
    data_ = filtered_data(id_, :);
    fprintf("Doing %d/%d (%s)\n", id_, height(filtered_data), data_.partId{1});
    
    SUB = data_{1, 'Phone'}{1};
    birthdate = data_{1, 'birthdate'};
    gender = data_{1, 'gender'};
    
    test_data_rtime = data_{1, 'rtime'}{1};
    test_data_2back = data_{1, '2back'}{1};
    test_data_corsi = data_{1, 'corsi'}{1};
    test_data_taskswitch = data_{1, 'taskswitch'}{1};
    
    if ~isfield(test_data_rtime, 'session') || ...
            ~isfield(test_data_2back, 'session') || ...
            ~isfield(test_data_corsi, 'session') || ...
            ~isfield(test_data_taskswitch, 'session')
        fprintf("\tTest(s) is (are) empty...jump\n")
        continue
    end
    
    all_jids = cell(1, 4);
    n_taps = 0;
    n_days = 0;
    
    start_time_rtime = posixtime(test_data_rtime.session{1, 1}.TIME_start) * 1000;
    start_time_2back = posixtime(test_data_2back.session{1, 1}.TIME_start) * 1000;
    start_time_corsi = posixtime(test_data_corsi.session{1, 1}.TIME_start) * 1000;
    start_time_taskswitch = posixtime(test_data_taskswitch.session{1, 1}.TIME_start) * 1000;
    
    start_time = min([start_time_rtime, start_time_2back, start_time_corsi, start_time_taskswitch]);
    stop_time = max([start_time_rtime, start_time_2back, start_time_corsi, start_time_taskswitch]);
    win_taps = SUB.taps((SUB.taps.start >= start_time + begin) & (SUB.taps.stop <= stop_time + ending), :);
    
    if sum(win_taps.tapsSession) >= 100
        all_jids{1, 1} = FullJID(win_taps.taps, 'Norm', true);
        all_jids{1, 2} = LauncherJID(win_taps, SUB.apps, 'Norm', true);
        all_jids{1, 3} = SocialJID(win_taps, SUB.apps, 'Norm', true);
        all_jids{1, 4} = TransitionJID(win_taps, SUB.apps, 'Norm', true);
        n_taps = sum(win_taps.tapsSession);
        last_tap = datetime(SUB.taps.stop(end) / 1000, 'ConvertFrom', 'epochtime');
        age = int32(years(last_tap - birthdate));
        n_days = double(int32((win_taps.stop(end) - win_taps.start(1)) / 1000 / 3600 / 24));
    end
    
    
    [sRT, cRT] = getpsytoolkitDLRT(test_data_rtime.session{1, 1}.vals);
    
    if (length(sRT) < 2) || (length(cRT)) < 2
        continue
    end
    
    n_pre_RT = [length(sRT), length(cRT(:, 1))];
    
    
    [Dprime, pHit, pFA, Nhits, Nmiss, NfA, NCorRej, RThits, RTfalseA] = getpsytoolkit2Back(test_data_2back.session{1, 1}.vals);
    
    if ~isfield(Dprime, 'dpri') || (length(RThits)) < 2
        continue
    end
    
    n_pre_2back = [Nhits + Nmiss + NfA + NCorRej];
    
    [Same, Mixed] = getpsytoolkitswitch(test_data_taskswitch.session{1, 1}.vals);
    
    SameRT = [median(Same.color.RT_correct(:,1))+median(Same.shape.RT_correct(:,1))]/2;
    MixedRT = median([Mixed.RT_correct_switch(:,1); Mixed.RT_correct_noswitch(:,1)]);
    
    GlobalCostRT_norm = [(MixedRT-SameRT)/SameRT];
%     GlobalCostRT = [(MixedRT-SameRT)];
    
    SwitchRT = median(Mixed.RT_correct_switch(:,1));
    NonSwitchRT = median(Mixed.RT_correct_noswitch(:,1));
    
    LocalCostRT_norm = (SwitchRT-NonSwitchRT)/NonSwitchRT;
%     LocalCostRT = (SwitchRT-NonSwitchRT);
    
    n_pre_TS = [length(Same.color.RT_correct(:,1)) + length(Same.shape.RT_correct(:,1)) ...
                                   + length(Mixed.RT_correct_switch(:,1)) + length(Mixed.RT_correct_noswitch(:,1))];
                
    
    [Cspan, ~, Tpresented] = getpsytoolkitcorsi(test_data_corsi.session{1, 1}.vals);
    if isempty(Cspan)
        continue
    end
    n_pre_CR = [Tpresented];
    
    values = [median(sRT), median(cRT(:, 1)), Dprime.dpri, Cspan, GlobalCostRT_norm, LocalCostRT_norm];
    n_presentations = [n_pre_RT, n_pre_2back, n_pre_CR, n_pre_TS];
    
    all_data_proc = [all_data_proc;
        {data_.partId{1} ...
        data_.psyId{1} ...
        all_jids ...
        values ...
        n_taps ...
        age ...
        gender ...
        n_presentations ...
        n_days}
        ];

end

outdata = all_data_proc;