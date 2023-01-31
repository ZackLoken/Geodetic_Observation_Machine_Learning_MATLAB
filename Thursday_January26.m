%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Read in the tenv3 & xy files              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% P395 NA 24-hour final solutions
fid = fopen('P395.NA.tenv3.txt');
P395 = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %.10f %.10f %f', 'headerlines', 1);
fclose(fid);

% P396 NA 24-hour final solutions
fid = fopen('P396.NA.tenv3.txt');
P396 = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', 1);
fclose(fid);

% P404 NA 24-hour final solutions
fid = fopen('P404.NA.tenv3.txt');
P404 = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', 1);
fclose(fid);

% Coastline XYs
fid = fopen('coastfile.xy.txt');
Coastline = textscan(fid,'%f %f');
fclose(fid);

% Political boundary XYs
fid = fopen('politicalboundaryfile.xy.txt');
Land = textscan(fid,'%f %f');
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Isolate time, easting, northing, and vertical      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Station P395
T_P395 = P395{3};
E_P395 = P395{9}; 
N_P395 = P395{11};
V_P395 = P395{13};

% Station P396
T_P396 = P396{3};
E_P396 = P396{9};
N_P396 = P396{11};
V_P396 = P396{13};

% Station P404
T_P404 = P404{3};
E_P404 = P404{9};
N_P404 = P404{11};
V_P404 = P404{13};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Isolate lat/long positions for mapping velocity    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P395lat = P395{21};
P395lat(end) = []; % Remove last value for plotting daily velocity
P395long = P395{22};
P395long(end) = [];

P396lat = P396{21};
P396lat(end) = [];
P396long = P396{22};
P396long(end) = [];

P404lat = P404{21};
P404lat(end) = [];
P404long = P404{22};
P404long(end) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Calculate daily velocity for mapping         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% P395
E_P395v_daily = diff(E_P395) ./ diff(T_P395); % v in units meters/day
N_P395v_daily = diff(N_P395) ./ diff(T_P395);

% P396
E_P396v_daily = diff(E_P396) ./ diff(T_P396);
N_P396v_daily = diff(N_P396) ./ diff(T_P396);

% P404
E_P404v_daily = diff(E_P404) ./ diff(T_P404);
N_P404v_daily = diff(N_P404) ./ diff(T_P404);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Calculate coefficients for e, n, & v          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% P395 easting
[E_P395coef, E_P395stderr] = polyfit(T_P395, E_P395, 1);
[E_P395y_fit, E_P395delta] = polyval(E_P395coef, T_P395, E_P395stderr);

% P396 easting
[E_P396coef, E_P396stderr] = polyfit(T_P396, E_P396, 1);
[E_P396y_fit, E_P396delta] = polyval(E_P396coef, T_P396, E_P396stderr);

% P404 easting
[E_P404coef, E_P404stderr] = polyfit(T_P404, E_P404, 1);
[E_P404y_fit, E_P404delta] = polyval(E_P404coef, T_P404, E_P404stderr);

% P395 northing
[N_P395coef, N_P395stderr] = polyfit(T_P395, N_P395, 1);
[N_P395y_fit, N_P395delta] = polyval(N_P395coef, T_P395, N_P395stderr);

% P396 northing
[N_P396coef, N_P396stderr] = polyfit(T_P396, N_P396, 1);
[N_P396y_fit, N_P396delta] = polyval(N_P396coef, T_P396, N_P396stderr);

% P404 northing
[N_P404coef, N_P404stderr] = polyfit(T_P404, N_P404, 1);
[N_P404y_fit, N_P404delta] = polyval(N_P404coef, T_P404, N_P404stderr);

% P395 vertical
[V_P395coef, V_P395stderr] = polyfit(T_P395, V_P395, 1);
[V_P395y_fit, V_P395delta] = polyval(V_P395coef, T_P395, V_P395stderr);

% P396 vertical
[V_P396coef, V_P396stderr] = polyfit(T_P396, V_P396, 1);
[V_P396y_fit, V_P396delta] = polyval(V_P396coef, T_P396, V_P396stderr);

