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

global points_history;
points_history = {};

%% I preferred to take points without using any input, but you can if you want.
p1 = [4.1, 3.6, 3];
p2 = [2.8, 2.4, 10];
p3 = [-3, 5.2, -5];
p4 = [3, 2, -4];

points = [p1; p2; p3; p4];
points_history{1} = points;

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
hButtonNext = uicontrol('Style', 'pushbutton', 'String', 'Next', ...
                    'Position', [20, 20, 100, 30], ...
                    'Callback', {@updatePlot, hAxes});

hButtonPrev = uicontrol('Style', 'pushbutton', 'String', 'Previous', ...
                    'Position', [180, 20, 100, 30], ...
                    'Callback', {@previousPlot, hAxes});

global standartDeviationScreen;
standartDeviationScreen = uicontrol('Style', 'text', 'String', 'Std Dev: ', ...
                                'Position', [320, 20, 200, 30]);

center = mean(points);
x1 = center(1);
y1 = center(2);
z1 = center(3);
[X, Y, Z] = sphere(32);
x = [x1 + 0.5*X(:); x1 + 0.75*X(:); x1 + X(:)];
y = [y1 + 0.5*Y(:); y1 + 0.75*Y(:); y1 + Y(:)];
z = [z1 + 0.5*Z(:); z1 + 0.75*Z(:); z1 + Z(:)];

S = repmat([50,25,10],numel(X),1);
C = repmat([1,2,3],numel(X),1);
s = S(:);
c = C(:);
scatter3(x,y,z,s,c)
view(40,35)
colorbar(hAxes);
hold(hAxes, 'on');
pointsSorted = sortVectors(pointsNumber, dimensionNumber, points, func);
plot3(hAxes, pointsSorted(:, 1), pointsSorted(:, 2), pointsSorted(:, 3), 'bo', 'MarkerFaceColor', 'b');
text(hAxes, pointsSorted(:, 1), pointsSorted(:, 2), pointsSorted(:, 3), arrayfun(@(n) sprintf('S%d', n), 1:size(pointsSorted, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
plotTetrahedron(hAxes, pointsSorted);

title('Step number : ' + string(stepNo));
global std_dev;
std_dev = std(points);
set(standartDeviationScreen, 'String', ['Std Dev     ', 'x :' num2str(std_dev(1,1)), '     y : ', num2str(std_dev(1, 2)), '     z :', num2str(1, 3)]);
% Define the global variables
global g_points g_func g_dimensionNumber g_pointsNumber g_stepNo;
g_points = points;
g_func = func;
g_dimensionNumber = dimensionNumber;
g_pointsNumber = pointsNumber;
g_stepNo = stepNo;

% Callback function to update the plot
function updatePlot(~, ~, hAxes)
    global g_points g_func g_dimensionNumber g_pointsNumber g_stepNo points_history std_dev standartDeviationScreen;

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
    center = mean(g_points);
    x1 = center(1);
    y1 = center(2);
    z1 = center(3);
    [X, Y, Z] = sphere(32);
    x = [x1 + 0.5*X(:); x1 + 0.75*X(:); x1 + X(:)];
    y = [y1 + 0.5*Y(:); y1 + 0.75*Y(:); y1 + Y(:)];
    z = [z1 + 0.5*Z(:); z1 + 0.75*Z(:); z1 + Z(:)];
    S = repmat([50,25,10],numel(X),1);
    C = repmat([1,2,3],numel(X),1);
    s = S(:);
    c = C(:);
    scatter3(x,y,z,s,c)
    view(40,35)
    colorbar(hAxes);
    hold(hAxes, 'on');
    plot3(hAxes, g_points(:, 1), g_points(:, 2), g_points(:, 3), 'bo', 'MarkerFaceColor', 'b');
    text(hAxes, g_points(:, 1), g_points(:, 2), g_points(:, 3), arrayfun(@(n) sprintf('S%d', n), 1:size(g_points, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    plotTetrahedron(hAxes, g_points);
    
    g_stepNo = g_stepNo + 1;
    points_history{g_stepNo + 1} = g_points;

    title('Step number : ' + string(g_stepNo));
    std_dev = std(g_points);
    set(standartDeviationScreen, 'String', ['Std Dev     ', 'x :' num2str(std_dev(1,1)), '     y : ', num2str(std_dev(1, 2)), '     z :', num2str(1, 3)]);
end

% Callback function to go back to the previous plot
function previousPlot(~, ~, hAxes)
    global g_stepNo points_history g_func g_points std_dev standartDeviationScreen;

    if g_stepNo <= 0
        return; % Exit if there are no previous steps
    end

    prev_points = points_history{g_stepNo}; % Retrieve previous points
    g_stepNo = g_stepNo - 1;
    g_points = prev_points;

    cla(hAxes);
    center = mean(prev_points);
    x1 = center(1);
    y1 = center(2);
    z1 = center(3);
    [X, Y, Z] = sphere(32);
    x = [x1 + 0.5*X(:); x1 + 0.75*X(:); x1 + X(:)];
    y = [y1 + 0.5*Y(:); y1 + 0.75*Y(:); y1 + Y(:)];
    z = [z1 + 0.5*Z(:); z1 + 0.75*Z(:); z1 + Z(:)];
    S = repmat([50,25,10],numel(X),1);
    C = repmat([1,2,3],numel(X),1);
    s = S(:);
    c = C(:);
    scatter3(x,y,z,s,c)
    view(40,35)
    colorbar(hAxes);
    hold(hAxes, 'on');
    plot3(hAxes, prev_points(:, 1), prev_points(:, 2), prev_points(:, 3), 'bo', 'MarkerFaceColor', 'b');
    text(hAxes, prev_points(:, 1), prev_points(:, 2), prev_points(:, 3), arrayfun(@(n) sprintf('S%d', n), 1:size(prev_points, 1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    plotTetrahedron(hAxes, prev_points);
    
    title('Step number : ' + string(g_stepNo));
    std_dev = std(g_points);
    set(standartDeviationScreen, 'String', ['Std Dev     ', 'x :' num2str(std_dev(1,1)), '     y : ', num2str(std_dev(1, 2)), '     z :', num2str(1, 3)]);
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
