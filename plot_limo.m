%% AGE

figure(7)
count = 1;
test = {'age'};
jids = {'Full', 'Launcher', 'Social', 'Transition'};
for i = 1:1
    for j = 1:3
        subplot(2, 4, count)
        imagesc(reshape(all_age{i, j}.R2, 50, 50))
% %         imagesc(reshape(all_age_norm{i, j}.Betas(:, 1, 1), 50, 50))
%         imagesc(reshape(all_age_no_norm{i, j}.Betas(:, 1, 1), 50, 50))
        set(gca, 'YDir', 'normal')
        title(sprintf("%s - %s (NORM)", test{i}, jids{j}))
        colorbar()
        count = count + 1;
    end
end

imagesc(reshape(all_age{1, 1}.R2, 50, 50))
set(gca, 'YDir', 'normal')
title("Full JID vs AGE (NORM)")
colorbar()

%% ENTROPY vs AGE
n_sub = size(all_age{1, 2}.A, 1);
allJIDs = squeeze(all_age{1, 2}.A);
entropy = zeros(n_sub, 1);
age = squeeze(all_age{1, 2}.B(:, 1));

for i = 1:n_sub
    entropy(i) = JID_entropy(10 .^ reshape(allJIDs(i, :), 50, 50));
end

[~, id_e] = sort(entropy);

for i = 1:10
    subplot(2, 10, i)
    imagesc(10 .^ reshape(allJIDs(id_e(i), :), 50, 50))
    set(gca, 'YDir', 'normal')
    subplot(2, 10, i + 10)
    imagesc(10 .^ reshape(allJIDs(id_e(end + 1 - i), :), 50, 50))
    set(gca, 'YDir', 'normal')
end


x = age(entropy > 5); %Population of states
y = entropy(entropy > 5); %Accidents per state
z = rand(size(x));
% tbl = array2table([x(:), y(:), y(:)], 'VariableNames', {'Age', 'Entropy', 'Gender'});
% mdl = fitlm(tbl, 'Entropy ~ Age + Gender', 'RobustOpts', 'on');
% plotResiduals(mdl,'probability')
% plotAdded(mdl);

