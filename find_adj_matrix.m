a = 0:50 * 50-1;

ADJ = zeros(2500, 2500);

for k = 0:50 * 50-1


l = 10;
% b = (abs(a - k) <= l);
c = (abs(int32(a / 50) - int32(k / 50)) <= l);
d = (abs(int32(mod(a,50)) - int32(mod(k, 50))) <= l);
ADJ(:, k + 1) = c & d;

end
