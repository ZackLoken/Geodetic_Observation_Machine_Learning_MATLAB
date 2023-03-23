clear 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Kumamoto Before DEM               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filenameB = 'compare_dem_before.tif'; 
[arrayB, metadataB] = readgeoraster(filenameB); 
xB = metadataB.XWorldLimits; % StructuralArray.FieldName - this takes x and y bounds from metadata
yB = metadataB.YWorldLimits; 
zB = flipud(arrayB); % you need to flip the way the array is read in so east is positive x and north is positive y.
zB(zB==-9999) = NaN; % Remove values (z = -9999); this is noData value

dz_xB = diff(zB); % diff of z in the x direction
dz_yB = diff(zB, 1, 2); % diff of z in the y direction, 1st derivative, 2nd dimension (changes light source)
% The standard hillshide light source angle is dz_y. Use this. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Kumamoto After DEM                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filenameA = 'reference_dem_after.tif';
[arrayA, metadataA] = readgeoraster(filenameA);
xA = metadataA.XWorldLimits; % StructuralArray.FieldName - this takes x and y bounds from metadata
yA = metadataA.YWorldLimits;
zA = flipud(arrayA); % you need to flip the way the array is read in so east is positive x and north is positive y.
zA(zA==-9999) = NaN; % Remove values (z = -9999); this is noData value

dz_xA = diff(zA); % diff of z in the x direction
dz_yA = diff(zA, 1, 2); % diff of z in the y direction, 1st derivative, 2nd dimension (changes light source)
% The standard hillshide light source angle is dz_y. Use this. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Vertical Difference from DEM            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
zC = (zA - zB); % after - before
[min_zC, max_zC] = bounds(zC, 'all');

% figure('Name', 'Change in Elevation from 2016 Kumamoto Earthquake', 'NumberTitle', 'off');
% imagesc(xA/1e3, yA/1e3, zC, 'AlphaData', ~isnan(zC)) % x and y converted to kilometers, AlphaData sets NaNs to background value
% set(gca, 'Color', [0.8 0.8 0.8]); % Change background color to gray 
% title('Elevational Change from 2016 Kumamoto Earthquake');
% axis xy % this reverses the order of y values so numbers increase as you go up
% axis equal % tell plotter that x and y are same units; keeps dimensions proportionate
% xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
% ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
% clim([-36, 36]); % Colorbar limits 
% cbr = colorbar('Location', 'southoutside'); % Place colorbar below the x-axis (and outside)
% set(cbr, 'YTick', -36:6:36); % Place ytick every 2 units
% cbr.Label.String = 'Vertical Difference (m)'; % Label the colorbar
% cbr.Label.FontWeight = 'bold'; % Bold colorbar label
% cbr.Label.FontSize = 10; % Colorbar label font size 10
% cmap = colormap(flipud(cpolar));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             3D Vertical Differencing              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf([datestr(now),'\n']) % keep track of time

% Read in point cloud data

  filename = 'comp_points_before.laz'; % This one is 6 M points
  lasreader = lasFileReader(filename);
  ptcloud = readPointCloud(lasreader);
  pre_xyz = ptcloud.Location;

  filename = 'ref_points_after.laz'; % This one is 10 M points
  lasreader = lasFileReader(filename);
  ptcloud = readPointCloud(lasreader);
  post_xyz = ptcloud.Location;

  pre_x = pre_xyz(:,1);
  pre_y = pre_xyz(:,2);
  pre_z = pre_xyz(:,3);

  post_x = post_xyz(:,1);
  post_y = post_xyz(:,2);
  post_z = post_xyz(:,3);

% visualize the point clouds
%  - tip: for a quicker, less memory intensive ways to view these,
%    view in 2D, and/or downsample and view fewer points

  isubset = round(rand(1e4, 1) * 10e6);

  % a 2D plot
%   figure(1), clf
%   scatter(post_x(isubset)/1e3, post_y(isubset)/1e3, 5, post_z(isubset), 'filled');
%   axis equal;
%   colorbar;

  % a 3D plot
%   figure(2), clf
%   scatter3(post_x(isubset)/1e3, post_y(isubset)/1e3, post_z(isubset), 5, post_z(isubset), 'filled');
%   colorbar;

% set parameters for the differencing windows

  % This set took ~30 seconds to run on Karen's computer
  grd = 50; % Grid spacing in meters; make equal to sz if time allows 
  sz = 25;   % Differencing window size in meters
  margin = 5; % Additional dimension of post-earthquake window. Must be larger than the expect surface displacement


% Construct a core point grid for differencing 

  grid_x_points = [min(pre_x):grd:max(pre_x)];
  grid_y_points = [min(pre_y):grd:max(pre_y)];

  [core_x,core_y] = meshgrid(grid_x_points,grid_y_points);
  core_x = core_x(:);
  core_y = core_y(:);


