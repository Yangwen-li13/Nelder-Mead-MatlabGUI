function pointsSorted = sortVectors(pointsNumber, dimensionNumber, points, func)
%% We need to sort points according to their values.
Results_points = zeros(pointsNumber, 1);
pointsSorted = zeros(pointsNumber, dimensionNumber);
for i = 1:pointsNumber
    pointscell = num2cell(points(i, 1:dimensionNumber));
    current_value = func(pointscell{:});
    Results_points(i) = current_value;
end
[resultsSorted, I] = sort(Results_points);
for i = 1:dimensionNumber
    pointsSorted(:,i) = points(I,i);
end
% Now we have sorted values and points that sorted based on their values.
end