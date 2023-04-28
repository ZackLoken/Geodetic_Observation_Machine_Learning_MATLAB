clear
tic

%
% Quick demonstration of source separation, using 5 stations in Japan
%  - Once you run and understand each section of code below,
%    try changing some parameters (actually hyperparameters),
%    and see what happens!  e.g.,
%  - what if you make the smoothing window larger or smaller?
%  - what if you tell ICA to find more or fewer components?
%  - what if you add or remove another GNSS station?
%  - what if you replace a data point with a NaN or a crazy outlier value?
%  - try changing nothing, but running again.  How much random 
%    variation do you get in the ICA results?
%  - read about some of the options flags for pca and rica, try them out!
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load and clean data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Load and parse the data
%
mystations={'J231','J236','J935','J559','J938'};
nGNSS=numel(mystations);

for k=1:nGNSS
    station = mystations{k};
    %         webAddress = sprintf('http://geodesy.unr.edu/gps_timeseries/tenv3/plates/OK/%s.OK.tenv3 > %s.OK.tenv3', station, station);
    %         stationDownload = system(sprintf('curl %s', webAddress));
    fid = fopen(sprintf('%s.OK.tenv3', station));
    C = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
    fclose(fid);

    T{k}=datenum(C{2},'yymmmdd');
    X{k}=C{9}-C{9}(1);
    Y{k}=C{11}-C{11}(1);
    Z{k}=C{13}-C{13}(1);

    stationlat(k)=C{21}(1);
    stationlon(k)=mod(C{22}(1)+180,360)-180; % make sure the lon is [-180,180]
    stationelv(k)=C{23}(1);
end

%
% quick plot of raw data and station locations
%
shift=-0.05;
figure(1),clf
for k=1:nGNSS
    subplot(321),plot(T{k},X{k}-shift*(k-1),'.'),datetick,hold on
    subplot(323),plot(T{k},Y{k}-shift*(k-1),'.'),datetick,hold on
    subplot(325),plot(T{k},Z{k}-shift*(k-1),'.'),datetick,hold on
end

c=load('coastfile.xy.txt');
b=load('politicalboundaryfile.xy.txt');
subplot(3,2,[2,4,6]),
plot(c(:,1),c(:,2)),hold on,plot(b(:,1),b(:,2),'color',[1 1 1]*0.75)
plot(stationlon,stationlat,'k^')
text(stationlon,stationlat-0.15,mystations)
R=[138,143,36,42];
axis(R)
subplot(321),legend(mystations,'location','northwest')

%
% Fill time gaps with NaNs, trim time series to same timespan, and smooth to fill small gaps
%
% pick the dates for trimming the time series
t0=datenum([2009,02,01]);
% t1=datenum([2022,12,31]);
t1=datenum([2014,12,31]); % shorter time series runs faster for demo!

dt=1;
t=t0:dt:t1;

for k=1:nGNSS;
    [t2,z2]=filltimegap(T{k},Z{k},dt);
    [t2,x2]=filltimegap(T{k},X{k},dt);
    [t2,y2]=filltimegap(T{k},Y{k},dt);

    iduring=find(t2>=t0 & t2<=t1);

    easting(k,:)=x2(iduring)-x2(iduring(1)); % make the first value in the time series be zero
    northing(k,:)=y2(iduring)-y2(iduring(1));
    vertical(k,:)=z2(iduring)-z2(iduring(1));
end

dt_smooth=14; % smoothing window in units of samples, which is also in days since our sample interval dt = 1 day
sm_easting=movmedian(easting,dt_smooth,2,'omitnan');
sm_northing=movmedian(northing,dt_smooth,2,'omitnan');
sm_vertical=movmedian(vertical,dt_smooth,2,'omitnan');

%verify we got rid of all the NaNs by smoothing...
[numel(find(isnan(easting))),numel(find(isnan(northing))),numel(find(isnan(vertical)));...
    numel(find(isnan(sm_easting))),numel(find(isnan(sm_northing))),numel(find(isnan(sm_vertical)))]

