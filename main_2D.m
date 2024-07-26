clear all; clc;

%% Before starting the process, change the numbers, function, and initialization.
% dimensionNumber is the number of the dimension of the function
dimensionNumber = 2;

% pointsNumber depends on the shape.
pointsNumber = dimensionNumber + 1;

% Function for our algorithm.
func = @(x, y) x.^2 + 4*x + 4 + y.^2;

stepNo = 0;

global area_history points_history std_dev_history;
points_history = {};
std_dev_history = {};
area_history = {};

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
% Create a figure window
f = figure('Name', 'Nelder Mead Method', 'Position', [100, 100, 800, 600]);

hAxes = subplot(3, 3, [1 2 4 5], 'Parent', f);
areaPlot = subplot(3, 3, 3, 'Parent', f);
stdDevPlot = subplot(3, 3, 6, 'Parent', f);

hButtonNext = uicontrol('Style', 'pushbutton', 'String', 'Next', ...
                        'Position', [260, 20, 100, 30], ...
                        'Callback', {@updatePlot, hAxes, areaPlot, stdDevPlot});

hButtonPrev = uicontrol('Style', 'pushbutton', 'String', 'Previous', ...
                        'Position', [380, 20, 100, 30], ...
                        'Callback', {@previousPlot, hAxes, areaPlot, stdDevPlot});

% Create a text display for the next case
global nextCase meanPoint;

nextCase = uicontrol('Style', 'text', 'String', 'Next Case', 'FontSize', 10, ...
                        'Position', [270, 60, 200, 50]);

meanPoint = uicontrol('Style', 'text', 'String', 'Mean :', 'FontSize', 10, ...
                        'Position', [270, 120, 200, 50]);



%% Initial plot, if you change dimension number, change this area.
fcontour(hAxes, func, 'LevelStep', 5);
colorbar(hAxes);
hold(hAxes, 'on');
grid(hAxes, 'minor');

