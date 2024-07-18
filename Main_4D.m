clear all; clc;

%% Before starting the process, change the numbers, function, and initialization.
% dimensionNumber is the number of the dimension of the function
dimensionNumber = 3;
% pointsNumber depends on the shape.
pointsNumber = dimensionNumber + 1;
func = @(x, y, z) x.^2 + y.^2 + z.^2;
points = [];
Results_points = [];
stepNo = 0;

%% I preferred to take points without using any input, but you can if you want.
p1 = [4.1, 3.6, 3];
p2 = [2.8, 2.4, 10];
p3 = [-3, 5.2, -5];
p4 = [3, 2, -4];

points = [p1; p2; p3; p4];

%{
for i = 1:pointsNumber
    for k = 1:dimensionNumber
    message = 'Select ' + string(i) + 'th point and ' + string(k) + 'th dimension \n';
    points(i,k) = input(message);
    end
end
%}
%% After initialization, let's recall functions.

%% Create GUI
f = figure('Name', 'Nelder Mead Method', 'Position', [100, 100, 800, 600]);
hAxes = axes('Parent', f, 'Position', [0.1, 0.3, 0.8, 0.6]);
hButton = uicontrol('Style', 'pushbutton', 'String', 'Next', ...
                    'Position', [20, 20, 100, 30], ...
                    'Callback', {@updatePlot, hAxes});

% Initial plot, if you change dimension number, change this area.
[x, y] = meshgrid(-5:0.5:5, -5:0.5:5);
z = arrayfun(@(x, y) func(x, y, 0), x, y); % For 3D mesh, fixing z dimension to 0
mesh(hAxes, x, y, z);
colorbar(hAxes);
hold(hAxes, 'on');
pointsSorted = sortVectors(pointsNumber, dimensionNumber, points, func);
plot3(hAxes, pointsSorted(:, 1), pointsSorted(:, 2), pointsSorted(:, 3), 'bo', 'MarkerFaceColor', 'b');
text(hAxes, pointsSorted(:, 1), pointsSorted(:, 2), pointsSorted(:, 3), arrayfun(@(n) sprintf('S%d', n), 1:size(pointsSorted, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
plotTetrahedron(hAxes, pointsSorted);

% Define the global variables
global g_points g_func g_dimensionNumber g_pointsNumber g_stepNo;
g_points = points;
g_func = func;
g_dimensionNumber = dimensionNumber;
g_pointsNumber = pointsNumber;
g_stepNo = stepNo;

% Callback function to update the plot
function updatePlot(~, ~, hAxes)
    global g_points g_func g_dimensionNumber g_pointsNumber g_stepNo;

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
    [x, y] = meshgrid(-5:0.5:5, -5:0.5:5);
    z = arrayfun(@(x, y) g_func(x, y, 0), x, y); % For 3D mesh, fixing z dimension to 0
    mesh(hAxes, x, y, z);
    colorbar(hAxes);
    hold(hAxes, 'on');
    plot3(hAxes, g_points(:, 1), g_points(:, 2), g_points(:, 3), 'bo', 'MarkerFaceColor', 'b');
    text(hAxes, g_points(:, 1), g_points(:, 2), g_points(:, 3), arrayfun(@(n) sprintf('S%d', n), 1:size(g_points, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    plotTetrahedron(hAxes, g_points);
    
    g_stepNo = g_stepNo + 1;
    disp(['Step number: ', num2str(g_stepNo)]);
    disp(['Standart deviation of points is respectively: ']);
    disp(num2str(std(g_points)));
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
