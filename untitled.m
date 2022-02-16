

% T = readtable('storke_partids_age.csv');
% T = readtable('/media/Storage/Common_Data_Storage/TAP/raw/metaData_2021-10-04.csv');

T = readtable('cleaned_up_stroke_info.csv');

partIds = unique(T.partId);


for i = 1:length(partIds)
    SUB = getTapDataParsed(partIds{i}, 'refresh', 1);
    if ~isempty(SUB)
       T.Phone{i} = SUB; 
    end
end

%%

single_jids_strokestudy = genericSingleJID(T);

with_jid = single_jids_strokestudy(~cellfun('isempty', single_jids_strokestudy.jids(:, 1)), :);


JIDs = with_jid.jids(:, 1);

%%
ages = with_jid.age;
%%

A = zeros(26, 2500, 1);
for i= 1:26
    A(i, :) = log10(reshape(JIDs{i}, 2500, 1) + 1e-15);
end

%%
JIDs = log10(reshape(A, n_subs, n_time, n_ch) + 1e-15);