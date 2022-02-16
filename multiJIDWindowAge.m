function outdata = multiJIDWindow(indata, varargin)


% Enea Ceolini, Leiden University, 17/09/2021

p = inputParser;
addRequired(p,'indata');
addOptional(p,'Norm', true);
addOptional(p,'Window', 7); 

parse(p, indata, varargin{:});

norm = p.Results.Norm;
n_days_win = p.Results.Window;
length_win = n_days_win * 24 * 3600 * 1000;

filtered_data = indata(~cellfun('isempty', indata{:, 'Phone'}), :);

all_data_proc = cell2table(cell(0, 8), 'VariableNames', {'partId', 'jids', 'n_taps', 'age', 'gender', 'entropy', 'usage', 'ndays'});

K = height(filtered_data);

for id_ = 1:K
    data_ = filtered_data(id_, :);
    fprintf("Doing %d/%d (%s)\n", id_, K, data_.partId{1});
    
    SUB = data_{1, 'Phone'}{1};
    
    age = data_{1, 'age'};
    gender = data_{1, 'gender'};
    
    first_event = datetime(SUB.taps.start(1) / 1000, 'ConvertFrom', 'epochtime');
    last_event = datetime(SUB.taps.stop(end) / 1000, 'ConvertFrom', 'epochtime');
    total_days = floor(days(last_event - first_event));
    
    n_win = floor(total_days / n_days_win);
    
    if mod(total_days, n_days_win) >= 7
        n_win = n_win + 1;
    end
    
    
    all_jids = [];
    all_n_taps = [];
    all_ages = [];
    all_genders = [];
    all_med_usage = [];
    all_entropy = [];
    all_ndays = [];
   
    for this_win = 1:n_win
    
        win_taps = SUB.taps((SUB.taps.start >= SUB.taps.start(1) + (this_win - 1) * length_win) & (SUB.taps.start < SUB.taps.start(1) + (this_win) * length_win), :);

        if length(cell2mat(win_taps.taps)) >= 100
            
            % median usage
            start_time = win_taps.start(1);
            n_days = double(int32((win_taps.stop(end) - win_taps.start(1)) / 1000 / 3600 / 24));
            count_days = zeros(n_days, 1); 
            for i = 1:n_days
                count_days(i) = sum(win_taps((win_taps.start >= (i - 1) * 1000.0 * 3600 * 24 + start_time) & (win_taps.start < i * 1000.0 * 3600 * 24 + start_time), :).tapsSession);
            end
            med_usage = median(count_days(count_days > 0));
            
            % JID
            this_jid = FullJID(win_taps.taps, 'Norm', norm);
            
            % entropy
            entropy = JID_entropy(this_jid);
            
            this_n_taps = sum(win_taps.tapsSession);
            last_tap = datetime(win_taps.stop(end) / 1000, 'ConvertFrom', 'epochtime');
            all_jids = cat(3, all_jids, this_jid);
            all_n_taps = [all_n_taps, this_n_taps];
            all_ages = [all_ages, age];
            all_genders = [all_genders, gender];
            all_med_usage = [all_med_usage, med_usage];
            all_entropy = [all_entropy, entropy];
            all_ndays = [all_ndays, n_days];
        end
    
    end
        
        all_data_proc = [all_data_proc; {data_.partId(1) ...
        all_jids ...
        all_n_taps' ...
        all_ages' ...
        all_genders' ...
        all_entropy' ...
        all_med_usage' ...
        all_ndays'}];

end

outdata = all_data_proc;