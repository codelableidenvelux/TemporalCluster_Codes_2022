function ADJ = find_adj_matrix(bins, neigh)
a = 0:bins * bins-1;

ADJ = zeros(bins * bins, bins * bins);

for k = 0:bins * bins - 1
    c = (abs(int32(a / bins) - int32(k / bins)) <= neigh);
    d = (abs(int32(mod(a, bins)) - int32(mod(k, bins))) <= neigh);
    ADJ(:, k + 1) = c & d;
end
