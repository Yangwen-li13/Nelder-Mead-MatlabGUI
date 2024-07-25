clear all; clc;
%% Before starting the process, change the numbers, function, and initialization.
% dimensionNumber is the number of the dimension of the function
dimensionNumber = 3;
pointsNumber = dimensionNumber + 1;

func = @(x, y, z) x.^2 + y.^2 + z.^2;

stepNo = 0;

global volume_history points_history std_dev_history;
points_history = {};
std_dev_history = {};
volume_history = {};

%% Initial points
p1 = [4.1, 3.6, 3];
p2 = [2.8, 2.4, 10];
p3 = [-3, 5.2, -5];
p4 = [3, 2, -4];

points = [p1; p2; p3; p4];

points_history{1} = points;
%% Create GUI
f = figure('Name', 'Nelder Mead Method', 'Position', [100, 100, 800, 600]);

hAxes = subplot(3, 3, [1 2 4 5], 'Parent', f);
volumePlot = subplot(3, 3, 3, 'Parent', f);
stdDevPlot = subplot(3, 3, 6, 'Parent', f);

hButtonNext = uicontrol('Style', 'pushbutton', 'String', 'Next', ...
                        'Position', [260, 20, 100, 30], ...
                        'Callback', {@updatePlot, hAxes, volumePlot, stdDevPlot});

hButtonPrev = uicontrol('Style', 'pushbutton', 'String', 'Previous', ...
                        'Position', [380, 20, 100, 30], ...
                        'Callback', {@previousPlot, hAxes, volumePlot, stdDevPlot});

global nextCase;
nextCase = uicontrol('Style', 'text', 'String', 'Next Case', ...
                        'Position', [270, 80, 200, 50]);

