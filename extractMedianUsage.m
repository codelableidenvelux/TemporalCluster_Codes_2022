function outdata = extractMedianUsage(indata)

filtered_data = indata(~cellfun('isempty', indata{:, 'Phone'}), :);

all_data_proc = cell2table(cell(0, 5), 'VariableNames', {'partId', 'median(usage)', 'age', 'n_taps', 'gender'});

K = height(filtered_data);

for id_ = 1:K
    data_ = filtered_data(id_, :);
    fprintf("Doing %d/%d (%s)\n", id_, K, data_.partId{1});
    
    SUB = data_{1, 'Phone'}{1};
    birthdate = data_{1, 'birthdate'};
    gender = data_{1, 'gender'};

    taps = SUB.taps;
    
    start_time = SUB.taps.start(1);
    n_days = double(int32((SUB.taps.stop(end) - SUB.taps.start(1)) / 1000 / 3600 / 24));
    count_days = zeros(n_days, 1);
    
    for i = 1:n_days
        count_days(i) = sum(taps((taps.start >= (i - 1) * 1000.0 * 3600 * 24 + start_time) & (taps.start < i * 1000.0 * 3600 * 24 + start_time), :).tapsSession);
    end
    
    med_usage = median(count_days(count_days > 0));
    
    n_taps = sum(taps.tapsSession);
    last_tap = datetime(SUB.taps.stop(end) / 1000, 'ConvertFrom', 'epochtime');
    age = int32(years(last_tap - birthdate));
    
    all_data_proc = [all_data_proc; {data_.partId(1) ...
    med_usage ...
    [age] ...
    n_taps ...
    gender}];

end

outdata = all_data_proc;