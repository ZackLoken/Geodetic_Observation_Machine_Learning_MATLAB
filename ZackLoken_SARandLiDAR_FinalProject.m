clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Surface Water Mapping Using RTC SAR in dB Scale  %      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Load in sample data
%

% RTC from pre-duck season: November 13, 2018
% Clipped to Arkansas MAV boundary using ArcGIS
pre_file = "11132018_MAV_dB_clip.tif";
[array_pre, metadata_pre] = readgeoraster(pre_file); 
x_pre = metadata_pre.XWorldLimits; % StructuralArray.FieldName - this takes x and y bounds from metadata
y_pre = metadata_pre.YWorldLimits; 
dB_pre = flipud(array_pre); % you need to flip the way the array is read in so east is positive x and north is positive y.

% RTC from mid-duck season: December 19, 2018
% Clipped to Arkansas MAV boundary using ArcGIS
mid_file = "12192018_MAV_dB_clip.tif";
[array_mid, metadata_mid] = readgeoraster(mid_file);
x_mid = metadata_mid.XWorldLimits; 
y_mid = metadata_mid.YWorldLimits; 
dB_mid = flipud(array_mid); 

% RTC from post-duck season: February 17, 2019
% Clipped to Arkansas MAV boundary using ArcGIS
post_file = "02172019_MAV_dB_clip.tif";
[array_post, metadata_post] = readgeoraster(post_file);
x_post = metadata_post.XWorldLimits; 
y_post = metadata_post.YWorldLimits; 
dB_post = flipud(array_post); 

%
% Mask the dB values using global threshold of -18.2. Value was chosen by
% viewing histograms for each of two images and determining where the
% natural split between peaks occurred. Values less than or equal to global
% threshold are classified as having water. 
%

dB_pre(dB_pre > -18.2 | dB_pre < -60) = NaN; % Values above global threshold are not water, set to NaN
dB_mid(dB_mid > -18.2 | dB_mid < -60) = NaN; % < -60 are noData values
dB_post(dB_post > -18.2 | dB_post < -60) = NaN;


%
% Plot the sample surface water data
%

% Pre-season
figure('Name', 'Pre-season dB Scale Values: November 13, 2018', 'NumberTitle', 'off');
imagesc(x_pre/1e3, y_pre/1e3, dB_pre, 'AlphaData', ~isnan(dB_pre)); % x and y in meters, convert to kilometers
title('Pre-season Surface Water: November 13, 2018');
axis xy % this reverses the order of y values so numbers increase as you go up
axis equal % tell plotter that x and y are same units; keeps dimensions proportionate
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
% clim([-1, 1]); % restrict color axis values to smaller range--increases detail
colormap(flipud(cpolar)); % change the color scheme

% Mid-season
figure('Name', 'Mid-season dB Scale Values: December 19, 2018', 'NumberTitle', 'off');
imagesc(x_mid/1e3, y_mid/1e3, dB_mid, 'AlphaData', ~isnan(dB_mid));
title('Mid-season Surface Water: December 19, 2018');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
% clim([-1, 1]);
colormap(flipud(cpolar));

% Post-season
figure('Name', 'Post-season dB Scale Values: February 17, 2019', 'NumberTitle', 'off');
imagesc(x_post/1e3, y_post/1e3, dB_post, 'AlphaData', ~isnan(dB_post));
title('Post-season Surface Water: February 17, 2019');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
% clim([-1, 1]);
colormap(flipud(cpolar));


%
% Convert UTM to latlong
%

% Pre-season
[xmesh,ymesh] = meshgrid(x_pre, y_pre);
[lat, lon] = utm2ll(xmesh, ymesh, 15); % UTM Zone 15N

% Mid-season
[xmesh,ymesh] = meshgrid(x_mid, y_mid);
[lat, lon] = utm2ll(xmesh, ymesh, 15); % UTM Zone 15N

% Post-season
[xmesh,ymesh] = meshgrid(x_post, y_post);
[lat, lon] = utm2ll(xmesh, ymesh, 15); % UTM Zone 15N


%
% Save the surface water data as a geoTIFF
%

% Pre-season
R = georasterref('RasterSize', size(dB_pre), 'LatitudeLimits', [min(lat), max(lat)], ...
    'LongitudeLimits', [min(lon), max(lon)]); 
output_tif = 'SurfaceWater_11132018.tif';
geotiffwrite(output_tif, dB_pre, R, 'TiffType', 'bigtiff');

% Mid-season
R = georasterref('RasterSize', size(dB_mid), 'LatitudeLimits', [min(lat), max(lat)], ...
    'LongitudeLimits', [min(lon), max(lon)]); 
