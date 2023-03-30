clear 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Fort Hood Before DEM               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filenameBE = 'FortHood_2011_Before_DEM_clip.tif'; % Clipped in ArcGIS to match extents
[arrayBE, metadataBE] = readgeoraster(filenameBE); 
xBE = metadataBE.XWorldLimits; % StructuralArray.FieldName - this takes x and y bounds from metadata
yBE = metadataBE.YWorldLimits; 
zBE = flipud(arrayBE); % you need to flip the way the array is read in so east is positive x and north is positive y.
zBE(zBE == -9999) = NaN; % Remove values (z = -9999); this is noData value

dz_yBE = diff(zBE, 1, 2); % diff of z in the y direction, 1st derivative, 2nd dimension (changes light source)

% Plot ground hillshade for Fort Hood Before
figure('Name', 'Fort Hood Before Hillshade - Ground', 'NumberTitle', 'off');
imagesc(xBE/1e3, yBE/1e3, dz_yBE); % x and y in meters, convert to kilometers
title('Ground Hillshade - Before');
axis xy % this reverses the order of y values so numbers increase as you go up
axis equal % tell plotter that x and y are same units; keeps dimensions proportionate
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
clim([-1, 1]); % restrict color axis values to smaller range--increases detail
colormap(flipud(cpolar)); % change the color scheme


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Fort Hood Before DSM               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filenameBS = 'FortHood_2011_Before_DSM_clip.tif'; 
[arrayBS, metadataBS] = readgeoraster(filenameBS); 
xBS = metadataBS.XWorldLimits; 
yBS = metadataBS.YWorldLimits; 
zBS = flipud(arrayBS); 
zBS(zBS == -9999) = NaN;

dz_yBS = diff(zBS, 1, 2); 

% Plot surface hillshade for Fort Hood Before
figure('Name', 'Fort Hood Before Hillshade - Surface', 'NumberTitle', 'off');
imagesc(xBS/1e3, yBS/1e3, dz_yBS); 
title('Surface Hillshade - Before');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
clim([-1, 1]); 
colormap(flipud(cpolar)); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Fort Hood Before Canopy Height            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
zBC = (zBS - zBE); % First return - ground return (surface - elevation)
[min_zBC, max_zBC] = bounds(zBC, 'all');

% Plot 2D Canopy Height Model using before data 
figure('Name', 'Canopy Height Model Before 2011 Jack Mountain Fire', 'NumberTitle', 'off');
imagesc(xBE/1e3, yBE/1e3, zBC, 'AlphaData', ~isnan(zBC)) % AlphaData sets NaNs to background value
set(gca, 'Color', [0.8 0.8 0.8]); % Change background color to gray 
title('Canopy Height Model Months Before');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
clim([0, 1]); 
cbr = colorbar('Location', 'southoutside'); % Place colorbar below the x-axis (and outside)
cbr.Label.String = 'Canopy Height'; % Label the colorbar
cbr.Label.FontWeight = 'bold'; % Bold colorbar label
cbr.Label.FontSize = 10; % Colorbar label font size 10

% Plot canopy hillshade for Fort Hood Before
figure('Name', 'Fort Hood Canopy Hillshade Before', 'NumberTitle', 'off');
imagesc(xBS/1e3, yBS/1e3, (dz_yBS - dz_yBE));
title('Canopy Hillshade - Before');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
clim([-1, 1]);
colormap(flipud(cpolar));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Fort Hood After DEM                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filenameAE = 'FortHood_2017_After_DEM_clip.tif'; 
[arrayAE, metadataAE] = readgeoraster(filenameAE);
xAE = metadataAE.XWorldLimits; 
yAE = metadataAE.YWorldLimits;
zAE = flipud(arrayAE); 
zAE(zAE == -9999) = NaN; 

dz_yAE = diff(zAE, 1, 2); 

% Plot ground hillshade for Fort Hood Before
figure('Name', 'Fort Hood After Hillshade - Ground', 'NumberTitle', 'off');
imagesc(xAE/1e3, yAE/1e3, dz_yAE); 
title('Ground Hillshade - After');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
clim([-1, 1]); 
colormap(flipud(cpolar)); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Fort Hood After DSM                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filenameAS = 'FortHood_2017_After_DSM_clip.tif'; 
[arrayAS, metadataAS] = readgeoraster(filenameAS);
xAS = metadataAS.XWorldLimits;
yAS = metadataAS.YWorldLimits;
zAS = flipud(arrayAS); 
zAS(zAS == -9999) = NaN;
 
dz_yAS = diff(zAS, 1, 2); 

% Plot surface hillshade for Fort Hood After
figure('Name', 'Fort Hood After Hillshade - Surface', 'NumberTitle', 'off');
imagesc(xAS/1e3, yAS/1e3, dz_yAS); 
title('Surface Hillshade - After');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
clim([-1, 1]);
colormap(flipud(cpolar));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Fort Hood After Canopy Height            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
zAC = (zAS - zAE);
[min_zAC, max_zAC] = bounds(zAC, 'all');

% Plot 2D Canopy Height Model using before data 
figure('Name', 'Canopy Height Model After 2011 Jack Mountain Fire', 'NumberTitle', 'off');
imagesc(xAE/1e3, yAE/1e3, zAC, 'AlphaData', ~isnan(zAC)) 
set(gca, 'Color', [0.8 0.8 0.8]); 
title('Canopy Height Model 6 Years After');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
clim([0, 1]); 
cbr = colorbar('Location', 'southoutside');
cbr.Label.String = 'Canopy Height';
cbr.Label.FontWeight = 'bold';
cbr.Label.FontSize = 10; 

% Plot canopy hillshade for Fort Hood After
figure('Name', 'Fort Hood Canopy Hillshade After', 'NumberTitle', 'off');
imagesc(xAS/1e3, yAS/1e3, (dz_yAS - dz_yAE)); 
title('Canopy Hillshade - After');
axis xy 
axis equal
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
clim([-1, 1]);
colormap(flipud(cpolar));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Canopy Height Vertical Difference         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
zCC = (zAC - zBC); % (canopy height model after) - (canopy height model before)
[min_zCC, max_zCC] = bounds(zCC, 'all');

% 2D plot of canopy height difference six years after the 2011 jack
% mountain fire in Fort Hood
figure('Name', 'Canopy Height Difference Six Years After 2011 Jack Mountain Fire', 'NumberTitle', 'off');
imagesc(xAE/1e3, yAE/1e3, zCC, 'AlphaData', ~isnan(zCC))
set(gca, 'Color', [0.8 0.8 0.8]);
title('Canopy Height Difference 6 Years After');
axis xy
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
clim([-3, 3]);
cbr = colorbar('Location', 'southoutside');
cbr.Label.String = 'Height Difference';
cbr.Label.FontWeight = 'bold';
cbr.Label.FontSize = 10; 
colormap(flipud(cpolar));