% P404 vertical
[V_P404coef, V_P404stderr] = polyfit(T_P404, V_P404, 1);
[V_P404y_fit, V_P404delta] = polyval(V_P404coef, T_P404, V_P404stderr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Plot e, n, v time series with best fit line       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% P395 easting
figure('Name', 'Stations P395, P396, & P404: Positional Time Series', 'NumberTitle', 'off'); % One figure with nine subplots
subplot(3, 3, 1);
plot(T_P395, (E_P395 - mean(E_P395, 'all')) * 1000, 'b'); % Demeaned and converted to mm
hold on
plot(T_P395, (E_P395y_fit - mean(E_P395y_fit, 'all')) * 1000, 'r-', 'LineWidth', 2); % Line of best fit: demeaned and converted to mm
title('Station P395');
ylabel('East (mm)', 'fontweight', 'bold');
legend('Data', 'Linear Fit', 'Location', 'southeast');
grid;
hold off

% P396 easting
subplot(3, 3, 2);
plot(T_P396, (E_P396 - mean(E_P396, 'all')) * 1000, 'b');
hold on
plot(T_P396, (E_P396y_fit - mean(E_P396y_fit, 'all')) * 1000, 'r-', 'LineWidth', 2);
title('Station P396');
legend('Data', 'Linear Fit', 'Location', 'southeast');
grid;
hold off

% P404 easting
subplot(3, 3, 3);
plot(T_P404, (E_P404 - mean(E_P404, 'all')) * 1000, 'b');
hold on
plot(T_P404, (E_P404y_fit - mean(E_P404y_fit, 'all')) * 1000, 'r-', 'LineWidth', 2);
title('Station P404');
legend('Data', 'Linear Fit', 'Location', 'southeast');
grid;
hold off

% P395 northing
subplot(3, 3, 4);
plot(T_P395, (N_P395 - mean(N_P395, 'all')) * 1000, 'b');
hold on
plot(T_P395, (N_P395y_fit - mean(N_P395y_fit, 'all')) * 1000, 'r-', 'LineWidth', 2);
ylabel('North (mm)', 'fontweight', 'bold');
legend('Data', 'Linear Fit', 'Location', 'southeast');
grid;
hold off

% P396 northing
subplot(3, 3, 5);
plot(T_P396, (N_P396 - mean(N_P396, 'all')) * 1000, 'b');
hold on
plot(T_P396, (N_P396y_fit - mean(N_P396y_fit, 'all')) * 1000, 'r-', 'LineWidth', 2);
legend('Data', 'Linear Fit', 'Location', 'southeast');
grid;
hold off

% P404 northing
subplot(3, 3, 6);
plot(T_P404, (N_P404 - mean(N_P404, 'all')) * 1000, 'b');
hold on
plot(T_P404, (N_P404y_fit - mean(N_P404y_fit, 'all')) * 1000, 'r-', 'LineWidth', 2);
legend('Data', 'Linear Fit', 'Location', 'southeast');
grid;
hold off

% P395 vertical
subplot(3, 3, 7);
plot(T_P395, (V_P395 - mean(V_P395, 'all')) * 1000, 'b');
hold on
plot(T_P395, (V_P395y_fit - mean(V_P395y_fit, 'all')) * 1000, 'r-', 'LineWidth', 2);
ylabel('Vertical (mm)', 'fontweight', 'bold');
legend('Data', 'Linear Fit', 'Location', 'southeast');
grid;
hold off

% P396 vertical
subplot(3, 3, 8);
plot(T_P396, (V_P396 - mean(V_P396, 'all')) * 1000, 'b');
hold on
plot(T_P396, (V_P396y_fit - mean(V_P396y_fit, 'all')) * 1000, 'r-', 'LineWidth', 2);
xlabel('Year', 'fontweight', 'bold');
legend('Data', 'Linear Fit', 'Location', 'southeast');
grid;
hold off

% P404 vertical
subplot(3, 3, 9);
plot(T_P404, (V_P404 - mean(V_P404, 'all')) * 1000, 'b');
hold on
plot(T_P404, (V_P404y_fit - mean(V_P404y_fit, 'all')) * 1000, 'r-', 'LineWidth', 2);
legend('Data', 'Linear Fit', 'Location', 'southeast');
grid;
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Plot velocity (meters/day) vector plots         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Should I convert lat/long decimal degrees to meters??
figure('Name', 'Stations P395, P396, & P404: Velocity Vector Plots', 'NumberTitle', 'off'); % One figure with three subplots
subplot(3, 1, 1);
quiver(P395long, P395lat, E_P395v_daily, N_P395v_daily, 'r');
title('Station P395');
grid;

subplot(3, 1, 2);
quiver(P396long, P396lat, E_P396v_daily, N_P396v_daily, 'g');
ylabel('Latitude', 'fontweight', 'bold');
title('Station P396');
grid;

subplot(3, 1, 3);
quiver(P404long, P404lat, E_P404v_daily, N_P404v_daily, 'b');
xlabel('Longitude', 'fontweight', 'bold');
title('Station P404');
grid;

%%% Plotting coastline and political boundary file with vector plots
figure('Name', 'Stations P395, P396, & P404: Velocity Map', 'NumberTitle', 'off');
plot(Land{1}, Land{2}, 'black--');
hold all
plot(Coastline{1}, Coastline{2}, 'Color', 'black');
quiver(P395long, P395lat, E_P395v_daily*0.05, N_P395v_daily*0.05, 'AutoScale', 'off', 'Color', 'red'); % Vectors only plot (or are visible) if AutoScale is off??
quiver(P396long, P396lat, E_P396v_daily*0.05, N_P396v_daily*0.05, 'AutoScale', 'off', 'Color','green'); % Would help to group these by year to reduce number of lines on plot
quiver(P404long, P404lat, E_P404v_daily*0.05, N_P404v_daily*0.05, 'AutoScale', 'off', 'Color', 'blue'); % Scaled by scale factor of 0.05, so... units?? 20^-1m per day? 
title('Stations P395, P396, & P404: Velocity Map');
xlabel('Longitude', 'fontweight', 'bold');
ylabel('Latitude', 'fontweight', 'bold');
legend('Political Boundary', 'Coastline', 'P395 Velocity', 'P396 Velocity', 'P404 Velocity', 'Location', 'southwest');
grid;
hold off

% Declining the opportunity to learn how to make fancy maps in MATLAB
