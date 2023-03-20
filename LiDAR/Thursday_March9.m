clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               ridgecrest_before.tif               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filenameB = 'ridgecrest_before.tif';
[arrayB, metadataB] = readgeoraster(filenameB);
xB = metadataB.XWorldLimits; % StructuralArray.FieldName - this takes x and y bounds from metadata
yB = metadataB.YWorldLimits;
zB = flipud(arrayB); % you need to flip the way the array is read in so east is positive x and north is positive y.
zB(zB==-9999) = NaN; % Remove values (z = -9999); this is noData value

dz_xB = diff(zB); % diff of z in the x direction
dz_yB = diff(zB, 1, 2); % diff of z in the y direction, 1st derivative, 2nd dimension (changes light source)
% The standard hillshide light source angle is dz_y. Use this. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               ridgecrest_after.tif                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filenameA = 'ridgecrest_after.tif';
[arrayA, metadataA] = readgeoraster(filenameA);
xA = metadataA.XWorldLimits; % StructuralArray.FieldName - this takes x and y bounds from metadata
yA = metadataA.YWorldLimits;
zA = flipud(arrayA); % you need to flip the way the array is read in so east is positive x and north is positive y.
zA(zA==-9999) = NaN; % Remove values (z = -9999); this is noData value

dz_xA = diff(zA); % diff of z in the x direction
dz_yA = diff(zA, 1, 2); % diff of z in the y direction, 1st derivative, 2nd dimension (changes light source)
% The standard hillshide light source angle is dz_y. Use this. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Vertical Difference Post-earthquake        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
zC = (zA - zB); % after - before
[min_zC, max_zC] = bounds(zC, 'all');

figure('Name', 'Change in Elevation from 2019 Ridgecrest Earthquake', 'NumberTitle', 'off');
imagesc(xA/1e3, yA/1e3, zC, 'AlphaData', ~isnan(zC)) % x and y converted to kilometers, AlphaData sets NaNs to background value
set(gca, 'Color', [0.8 0.8 0.8]); % Change background color to gray 
title('Elevational Change from Ridgecrest 2019 Earthquake');
axis xy % this reverses the order of y values so numbers increase as you go up
axis equal % tell plotter that x and y are same units; keeps dimensions proportionate
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
clim([-12, 12]); % Colorbar limits 
% clim([min_zC, max_zC]);
cbr = colorbar('Location', 'southoutside'); % Place colorbar below the x-axis (and outside)
set(cbr, 'YTick', -12:2:12); % Place ytick every 2 units
cbr.Label.String = 'Vertical Difference (m)'; % Label the colorbar
cbr.Label.FontWeight = 'bold'; % Bold colorbar label
cbr.Label.FontSize = 10; % Colorbar label font size 10
cmap = colormap(flipud(cpolar));




