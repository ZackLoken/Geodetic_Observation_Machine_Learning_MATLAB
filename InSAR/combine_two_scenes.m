clear
tic

%
% practice stitching together two interferograms from adjacent scenes
%  - one to the south, and one to the north
%
  filenameS='Turkiye_2023/S1-GUNW-D-R-021-tops-20230210_20230129-033504-00035E_00035N-PP-8473-v2_0_6.nc';
  filenameN='Turkiye_2023/S1-GUNW-D-R-021-tops-20230210_20230129-033440-00036E_00037N-PP-c92c-v2_0_6.nc';

  % ncdisp(filename); % copied this to output_ncdisp.txt
  % ncdisp(filename,'/','min'); % shorter format 

  S.x=ncread(filenameS,'/science/grids/data/longitude');
  S.y=ncread(filenameS,'/science/grids/data/latitude');
  S.u=ncread(filenameS,'/science/grids/data/unwrappedPhase')'; % unwrapped phase (radians)
  S.c=ncread(filenameS,'/science/grids/data/coherence')';
  S.m=ncread(filenameS,'/science/grids/data/connectedComponents')';
  S.a=ncread(filenameS,'/science/grids/data/amplitude')';
  S.L=ncread(filenameS,'/science/radarMetaData/wavelength'); % wavelength (m)

  N.x=ncread(filenameN,'/science/grids/data/longitude');
  N.y=ncread(filenameN,'/science/grids/data/latitude');
  N.u=ncread(filenameN,'/science/grids/data/unwrappedPhase')'; % unwrapped phase (radians)
  N.c=ncread(filenameN,'/science/grids/data/coherence')';
  N.m=ncread(filenameN,'/science/grids/data/connectedComponents')';
  N.a=ncread(filenameN,'/science/grids/data/amplitude')';
  N.L=ncread(filenameN,'/science/radarMetaData/wavelength'); % wavelength (m)
  
toc

%
% Plot the components from each individual scene
%
  figure(1),clf
  subplot(241),imagesc(N.x,N.y,N.u),axis xy,colorbar,title('North frame unwrappedPhase')
  subplot(242),imagesc(N.x,N.y,N.c),axis xy,colorbar,title('North frame coherence')
  subplot(243),imagesc(N.x,N.y,N.m),axis xy,colorbar,title('North frame connectedComponents')
  subplot(244),imagesc(N.x,N.y,N.a),axis xy,colorbar,title('North frame amplitude'),caxis([0,1e4])
  subplot(245),imagesc(S.x,S.y,S.u),axis xy,colorbar,title('South frame unwrappedPhase')
  subplot(246),imagesc(S.x,S.y,S.c),axis xy,colorbar,title('South frame coherence')
  subplot(247),imagesc(S.x,S.y,S.m),axis xy,colorbar,title('South frame connectedComponents')
  subplot(248),imagesc(S.x,S.y,S.a),axis xy,colorbar,title('South frame amplitude'),caxis([0,1e4])


%
% Define the larger grid that will contain both of the smaller grids
%  - the outer limits of the big grid are defined by the 
%    limits of the smaller ones together
%  - round to a whole number of degrees, to avoid numerical imprecision issues
%  - Make big empty grids (filled with NaNs) for each of the components
%    for each scene
%
  dx=1/60/20; % how many degrees apart are the points (3 arcseconds)
  dy=dx;

  x=floor(min([N.x;S.x])):dx:ceil(max([N.x;S.x]));
  y=floor(min([N.y;S.y])):dx:ceil(max([N.y;S.y]));

  N.abig=zeros(numel(y),numel(x))*NaN;
  N.ubig=zeros(numel(y),numel(x))*NaN;
  N.cbig=zeros(numel(y),numel(x))*NaN;
  N.mbig=zeros(numel(y),numel(x))*NaN;

  S.abig=zeros(numel(y),numel(x))*NaN;
  S.ubig=zeros(numel(y),numel(x))*NaN;
  S.cbig=zeros(numel(y),numel(x))*NaN;
  S.mbig=zeros(numel(y),numel(x))*NaN;