output_tif = 'SurfaceWater_12192018.tif';
geotiffwrite(output_tif, dB_mid, R, 'TiffType', 'bigtiff');

% Post-season
R = georasterref('RasterSize', size(dB_post), 'LatitudeLimits', [min(lat), max(lat)], ...
    'LongitudeLimits', [min(lon), max(lon)]); 
output_tif = 'SurfaceWater_02172019.tif';
geotiffwrite(output_tif, dB_post, R, 'TiffType', 'bigtiff');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Annual Growth using LiDAR-derived CHM        %      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Load the LiDAR data--using Fort Hood LiDAR as a visual sample due to
% lack of time for finding a more relevant dataset. 
%

% Fort hood pre DEM
filenameBE = 'FortHood_2011_Before_DEM_clip.tif'; % Clipped in ArcGIS to match extents
[arrayBE, metadataBE] = readgeoraster(filenameBE); 
xBE = metadataBE.XWorldLimits; % StructuralArray.FieldName - this takes x and y bounds from metadata
yBE = metadataBE.YWorldLimits; 
zBE = flipud(arrayBE); % you need to flip the way the array is read in so east is positive x and north is positive y.
zBE(zBE == -9999) = NaN; % Remove values (z = -9999); this is noData value

dz_yBE = diff(zBE, 1, 2); % diff of z in the y direction, 1st derivative, 2nd dimension (changes light source)

% Fort hood pre DSM
filenameBS = 'FortHood_2011_Before_DSM_clip.tif'; 
[arrayBS, metadataBS] = readgeoraster(filenameBS); 
xBS = metadataBS.XWorldLimits; 
yBS = metadataBS.YWorldLimits; 
zBS = flipud(arrayBS); 
zBS(zBS == -9999) = NaN;

dz_yBS = diff(zBS, 1, 2);

% Fort hood post DEM
filenameAE = 'FortHood_2017_After_DEM_clip.tif'; 
[arrayAE, metadataAE] = readgeoraster(filenameAE);
xAE = metadataAE.XWorldLimits; 
yAE = metadataAE.YWorldLimits;
zAE = flipud(arrayAE); 
zAE(zAE == -9999) = NaN; 

dz_yAE = diff(zAE, 1, 2); 

% Fort hood post DSM
filenameAS = 'FortHood_2017_After_DSM_clip.tif'; 
[arrayAS, metadataAS] = readgeoraster(filenameAS);
xAS = metadataAS.XWorldLimits;
yAS = metadataAS.YWorldLimits;
zAS = flipud(arrayAS); 
zAS(zAS == -9999) = NaN;
 
dz_yAS = diff(zAS, 1, 2); 


%
% Subtract DEM from DSM to create your pre and post canopy height models. 
%

% Fort hood pre CHM
zBC = (zBS - zBE); % First return - ground return (surface - elevation)
[min_zBC, max_zBC] = bounds(zBC, 'all');

% Plot 2D Canopy Height Model using pre data 
figure('Name', 'Canopy Height Model Before 2011 Jack Mountain Fire', 'NumberTitle', 'off');
imagesc(xBE/1e3, yBE/1e3, zBC, 'AlphaData', ~isnan(zBC)) % AlphaData sets NaNs to background value
set(gca, 'Color', [0.8 0.8 0.8]); % Change background color to gray 
title('Canopy Height Model Before');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
clim([0, 1]); 
cbr = colorbar; % Place colorbar below the x-axis (and outside)
cbr.Label.String = 'Scaled Canopy Height'; % Label the colorbar
cbr.Label.FontWeight = 'bold'; % Bold colorbar label
cbr.Label.FontSize = 10; % Colorbar label font size 10

% Fort hood post CHM
zAC = (zAS - zAE);
[min_zAC, max_zAC] = bounds(zAC, 'all');

% Plot 2D Canopy Height Model using post data 
figure('Name', 'Canopy Height Model After 2011 Jack Mountain Fire', 'NumberTitle', 'off');
imagesc(xAE/1e3, yAE/1e3, zAC, 'AlphaData', ~isnan(zAC)) 
set(gca, 'Color', [0.8 0.8 0.8]); 
title('Canopy Height Model After');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
clim([0, 1]); 
cbr = colorbar;
cbr.Label.String = 'Scaled Canopy Height';
cbr.Label.FontWeight = 'bold';
cbr.Label.FontSize = 10; 


%
% Calculate vertical difference between pre and post CHMs. These are your
% growth values. Subtract pre CHM from post CHM. 
%

% Canopy height vertical difference
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
clim([-1, 1]);
cbr = colorbar;
cbr.Label.String = 'Scaled Height Difference';
cbr.Label.FontWeight = 'bold';
cbr.Label.FontSize = 10; 
