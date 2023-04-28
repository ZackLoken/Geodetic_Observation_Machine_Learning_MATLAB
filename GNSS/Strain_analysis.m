clear

%
% download the data for 3 stations: P395, P404, and P396?
%
  % !curl http://geodesy.unr.edu/gps_timeseries/tenv3/plates/NA/P395.NA.tenv3 > dats/P395.NA.tenv3
  % !curl http://geodesy.unr.edu/gps_timeseries/tenv3/plates/NA/P396.NA.tenv3 > dats/P396.NA.tenv3
  % !curl http://geodesy.unr.edu/gps_timeseries/tenv3/plates/NA/P404.NA.tenv3 > dats/P404.NA.tenv3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the data and store the relevant columns in their own variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fid=fopen('P395.NA.tenv3');
    C=textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
    fclose(fid);

    t1=C{3};
    x1=C{9};
    y1=C{11};
    z1=C{13};

    lat1=C{21}(1); % just need the first value, not the whole column
    lon1=C{22}(1);

    fid=fopen('P396.NA.tenv3');
    C=textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
    fclose(fid);

    t2=C{3};
    x2=C{9};
    y2=C{11};
    z2=C{13};

    lat2=C{21}(1);
    lon2=C{22}(1);
    
    fid=fopen('P404.NA.tenv3');
    C=textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
    fclose(fid);

    t3=C{3};
    x3=C{9};
    y3=C{11};
    z3=C{13};

    lat3=C{21}(1);
    lon3=C{22}(1);

%
% Plot the time series
%
    figure(1),clf,
    subplot(311),plot(t1,x1-x1(1),t2,x2-x2(1),t3,x3-x3(1)),ylabel('east (m)')
      legend('P395','P396','P404','location','northwest')
    subplot(312),plot(t1,y1-y1(1),t2,y2-y2(1),t3,y3-y3(1)),ylabel('north (m)')
    subplot(313),plot(t1,z1-z1(1),t2,z2-z2(1),t3,z3-z3(1)),ylabel('elevation (m)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the velocity components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % calculate the horizontal velocity of each station over the full time series
  %
    Px1=polyfit(t1,x1,1);  vx1=Px1(1);
    Py1=polyfit(t1,y1,1);  vy1=Py1(1);
    Px2=polyfit(t2,x2,1);  vx2=Px2(1);
    Py2=polyfit(t2,y2,1);  vy2=Py2(1);
    Px3=polyfit(t3,x3,1);  vx3=Px3(1);
    Py3=polyfit(t3,y3,1);  vy3=Py3(1);

  %
  % calculate the magnitude and direction of each velocity vector
  %  - atan gives the "regular" 2-quadrant arctangent result
  %  - atan2 gives the 4-quadrant arctangent result in radians
  %  - atan2d gives the 4-quadrant arctangent result in degress: use this one
  %
    v1=sqrt(vx1^2+vy1^2);  th1=90-atan2d(vy1,vx1); % 90- because by default, angle is degrees CCW from east
    v2=sqrt(vx2^2+vy2^2);  th2=90-atan2d(vy2,vx2); % 90- because by default, angle is degrees CCW from east
    v3=sqrt(vx3^2+vy3^2);  th3=90-atan2d(vy3,vx3); % 90- because by default, angle is degrees CCW from east

  %
  % print out velocity components to the screen, just to check that they make sense
  %   columns: vx, vy, v in m, and azimuth in degrees
  %
    [vx1,vy1,v1,th1;vx2,vy2,v2,th2;vx3,vy3,v3,th3]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the velocity vectors on a map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % load coastline data and political boundary data
  % Start a map plot
  %
    c=load('coastfile.xy');
    b=load('politicalboundaryfile.xy');
    
    figure(2),clf
    plot(c(:,1),c(:,2),'k',b(:,1),b(:,2),'k:')

  %
  % plot the stations as squares and 
  % velocity vectors as arrows on the map
  % zoom in to region of interest
  %
    hold on
    plot(lon1,lat1,'s',lon2,lat2,'s',lon3,lat3,'s'),
    quiver([lon1;lon2;lon3],[lat1;lat2;lat3],[vx1;vx2;vx3],[vy1;vy2;vy3],'k')
    axis([-127.97      -119.73       41.366       50.102])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate strain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % create the 6x1 "data" vector from the velocities we already calculated
  %
    d=[vx1;vy1;vx2;vy2;vx3;vy3];

  %
  % convert station positions to UTM coordingates with units of eastings
  %
    lats=[lat1;lat2;lat3];
    lons=[lon1;lon2;lon3];

    [x,y]=ll2utm(lats,lons); %station oordinates in UTM

  %
  % find the centroid, and calculate the delta-x and delta-y
  % distances between the centroid and each station
  %
    centroid=[mean(x),mean(y)];
    dx=x-mean(x);
    dy=y-mean(y);


  %
  % set up 6x6 coefficient matrix, or the "model" matrix
  %
    G = [1, 0, dx(1), dy(1),     0, -dy(1);...
         0, 1,     0, dx(1), dy(1),  dx(1);...
         1, 0, dx(2), dy(2),     0, -dy(2);...
         0, 1,     0, dx(2), dy(2),  dx(2);...
         1, 0, dx(3), dy(3),     0, -dy(3);...
         0, 1,     0, dx(3), dy(3),  dx(3)];

  %
  % solve for model paramaters (tx, ty, exx, exy, eyy, w)
  %
      m=G\d;

  %
  % pull out the individual values for easy display,
  % and create the 2x2 strain matrix
  %
    tx=m(1) % in units of meters
    ty=m(2)
    exx=m(3); % in units of strain (dimensionless)
    exy=m(4);
    eyy=m(5);
    strain=[exx exy; exy eyy]*1e9 % in units of nanostrain
    rotation=m(6) % in units of radians (also very small)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualize and think about strain results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Calculate the principal strains and principal strain axes
  %
    [paxes, pvals]=eig(strain);

  %
  % make a figure in UTM space with the station positions relative
  % to their centroid, and the velocity vectors as before
  %
    figure(3),clf
    plot(dx/1e3,dy/1e3,'^k'),axis equal, grid,
    xlabel('east distance from centroid (km)')
    ylabel('north distance from centroid (km)')
    hold on
    scale=1e3;
    quiver(dx/1e3,dy/1e3,[vx1;vx2;vx3]*scale,[vy1;vy2;vy3]*scale,0,'k')
    quiver(-15,-18,10e-3*scale,0,0,'k'),ylim([-20,30])
    text(-15,-19,'10 mm/yr')

  %
  % add bars to represent the principal strains, scaled 
  %  - starts with a line from -1 to 1
  %  - scales by the relevant unit vector components to get the right orientation
  %  - scales by the relevant principal strain components to get the right length
  %  - scales by an additional factor to make it plot at a good size for the figure
  %
    scale=1e-1;
    plot([1,-1]*paxes(1,1)*pvals(1,1)*scale,[1,-1]*paxes(2,1)*pvals(1,1)*scale,'b','linewidth',3)
    plot([1,-1]*paxes(1,2)*pvals(2,2)*scale,[1,-1]*paxes(2,2)*pvals(2,2)*scale,'r','linewidth',3)

  %
  % add title with information about the strains
  %
    compression=pvals(1,1);
    compression_axis=paxes(:,1);
    compression_azimuth=atand(compression_axis(1)/compression_axis(2)); % angle in deg E of N 

    title(['principal compression is ',num2str(compression),' nanostrain at ',num2str(compression_azimuth),' deg EofN'])