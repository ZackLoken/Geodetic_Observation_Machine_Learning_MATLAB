clear
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBSERVATIONS: the interferogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Load in interferogram
  %
    filename='Ridgecrest_ARIA/S1-GUNW-D-R-071-tops-20190716_20190622-135212-36450N_34472N-PP-7915-v2_0_2.nc';
    x=ncread(filename,'/science/grids/data/longitude');
    y=ncread(filename,'/science/grids/data/latitude');
    u=ncread(filename,'/science/grids/data/unwrappedPhase')'; % unwrapped phase (radians)
    c=ncread(filename,'/science/grids/data/coherence')';
    m=ncread(filename,'/science/grids/data/connectedComponents')';
    a=ncread(filename,'/science/grids/data/amplitude')';
    L=ncread(filename,'/science/radarMetaData/wavelength'); % wavelength (m)

  %
  % flip the grids and y coordinate so that y coordinate increases
  % (this will ensure the same orientation as the okada model below)
  %
    y=flipud(y);
    u=flipud(u);
    c=flipud(c);
    m=flipud(m);
    a=flipud(a);

  %
  % Plot the interferogram, just to make sure there are no problems
  %
    figure(1),clf
    subplot(341),imagesc(x,y,u),axis xy,colorbar,title('original unwrappedPhase')
    subplot(342),imagesc(x,y,c),axis xy,colorbar,title('original coherence')
    subplot(343),imagesc(x,y,m),axis xy,colorbar,title('original connectedComponents')
    subplot(344),imagesc(x,y,a),axis xy,colorbar,title('original amplitude'),caxis([0,1e4])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONVERT LOCATION INFO: from lat,lon to centered x,y km
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Convert the positions from lat lon to UTM km
  % Shift to have (0,0) be at the center of your feature
  %
    % lat lon of each point in the grid
    [xmesh,ymesh]=meshgrid(x,y);

    % UTM coordinate of each point in the grid
    [Xutm,Yutm]=ll2utm(ymesh,xmesh);

    %define the center of your feature, in lat lon and UTM
    x0=-117.548;
    y0=35.713;
    [X0,Y0]=ll2utm(y0,x0);

    % shift (0,0) to be at the center of your feature, and convert to km
    Xshifted=(Xutm-X0)/1e3;
    Yshifted=(Yutm-Y0)/1e3;

    % make a single vector of X and Y (approximate)
    X=mean(Xshifted);
    Y=mean(Yshifted,2);

    subplot(345),imagesc(X,Y,u),axis xy,colorbar,title('UTM shifted unwrappedPhase')
    subplot(346),imagesc(X,Y,c),axis xy,colorbar,title('UTM shifted coherence')
    subplot(347),imagesc(X,Y,m),axis xy,colorbar,title('UTM shifted connectedComponents')
    subplot(348),imagesc(X,Y,a),axis xy,colorbar,title('UTM shifted amplitude'),caxis([0,1e4])

  %
  % calculate line of sight deformation, and wrapped phase, for later comparison,
  %
    w=mod(u,2*pi);
    LOS=u*L/4/pi;

  %
  % Optionally, trim the grids so they're centered around the feature of interest
  % (this will also save time when runing the okada model over fewer points)
  %
    boxsize=30; % how many km to include on each side of the feature?

    ix=find(X>=-boxsize & X<=boxsize);
    iy=find(Y>=-boxsize & Y<=boxsize);

    u=u(iy,ix);
    c=c(iy,ix);
    m=m(iy,ix);
    a=a(iy,ix);
    w=w(iy,ix);
    LOS=LOS(iy,ix);

    Xshifted=Xshifted(iy,ix);
    Yshifted=Yshifted(iy,ix);

    X=X(ix);
    Y=Y(iy);

    subplot(3,4, 9),imagesc(X,Y,u),axis xy,colorbar,title('trimmed unwrappedPhase')
    subplot(3,4,10),imagesc(X,Y,c),axis xy,colorbar,title('trimmed coherence')
    subplot(3,4,11),imagesc(X,Y,m),axis xy,colorbar,title('trimmed connectedComponents')
    subplot(3,4,12),imagesc(X,Y,a),axis xy,colorbar,title('trimmed amplitude'),caxis([0,1e4])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODEL: make a prediction using Okada solutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Make an okada model of displacement due to disolocation on a plane embeded within an
  % elastic halfspace, and calculate the modeled line-of-sight displacement for comparison 
  % with unwrapped interferograms
  %  - use the shifted UTM grid you already have for the calculations
  %
    E=Xshifted;
    N=Yshifted;

    % fault/plane orientation info
    STRIKE=135; % degrees east of north
    DIP=85;     % degress down from horizontal

    % fault/plane dimensions and location
    DEPTH=3;    % center of plane, km below the surface
    LENGTH=40;  % along strike length, km
    WIDTH=5;    % along dip width, km

    % amount and direction of motion on fault/plane
    RAKE=-180;    % direction of in-plane hanging wall motion, in deg CCW from strike
    SLIP=4;     % how much in-plane slip (m)
    OPEN=0.0;   % how much opening or closing of the plane (m)

  %
  % Use the Okada solutions to determine expected surface displacement
  %  in East, North, and Vertical directions (m)
  % Plot the displacements
  %   Note: csym is a Karen subroutine that makes the colorscale symmetric
  %
    toc
    [uE,uN,uZ] = okada85(E,N,DEPTH,STRIKE,DIP,LENGTH,WIDTH,RAKE,SLIP,OPEN);
    toc

    figure(2),clf
    subplot(131),imagesc(X,Y,uE),axis xy,axis equal,colorbar,csym,title('modeled east (m)')
    subplot(132),imagesc(X,Y,uN),axis xy,axis equal,colorbar,csym,title('modeled north (m)')
    subplot(133),imagesc(X,Y,uZ),axis xy,axis equal,colorbar,csym,title('modeled vertical (m)')
    colormap(jet)

  %
  % Resolve displacements from East/North/Vertical directions into 
  % line-of-sight direction.
  %  - Note: actual radar geometry varies a bit across the scene,
  %    but using a single number is close enough for our purposes.
  %
    % define radar geometry
    IncAngle=39;   % degrees from vertical - ranges from 32 - 46, so this is a good average number
    % HeadAngle=-10; % degrees from north - ascending flight direction, in deg E of N
    HeadAngle=-170; % degrees from north - descending flight direction, in deg E of N

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
    LOS_model=uE*px+uN*py+uZ*pz;

    % Just for fun (and learning/demonstration), convert the predicted displacement back to wrapped phase
    w_model=mod(LOS_model/L*4*pi,2*pi);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARE MODEL AND OBSERVATIONS: visually and quantitatively
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Plot the observed and modeled line of sight displacement, and the residual
  %
    residual=LOS-LOS_model;
    residual_rms=rms(residual(:),'omitnan');

    figure(3),clf
    subplot(231),imagesc(X,Y,LOS),axis xy,axis equal,colorbar,csym,grid,title('observed line of sight displacement (m)')
    subplot(232),imagesc(X,Y,LOS_model),axis xy,axis equal,colorbar,csym,grid,title('modeled line of sight displacement (m)')
    subplot(233),imagesc(X,Y,residual),axis xy,axis equal,colorbar,csym,grid,title(['residual, rms = ',num2str(residual_rms)])
    subplot(234),imagesc(X,Y,w),axis xy,axis equal,colorbar,title('observed wrapped phase')
    subplot(235),imagesc(X,Y,w_model),axis xy,axis equal,colorbar,title('modeled wrapped phase')
    colormap(jet)
  toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETER SEARCH: run multiple models, which one fits best?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Define the default parameters
  %
    % fault/plane orientation info
    STRIKE=135; % degrees east of north
    DIP=85;     % degress down from horizontal

    % fault/plane dimensions and location
    DEPTH=3;    % center of plane, km below the surface
    LENGTH=40;  % along strike length, km
    WIDTH=5;    % along dip width, km

    % amount and direction of motion on fault/plane
    RAKE=-180;    % direction of in-plane hanging wall motion, in deg CCW from strike
    SLIP=4;     % how much in-plane slip (m)
    OPEN=0.0;   % how much opening or closing of the plane (m)

  %
  % Simplest: Pick one parameter at at time to vary
  % (more robust to search over all parameter space jointly,
  %  but this should get you close to the global min for simple cases)
  %
    % STRIKEset=[0:45:360];
    STRIKEset=[0:20:100,120:5:160,180:20:360]; % finer sampling near the probable best value

  %
  % Loop over the varying set of parameters
  % Run the Okada model for each one and calculate the residual
  % Just store the RMS value
  %
    toc
    for k=1:numel(STRIKEset)
      STRIKE=STRIKEset(k);
      [uE,uN,uZ] = okada85(E,N,DEPTH,STRIKE,DIP,LENGTH,WIDTH,RAKE,SLIP,OPEN);
      LOS_model=uE*px+uN*py+uZ*pz;
      residual=LOS-LOS_model;
      residual_rms(k)=rms(residual(:),'omitnan');
    end
    toc

  %
  % plot the misfit as a function of parameters
  %
    figure(4),clf
    plot(STRIKEset,residual_rms,'o-')
    xlabel('strike'),ylabel('rms misfit')
toc