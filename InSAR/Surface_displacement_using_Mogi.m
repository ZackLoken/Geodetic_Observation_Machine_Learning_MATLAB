clear

%
% Make a Mogi model of displacement due to 
% an inflating sphere embeded within an
% elastic halfspace, and calculate the modeled
% line-of-sight displacement for comparison 
% with unwrapped interferograms
%
% Note, sphere is radially symmetric, so surface displacement
% depends only on radial distance from center of sphere
%

%
% 1D demo
%
  R=0:100:50e3; % radial points for sampling the predicted displacement field (m)
  F=-2e3; % depth to center of sphere in (m)
  V=1e6; % volumetric change, in m^3 (assumes a point source)
  nu=0.25; % Poisson's ratio
  % A=1e3; % radius of sphere (m)
  % P=1e6; % hydrostatic pressure change in sphere (Pa)
  % E=70e9; % Youngs modulus (Pa)

  [ur,uz,dt,er,et] = mogi(R,F,V,nu); % assumes a point source with volume change
  % [ur,uz,dt,er,et] = mogi(R,F,A,P,E,nu); % gives radius and pressure change

  figure(1),clf
  subplot(511),plot(R/1e3,ur),xlabel('radial distance from source (km)'),ylabel('m'),title('radial displacement')
  subplot(512),plot(R/1e3,uz),xlabel('radial distance from source (km)'),ylabel('m'),title('tangential displacement')
  subplot(513),plot(R/1e3,dt),xlabel('radial distance from source (km)'),ylabel('rad'),title('ground tilt')
  subplot(514),plot(R/1e3,er),xlabel('radial distance from source (km)'),ylabel('m/m'),title('radial strain')
  subplot(515),plot(R/1e3,et),xlabel('radial distance from source (km)'),ylabel('m/m'),title('tangential strain')

%
% 2D demo:
% Define the grid of points where we'll sample the displacement field
% (units of km from center of dislocation at 0,0)
%
  xmodel=[-50:.1:50];
  ymodel=[-50:.1:50];
  [xmesh,ymesh]=meshgrid(xmodel,ymodel);

  rmesh=sqrt(xmesh.^2+ymesh.^2);
  azimesh=90-atan2d(ymesh,xmesh);

  % check that the grids have the right values, and that they're not backward
  figure(2),clf,
  subplot(221),imagesc(xmodel,ymodel,xmesh),axis xy,colorbar,title('x value of grid for calculating displacements')
  subplot(222),imagesc(xmodel,ymodel,ymesh),axis xy,colorbar,title('y value of grid for calculating displacements')
  subplot(223),imagesc(xmodel,ymodel,rmesh),axis xy,colorbar,title('r value of grid for calculating displacements')
  subplot(224),imagesc(xmodel,ymodel,azimesh),axis xy,colorbar,title('azimuth value of grid for calculating displacements')

%
% compute displacement at radius values from across the grid
%
  R=rmesh(:)*1e3; % radial points for sampling the predicted displacement field (m)
  F=-2e3; % depth to center of sphere (m)
  nu=0.25; % Poisson's ratio
  V=1e6; % volume of material injected at this point (m^3).  1e6 = 100 meter cube

  [uR,uT] = mogi(R,F,V,nu); % we just care about displacement

%
% convert radial and tangential dislocations into E and N
%
  uRmesh=reshape(uR,size(xmesh));
  uTmesh=reshape(uT,size(xmesh));

  uE=uRmesh.*sind(azimesh);
  uN=uRmesh.*cosd(azimesh);
  uZ=uTmesh; % does tangential mean vertically? not azimuthally?

  figure(3),clf,
  subplot(221),imagesc(xmodel,ymodel,uRmesh),axis xy,colorbar,title('radial displacement (m)')
  subplot(222),imagesc(xmodel,ymodel,uTmesh),axis xy,colorbar,title('tangential (vertical) displacement (m)')
  subplot(223),imagesc(xmodel,ymodel,uE),axis xy,colorbar,title('East displacement (m)')
  subplot(224),imagesc(xmodel,ymodel,uN),axis xy,colorbar,title('North displacement (m)')

%
% Resolve displacements from East/North/Vertical directions into 
% line-of-sight direction.
%  - Note: actual radar geometry varies a bit across the scene,
%    but using a single number is close enough for our purposes.
%
  % define radar geometry
  IncAngle=39;   % degrees from vertical - ranges from 32 - 46, so this is a good average number
  HeadAngle=-10; % degrees from north - ascending flight direction, in deg E of N
  % HeadAngle=-170; % degrees from north - descending flight direction, in deg E of N

  % unit vector components for the line-of-sight direction
  %  - careful to choose whether you want satellite to ground,
  %    or ground to satellite (just a sign change)
  %

  % % vector components for line-of-sight range change (point from satellite to ground)
  % px=sind(IncAngle)*cosd(HeadAngle);
  % py=-sind(IncAngle)*sind(HeadAngle);
  % pz=-cosd(IncAngle);

  % vector components for line-of-sight surface displacement (point from ground to satellite)
  px=-sind(IncAngle)*cosd(HeadAngle);
  py=sind(IncAngle)*sind(HeadAngle);
  pz=cosd(IncAngle);

  % displacement in LOS direction is dot product of 3D displacement with LOS unit vector
  uLOS=uE*px+uN*py+uZ*pz;

  % Just for fun (and learning/demonstration), convert the predicted displacement back to wrapped phase
  wavelength=0.05546576;
  uphase=mod(uLOS/wavelength*4*pi,2*pi);

  figure(4),clf
  subplot(121),imagesc(xmodel,ymodel,uLOS),axis xy,colorbar,csym,title('modeled line of sight displacement (m)')
  subplot(122),imagesc(xmodel,ymodel,uphase),axis xy,colorbar,title('modeled wrapped phase')
  colormap(jet)