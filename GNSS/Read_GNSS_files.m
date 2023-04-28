% Read in the ASCII file
fid = fopen('P140tenv3.txt');
P140 = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', 1);
fclose(fid);

% Isolate time, easting, northing, and vertical into separate variables
T = P140{3};
E = (P140{9} - mean(P140{9}, 'all')) * 1000; % Demeaned and converted to mm
N = (P140{11} - mean(P140{11}, 'all')) * 1000;
V = (P140{13} - mean(P140{13}, 'all')) * 1000;

% Plot the three time series as subplots in one figure
figure('Name', 'Station P140 Time Series', 'NumberTitle', 'off');
subplot(3, 1, 1);
plot(T, E, 'r');
ylabel('Easting (mm)');
title('Station P140: Eastings (2006 - 2023)');
grid;

subplot(3, 1, 2);
plot(T, N, 'g');
ylabel('Northing (mm)');
title('Station P140: Northings (2006 - 2023)');
grid;

subplot(3, 1, 3);
plot(T, V, 'b');
xlabel('Year');
ylabel('Vertical (mm)');
title('Station P140: Verticals (2006 - 2023)');
grid;
