clear
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Read in the tenv3 & xy files              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % NGL station names for analysis
% mystations = {'ARBK',...
% 'MSCL',...
% 'MSGW',...
% 'MSNS',...
% 'MSRF',...
% 'MSSN',...
% 'MSTU',...
% 'MSVC',...
% 'MSYZ',...
% 'TALL',...
% 'ZME1'};
% nGNSS = numel(mystations);

% NGL station names for analysis w/out MSRF
mystations = {'ARBK',...
'MSCL',...
'MSGW',...
'MSNS',...
'MSSN',...
'MSTU',...
'MSVC',...
'MSYZ',...
'TALL',...
'ZME1'};
nGNSS = numel(mystations);

% Coastline XYs
fid = fopen('coastfile.xy.txt');
Coastline = textscan(fid,'%f %f');
fclose(fid);

% Political boundary XYs
fid = fopen('politicalboundaryfile.xy.txt');
Land = textscan(fid,'%f %f');
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Download NGL Station Data                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for k = 1:numel(mystations)
%     station = mystations{k};
%     Download the data directly from the source 
%     webAddress = sprintf('http://geodesy.unr.edu/gps_timeseries/tenv3/plates/NA/%s.NA.tenv3 > %s.NA.tenv3', station, station);
%     stationDownload = system(sprintf('curl %s', webAddress));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Clean relevant variables & store in cell array     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_cutoff = datenum([2019 10 1]); % time period for filtering data

