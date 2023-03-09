clear

%
% Loop through all NGL stations
% Download the data directly from the source 
% IGS14 Reference Frame
%

fid = fopen('stations.txt'); % list of all NGL station names
allStations = textscan(fid, '%s');
fclose(fid);

% Coastline XYs
fid = fopen('coastfile.xy.txt');
Coastline = textscan(fid,'%f %f');
fclose(fid);

% Political boundary XYs
fid = fopen('politicalboundaryfile.xy.txt');
Land = textscan(fid,'%f %f');
fclose(fid);

stationNames = allStations{1};

for row = 1:size(stationNames, 1)
    station = stationNames(row,:);
    webAddress = sprintf('http://geodesy.unr.edu/gps_timeseries/tenv3/IGS14/%s.tenv3 > %s.tenv3', station{1}, station{1});
    stationDownload = system(sprintf('curl %s', webAddress));

    fid = fopen(sprintf('%s.tenv3', station{1}));
    C = textscan(fid, '%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', 1);
    fclose(fid);

    % Isolate the t, e, n, v variables
    t = C{3};
    x = C{9};
    y = C{11};
    z = C{13};
    
    % Isolate the lat and long 
    stationlat = C{21};
    stationlon = C{22};

    % Plot the base data
    figure('Name', sprintf('Station %s: Positional Time Series', station{1}), 'NumberTitle', 'off');
    subplot(3, 1, 1);
    plot(t, x, '.-');
    grid;
    ylabel('east (m)');
    title(sprintf('%s in IGS14 reference frame', station{1}));
    subplot(3, 1, 2);
    plot(t, y, '.-');
    grid;
    ylabel('north (m)');
    subplot(3, 1, 3);
    plot(t, z, '.-');
    grid;
    ylabel('elevation (m)');

    % Calculate the velocity of each component
    pX = polyfit(t, x, 1);
    pY = polyfit(t, y, 1);
    pZ = polyfit(t, z, 1);

    vX = pX(1);
    vY = pY(1);
    vZ = pZ(1);

    % Add the line of best fit to the original data
    subplot(3, 1, 1);
    hold on
    plot(t, polyval(pX,t), 'linewidth', 3);
    subplot(3, 1, 2);
    hold on
    plot(t, polyval(pY,t), 'linewidth', 3);
    subplot(3, 1, 3);
    hold on
    plot(t, polyval(pZ,t), 'linewidth', 3);

    % Make a simple velocity plot
    figure('Name', sprintf('Station %s: Annual Velocity Map', station{1}), 'NumberTitle', 'off');
    plot(Land{1}, Land{2}, 'black--');
    hold all
    plot(Coastline{1}, Coastline{2}, 'Color', 'black');
    quiver(stationlon(1,:), stationlat(1,:), vX * 10000, vY * 10000, 'AutoScale', 'off', 'Color', 'red', 'LineWidth', 1.5);
    title(sprintf('Station %s: Annual Velocity Map', station{1}));
    xlabel('Longitude', 'fontweight', 'bold');
    ylabel('Latitude', 'fontweight', 'bold');
    legend('Political Boundary', 'Coastline', sprintf('Station %s Velocity', station{1}), 'Location', 'southwest');
    grid;
    hold off

end

%%% Something wonky is going on when mapping velocities for stations in the
%%% eastern hemisphere. Do I need to scale the longitudes?? Thoughts for later me.  
