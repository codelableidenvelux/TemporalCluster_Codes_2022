function outdata = extractSingleJID(indata, varargin)

p = inputParser;
addRequired(p,'indata');
addOptional(p,'Norm', true);

parse(p, indata, varargin{:});

norm = p.Results.Norm;

filtered_data = indata(~cellfun('isempty', indata{:, 'Phone'}), :);

all_data_proc = cell2table(cell(0, 5), 'VariableNames', {'partId', 'jids', 'age', 'n_taps', 'gender'});

K = height(filtered_data);

for id_ = 1:K
    data_ = filtered_data(id_, :);
    fprintf("Doing %d/%d (%s)\n", id_, K, data_.partId{1});
    
    SUB = data_{1, 'Phone'}{1};
    birthdate = data_{1, 'birthdate'};
    gender = data_{1, 'gender'};

    all_jids = cell(1, 4);
    n_taps = 0;

    win_taps = SUB.taps;
    if sum(win_taps.tapsSession) >= 100
        all_jids{1, 1} = FullJID(win_taps.taps, 'Norm', norm);
        all_jids{1, 2} = LauncherJID(win_taps, SUB.apps, 'Norm', norm);
        all_jids{1, 3} = SocialJID(win_taps, SUB.apps, 'Norm', norm);
        all_jids{1, 4} = TransitionJID(win_taps, SUB.apps, 'Norm', norm);
        n_taps = sum(win_taps.tapsSession);
        last_tap = datetime(SUB.taps.stop(end) / 1000, 'ConvertFrom', 'epochtime');
        age = int32(years(last_tap - birthdate));
    end
        
        all_data_proc = [all_data_proc; {data_.partId(1) ...
        all_jids ...
        [age] ...
        n_taps ...
        gender}];

end

outdata = all_data_proc;