%
% Quick plot of the cleaned, trimmed, and smoothed data
%
shift=-0.01;
figure(2),clf
subplot(311),
plot(t,easting-shift*(0:nGNSS-1)'*ones(size(t)),'.'),datetick,hold on,
plot(t,sm_easting-shift*(0:nGNSS-1)'*ones(size(t)),'k')
legend(mystations,'location','northwest')
ylabel('easting (m)')
subplot(312),
plot(t,northing-shift*(0:nGNSS-1)'*ones(size(t)),'.'),datetick,hold on,
plot(t,sm_northing-shift*(0:nGNSS-1)'*ones(size(t)),'k')
ylabel('northing (m)')
subplot(313),
plot(t,vertical-shift*(0:nGNSS-1)'*ones(size(t)),'.'),datetick,hold on,
plot(t,sm_vertical-shift*(0:nGNSS-1)'*ones(size(t)),'k')
ylabel('vertical (m)')

toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PCA analyses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PCA analysis: test 1, eastings only
%
[PCA_comp1,PCA_weight1]=pca(sm_easting);
Ncomponents=size(PCA_comp1,2);

f3=figure(3);clf,f3.Name='PCA Eastings only';
for k=1:Ncomponents
    subplot(Ncomponents,2,k*2-1),
    plot(t,PCA_comp1(:,k)),datetick,grid
    title(['PCA component # ',num2str(k)])
end
subplot(122),
imagesc(PCA_weight1'),colorbar
xticks(1:nGNSS),xticklabels(mystations),xlabel('station')
yticks(1:Ncomponents),ylabel('principal component number')
title('PCA weights at each station')

%
% PCA analysis: test 2, vertical only
%
[PCA_comp2,PCA_weight2]=pca(sm_vertical);
Ncomponents=size(PCA_comp2,2);

f4=figure(4);clf,f4.Name='PCA Vertical only';
for k=1:Ncomponents
    subplot(Ncomponents,2,k*2-1),
    plot(t,PCA_comp2(:,k)),datetick,grid
    title(['PCA component # ',num2str(k)])
end
subplot(122),
imagesc(PCA_weight2'),colorbar
xticks(1:nGNSS),xticklabels(mystations),xlabel('station')
yticks(1:Ncomponents),ylabel('principal component number')
title('PCA weights at each station')

%
% PCA analysis: test 3, all 3 components
%
[PCA_comp3,PCA_weight3]=pca([sm_easting;sm_northing;sm_vertical]);
Ncomponents=size(PCA_comp3,2);

f5=figure(5);clf,f5.Name='PCA ENV';
for k=1:Ncomponents
    subplot(Ncomponents,2,k*2-1),
    plot(t,PCA_comp3(:,k)),datetick,grid
    title(['PCA component # ',num2str(k)])
end
subplot(122),
imagesc(PCA_weight3'),colorbar
xticks(1:nGNSS*3),xlabel('station')
xticklabels([cellfun(@(x) [x,' E'],mystations,'uniformoutput',false),...
    cellfun(@(x) [x,' N'],mystations,'uniformoutput',false),...
    cellfun(@(x) [x,' V'],mystations,'uniformoutput',false)])
yticks(1:Ncomponents),ylabel('principal component number')
title('PCA weights at each station')

toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rICA analyses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % ICA analysis: test 1, eastings only
  %
    Ncomponents=4;

    data=sm_easting;
    Mdl=rica(data,Ncomponents);
    ICA_comp1=Mdl.TransformWeights;
    ICA_weight1=transform(Mdl,data);
    toc

    f6=figure(6);clf,f6.Name='ICA Eastings only';
    for k=1:Ncomponents
      subplot(Ncomponents,2,k*2-1),
      plot(t,ICA_comp1(:,k)),datetick,grid
      title(['ICA component # ',num2str(k)])
    end
    subplot(122),
      imagesc(ICA_weight1'),colorbar
      xticks(1:nGNSS),xticklabels(mystations),xlabel('station')
      yticks(1:Ncomponents),ylabel('principal component number')
      title('ICA weights at each station')

  %
  % ICA analysis: test 2, vertical only
  %
    Ncomponents=4;

    data=sm_vertical;
    Mdl=rica(data,Ncomponents);
    ICA_comp2=Mdl.TransformWeights;
    ICA_weight2=transform(Mdl,data);
    toc

    f7=figure(7);clf,f7.Name='ICA Vertical only';
    for k=1:Ncomponents
      subplot(Ncomponents,2,k*2-1),
      plot(t,ICA_comp2(:,k)),datetick,grid
      title(['ICA component # ',num2str(k)])
    end
    subplot(122),
      imagesc(ICA_weight2'),colorbar
      xticks(1:nGNSS),xticklabels(mystations),xlabel('station')
      yticks(1:Ncomponents),ylabel('principal component number')
      title('ICA weights at each station')

  %
  % ICA analysis: test 3, all 3 components
  %
    Ncomponents=6;

    data=[sm_easting;sm_northing;sm_vertical];
    Mdl=rica(data,Ncomponents);
    ICA_comp3=Mdl.TransformWeights;
    ICA_weight3=transform(Mdl,data);
    toc


    f8=figure(8);clf,f8.Name='ICA ENV';
    for k=1:Ncomponents
      subplot(Ncomponents,2,k*2-1),
      plot(t,ICA_comp3(:,k)),datetick,grid
      title(['ICA component # ',num2str(k)])
    end
    subplot(122),
      imagesc(ICA_weight3'),colorbar
      xticks(1:nGNSS*3),xlabel('station')
      xticklabels([cellfun(@(x) [x,' E'],mystations,'uniformoutput',false),...
                   cellfun(@(x) [x,' N'],mystations,'uniformoutput',false),...
                   cellfun(@(x) [x,' V'],mystations,'uniformoutput',false)])
      yticks(1:Ncomponents),ylabel('principal component number')
      title('ICA weights at each station')