%
% Put the scene info from the smaller array into the
% correct place within the larger array
%
  ix=find(x>=S.x(1)-dx/2 & x<=S.x(end)+dx/2);
  iy=find(y>=S.y(end)-dy/2 & y<=S.y(1)+dy/2); % these look backward because original y vector decreases

  S.abig(iy,ix)=flipud(S.a); % flip upside down because our new y vector increases, not decreases
  S.ubig(iy,ix)=flipud(S.u);
  S.cbig(iy,ix)=flipud(S.c);
  S.mbig(iy,ix)=flipud(S.m);

  ix=find(x>=N.x(1)-dx/2 & x<=N.x(end)+dx/2);
  iy=find(y>=N.y(end)-dy/2 & y<=N.y(1)+dy/2); % these look backward because original y vector decreases

  N.abig(iy,ix)=flipud(N.a); % flip upside down because our new y vector increases, not decreases
  N.ubig(iy,ix)=flipud(N.u);
  N.cbig(iy,ix)=flipud(N.c);
  N.mbig(iy,ix)=flipud(N.m);

  figure(2),clf
  subplot(341),imagesc(x,y,N.ubig),axis xy,colorbar,title('North frame unwrappedPhase')
  subplot(342),imagesc(x,y,N.cbig),axis xy,colorbar,title('North frame coherence')
  subplot(343),imagesc(x,y,N.mbig),axis xy,colorbar,title('North frame connectedComponents')
  subplot(344),imagesc(x,y,N.abig),axis xy,colorbar,title('North frame amplitude'),caxis([0,1e4])
  subplot(345),imagesc(x,y,S.ubig),axis xy,colorbar,title('South frame unwrappedPhase')
  subplot(346),imagesc(x,y,S.cbig),axis xy,colorbar,title('South frame coherence')
  subplot(347),imagesc(x,y,S.mbig),axis xy,colorbar,title('South frame connectedComponents')
  subplot(348),imagesc(x,y,S.abig),axis xy,colorbar,title('South frame amplitude'),caxis([0,1e4])

%
% combine the big grids by taking the maximum of each (will ignore values with NaNs)
% (could instead take the mean, if you explicitly tell it to ignore the NaNs)
%
  a=max(S.abig,N.abig);
  u=max(S.ubig,N.ubig);
  c=max(S.cbig,N.cbig);
  m=max(S.mbig,N.mbig);

  subplot(3,4, 9),imagesc(x,y,u),axis xy,colorbar,title('both together unwrappedPhase')
  subplot(3,4,10),imagesc(x,y,c),axis xy,colorbar,title('both together coherence')
  subplot(3,4,11),imagesc(x,y,m),axis xy,colorbar,title('both together connectedComponents')
  subplot(3,4,12),imagesc(x,y,a),axis xy,colorbar,title('both together amplitude'),caxis([0,1e4])

%
% make the wrapped phase and the Line of Sight displacement for the whole grid,
% and make versions of each with the incoherent bits masked out
%
  w=mod(u,2*pi); % wrapped phase

  L=N.L; % radar wavelength is the same for either
  LOS=u*L/4/pi; % !note 4pi because of 2-way travel

  imask=find(c<0.3 | m<1);
  
  am=a;
  am(imask)=NaN;

  um=u;
  um(imask)=NaN;

  wm=w;
  wm(imask)=NaN;

  LOSm=LOS;
  LOSm(imask)=NaN;

  figure(3),clf
  ax(1)=subplot(241);imagesc(x,y,a),axis xy,colorbar,title('amplitude'),caxis([-1e2,1e4])
  ax(2)=subplot(242);imagesc(x,y,w),axis xy,colorbar,title('wrapped phase'),
  ax(3)=subplot(243);imagesc(x,y,u),axis xy,colorbar,title('unwrapped phase'),csym
  ax(4)=subplot(244);imagesc(x,y,LOS),axis xy,colorbar,title('LOS displacement'),csym
  ax(5)=subplot(245);imagesc(x,y,am),axis xy,colorbar,title('amplitude'),caxis([-1e2,1e4])
  ax(6)=subplot(246);imagesc(x,y,wm),axis xy,colorbar,title('wrapped phase'),
  ax(7)=subplot(247);imagesc(x,y,um),axis xy,colorbar,title('unwrapped phase'),csym
  ax(8)=subplot(248);imagesc(x,y,LOSm),axis xy,colorbar,title('LOS displacement'),csym
  
  C=jet;
  C(1,:)=[1 1 1]*0.75;
  colormap(C)
  linkaxes(ax,'xy'),