% loop over grid sections to perform ICP

  for i = 1:length(core_x)
    
    % This is the center of the grid point in question
    
      x0 = core_x(i);
      y0 = core_y(i);
     
    
    % find the set of points that are within the specified window size
    % around the core point. (the after gets a slightly larger window)
    
      ib = find(pre_x > x0-sz/2 & pre_x < x0+sz/2 & pre_y > y0-sz/2 & pre_y < y0+sz/2);
      
      sz_a = sz + 2 * margin;
      ia = find(post_x > x0-sz_a/2 & post_x < x0+sz_a/2 & post_y > y0-sz_a/2 & post_y < y0+sz_a/2);

    
    % shift (0,0,0) to lie at the center of the grid 
    
      xmean = mean(pre_x(ib));
      ymean = mean(pre_y(ib));
      zmean = mean(pre_z(ib));

    % get the before and after datasets in the right format:
    %  - 

      clear q_before p_after % clear these out after each run, because each set of points is a different length
      q_before(1,:) = pre_x(ib) - xmean;
      q_before(2,:) = pre_y(ib) - ymean;
      q_before(3,:) = pre_z(ib) - zmean;

      p_after(1,:) = post_x(ia) - xmean;
      p_after(2,:) = post_y(ia) - ymean;
      p_after(3,:) = post_z(ia) - zmean;

    
    % Perform the actual iterative closest point differencing
    %  - could run in point-to-plane or point-to-point modes
    %    Try both and see if/when there's a difference
    
    % Usage: [TR, TT, ER, t] = icp(p_after, q_before, 'Minimize', 'plane');
    % Output:
    %  - TR: Rotation
    %  - TT: Displacement 
    %  - ER: RMS error after each rotation
    %  - t: Calculations time per interation 
    % (we mostly just care about displacement)
    
      [~,translation] = icp(p_after, q_before, 'Minimize', 'plane');
      % [~,translation] = icp(p_after,q_before,'Minimize','point');

    
    % store the results in a simple way: single Nx5 array
    
      results(i,:) = [core_x(i) core_y(i) translation'];
  end

% plot differencing results 

%   figure(3), clf
%   quiver(results(:,1)/1e3, results(:,2)/1e3, results(:,3), results(:,4), 'k', 'LineWidth', 1);
%   hold on 
%   scatter(results(:,1)/1e3, results(:,2)/1e3, 45, results(:,5), 'filled');
%   axis equal;
%   colorbar;
%   caxis([-1,1]);
%   colormap(cpolar);

% As a demo, plot example point clouds from one window

  i = find(core_x == -14000 & core_y == -22100);
  x0 = core_x(i);
  y0 = core_y(i);
     
  ib = find(pre_x > x0-sz/2 & pre_x < x0+sz/2 & pre_y > y0-sz/2 & pre_y < y0+sz/2);
  sz_a = sz + 2 * margin;
  ia = find(post_x > x0-sz_a/2 & post_x < x0+sz_a/2 & post_y > y0-sz_a/2 & post_y < y0+sz_a/2);

  xmean = mean(pre_x(ib));
  ymean = mean(pre_y(ib));
  zmean = mean(pre_z(ib));

  clear q_before p_after % clear these out after each run, because each set of points is a different length
  q_before(1,:) = pre_x(ib) - xmean;
  q_before(2,:) = pre_y(ib) - ymean;
  q_before(3,:) = pre_z(ib) - zmean;

  p_after(1,:) = post_x(ia) - xmean;
  p_after(2,:) = post_y(ia) - ymean;
  p_after(3,:) = post_z(ia) - zmean;

%   figure(4),clf,
%   scatter3(q_before(1,:), q_before(2,:), q_before(3,:), 5, 'k', 'filled')          
%   hold on
%   scatter3(p_after(1,:), p_after(2,:), p_after(3,:), 5, 'r', 'filled')
%   legend('Before', 'After')

% Plot the quiver vector plot from the 3D differencing on top of 2d raster

figure('Name', 'Change in Elevation from 2016 Kumamoto Earthquake', 'NumberTitle', 'off');
imagesc(xA/1e3, yA/1e3, zC, 'AlphaData', ~isnan(zC)) % x and y converted to kilometers, AlphaData sets NaNs to background value
hold on
quiver(results(:,1)/1e3, results(:,2)/1e3, results(:,3), results(:,4), 'k', 'LineWidth', 1);
hold on 
scatter(results(:,1)/1e3, results(:,2)/1e3, 45, results(:,5), 'filled', 'LineWidth', 1, 'MarkerEdgeColor', 'k');
set(gca, 'Color', [0.8 0.8 0.8]); % Change background color to gray 
title('Elevational Change from 2016 Kumamoto Earthquake');
axis xy % this reverses the order of y values so numbers increase as you go up
axis equal % tell plotter that x and y are same units; keeps dimensions proportionate
xlabel('Kilometers East', 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Kilometers North', 'FontWeight', 'bold', 'FontSize', 10);
clim([-1, 1]); % Colorbar limits 
cbr = colorbar('Location', 'southoutside'); % Place colorbar below the x-axis (and outside)
% set(cbr, 'YTick', -36:6:36); % Place ytick every 2 units
cbr.Label.String = 'Vertical Difference (m)'; % Label the colorbar
cbr.Label.FontWeight = 'bold'; % Bold colorbar label
cbr.Label.FontSize = 10; % Colorbar label font size 10
cmap = colormap(flipud(cpolar));

fprintf([datestr(now),'\n']) % keep track of time

