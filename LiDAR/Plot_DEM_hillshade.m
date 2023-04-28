clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               ridgecrest_before.tif               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filenameB = 'ridgecrest_before.tif';
[arrayB, metadataB] = readgeoraster(filenameB);
xB = metadataB.XWorldLimits; % StructuralArray.FieldName - this takes x and y bounds from metadata
yB = metadataB.YWorldLimits;
zB = flipud(arrayB); % you need to flip the way the array is read in so east is positive x and north is positive y.
zB(find(zB==-9999)) = NaN; % Remove blue values (z = -9999); this is noData value

figure(1)
imagesc(xB/1e3, yB/1e3, zB) % x and y in meters, convert to kilometers
axis xy % this reverses the order of y values so numbers increase as you go up
colorbar

dz_xB = diff(zB); % diff of z in the x direction
dz_yB = diff(zB, 1, 2); % diff of z in the y direction, 1st derivative, 2nd dimension (changes light source)
% The standard hillshide light source angle is dz_y. Use this. 


figure(2)
imagesc(xB/1e3, yB/1e3, dz_xB(2:end,:)) % x and y in meters; convert to kilometers
axis xy % this reverses the order of y values so numbers increase as you go up
axis equal % tell plotter that x and y are same units; keeps dimensions proportionate when zooming
colorbar
clim([-1, 1]); % restrict color axis values to smaller range--increases detail
colormap(cpolar); % change the color scheme

figure(3)
imagesc(xB/1e3, yB/1e3, dz_yB(:,2:end)) % x and y in meters, convert to kilometers
axis xy % this reverses the order of y values so numbers increase as you go up
axis equal % tell plotter that x and y are same units; keeps dimensions proportionate
colorbar
clim([-1, 1]); % restrict color axis values to smaller range--increases detail
colormap(cpolar); % change the color scheme

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               ridgecrest_after.tif                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filenameA = 'ridgecrest_after.tif';
[arrayA, metadataA] = readgeoraster(filenameA);
xA = metadataA.XWorldLimits; % StructuralArray.FieldName - this takes x and y bounds from metadata
yA = metadataA.YWorldLimits;
zA = flipud(arrayA); % you need to flip the way the array is read in so east is positive x and north is positive y.
zA(find(zA==-9999)) = NaN; % Remove blue values (z = -9999); this is noData value

figure(4)
imagesc(xA/1e3, yA/1e3, zA) % x and y in meters, convert to kilometers
% z is still in meters
axis xy % this reverses the order of y values so numbers increase as you go up
colorbar

dz_xA = diff(zA); % diff of z in the x direction
dz_yA = diff(zA, 1, 2); % diff of z in the y direction, 1st derivative, 2nd dimension (changes light source)
% The standard hillshide light source angle is dz_y. Use this. 

figure(5)
imagesc(xA/1e3, yA/1e3, dz_xA) % x and y in meters; convert to kilometers
axis xy % this reverses the order of y values so numbers increase as you go up
axis equal % tell plotter that x and y are same units; keeps dimensions proportionate when zooming
colorbar
clim([-1, 1]); % restrict color axis values to smaller range--increases detail
colormap(cpolar); % change the color scheme

figure(6)
imagesc(xA/1e3, yA/1e3, dz_yA) % x and y in meters, convert to kilometers
axis xy % this reverses the order of y values so numbers increase as you go up
axis equal % tell plotter that x and y are same units; keeps dimensions proportionate
colorbar
clim([-1, 1]); % restrict color axis values to smaller range--increases detail
colormap(cpolar); % change the color scheme

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Vertical Motion during EQ              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Slip in the vertical (y) direction (
% dz_yC = (dz_yA - dz_yB);
% [min_yC, max_yC] = bounds(dz_yC, 'all');

% figure('Name', 'Vertical Displacement from 2019 Ridgecrest Earthquake', 'NumberTitle', 'off');
% im_yC = imagesc(xA/1e3, yA/1e3, dz_yC); % x and y in meters, convert to kilometers
% title('Vertical Motion from Ridgecrest 2019 Earthquake');
% axis xy % this reverses the order of y values so numbers increase as you go up
% axis equal % tell plotter that x and y are same units; keeps dimensions proportionate
% cb = colorbar('Location', 'southoutside');
% clim([-1, 1]); % restrict color axis values to smaller range--increases detail
% colormap(flipud(cpolar)); % change the color scheme
% ylabel(cb, 'Vertical Motion (meters north)', 'FontWeight', 'bold'); % uncertain of units