clear 

% List of station names to loop over
fid = fopen('stations.txt'); 
allStations = textscan(fid, '%s');
fclose(fid);

stationNames = allStations{1};

for row = 1:size(stationNames, 1) % loop through each station name
    station = stationNames(row,:);
    % Download the tenv3 file from NGL site
    webAddress = sprintf('http://geodesy.unr.edu/gps_timeseries/tenv3/plates/NA/%s.NA.tenv3 > %s.NA.tenv3', station{1}, station{1});
    stationDownload = system(sprintf('curl %s', webAddress));

    % Load the data
    fid = fopen(sprintf('%s.NA.tenv3', station{1}));
    C = textscan(fid, '%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', 1);
    fclose(fid);

    % Isolate t, e, n, v, lat, and long
    T_dyr = C{3}; % decimal year 
    T = datenum(C{2},'yymmmdd'); % convert to sequential days (i.e., Matlab time)
    E = C{9};
    N = C{11};
    V = C{13};

    lat = C{21}(1);
    lon = C{22}(1);

    % Plot the data
    figure('Name', sprintf('Station %s: Positional Time Series', station{1}), 'NumberTitle', 'off');
    subplot(3, 1, 1);
    plot(T, E, '.-');
    ylabel('East (m)');
    title(sprintf('%s in NA Reference Frame - Raw Data', station{1}));
    datetick;
    grid;
    subplot(3, 1, 2);
    plot(T, N, '.-');
    ylabel('North (m)');
    datetick;
    grid;
    subplot(3, 1, 3);
    plot(T, V, '.-');
    ylabel('Elevation (m)');
    datetick;
    grid;

    % Fill the gaps in data with NaNs & make continuous time vector
    T_orig = T;
    E_orig = E;
    N_orig = N;
    V_orig = V;

    Day_int = 1; % time between obserations is 1 day

    [T, E] = filltimegap(T_orig, E_orig, Day_int);
    [T, N] = filltimegap(T_orig, N_orig, Day_int); 
    [T, V] = filltimegap(T_orig, V_orig, Day_int); 

    % Plot the data with NaN filled gaps
    figure('Name', sprintf('Station %s: Positional Time Series', station{1}), 'NumberTitle', 'off');
    subplot(3, 1, 1);
    plot(T, E, '.-');
    ylabel('East (m)');
    title(sprintf('%s in NA Reference Frame - NaN Filled Gaps', station{1}));
    datetick;
    grid;
    subplot(3, 1, 2);
    plot(T, N, '.-');
    ylabel('North (m)');
    datetick;
    grid;
    subplot(3, 1, 3);
    plot(T, V, '.-');
    ylabel('Elevation (m)');
    datetick;
    grid;

    % Variable containing NaN gaps
    T_NaNgaps = T;
    E_NaNgaps = E;
    N_NaNgaps = N;
    V_NaNgaps = V;

    % Take care of jumps in easting component
    T_jump = datenum([2017 8 2]); % the date when jump occurs // How did you determine this??? Struggling with this step. 
    i_after = T > T_jump; % the points to fix
    Jump_amount = 6.39; % meters
    E(i_after) = E(i_after) - Jump_amount;

    T_jump = datenum([2017 11 20]); 
    i_after = T > T_jump; 
    Jump_amount = 0.44; 
    E(i_after) = E(i_after) - Jump_amount;

    % Take care of jumps in northing component
    T_jump = datenum([2017 8 2]); % the date when jump occurs // How did you determine this??? Struggling with this step. 
    i_after = T > T_jump; % the points to fix
    Jump_amount = -6.71; % meters
    N(i_after) = N(i_after) - Jump_amount;

    T_jump = datenum([2017 11 20]); 
    i_after = T > T_jump; 
    Jump_amount = 0.34; 
    N(i_after) = N(i_after) - Jump_amount;

    % Take care of jumps in vertical component
    T_jump = datenum([2017 8 2]); % the date when jump occurs // How did you determine this??? Struggling with this step. 
    i_after = T > T_jump; % the points to fix
    Jump_amount = -1.44; % meters
    V(i_after) = V(i_after) - Jump_amount;

    % Plot the data with jumps fixed
    figure('Name', sprintf('Station %s: Positional Time Series', station{1}), 'NumberTitle', 'off');
    subplot(3, 1, 1);
    plot(T, E, '.-');
    ylabel('East (m)');
    title(sprintf('%s in NA Reference Frame - Jumps Fixed', station{1}));
    datetick;
    grid;
    subplot(3, 1, 2);
    plot(T, N, '.-');
    ylabel('North (m)');
    datetick;
    grid;
    subplot(3, 1, 3);
    plot(T, V, '.-');
    ylabel('Elevation (m)');
    datetick;
    grid;

    % Handle outliers in the eastings component
    E_upper = -0.35;  % threshold for outliers
    E_lower = -0.6;
    i_bad = E < E_lower | E > E_upper; % the bad values
    E(i_bad) = NaN; % replace with NaN

    % Handle outliers in the northings component
    N_upper = 0.26; 
    N_lower = -0.15;
    i_bad = N < N_lower | N > N_upper;
    N(i_bad) = NaN;

    % Handle outliers in the vertical component
    V_cutoff = -0.75; 
    i_bad = V > V_cutoff; 
    V(i_bad) = NaN;

    % Plot the data with outliers fixed
    figure('Name', sprintf('Station %s: Positional Time Series', station{1}), 'NumberTitle', 'off');
    subplot(3, 1, 1);
    plot(T, E, '.-');
    ylabel('East (m)');
    title(sprintf('%s in NA Reference Frame - Outliers Fixed', station{1}));
    datetick;
    grid;
    subplot(3, 1, 2);
    plot(T, N, '.-');
    ylabel('North (m)');
    datetick;
    grid;
    subplot(3, 1, 3);
    plot(T, V, '.-');
    ylabel('Elevation (m)');
    datetick;
    grid;

    % Remove observations before 2014
    T_cutoff = datenum([2014 1 1]);
    i_bad = T < T_cutoff;
    E(i_bad) = NaN;
    N(i_bad) = NaN;
    V(i_bad) = NaN;

    T_cleaned = T;
    E_cleaned = E; 
    N_cleaned = N;
    V_cleaned = V;

    % Now that data is cleaned, smooth and fill in the small gaps using a
    % moving median (ignore NaNs)
    T_window = 30; % smooth from 1- to 30-day resolution?

    [numel(find(isnan(E))),numel(find(isnan(N))),numel(find(isnan(V)))]

    E_smoothed = movmedian(E, T_window, 'omitnan');
    N_smoothed = movmedian(N, T_window, 'omitnan');
    V_smoothed = movmedian(V, T_window, 'omitnan');

    % Plot the data with smoothed clean data
    figure('Name', sprintf('Station %s: Positional Time Series', station{1}), 'NumberTitle', 'off');
    subplot(3, 1, 1);
    plot(T, E_smoothed, '.-');
    ylabel('East (m)');
    title(sprintf('%s in NA Reference Frame - Cleaned & Smoothed', station{1}));
    datetick;
    grid;
    subplot(3, 1, 2);
    plot(T, N_smoothed, '.-');
    ylabel('North (m)');
    datetick;
    grid;
    subplot(3, 1, 3);
    plot(T, V_smoothed, '.-');
    ylabel('Elevation (m)');
    datetick;
    grid;

    [numel(find(isnan(E_smoothed))),numel(find(isnan(N_smoothed))),numel(find(isnan(V_smoothed)))]

end

% I now realize cleaning GPS station data may not be easily suited for looping. 
