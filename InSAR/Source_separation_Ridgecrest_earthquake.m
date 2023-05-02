clear
tic

%
% four coseismic files for Ridgecrest earthquake based on 4 scenes:
% Descending passes on:
%  - 2019-06-22
%  - 2019-07-04 (just a smidgen before the eq...)
%  - 2019-07-16
%  - 2019-07-28
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the individual interferograms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % URLS if we wanted to make a curl script.
%   !curl https://grfn.asf.alaska.edu/door/download/S1-GUNW-D-R-071-tops-20190728_20190704-135213-36450N_34472N-PP-9181-v2_0_2.nc
%   !curl https://grfn.asf.alaska.edu/door/download/S1-GUNW-D-R-071-tops-20190728_20190622-135213-36450N_34472N-PP-b4b2-v2_0_2.nc
%   !curl https://grfn.asf.alaska.edu/door/download/S1-GUNW-D-R-071-tops-20190716_20190622-135212-36450N_34472N-PP-7915-v2_0_2.nc
%   !curl https://grfn.asf.alaska.edu/door/download/S1-GUNW-D-R-071-tops-20190716_20190704-135212-36450N_34472N-PP-bf9f-v2_0_2.nc

  %
  % There are enough of these that it's simpler to handle as a loop.  So put them all in cell arrays
  %
    filename{1}='S1-GUNW-D-R-071-tops-20190716_20190622-135212-36450N_34472N-PP-7915-v2_0_2.nc';
    filename{2}='S1-GUNW-D-R-071-tops-20190728_20190622-135213-36450N_34472N-PP-b4b2-v2_0_2.nc';
    filename{3}='S1-GUNW-D-R-071-tops-20190716_20190704-135212-36450N_34472N-PP-bf9f-v2_0_2.nc';
    filename{4}='S1-GUNW-D-R-071-tops-20190728_20190704-135213-36450N_34472N-PP-9181-v2_0_2.nc';

    T0{1}='2019-06-22';
    T0{2}='2019-06-22';
    T0{3}='2019-07-04';
    T0{4}='2019-07-04';

    T1{1}='2019-07-16';
    T1{2}='2019-07-28';
    T1{3}='2019-07-16';
    T1{4}='2019-07-28';

  %
  % Load them all into a different cell arrays
  %
    % ncdisp(filename); % copied this to output_ncdisp.txt
    % ncdisp(filename,'/','min'); % shorter format 

    for k=1:4
      full_x{k}=ncread(filename{k},'/science/grids/data/longitude');
      full_y{k}=ncread(filename{k},'/science/grids/data/latitude');
      full_u{k}=ncread(filename{k},'/science/grids/data/unwrappedPhase')'; % unwrapped phase (radians)
      full_c{k}=ncread(filename{k},'/science/grids/data/coherence')';
      full_m{k}=ncread(filename{k},'/science/grids/data/connectedComponents')';
      full_a{k}=ncread(filename{k},'/science/grids/data/amplitude')';
    end
    L=ncread(filename{k},'/science/radarMetaData/wavelength'); % wavelength (m)

