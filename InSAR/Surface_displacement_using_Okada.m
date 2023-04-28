clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Data Loading                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Georeferenced, unwrapped interferogram for the Ridgecrest 2019 Earthquake.
filename = 'S1-GUNW-A-R-064-tops-20190710_20190628-015013-36885N_35006N-PP-a1b9-v2_0_2.nc';

% ncdisp(filename); % list the components included in the file

% Transpose variables so plot in proper orientation
A = ncread(filename,'/science/grids/data/amplitude')';
y = ncread(filename,'/science/grids/data/latitude');
x = ncread(filename,'/science/grids/data/longitude');
phase = ncread(filename,'/science/grids/data/unwrappedPhase')';
coh = ncread(filename,'/science/grids/data/coherence')';
concomp = ncread(filename,'/science/grids/data/connectedComponents')';
wavelength = ncread(filename,'/science/radarMetaData/wavelength');

% Convert from phase to line of sight displacement
LOSdisp=phase*wavelength/4/pi;

% Remove decorrelated areas
i_incoherent=find(concomp==0);
LOSdisp(i_incoherent)=NaN;
i_incoherent=find(coh<0.4);
LOSdisp(i_incoherent)=NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Data Visualization                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot the georeferenced, unwrapped interferogram's raw data. 
figure(1), clf
subplot(2, 2, 1), imagesc(x, y, A), axis xy, colorbar, title('Amplitude'), clim([0,1e4]),
subplot(2, 2, 2), imagesc(x, y, phase), axis xy, colorbar, title('Phase'), % clim([0,1e4]),
subplot(2, 2, 3), imagesc(x, y, coh), axis xy, colorbar, title('Coherence'), % clim([0,1e4]),
subplot(2, 2, 4), imagesc(x, y, concomp), axis xy, colorbar, title('Connected Components'), %clim([0,1e4]),

% Plot the line-of-sight (LOS) displacement. 
figure(2),clf
imagesc(x, y, LOSdisp)
axis xy
c = colorbar;
title('Ridgecrest 2019 Earthquake: LOS displacement June 28 - July 10')
xlabel('Longitude (Degrees)')
ylabel('Latitude (Degrees)')
c.Label.String = 'LOS Displacement (cm)';
Colorscale = jet;
Colorscale(1,:)=[0 0 0];
colormap(jet)
colormap(Colorscale)
clim([-0.1, 0.1])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Okada Solutions                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use the Okada solutions for surface displacement due to a buried planar
% dislocation to model the expected line-of-sight deformation from the
% Ridgecrest 2019 Earthquake using various source parameters (depth,
% length, width, strike, diop, rake, slip amount, and opening amount). 

% Make an okada model of displacement due to 
% disolocation on a plane embeded within an
% elastic halfspace, and calculate the modeled
% line-of-sight displacement for comparison 
% with unwrapped interferograms

% Define the grid of points where we'll sample the displacement field
% (units of km from center of dislocation at 0,0)

  xmodel=[-50:.1:50];
  ymodel=[-50:.1:50];
  [xmesh,ymesh]=meshgrid(xmodel,ymodel);

  % check that the grids have the x and y values, and that they're not backwards
  figure(3),clf,
  subplot(121),imagesc(xmodel,ymodel,xmesh),axis xy,colorbar,title('x value of grid for calculating displacements')
  subplot(122),imagesc(xmodel,ymodel,ymesh),axis xy,colorbar,title('y value of grid for calculating displacements')


% Define the paramaters we'll use for our model

  % Points to sample the surface displacement
  E = xmesh;
  N = ymesh;

  % Fault/plane orientation info
  STRIKE = 325; % degrees east of north
  DIP = 80;     % degress down from horizontal

  % Fault/plane dimensions and location
  DEPTH = 6;    % center of plane, km below the surface
  LENGTH = 35;  % along strike length, km
  WIDTH = 4;    % along dip width, km

  % Amount and direction of motion on fault/plane
  RAKE = 35;    % direction of in-plane hanging wall motion, in deg CCW from strike
  SLIP = 7;     % how much in-plane slip (m)
  OPEN = 2;   % how much opening or closing of the plane (m)

% Use the Okada solutions to determine expected surface displacement
%  in East, North, and Vertical directions (m)
% Plot the displacements
%   Note: csym is a Karen Luttrell subroutine that makes the colorscale symmetric

  [uE,uN,uZ] = okada85(E,N,DEPTH,STRIKE,DIP,LENGTH,WIDTH,RAKE,SLIP,OPEN);

  figure(4),clf
  subplot(131),imagesc(xmodel,ymodel,uE),axis xy,colorbar,csym,title('modeled east (m)')
  subplot(132),imagesc(xmodel,ymodel,uN),axis xy,colorbar,csym,title('modeled north (m)')
  subplot(133),imagesc(xmodel,ymodel,uZ),axis xy,colorbar,csym,title('modeled vertical (m)')
  colormap(jet)


% Resolve displacements from East/North/Vertical directions into 
% line-of-sight direction.
%  - Note: actual radar geometry varies a bit across the scene,
%    but using a single number is close enough for our purposes.

  % define radar geometry
  IncAngle=39;   % degrees from vertical - ranges from 32 - 46, so this is a good average number
  HeadAngle=-10; % degrees from north - ascending flight direction, in deg E of N
  % HeadAngle=-170; % degrees from north - descending flight direction, in deg E of N

  % unit vector components for the line-of-sight direction
  px=sind(IncAngle)*cosd(HeadAngle);
  py=-sind(IncAngle)*sind(HeadAngle);
  pz=-cosd(IncAngle);

  % displacement in LOS direction is dot product of 3D displacement with LOS unit vector
  uLOS=uE*px+uN*py+uZ*pz;

  % Just for fun (and learning/demonstration), convert the predicted displacement back to wrapped phase
  wavelength=0.05546576;
  uphase=mod(uLOS/wavelength*4*pi,2*pi);

  figure(5),clf
  subplot(121),imagesc(xmodel,ymodel,uLOS),axis xy,colorbar,csym,title('modeled line of sight displacement (m)')
  subplot(122),imagesc(xmodel,ymodel,uphase),axis xy,colorbar,title('modeled wrapped phase')
  colormap(jet)

  % Check consistency of okada85 results using the "Checklist for numerical calculations"
% from Table 2 [Okada, 1985] page 1149.

okada85_checklist(); % What are the arguments for this function??? 