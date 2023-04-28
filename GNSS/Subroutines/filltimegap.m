function [t2,d2]=filltimegap(t,d,dt)
%
%  [t2,d2]=filltimegap(t,d,dt)
%     t = time column vector, with gaps
%     d = data column vector, with gaps
%     dt = spacing of time vector
%     t2 = time vector, without gaps
%     d2 = data vector, gaps filled with NaNs
%


%
% are there any gaps?
%    
  difft=diff(t)/dt;
  i=find(difft>1.5); % these are the starts of the gaps

  if numel(i)>0
  
    ngap=round(difft(i));  % this is how many points are missing
    i2=[1;i+1;numel(t)+1]; % these are the starts of the data sections
%
% divide the time and data vectors by the gaps  
%
    bits=cell(2,numel(ngap)*2+1);
    for j=1:numel(ngap)+1
      bits{1,(j*2)-1}=t(i2(j):i2(j+1)-1);  
      bits{2,(j*2)-1}=d(i2(j):i2(j+1)-1);  
    end
%
% fill the gaps with nans
%
    for j=1:numel(ngap)
      bits{1,j*2}=[t(i(j))+dt:dt:t(i(j))+dt*(ngap(j)-1)]';
      bits{2,j*2}=ones(ngap(j)-1,1)*NaN;
    end
%
% reconstitute the time series
%
    t2=cell2mat(bits(1,:)');
    d2=cell2mat(bits(2,:)');
  
  else
    t2=t;
    d2=d;
  end

  i=find(difft<0.5);
  if numel(i)>0
    't has repeats'
  end