%
% Plot the components
%
  figure(1),clf
  for k=1:4
    subplot(4,4,(k-1)*4+1),imagesc(full_x{k},full_y{k},full_u{k}),axis xy,colorbar,title([T0{k},' - ',T1{k},' unwrappedPhase'])
    subplot(4,4,(k-1)*4+2),imagesc(full_x{k},full_y{k},full_c{k}),axis xy,colorbar,title([T0{k},' - ',T1{k},' coherence'])
    subplot(4,4,(k-1)*4+3),imagesc(full_x{k},full_y{k},full_m{k}),axis xy,colorbar,title([T0{k},' - ',T1{k},' connectedComponents'])
    subplot(4,4,(k-1)*4+4),imagesc(full_x{k},full_y{k},full_a{k}),axis xy,colorbar,title([T0{k},' - ',T1{k},' amplitude']),caxis([0,1e4])
  end
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trim them to all be the same size and area
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % pick a subset and make smaller versions that have the same limits (and that we can do math with)
  %
    x0=-118.2;
    x1=-117;
    y0=35.2;
    y1=36.2;

    dx=1/60/20; % how many degrees apart are the points (20 arcseconds)
    dy=dx;

  %
  % make the vectors that will represent the new trimmed edge coordinates
  %
    x=x0:dx:x1;
    y=y0:dy:y1;

  %
  % Loop over each interferogram, trim the data, and store as layers
  % of a 3D array (ny x nx x 4)
  %
    for k=1:4
      ix=find(full_x{k}>=x0-dx/2 & full_x{k} <=x1+dx/2); % allow an extra half pixel for numerical precision issues
      iy=find(full_y{k}>=y0-dy/2 & full_y{k} <=y1+dy/2);
      
      U(:,:,k)=flipud(full_u{k}(iy,ix));
      C(:,:,k)=flipud(full_c{k}(iy,ix));
      M(:,:,k)=flipud(full_m{k}(iy,ix));
      A(:,:,k)=flipud(full_a{k}(iy,ix));
    end

  %
  % Plot the trimmed components, just to make sure everything still looks ok
  %
    figure(2),clf,
    for k=1:4
      subplot(4,4,(k-1)*4+1),imagesc(x,y,U(:,:,k)),axis xy,colorbar,title([T0{k},' - ',T1{k},' unwrappedPhase'])
      subplot(4,4,(k-1)*4+2),imagesc(x,y,C(:,:,k)),axis xy,colorbar,title([T0{k},' - ',T1{k},' coherence'])
      subplot(4,4,(k-1)*4+3),imagesc(x,y,M(:,:,k)),axis xy,colorbar,title([T0{k},' - ',T1{k},' connectedComponents'])
      subplot(4,4,(k-1)*4+4),imagesc(x,y,A(:,:,k)),axis xy,colorbar,title([T0{k},' - ',T1{k},' amplitude']),caxis([0,1e4])
    end
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% How different are each of the scenes?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Convert to LOS displacement
  %
    LOS=U*L/4/pi;

  %
  % Plot each LOS on the diagonals, and the difference between each pair on the off-diagnonals
  % (just to see how they differ, not for analysis)
  % Note: lots of atmospheric features, correlated with topography!
  %
    figure(3),clf
    for k=1:4
      ax((k-1)*4+k)=subplot(4,4,(k-1)*4+k);
      imagesc(x,y,LOS(:,:,k)),axis xy,colorbar,csym(1),
      title([T0{k},' - ',T1{k},' LOS (m)'])
      set(gca,'dataaspectratio',[1/cosd(35.7),1,1])
      for j=k+1:4
        ax((k-1)*4+j)=subplot(4,4,(k-1)*4+j);
        imagesc(x,y,LOS(:,:,k)-LOS(:,:,j)),axis xy,colorbar,csym(0.15),
        title('difference')
        set(gca,'dataaspectratio',[1/cosd(35.7),1,1])
      end
    end
    colormap(cpolar)
    linkaxes(ax,'xy')

toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Source separation: pull out atmosphere vs motion?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % reshape each 2D image into a 1D vector of observations
  % Since we have 4 images in a 3D array (ny x nx x 4),
  % the result will be a new 2D array (ny*nx x 4)
  %
    nx=numel(x);
    ny=numel(y);

    LOS1d=reshape(LOS,[nx*ny,4,1]);

  %
  % Check that this rearranged everything the way we intended: can we get one back? yes!
  %
    figure(99),clf,imagesc(reshape(LOS1d(:,1),ny,nx)),axis xy,colorbar

  %
  % use Principal Component Analysis to identify the different
  % "signal" and "noise" contributions
  %
    [PCAcomp1D,PCAweight,~,~,explained,~]=pca(LOS1d','centered',false);

  %
  % Plot the PCA components ("sources")
  %
    figure(4),clf
    for k=1:4
      PCAcomp(:,:,k)=reshape(PCAcomp1D(:,k),ny,nx);
      subplot(2,2,k),imagesc(x,y,PCAcomp(:,:,k)),axis xy,colorbar,
      csym(quantile(abs(PCAcomp(:,:,k)),0.97,'all')) % automatically choose useful color limits
      title(['this component explains ',num2str(explained(k),'%0.1f'),'% of the total data variance'])
    end
    colormap(cpolar)

  %
  % Plot the PCA weights (how much is each component present in each interferogram?)
  %
    PCAweight % this prints the numbers to the screen

    figure(5),clf
    imagesc(PCAweight),colorbar,csym
    colormap(cpolar)
    xticks(1:numel(filename)),xlabel('PCA component number')
    yticks(1:numel(filename)),ylabel('interferogram number')
toc