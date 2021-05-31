%% plotting % of social taps vs 2-back

% filtered_data = taps_tests(~cellfun('isempty', taps_tests{:, '2back'}) & ...
%                        ~cellfun('isempty', taps_tests{:, 'Phone'}), :);

%%
                   
all_data_proc = cell2table(cell(0, 5), 'VariableNames', {'partId', 'social_taps', 'all_taps', 'back2', 'age'});

K = height(filtered_data);

for id_ = 1:K
    data_ = filtered_data(id_, :);
    fprintf("Doing %d/%d (%s)\n", id_, K, data_.partId{1});
    
    SUB = data_{1, 'Phone'}{1};
    birthdate = data_{1, 'birthdate'};
    gender = data_{1, 'gender'};
    test_data = data_{1, '2back'}{1};

    all_jids = cell(1, 4);
    n_taps = 0;
    
    all_devId = SUB.taps.devPartId;
    unique_id = unique(all_devId);

    sep_taps = cell(length(unique_id), 1);
    sep_apps = cell(length(unique_id), 1);

    if isempty(SUB.apps)
       continue;
    end

    for i = 1:length(unique_id)
        these_taps = SUB.taps(strcmp(SUB.taps.devPartId, unique_id{i}), :);
        sep_taps{i} = these_taps;
        these_apps = SUB.apps(strcmp(SUB.apps.devPartId, unique_id{i}), :);
        sep_apps{i} = these_apps;
    end

    all_taps_launcher = [];

    for i = 1:length(sep_taps)
        social = SUB.apps(strcmp(SUB.apps.category, 'COMMUNICATION')|strcmp(SUB.apps.category, 'SOCIAL'), 3).applicationId;
        idx = cellfun(@(c) ismember(c, social), sep_taps{i}.appIds0, 'UniformOutput', false);
        filtered_taps = cellfun(@(a, b) a(b), sep_taps{i}.taps, idx, 'UniformOutput', false);
        all_taps_launcher = [all_taps_launcher; filtered_taps];
    end


    last_tap = datetime(SUB.taps.stop(end) / 1000, 'ConvertFrom', 'epochtime');
    age = int32(years(last_tap - birthdate));
    
    if ~isfield(test_data, 'session')
        fprintf("\tTest is empty...jump\n")
        continue
    end
    
    [Dprime, ~, ~, ~, ~, ~, ~, RThits, ~] = getpsytoolkit2Back(test_data.session{1, 1}.vals);

    if ~isfield(Dprime, 'dpri') || (length(RThits)) < 2
        continue;
    end

    values = [Dprime.dpri, median(RThits)];

    all_data_proc = [all_data_proc; {data_.partId(1) ...
    length(all_taps_launcher)...
    length(cell2mat(SUB.taps.taps)) ...
    values...
    age }];

end

%%

ratios = all_data_proc.social_taps ./ all_data_proc.all_taps;
values_back = all_data_proc.back2;

subplot(1,2,1)
plot(values_back(:, 1), ratios, 'x');
title("Dprime")
subplot(1,2,2)
plot(values_back(:, 2), ratios, 'x');
title("median(rthits)")