%% Initial plot
cla(hAxes);
[points, Results_points] = sortVectors(pointsNumber, dimensionNumber, points, func);
scatter3(hAxes, points(:,1), points(:,2), points(:,3), 'bo', 'filled');
text(hAxes, points(:,1), points(:,2), points(:,3), arrayfun(@(n) sprintf('S%d', n), 1:size(points, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
grid(hAxes, 'minor');
hold(hAxes, 'on');
plotTetrahedron(hAxes, points);

            
title(hAxes, 'Searching Parameters of the Fin via Nelder-Meads Method');
xlabel(hAxes,'Step Number : ' + string(stepNo));


% This is to see next step in the figure;
NelderMead(points, func);  


std_dev = std(Results_points);
std_dev_history{1} = std_dev;

volume = computeVolume(points);
volume_history{1} = volume;

hold(volumePlot, 'on');
grid(volumePlot, 'minor');
plot(volumePlot, stepNo, volume, 'ro-', 'MarkerFaceColor', 'b');
title(volumePlot, 'Volume of the Tetrahedron');

hold(stdDevPlot, 'on');
grid(stdDevPlot, 'minor');
plot(stdDevPlot, stepNo, std_dev, 'ro-', 'MarkerFaceColor', 'r');
title(stdDevPlot, 'Standart Deviation of Function Values');


% Define the global variables
global g_points g_func g_dimensionNumber g_pointsNumber g_stepNo;
g_points = points;
g_func = func;
g_dimensionNumber = dimensionNumber;
g_pointsNumber = pointsNumber;
g_stepNo = stepNo;

%% Callback function to update the plot
function updatePlot(~, ~, hAxes, volumePlot, stdDevPlot)
    global g_points g_func g_dimensionNumber g_pointsNumber g_stepNo points_history std_dev_history volume_history;
    
    if isempty(g_points)
        return;
    end

    [pointsSorted, Results_points] = sortVectors(g_pointsNumber, g_dimensionNumber, g_points, g_func);
    g_points = NelderMead(pointsSorted, g_func);

    [pointsSortedtemp, ~] = sortVectors(g_pointsNumber, g_dimensionNumber, g_points, g_func);
    g_points = pointsSortedtemp; 
    NelderMead(pointsSortedtemp, g_func);
    


    cla(hAxes);
    scatter3(hAxes, g_points(:,1), g_points(:,2), g_points(:,3), 'bo', 'filled');
    text(hAxes, g_points(:,1), g_points(:,2), g_points(:,3), arrayfun(@(n) sprintf('S%d', n), 1:size(g_points, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    plotTetrahedron(hAxes, g_points);
    
    g_stepNo = g_stepNo + 1;
    points_history{g_stepNo + 1} = g_points;

    xlabel(hAxes,['Step Number : ' + string(g_stepNo)]);
    view(hAxes, 3);
    grid(hAxes, 'on');

    std_dev = std(g_points);
    std_dev_history{g_stepNo + 1} = std_dev;
    volume_history{g_stepNo + 1} = computeVolume(g_points);

    % Update volume plot
    cla(volumePlot);
    volume = computeVolume(g_points);
    volume_history{g_stepNo + 1} = volume;
    plot(volumePlot, 0:g_stepNo, cell2mat(volume_history(1 ,1:g_stepNo + 1)), 'bo-', 'MarkerFaceColor', 'b');
    hold(volumePlot, 'on');


    cla(stdDevPlot);
    std_dev = std(Results_points);
    std_dev_history{g_stepNo + 1} = std_dev;
    plot(stdDevPlot, 0:g_stepNo, cell2mat(std_dev_history(1 ,1:g_stepNo + 1)), 'ro-', 'MarkerFaceColor', 'r');
    hold(stdDevPlot, 'on');

end

%% Callback function to go back to the previous plot
function previousPlot(~, ~, hAxes, volumePlot, stdDevPlot)
    global g_stepNo points_history std_dev_history volume_history g_points;

    if g_stepNo <= 0
        return;
    end

    prev_points = points_history{g_stepNo};
    g_points = prev_points;
    g_stepNo = g_stepNo - 1;

    cla(hAxes);
    scatter3(hAxes, prev_points(:,1), prev_points(:,2), prev_points(:,3), 'bo', 'filled');
    text(hAxes, prev_points(:,1), prev_points(:,2), prev_points(:,3), arrayfun(@(n) sprintf('S%d', n), 1:size(prev_points, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    plotTetrahedron(hAxes, prev_points);

    [pointsSortedtemp, ~] = sortVectors(g_pointsNumber, g_dimensionNumber, g_points, g_func);
    NelderMead(pointsSortedtemp, g_func);

    xlabel(hAxes,['Step Number : ' + string(g_stepNo)]);
    view(hAxes, 3);
    grid(hAxes, 'on');

    % Update volume plot
    cla(volumePlot);
    volume = computeVolume(g_points);
    volume_history{g_stepNo + 1} = volume;
    plot(volumePlot, 0:g_stepNo, cell2mat(volume_history(1 ,1:g_stepNo + 1)), 'bo-', 'MarkerFaceColor', 'b');
    hold(volumePlot, 'on');
    plot(volumePlot, 0:g_stepNo, cell2mat(volume_history(1:g_stepNo+1)), 'ro-', 'MarkerFaceColor', 'b');


    cla(stdDevPlot);
    std_dev = std(Results_points);
    std_dev_history{g_stepNo + 1} = std_dev;
    plot(stdDevPlot, 0:g_stepNo, cell2mat(std_dev_history(1 ,1:g_stepNo + 1)), 'ro-', 'MarkerFaceColor', 'r');
    hold(stdDevPlot, 'on');

end

function volume = computeVolume(points)
    % Construct the matrix from the points
    matrix = [
        points(1, :) 1;
        points(2, :) 1;
        points(3, :) 1;
        points(4, :) 1
    ];

    detMatrix = det(matrix);
    volume = abs(detMatrix) / 6;
end

function plotTetrahedron(hAxes, pointsSorted)
    % Plot lines between all vertices of the tetrahedron
    plot3(hAxes, [pointsSorted(1,1) pointsSorted(2,1)], [pointsSorted(1,2) pointsSorted(2,2)], [pointsSorted(1,3) pointsSorted(2,3)], 'r-');
    plot3(hAxes, [pointsSorted(1,1) pointsSorted(3,1)], [pointsSorted(1,2) pointsSorted(3,2)], [pointsSorted(1,3) pointsSorted(3,3)], 'r-');
    plot3(hAxes, [pointsSorted(1,1) pointsSorted(4,1)], [pointsSorted(1,2) pointsSorted(4,2)], [pointsSorted(1,3) pointsSorted(4,3)], 'r-');
    plot3(hAxes, [pointsSorted(2,1) pointsSorted(3,1)], [pointsSorted(2,2) pointsSorted(3,2)], [pointsSorted(2,3) pointsSorted(3,3)], 'r-');
    plot3(hAxes, [pointsSorted(2,1) pointsSorted(4,1)], [pointsSorted(2,2) pointsSorted(4,2)], [pointsSorted(2,3) pointsSorted(4,3)], 'r-');
    plot3(hAxes, [pointsSorted(3,1) pointsSorted(4,1)], [pointsSorted(3,2) pointsSorted(4,2)], [pointsSorted(3,3) pointsSorted(4,3)], 'r-');
end