for k = 1:nGNSS
    station = mystations{k};
    fid = fopen(sprintf('%s.NA.tenv3', station));
    C = textscan(fid, '%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', 1);
    fclose(fid);

    % Isolate the t, e, n, v, lat, and long variables
    t{k} = datenum(C{2},'yymmmdd'); % convert to sequential days (i.e., Matlab time)
    x{k} = C{9} - C{9}(1);
    y{k} = C{11} - C{11}(1);
    z{k} = C{13} - C{13}(1);
    lat{k} = C{21};
    lon{k} = C{22};
    ele{k} = C{23};

    % Remove observations before October 1, 2019
    t_cutoff = datenum([2019 10 1]);
    i_bad = find(t{k} < t_cutoff);
    t{k}(i_bad) = [];
    x{k}(i_bad) = [];
    y{k}(i_bad) = [];
    z{k}(i_bad) = [];
    lat{k}(i_bad) = [];
    lon{k}(i_bad) = [];
    ele{k}(i_bad) = [];

    % Position from October 1, 2019 is starting position
    lat{k} = lat{k}(1); 
    lon{k} = lon{k}(1);
    ele{k} = ele{k}(1);

    % Plot the filtered raw data
    figure('Name', sprintf('Station %s: Positional Time Series', station), 'NumberTitle', 'off');
    subplot(3, 1, 1);
    plot(t{k}, x{k}, '.-');
    ylabel('East (m)');
    title(sprintf('%s in NA Reference Frame - Raw Data', station));
    datetick;
    grid;
    subplot(3, 1, 2);
    plot(t{k}, y{k}, '.-');
    ylabel('North (m)');
    datetick;
    grid;
    subplot(3, 1, 3);
    plot(t{k}, z{k}, '.-');
    ylabel('Elevation (m)');
    datetick;
    grid;

    originalNaNs{k} = [numel(find(isnan(x{k}))), numel(find(isnan(y{k}))), numel(find(isnan(z{k})))];

    Day_int = 1; % time between obserations is 1 day

    % Fill the gaps in data with NaNs & make continuous time vector
    [t2, x2] = filltimegap(t{k}, x{k}, Day_int);
    [t2, y2] = filltimegap(t{k}, y{k}, Day_int); 
    [t2, z2] = filltimegap(t{k}, z{k}, Day_int);

    timeGapNaNs{k} = [numel(find(isnan(x2))), numel(find(isnan(y2))), numel(find(isnan(z2)))];

    % Plot the data with NaN filled gaps
    figure('Name', sprintf('Station %s: Positional Time Series', station), 'NumberTitle', 'off');
    subplot(3, 1, 1);
    plot(t2, x2, '.-');
    ylabel('East (m)');
    title(sprintf('%s in NA Reference Frame - NaN Filled Gaps', station));
    datetick;
    grid;
    subplot(3, 1, 2);
    plot(t2, y2, '.-');
    ylabel('North (m)');
    datetick;
    grid;
    subplot(3, 1, 3);
    plot(t2, z2, '.-');
    ylabel('Elevation (m)');
    datetick;
    grid;

    % Find outliers using moving detection method
    % Not perfect but works ok for looping
    x_tf = isoutlier(x2, 'movmedian', 365, 'SamplePoints', t2); % using median absolute deviation on 365-day median 
    y_tf = isoutlier(y2, 'movmedian', 365, 'SamplePoints', t2);
    z_tf = isoutlier(z2, 'movmedian', 365, 'SamplePoints', t2);
    
    % Add the outlier points to the NaN filled gaps plot
    subplot(3, 1, 1);
    hold on
    plot(t2(x_tf), x2(x_tf), '^', 'MarkerSize', 8, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', [1 .6 .6]);
    subplot(3, 1, 2);
    hold on
    plot(t2(y_tf), y2(y_tf), '^', 'MarkerSize', 8, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', [1 .6 .6]);
    subplot(3, 1, 3);
    hold on
    plot(t2(z_tf), z2(z_tf), '^', 'MarkerSize', 8, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', [1 .6 .6]);

    % Replace outliers with NaNs
    x2(x_tf==1) = NaN;
    y2(y_tf==1) = NaN;
    z2(z_tf==1) = NaN;

    % Sanity check: does timeGapNaNs + outlierNaNs = totalNaNs? 
    outlierNaNs{k} = [numel(find(x_tf==1)), numel(find(y_tf==1)), numel(find(z_tf==1))];
    totalNaNs{k} = [numel(find(isnan(x2))), numel(find(isnan(y2))), numel(find(isnan(z2)))];

    % Calculate the velocity of each component
    pX{k} = polyfit(t2(~isnan(x2)), x2(~isnan(x2)), 1); % ignore NaNs
    pY{k} = polyfit(t2(~isnan(y2)), y2(~isnan(y2)), 1);
    pZ{k} = polyfit(t2(~isnan(z2)), z2(~isnan(z2)), 1);

    % Velocity is slope coefficient (column 1)
    vX{k} = pX{k}(1);  
    vY{k} = pY{k}(1);
    vZ{k} = pZ{k}(1); 

    % Add the line of best fit to the NaN filled gaps plot
    subplot(3, 1, 1);
    hold on
    plot(t2, polyval(pX{k}, t2), 'linewidth', 3, 'Color', 'red');
    subplot(3, 1, 2);
    hold on
    plot(t2, polyval(pY{k}, t2), 'linewidth', 3, 'Color', 'red');
    subplot(3, 1, 3);
    hold on
    plot(t2, polyval(pZ{k}, t2), 'linewidth', 3, 'Color', 'red');

    % Make the first value in the time series be zero
    easting(k,:) = x2 - x2(1);
    northing(k,:) = y2 - y2(1);
    vertical(k,:) = z2 - z2(1);

    % Now that data is cleaned, smooth and fill in the small gaps using a
    % moving median (omit NaNs)
    t_window = 30; % smooth from 1- to 30-day resolution

    x_smoothed = movmedian(easting, t_window, 2, 'omitnan');
    y_smoothed = movmedian(northing, t_window, 2, 'omitnan');
    z_smoothed = movmedian(vertical, t_window, 2, 'omitnan');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Plot the smoothed and cleaned data            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Single station loop
for k = 1:nGNSS
    station = mystations{k};
    figure('Name', sprintf('Station %s: Positional Time Series', station), 'NumberTitle', 'off');
    subplot(3, 1, 1);
    plot(t2, (x_smoothed(k,:) - mean(x_smoothed(k,:), 'all')) * 1000, '.-'); % Demeaned and converted to mm
    ylabel('East (mm)');
    title(sprintf('%s in NA Reference Frame - Cleaned and Smoothed', station));
    datetick;
    grid;
    subplot(3, 1, 2);
    plot(t2, (y_smoothed(k,:) - mean(y_smoothed(k,:), 'all')) * 1000, '.-');
    ylabel('North (mm)');
    datetick;
    grid;
    subplot(3, 1, 3);
    plot(t2, (z_smoothed(k,:) - mean(z_smoothed(k,:), 'all')) * 1000, '.-');
    ylabel('Elevation (mm)');
    datetick;
    grid;
end

% All stations together
figure('Name', 'All Stations: Positional Time Series', 'NumberTitle', 'off');
subplot(3, 1, 1);
plot(t2, (x_smoothed - mean(x_smoothed, 'all')) * 1000, '.-'); % Demeaned and converted to mm
ylabel('East (mm)');
title('Stations in NA Reference Frame - Cleaned & Smoothed');
legend(mystations, 'NumColumns', 2);
datetick;
grid;
subplot(3, 1, 2);
plot(t2, (y_smoothed - mean(y_smoothed, 'all')) * 1000, '.-');
ylabel('North (mm)');
legend(mystations, 'NumColumns', 2);
datetick;
grid;
subplot(3, 1, 3);
plot(t2, (z_smoothed - mean(z_smoothed, 'all')) * 1000, '.-');
ylabel('Elevation (mm)');
legend(mystations, 'NumColumns', 2);
datetick;
grid;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Plot the velocities on single map             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make a simple velocity plot
figure('Name', 'LMAV Annual Velocity Map: 2020 - Present', 'NumberTitle', 'off');
set(gca, 'XLim', [min(cell2mat(lon)) - 1, max(cell2mat(lon)) + 1], 'YLim', [min(cell2mat(lat)) - 1, max(cell2mat(lat)) + 1]);
hold on
for k = 1:nGNSS
    plot(Land{1}, Land{2}, 'black--');
    plot(Coastline{1}, Coastline{2}, 'Color', 'black');
    scatter(cell2mat(lon(k)), cell2mat(lat(k)), 24, 'd', 'MarkerEdgeColor','black', 'MarkerFaceColor', 'red'); % GNSS station lat/long
    text(cell2mat(lon(k)) + 0.025, cell2mat(lat(k)) - 0.01, mystations{k});
    text(cell2mat(lon(k)) + 0.15, cell2mat(lat(k)) - 0.01, sprintf(': [%0.3g, %0.3g]', cell2mat(vX(k)), cell2mat(vY(k))));
    text(-91.75, 32.5, 'Louisiana', 'FontSize', 12);
    text(-91.75, 33.5, 'Arkansas', 'FontSize', 12);
    text(-90.25, 31.75, 'Mississippi', 'FontSize', 12);
    text(-89.5, 35.5, 'Tennessee', 'FontSize', 12);
    quiver(cell2mat(lon(k)), cell2mat(lat(k)), cell2mat(vX(k)), cell2mat(vY(k)), 'AutoScaleFactor', 100000, 'Color', 'red', 'LineWidth', 1.5);
    title('LMAV Annual Velocity Map: 2020 - Present');
    xlabel('Longitude', 'fontweight', 'bold');
    ylabel('Latitude', 'fontweight', 'bold');
    legend('Political Boundary', 'Coastline', 'Station', 'Velocity (m/yr)', 'Location', 'southwest');
end

toc

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Source separation using PCA               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PCA: eastings only
[PCA_comp1, PCA_weight1] = pca(x_smoothed);
nComponents = round(size(PCA_comp1, 2) * 0.5);
figure('Name', 'PCA: Eastings', 'NumberTitle', 'off');

for k = 1:nComponents
    subplot(nComponents, 2, k*2-1);
    plot(t2.', PCA_comp1(:,k)); 
    datetick;
    grid;
    title(['PCA component # ', num2str(k)]);
end

subplot(1, 2, 2);
imagesc(PCA_weight1(:, 1:nComponents)');
colorbar;
xticks(1:nGNSS);
xticklabels(mystations);
xlabel('Station');
yticks(1:nComponents);
ylabel('Principal Component Number');
title('PCA Weights - Eastings');

% PCA: northings only
[PCA_comp2, PCA_weight2] = pca(y_smoothed);
nComponents = round(size(PCA_comp2, 2) * 0.5);
figure('Name', 'PCA: Northings', 'NumberTitle', 'off');

for k = 1:nComponents
    subplot(nComponents, 2, k*2-1);
    plot(t2.', PCA_comp2(:,k)); 
    datetick;
    grid;
    title(['PCA component # ', num2str(k)]);
end

subplot(1, 2, 2);
imagesc(PCA_weight2(:, 1:nComponents)');
colorbar;
xticks(1:nGNSS);
xticklabels(mystations);
xlabel('Station');
yticks(1:nComponents);
ylabel('Principal Component Number');
title('PCA Weights - Northings');

% PCA: vertical only
[PCA_comp3, PCA_weight3] = pca(z_smoothed);
nComponents = round(size(PCA_comp3, 2) * 0.5);
figure('Name', 'PCA: Verticals', 'NumberTitle', 'off');

for k = 1:nComponents
    subplot(nComponents, 2, k*2-1);
    plot(t2.', PCA_comp3(:, k)); 
    datetick;
    grid;
    title(['PCA component # ', num2str(k)]);
end

subplot(1, 2, 2);
imagesc(PCA_weight3(:, 1:nComponents)');
colorbar;
xticks(1:nGNSS);
xticklabels(mystations);
xlabel('Station');
yticks(1:nComponents);
ylabel('Principal Component Number');
title('PCA Weights - Verticals');

% PCA: all 3 components
[PCA_comp4, PCA_weight4] = pca([x_smoothed; y_smoothed; z_smoothed]);
nComponents = round(size(PCA_comp4, 2) * 0.25);
figure('Name', 'PCA: All Components', 'NumberTitle', 'off');

for k = 1:nComponents
    subplot(nComponents, 2, k*2-1);
    plot(t2.', PCA_comp4(:, k)); 
    datetick;
    grid;
    title(['PCA component # ', num2str(k)]);
end

subplot(1, 2, 2);
imagesc(PCA_weight4(:, 1:nComponents)');
colorbar;
xticks(1:nGNSS*3);
xticklabels([cellfun(@(x) [x, ' x'], mystations, 'uniformoutput', false),...
             cellfun(@(x) [x, ' y'], mystations, 'uniformoutput', false),...
             cellfun(@(x) [x, ' z'], mystations, 'uniformoutput', false)]);
xlabel('Station');
yticks(1:nComponents);
ylabel('Principal Component Number');
title('PCA Weights - E, N, V');

toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Source separation using rICA               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ICA: eastings only
nComponents = 4;
data = x_smoothed;
Mdl = rica(data, nComponents);
ICA_comp1 = Mdl.TransformWeights;
ICA_weight1 = transform(Mdl, data);
figure('Name', 'ICA: Eastings', 'NumberTitle', 'off');

for k = 1:nComponents
    subplot(nComponents, 2, k*2-1);
    plot(t2.', ICA_comp1(:, k)); 
    datetick;
    grid;
    title(['ICA component # ', num2str(k)]);
end

subplot(1, 2, 2);
imagesc(ICA_weight1(:, 1:nComponents)');
colorbar;
xticks(1:nGNSS);
xticklabels(mystations);
xlabel('Station');
yticks(1:nComponents);
ylabel('Independent Component Number');
title('ICA Weights - Eastings');

% ICA: northings only
nComponents = 4;
data = y_smoothed;
Mdl = rica(data, nComponents);
ICA_comp2 = Mdl.TransformWeights;
ICA_weight2 = transform(Mdl, data);
figure('Name', 'ICA: Northings', 'NumberTitle', 'off');

for k = 1:nComponents
    subplot(nComponents, 2, k*2-1);
    plot(t2.', ICA_comp2(:, k)); 
    datetick;
    grid;
    title(['ICA component # ', num2str(k)]);
end

subplot(1, 2, 2);
imagesc(ICA_weight2(:, 1:nComponents)');
colorbar;
xticks(1:nGNSS);
xticklabels(mystations);
xlabel('Station');
yticks(1:nComponents);
ylabel('Independent Component Number');
title('ICA Weights - Northings');

% ICA: verticals only
nComponents = 4;
data = z_smoothed;
Mdl = rica(data, nComponents);
ICA_comp3 = Mdl.TransformWeights;
ICA_weight3 = transform(Mdl, data);
figure('Name', 'ICA: Verticals', 'NumberTitle', 'off');

for k = 1:nComponents
    subplot(nComponents, 2, k*2-1);
    plot(t2.', ICA_comp3(:, k)); 
    datetick;
    grid;
    title(['ICA component # ', num2str(k)]);
end

subplot(1, 2, 2);
imagesc(ICA_weight3(:, 1:nComponents)');
colorbar;
xticks(1:nGNSS);
xticklabels(mystations);
xlabel('Station');
yticks(1:nComponents);
ylabel('Independent Component Number');
title('ICA Weights - Verticals');

toc
