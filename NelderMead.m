%% Now, let's apply the algorithm to obtain better case.
function newPointsVector = NelderMead(SortedPointsVector, func)
global nextCase;

num_dims = size(SortedPointsVector, 2);
num_points = size(SortedPointsVector,1);

% Delete the worst case from points vector
remainingPoints = SortedPointsVector;
remainingPoints(num_points, :) = [];

worstPoint = num2cell(SortedPointsVector(end, :));
bestPoint = num2cell(SortedPointsVector(1, :));
lastRemainingPoint = num2cell(SortedPointsVector(end-1, :));

lastRemainingPoint_value = func(lastRemainingPoint{:});
bestPoint_value = func(bestPoint{:});
worstPoint_value = func(worstPoint{:});

% Now calculate some variables to use
centroid = mean(remainingPoints);
% Reflect the worst point and check

newPoint = 2 * centroid - cell2mat(worstPoint);
newPoint = num2cell(newPoint(1, 1:num_dims));
newPoint_value = func(newPoint{:});

% New value is between the last remaining and best value.
if (newPoint_value < lastRemainingPoint_value && newPoint_value >= bestPoint_value)
    newPointsVector = [remainingPoints; cell2mat(newPoint)];
    currentcase = 'Next Case : Reflection';
    set(nextCase, 'String', currentcase);

% New value is best value.
elseif (newPoint_value < bestPoint_value)
    newPoint_2 = 3 * centroid - 2 * cell2mat(worstPoint);
    newPoint_2 = num2cell(newPoint_2(1, 1:num_dims));
    newPoint_2_value = func(newPoint_2{:});
    if(newPoint_2_value < bestPoint_value)
        newPointsVector = [remainingPoints; cell2mat(newPoint_2)];
        currentcase = 'Next Case : Expansion';
        set(nextCase, 'String', currentcase);
    else
        newPointsVector = [remainingPoints; cell2mat(newPoint)];
        currentcase = 'Next Case : Reflection';
        set(nextCase, 'String', currentcase);
    end   

% New value is the worst.
elseif (newPoint_value >= lastRemainingPoint_value)
    if (newPoint_value < worstPoint_value)
        n2 = centroid + (cell2mat(newPoint) - centroid)/2;
        n2 = num2cell(n2(1, 1:num_dims));
        n2_value = func(n2{:});
        if (n2_value < newPoint_value)
            newPointsVector = [remainingPoints; cell2mat(n2)];
            currentcase = 'Next Case : Contract Outside';
            set(nextCase, 'String', currentcase);
        else
            v = zeros(num_points,num_dims);
            for i = 1:num_points
                for k = 1:num_dims
                    v(i,k) = bestPoint(1,k) + (SortedPointsVector(i,k)-bestPoint(1,k))/2;
                end
            end
            newPointsVector = cell2mat(v);
            currentcase = 'Next Case : Shrink';
            set(nextCase, 'String', currentcase);
        end
    elseif (newPoint_value >= worstPoint_value)
        n3 = centroid + (cell2mat(worstPoint) - centroid)/2;
        n3 = num2cell(n3(1, 1:num_dims));
        n3_value = func(n3{:});
        if(n3_value < worstPoint_value)
            newPointsVector = [remainingPoints; cell2mat(n3)];
            currentcase = 'Next Case : Contract inside';
            set(nextCase, 'String', currentcase);
        else
            v = zeros(num_points,num_dims);
            for i = 1:num_points
                for k = 1:num_dims
                    v(i,k) = bestPoint(1,k) + (SortedPointsVector(i,k)-bestPoint(1,k))/2;
                end
            end
            newPointsVector = cell2mat(v);
            currentcase = 'Next Case : Shrink';
            set(nextCase, 'String', currentcase);
        end
    end
end
end