%% simmetry
ss = zeros(n_sub, 1);
for i = 1:n_sub
    A = reshape(allJIDs(i, :), 50, 50);
    As = (A + A') / 2;
    Aa = (A - A') / 2;
    ss(i) = 1 - norm(Aa) / norm(As);
end
plot(ss)
plot(age, ss, 'o')
plot(sort(ss))
%% image complexity

SI_all = zeros(n_sub, 1);
for i = 1:n_sub
    A = reshape(allJIDs(i, :), 50, 50);
    [Gx, Gy] = imgradientxy(A);
    SI_all(i) = sum(sum(sqrt(Gx.^2 + Gy.^2))) / 2500;
end
plot(SI_all)

[~, id_c] = sort(SI_all);

for i = 1:10
    subplot(2, 10, i)
    imagesc(10 .^ reshape(allJIDs(id_c(i), :), 50, 50))
    set(gca, 'YDir', 'normal')
    title(sprintf("SI = %.2f", SI_all(id_c(i))))
    colorbar()
    subplot(2, 10, i + 10)
    imagesc(10 .^ reshape(allJIDs(id_c(end + 1 - i), :), 50, 50))
    set(gca, 'YDir', 'normal')
    title(sprintf("SI = %.2f", SI_all(id_c(end + 1 - i))))
    colorbar()
end

% plot(sort(SI_all))

x = age; %Population of states
y= SI_all; %Accidents per state
tbl = array2table([x(:), y(:)], 'VariableNames', {'Age', 'Complexity'});
mdl = fitlm(tbl, 'Complexity ~ Age', 'RobustOpts', 'on');
% plotResiduals(mdl,'probability')
plotAdded(mdl);
%% R TIME
figure(2)
count = 1;
test = {'sRT', 'cRT'};
jids = {'Full', 'Launcher', 'Social', 'Transition'};
for i = 1:2
    for j = 1:4
        subplot(2, 4, count)
        imagesc(reshape(all_r_time{i, j}.R2, 50, 50))
%         imagesc(reshape(all_r_time{i, j}.Betas(:, 1, 2), 50, 50))
        set(gca, 'YDir', 'normal')
        title(sprintf("%s - %s", test{i}, jids{j}))
        colorbar()
        count = count + 1;
    end
end


imagesc(reshape(all_r_time{2, 1}.R2, 50, 50))
set(gca, 'YDir', 'normal')
title("Full JID vs cRT (NORM)")
colorbar()

%% R TIME - no norm
figure(4)
count = 1;
test = {'age'};
jids = {'Full', 'Launcher', 'Social', 'Transition'};
for i = 1:1
    for j = 1:4
        subplot(2, 4, count)
%         imagesc(reshape(all_age{i, j}.R2, 50, 50))
        imagesc(reshape(all_age{i, j}.Betas(:, 1, 1), 50, 50))
        set(gca, 'YDir', 'normal')
        title(sprintf("%s - %s", test{i}, jids{j}))
        colorbar()
        count = count + 1;
    end
end

%% R 2-Back
figure(2)
count = 1;
test = {'DPrime', 'RTHits'};
jids = {'Full', 'Launcher', 'Social', 'Transition'};
for i = 1:2
    for j = 1:4
        subplot(2, 4, count)
        imagesc(reshape(all_2back{i, j}.R2, 50, 50))
        set(gca, 'YDir', 'normal')
        title(sprintf("%s - %s", test{i}, jids{j}))
        count = count + 1;
        colorbar();
    end
end

%% R Corsi
figure(3)
count = 1;
test = {'Corsi Span'};
jids = {'Full', 'Launcher', 'Social', 'Transition'};
for i = 1:1
    for j = 1:4
        subplot(1, 4, count)
        imagesc(reshape(all_corsi{i, j}.R2, 50, 50))
        set(gca, 'YDir', 'normal')
        title(sprintf("%s - %s", test{i}, jids{j}))
        colorbar()
        count = count + 1;
    end
end


%% R Task switch
figure(4)
count = 1;
test = {'GlobaCost_RT_norm', 'GlobalCostRT', 'LocalCost_RT_norm', 'LocalCostRT'};
jids = {'Full', 'Launcher', 'Social', 'Transition'};
for i = 1:4
    for j = 1:4
        subplot(4, 4, count)
        imagesc(reshape(all_switch{i, j}.R2, 50, 50))
        set(gca, 'YDir', 'normal')
        title(sprintf("%s - %s", test{i}, jids{j}))
        colorbar()
        count = count + 1;
    end
end
%% 
figure(1)
for i = 1:15
    subplot(3, 5, i)
    imagesc(reshape(mask(:, i), 50, 50))
    set(gca, 'YDir', 'normal')
    title(sprintf("Day %d", i - 8))
end

%%

figure(2)
for i = 1:15
    subplot(3, 5, i)
    image(reshape(R2(:, i), 50, 50))
    set(gca, 'YDir', 'normal')
    title(sprintf("Day %d", i - 8))
end

%%
figure(3)
for i = 1:15
    subplot(3, 5, i)
    imagesc(reshape(M(:, i), 50, 50))
    set(gca, 'YDir', 'normal')
    title(sprintf("Day %d", i - 8))
end

%% 
figure(7)
[newR2, ord] = sort(all_age{1, 1}.R2);


for i = 1:25
    subplot(5,5,i)
%     plot(all_r_time_no_norm{2, 1}.A(:, :, ord(end-i+1)), all_r_time_no_norm{2, 1}.B(:, 1), 'x')
    Y              = squeeze(all_age{1, 1}.A(:, :, ord(end-i+1)));
    X              = all_age{1, 1}.B;
    Betas          = squeeze(all_age{1, 1}.Betas(ord(end-i+1), :, :));

    plot(X(:, 1), Y, 'x')
    hold on
    plot(X(:, 1), (X(:, 1) .* Betas(1)) + Betas(2), 'r--');

    title(sprintf("R2 = %.2f", newR2(end-i+1)))
end


%% INTEGRAL

h = (5 - 1.5) / 50;
integral = 0;
a = 10 .^ squeeze(all_age_norm{1, 1}.A(44, :, :));
integral =sum(integral + a * h * h);
disp(integral)

%% 
A = squeeze(res.A);
sk = reshape(skewness(log10(A), 1), 50, 50);
imagesc(sk)

%% scatter social 2back

ratios = all_data_proc.social_taps ./ all_data_proc.all_taps;
values_back = all_data_proc.back2;

subplot(1,2,1)
plot(ratios, values_back(:, 1), 'o');
title("Dprime")
subplot(1,2,2)
plot(ratios, values_back(:, 2), 'o');
title("median(rthits)")

%% 
% figure(5)
% subplot(2,1,1)
% all_r_time{2, 1}.A
% scatter(reshape(, 50, 50)(:, :, 7 * 11 + 1), all_r_time{2, 1}.B(:, 1), 'x')
% subplot(2,1,2)
% scatter(all_r_time_no_norm{2, 1}.A(:, :, 7 * 11 + 1), all_r_time{2, 1}.B(:, 1), 'x')