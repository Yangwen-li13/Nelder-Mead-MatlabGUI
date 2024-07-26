function saveDataNelderMeads(PointsNumber)
global std_dev_history volume_history points_history std_dev_history area_history meanpoint;

if PointsNumber == 3
save('Nelder-Meads.mat', 'points_history', 'area_history', 'meanpoint', 'std_dev_history');

elseif PointsNumber == 4
save('Nelder-Meads.mat', 'points_history', 'volume_history', 'meanpoint', 'std_dev_history');

end