[pointsSorted, Results_points] = sortVectors(pointsNumber, dimensionNumber, points, func);
plot(hAxes, pointsSorted(:, 1), pointsSorted(:, 2), 'bo', 'MarkerFaceColor', 'b');
text(hAxes, pointsSorted(:, 1), pointsSorted(:, 2), arrayfun(@(n) sprintf('S%d', n), 1:size(pointsSorted, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
plot(hAxes, [pointsSorted(:, 1); pointsSorted(1, 1)], [pointsSorted(:, 2); pointsSorted(1, 2)], 'r-'); 

% This is to see next step in the figure;
NelderMead(pointsSorted, func);              

title(hAxes, 'Searching Parameters of the Fin via Nelder-Meads Method');
xlabel(hAxes,'Step Number : ' + string(stepNo));

area = computeArea(points);
area_history{1} = area;

hold(areaPlot, 'on');
grid(areaPlot, 'minor');
plot(areaPlot, stepNo, area, 'ro-', 'MarkerFaceColor', 'b');
title(areaPlot, 'Area of the Triangle');

std_dev = std(Results_points);
std_dev_history{1} = std_dev;

hold(stdDevPlot, 'on');
grid(stdDevPlot, 'minor');
plot(stdDevPlot, stepNo, std_dev, 'ro-', 'MarkerFaceColor', 'r');
title(stdDevPlot, 'Standart Deviation of Function Values');

meanpoint = mean(points);
set(meanPoint, 'String', 'Mean Point: x = ' + string(meanpoint(1,1)) + ' y = ' + string(meanpoint(1,2)));


% Define the global variables
global g_points g_func g_dimensionNumber g_pointsNumber g_stepNo;
g_points = points;
g_func = func;
g_dimensionNumber = dimensionNumber;
g_pointsNumber = pointsNumber;
g_stepNo = stepNo;

%% Callback function to update the plot
function updatePlot(~, ~, hAxes, areaPlot, stdDevPlot)
    global g_points g_func g_dimensionNumber g_pointsNumber g_stepNo points_history std_dev_history area_history meanPoint;


    if isempty(g_points)
        return; % Exit if points is empty
    end
    
    [pointsSorted, Results_points] = sortVectors(g_pointsNumber, g_dimensionNumber, g_points, g_func);
    g_points = NelderMead(pointsSorted, g_func);

    [pointsSortedtemp, ~] = sortVectors(g_pointsNumber, g_dimensionNumber, g_points, g_func);
    g_points = pointsSortedtemp; 
    NelderMead(pointsSortedtemp, g_func);
    
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

    title(hAxes, 'Searching Parameter of the Fin via Nelder-Meads Method');
    xlabel(hAxes,['Step Number : ' + string(g_stepNo)]);

    % Plot mean and std deviation
    cla(areaPlot);
    area = computeArea(g_points);
    area_history{g_stepNo + 1} = area;
    plot(areaPlot, 0:g_stepNo, cell2mat(area_history(1 ,1:g_stepNo + 1)), 'bo-', 'MarkerFaceColor', 'b');
    xlabel('Step Number : ' + string(g_stepNo));
    hold(areaPlot, 'on');

    
    cla(stdDevPlot);
    std_dev = std(Results_points);
    std_dev_history{g_stepNo + 1} = std_dev;
    plot(stdDevPlot, 0:g_stepNo, cell2mat(std_dev_history(1 ,1:g_stepNo + 1)), 'ro-', 'MarkerFaceColor', 'r');
    hold(stdDevPlot, 'on');


    xlabel('Step Number : ' + string(g_stepNo));

    meanpoint = mean(g_points);
    set(meanPoint, 'String', 'Mean Point: x = ' + string(meanpoint(1,1)) + ' y = ' + string(meanpoint(1,2)));
end

function previousPlot(~, ~, hAxes, areaPlot, stdDevPlot)
    global g_stepNo points_history g_func g_points std_dev_history area_history stepCase g_pointsNumber g_dimensionNumber meanPoint;

    if g_stepNo <= 0
        return; % Exit if there are no previous steps
    end

    g_stepNo = g_stepNo - 1;
    prev_points = points_history{g_stepNo + 1}; % Retrieve previous points
    g_points = prev_points;


    [pointsSortedtemp, ~] = sortVectors(g_pointsNumber, g_dimensionNumber, g_points, g_func);
    NelderMead(pointsSortedtemp, g_func);

    cla(hAxes);
    fcontour(hAxes, g_func, 'LevelStep', 5);
    colorbar(hAxes);
    hold(hAxes, 'on');
    plot(hAxes, prev_points(:, 1), prev_points(:, 2), 'bo', 'MarkerFaceColor', 'b');
    text(hAxes, prev_points(:, 1), prev_points(:, 2), arrayfun(@(n) sprintf('S%d', n), 1:size(prev_points, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    plot(hAxes, [prev_points(:, 1); prev_points(1, 1)], [prev_points(:, 2); prev_points(1, 2)], 'r-');
    
    xlabel(hAxes,'Step Number : ' + string(g_stepNo));
    
    % Plot mean and std deviation
    cla(areaPlot);
    plot(areaPlot, 0:g_stepNo, cell2mat(area_history(1 ,1:g_stepNo + 1)), 'bo-', 'MarkerFaceColor', 'b');
    hold(areaPlot, 'on');

    
    cla(stdDevPlot);
    plot(stdDevPlot, 0:g_stepNo, cell2mat(std_dev_history(1 ,1:g_stepNo + 1)), 'ro-', 'MarkerFaceColor', 'r');
    hold(stdDevPlot, 'on');

    
    meanpoint = mean(g_points);
    set(meanPoint, 'String', 'Mean Point: x = ' + string(meanpoint(1,1)) + ' y = ' + string(meanpoint(1,2)));
end

function area = computeArea(points)
    % Compute the area of the triangle formed by the points
    x1 = points(1, 1);
    y1 = points(1, 2);
    x2 = points(2, 1);
    y2 = points(2, 2);
    x3 = points(3, 1);
    y3 = points(3, 2);
    area = abs(x1*(y2 - y3) + x2*(y3 - y1) + x3*(y1 - y2)) / 2;
end
