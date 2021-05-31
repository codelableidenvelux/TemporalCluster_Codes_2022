presence = zeros(2500);
color = zeros(2500);
for i = 1:2500
    for j = i:2500
        if ~isempty(all_R_res{i, j})
            presence(i, j) = all_R_res{i, j}.p < 0.05;
            presence(j, i) = all_R_res{i, j}.p < 0.05;

            color(i, j) = all_R_res{i, j}.invert;
            color(j, i) = all_R_res{i, j}.invert;
        end
    end
end



%%
% presence = rand(2500) > 0.9;
% color = rand(2500) > 0.9;

figure(1)
hold on

for i = 1:2500
    for j = i:2500
        
        if presence(i, j)
        
            y1 = mod(i - 1, 50);
            x1 = int32((i - 1) / 50);
            y2 = mod(j - 1, 50);
            x2 = int32((j - 1) / 50);
            
            if mod(x1, 2) == 0 && mod(y1, 2) == 0 && mod(x2, 2) == 0 && mod(y2, 2) == 0
            
                if color(i, j)
                    plot([x1, x2], [y1, y2], 'Color', [0,0,1, 0.1])
                else
                    plot([x1, x2], [y1, y2], 'Color', [1,0,0, 0.1])
                end
            end
        end
        
    end
end

