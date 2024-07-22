clear all; clc;

%% Before starting the process, change the numbers, function, and initialization.
% dimensionNumber is the number of the dimension of the function
dimensionNumber = 2;
% pointsNumber depends on the shape.
pointsNumber = dimensionNumber + 1;
func = @(x, y) x.^2 + 4*x + 4 + y.^2;
points = [];
Results_points = [];
stepNo = 0;

global points_history;
points_history = {};

%% I preferred to take points without using any input, but you can if you want.
p1 = [4.1, 3.6];
p2 = [2.8, 2.4];
p3 = [-3, 5.2];

points = [p1; p2; p3];


%{
for i = 1:pointsNumber
    for k = 1:dimensionNumber
    message = 'Select ' + string(i) + 'th point and ' + string(k) + 'th dimension \n';
    points(i,k) = input(message);
    end
end
%}

points_history{1} = points;
%% After initialization, let's recall functions.

%% Create GUI
f = figure('Name', 'Nelder Mead Method', 'Position', [100, 100, 800, 600]);
hAxes = axes('Parent', f, 'Position', [0.1, 0.3, 0.8, 0.6]);
hButtonUpdate = uicontrol('Style', 'pushbutton', 'String', 'Next', ...
                    'Position', [20, 20, 100, 30], ...
                    'Callback', {@updatePlot, hAxes});

hButtonBack = uicontrol('Style', 'pushbutton', 'String', 'Previous', ...
                    'Position', [180, 20, 100, 30], ...
                    'Callback', {@previousPlot, hAxes});

% Initial plot, if you change dimension number, change this area.
fcontour(hAxes, func, 'LevelStep', 5);
colorbar(hAxes);
hold(hAxes, 'on');
pointsSorted = sortVectors(pointsNumber, dimensionNumber, points, func);
plot(hAxes, pointsSorted(:, 1), pointsSorted(:, 2), 'bo', 'MarkerFaceColor', 'b');
text(hAxes, pointsSorted(:, 1), pointsSorted(:, 2), arrayfun(@(n) sprintf('S%d', n), 1:size(pointsSorted, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
plot(hAxes, [pointsSorted(:, 1); pointsSorted(1, 1)], [pointsSorted(:, 2); pointsSorted(1, 2)], 'r-'); 
title('Step number : ' + string(stepNo));

% Define the global variables
global g_points g_func g_dimensionNumber g_pointsNumber g_stepNo;
g_points = points;
g_func = func;
g_dimensionNumber = dimensionNumber;
g_pointsNumber = pointsNumber;
g_stepNo = stepNo;

% Callback function to update the plot
function updatePlot(~, ~, hAxes)
    global g_points g_func g_dimensionNumber g_pointsNumber g_stepNo points_history;

    if isempty(g_points)
        return; % Exit if points is empty
    end
    
    pointsSorted = sortVectors(g_pointsNumber, g_dimensionNumber, g_points, g_func);
    g_points = NelderMead(pointsSorted, g_func);
    
    % Ensure points is not empty before plotting
    if isempty(g_points)
        return;
    end

    cla(hAxes);
    fcontour(hAxes, g_func, 'LevelStep', 5);
    colorbar(hAxes);
    hold(hAxes, 'on');
    plot(hAxes, g_points(:, 1), g_points(:, 2), 'bo', 'MarkerFaceColor', 'b');
    text(hAxes, g_points(:, 1), g_points(:, 2), arrayfun(@(n) sprintf('S%d', n), 1:size(g_points, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    plot(hAxes, [g_points(:,1); g_points(1,1)], [g_points(:,2); g_points(1,2)], 'r-');
    
    g_stepNo = g_stepNo + 1;
    
    points_history{g_stepNo + 1} = g_points;

    
    title('Step number : ' + string(g_stepNo));
    disp(['Standart deviation of points is respectively: ']);
    disp(num2str(std(g_points)));
end

function previousPlot(~, ~, hAxes)
    global g_stepNo points_history g_func g_points;

    if g_stepNo <= 0
        return; % Exit if there are no previous steps
    end

    g_stepNo = g_stepNo - 1;
    prev_points = points_history{g_stepNo + 1}; % Retrieve previous points
    g_points = prev_points;

    cla(hAxes);
    fcontour(hAxes, g_func, 'LevelStep', 5);
    colorbar(hAxes);
    hold(hAxes, 'on');
    plot(hAxes, prev_points(:, 1), prev_points(:, 2), 'bo', 'MarkerFaceColor', 'b');
    text(hAxes, prev_points(:, 1), prev_points(:, 2), arrayfun(@(n) sprintf('S%d', n), 1:size(prev_points, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    plot(hAxes, [prev_points(:,1); prev_points(1,1)], [prev_points(:,2); prev_points(1,2)], 'r-');
    
    title('Step number : ' + string(g_stepNo));
    disp(['Standart deviation of points is respectively: ']);
    disp(num2str(std(prev_points)));
end
