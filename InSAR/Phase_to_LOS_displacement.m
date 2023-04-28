clear

filename = 'S1-GUNW-D-R-013-tops-20221223_20221129-142407-00126W_00039N-PP-b1ef-v2_0_6.nc';

% ncdisp(filename); % list the components include in the file

A = ncread(filename,'/science/grids/data/amplitude')';
y = ncread(filename,'/science/grids/data/latitude');
x = ncread(filename,'/science/grids/data/longitude');
phase = ncread(filename,'/science/grids/data/unwrappedPhase')';
coh = ncread(filename,'/science/grids/data/coherence')';
concomp = ncread(filename,'/science/grids/data/connectedComponents')';
wavelength = ncread(filename,'/science/radarMetaData/wavelength');


figure(1),clf
subplot(2,2,1),imagesc(x,y,A),axis xy,colorbar,title('amplitude'),clim([0,1e4]),
subplot(2,2,2),imagesc(x,y,phase),axis xy,colorbar,title('phase'),%clim([0,1e4]),
subplot(2,2,3),imagesc(x,y,coh),axis xy,colorbar,title('coherence'),%clim([0,1e4]),
subplot(2,2,4),imagesc(x,y,concomp),axis xy,colorbar,title('connectedComponents'),%clim([0,1e4]),

% convert from phase to line of sight displacement
LOSdisp=phase*wavelength/4/pi;

i_incoherent=find(concomp==0);
LOSdisp(i_incoherent)=NaN;
i_incoherent=find(coh<0.3);
LOSdisp(i_incoherent)=NaN;

figure(2),clf
imagesc(x,y,LOSdisp)
axis xy
c = colorbar;
title('Humboldt County LOS displacement: 12/11/22 - 12/23/22')
xlabel('Longitude (Degrees)')
ylabel('Latitude (Degrees)')
c.Label.String = 'LOS Displacement (cm)';
Colorscale = jet;
Colorscale(1,:)=[0 0 0];
colormap(jet)
colormap(Colorscale)
clim([-0.03, 0.03])
