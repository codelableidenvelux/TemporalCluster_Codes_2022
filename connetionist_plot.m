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
        if abs(all_R_res2(i, j)) > 0.9
        
            x1 = mod(i - 1, 50);
            y1 = int32((i - 1) / 50);
            x2 = mod((j - 1), 50);
            y2 = int32((j - 1) / 50);
            
%             if mod(x1, 2) == 0 && mod(y1, 2) == 0 && mod(x2, 2) == 0 && mod(y2, 2) == 0
                if color(i, j) > 0
                    plot([x1, x2], [y1, y2], 'Color', [0,0,1, 0.1])
                else
                    plot([x1, x2], [y1, y2], 'Color', [1,0,0, 0.1])
                end
%             end
        end
        
    end
    
end

%% one more idea

figure(3)
hold on

counter_red = zeros(50);
counter_blue = zeros(50);

% 
for i = 0:2499
    for j = i:2499
        if abs(all_R_res2(i + 1, j + 1)) > 0.9
        
            x1 = mod(i, 50) + 1;
            y1 = floor(i / 50) + 1;
            x2 = mod(j, 50) + 1;
            y2 = floor(j / 50) + 1;
            
            
%             if mod(x1, 2) == 0 && mod(y1, 2) == 0 && mod(x2, 2) == 0 && mod(y2, 2) == 0
                if color(i + 1, j + 1) > 0
                    counter_red(x1, y1) = counter_red(x1, y1) + 1;
                    counter_red(x2, y2) = counter_red(x2, y2) + 1;
                else
                    counter_blue(x1, y1) = counter_blue(x1, y1) + 1;
                    counter_blue(x2, y2) = counter_blue(x2, y2) + 1;
                end
%             end
        end
        
    end
    
end

% Sizes = distance from origin
size_red = reshape(counter_red, 2500, 1);
size_red = size_red + 1;
size_red = size_red / max(size_red) * 100;

size_blue = reshape(counter_blue, 2500, 1);
size_blue = size_blue + 1;
size_blue = size_blue / max(size_blue) * 100;

x = mod(0:2499, 50);
y = floor((0:2499) / 50);
% colors = jet(numPoints);	% Initialize
% colors = colors(indexes,:); % Colored according to distance.
% Do the plot
scatter(x(size_red > size_blue), y(size_red > size_blue), size_red(size_red > size_blue), [0, 0, 1], 'filled');
scatter(x(size_red < size_blue), y(size_red < size_blue), size_blue(size_red < size_blue), [1, 0, 0], 'filled');
grid on;
