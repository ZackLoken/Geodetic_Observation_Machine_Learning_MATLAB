clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Read in the tenv3 & xy files              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% P395 NA 24-hour final solutions
fid = fopen('P395.NA.tenv3.txt');
P395 = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', 1);
fclose(fid);

% P396 NA 24-hour final solutions
fid = fopen('P396.NA.tenv3.txt');
P396 = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', 1);
fclose(fid);

% P404 NA 24-hour final solutions
fid = fopen('P404.NA.tenv3.txt');
P404 = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', 1);
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Isolate time, easting, northing, and vertical      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Station P395
T_P395 = P395{3};
E_P395 = P395{9}; 
N_P395 = P395{11};
V_P395 = P395{13};
P395lat = P395{21};
P395long = P395{22};

% Station P396
T_P396 = P396{3};
E_P396 = P396{9};
N_P396 = P396{11};
V_P396 = P396{13};
P396lat = P396{21};
P396long = P396{22};

% Station P404
T_P404 = P404{3};
E_P404 = P404{9};
N_P404 = P404{11};
V_P404 = P404{13};
P404lat = P404{21};
P404long = P404{22};

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
%                  Estimate velocities                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% P395
E_P395v = E_P395coef(1);
N_P395v = N_P395coef(1);
V_P395v = V_P395coef(1);

% P396
E_P396v = E_P396coef(1);
N_P396v = N_P396coef(1);
V_P396v = V_P396coef(1);

% P404
E_P404v = E_P404coef(1);
N_P404v = N_P404coef(1);
V_P404v = V_P404coef(1);

% Make the 6x1 'd' vector
d = [E_P395v; N_P395v; E_P396v; N_P396v; E_P404v; N_P404v];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Convert lat/long to UTM                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% P395
[E_P395utm, N_P395utm] = ll2utm(P395lat, P395long);

% P396
[E_P396utm, N_P396utm] = ll2utm(P396lat, P396long);

% P404
[E_P404utm, N_P404utm] = ll2utm(P404lat, P404long);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Calculate the distance from centroid           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x_mu = mean(E_P395utm, E_P396utm, E_P404utm);
y_mu = mean(N_P395utm, N_P396utm, N_P404utm);

% P395
E_P395dist = (E_P395utm - x_mu);
N_P395dist = (N_P395utm - y_mu);

% P396
E_P396dist = (E_P396utm - x_mu);
N_P396dist = (N_P396utm - y_mu);

% P404
E_P404dist = (E_P404utm - x_mu);
N_P404dist = (N_P404utm - y_mu);

% Mean x,y location of the start or end position of three stations? Or do I
% take the mean of all x's for each station and then take the mean of those
% three means? And repeat for y? 

% Am I calculating distance from centroid for each observation at each
% station? 

%%% Sorry. Bit of a rough weekend; having a hard time thinking straight right now.
%%% Will give this another go before class Thursday.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%