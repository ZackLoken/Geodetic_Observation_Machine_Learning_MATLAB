clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Flood Mapping Using RTC SAR in dB Scale      %      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Load in the data
%

% RTC pre-2016 historic Lousiana floods: August 7, 2016
pre_file = "S1A_IW_20160807T000141_DVP_RTC10_G_sdufem_5DD1_VV.tif";
[array_pre, metadata_pre] = readgeoraster(pre_file); 
x_pre = metadata_pre.XWorldLimits; % StructuralArray.FieldName - this takes x and y bounds from metadata
y_pre = metadata_pre.YWorldLimits; 
dB_pre = flipud(array_pre); % you need to flip the way the array is read in so east is positive x and north is positive y.

% RTC co-2016 historic Louisiana floods: August 19, 2016
% Clipped to extent of pre_file using ArcGIS
co_file = "S1A_IW_20160819T000142_DVP_RTC10_G_sdufem_DD67_VV_clip.tif";
[array_co, metadata_co] = readgeoraster(co_file);
x_co = metadata_co.XWorldLimits; 
y_co = metadata_co.YWorldLimits; 
dB_co = flipud(array_co); 


%
% Mask the dB values using global threshold of -14.5. Value was chosen by
% viewing histograms for each of two images and determining where the
% natural split between peaks occurred. Values less than or equal to global
% threshold are classified as having water. 
%

dB_pre(dB_pre > -14.5 | dB_pre < -60) = NaN; % Values above global threshold are not water, set to NaN
dB_co(dB_co > -14.5 | dB_co < -60) = NaN; % < -60 are outliers in data


%
% Plot the data for visual inspection
%

figure('Name', 'Pre-event dB Scale Values: August 7, 2016', 'NumberTitle', 'off');
imagesc(x_pre/1e3, y_pre/1e3, dB_pre, 'AlphaData', ~isnan(dB_pre)); % x and y in meters, convert to kilometers
title('Pre-event Surface Water: August 7, 2016');
axis xy % this reverses the order of y values so numbers increase as you go up
axis equal % tell plotter that x and y are same units; keeps dimensions proportionate
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
% clim([-1, 1]); % restrict color axis values to smaller range--increases detail
colormap(flipud(cpolar)); % change the color scheme

figure('Name', 'Co-event dB Scale Values: August 7, 2016', 'NumberTitle', 'off');
imagesc(x_co/1e3, y_co/1e3, dB_co, 'AlphaData', ~isnan(dB_co));
title('Co-event Surface Water: August 19, 2016');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
% clim([-1, 1]);
colormap(flipud(cpolar));


%
% Calculate change between pre- and co-event images to determine which
% pixels weren't water pre-event and are now water during event. These
% pixels represent flooded areas. 
%

flooded = dB_co - dB_pre; % subtract pre-event from co-event
[min_flooded, max_flooded] = bounds(flooded, 'all');


%
% Visualize the results -- this is your flood map
%

figure('Name', 'Change in dB Scale Values: Pre- and Co-event', 'NumberTitle', 'off');
imagesc(x_pre/1e3, y_pre/1e3, flooded, 'AlphaData', ~isnan(flooded)); 
title('Flooding in Southeastern Louisiana: August 19, 2016');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
clim([0, 1]);
colormap(flipud(cpolar)); 


%
% flooded values > 0 have gotten wetter since pre-event. Mask out values < 0
%

flooded(flooded < 0) = NaN;


%
% Convert UTM to latlong
%

[xmesh,ymesh] = meshgrid(x_pre, y_pre);
[lat, lon] = utm2ll(xmesh, ymesh, 16);


%
% Save the flood data as a geoTIFF
%

R = georasterref('RasterSize', size(flooded), 'LatitudeLimits', [min(lat), max(lat)], ...
    'LongitudeLimits', [min(lon), max(lon)]); 
output_tif = '2016_historic_floods.tif';
geotiffwrite(output_tif, flooded, R);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Damage Mapping Using InSAR Coherence        %      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Load in the data
%

% Coherence image created from interferometry using two pre-event scenes
pre_file = "S1AA_20160726T000140_20160807T000141_VVP012_INT80_G_ueF_7B19_corr_clip.tif";
[array_pre, metadata_pre] = readgeoraster(pre_file); 
x_pre = metadata_pre.XWorldLimits; 
y_pre = metadata_pre.YWorldLimits; 
coh_pre = flipud(array_pre); 

% Coherence image created from interferometry using one pre- and one
% co-event scene
co_file = "S1AA_20160807T000141_20160819T000142_VVP012_INT80_G_ueF_1DF1_corr.tif";
[array_co, metadata_co] = readgeoraster(co_file); 
x_co = metadata_co.XWorldLimits; 
y_co = metadata_co.YWorldLimits; 
coh_co = flipud(array_co); 


%
% Calculate Coherence difference (COD): subtract coh_co from coh_pre
%

COD = coh_pre - coh_co; 


%
% Visualize the results -- this is change in coherence (loss/gain)
% Negative COD (coh gain) results from pre-event surface changes
% Positive COD (coh loss) results from co-event surface changes
%

figure('Name', 'Change in Coherence: Pre- and Co-event', 'NumberTitle', 'off');
imagesc(x_pre/1e3, y_pre/1e3, COD, 'AlphaData', ~isnan(COD)); 
title('Interferometric Coherence Difference: Southeastern LA');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
clim([-1, 1]);
colormap(cpolar); 


%
% Mask out negative COD--this is surface change that occurred pre-event
%
%

COD(COD < 0.5) = NaN; % Set threshold manually using COD plot results for insight


%
% Visualize the results -- this is the flood damage map
%

figure('Name', 'Change in Coherence: Pre- and Co-event', 'NumberTitle', 'off');
imagesc(x_pre/1e3, y_pre/1e3, COD, 'AlphaData', ~isnan(COD)); 
title('Flood Damage in Southeastern LA: August 19, 2016');
axis xy 
axis equal 
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
colorbar
clim([-1, 1]);
colormap(cpolar); 


%
% Convert UTM to latlong
%

[xmesh,ymesh] = meshgrid(x_pre, y_pre);
[lat, lon] = utm2ll(xmesh, ymesh, 16);


%
% Save the flood data as a geoTIFF
%

R = georasterref('RasterSize', size(COD), 'LatitudeLimits', [min(lat), max(lat)], ...
    'LongitudeLimits', [min(lon), max(lon)]); 
output_tif = '2016_historic_floods_damage.tif';
geotiffwrite(output_tif, COD, R);