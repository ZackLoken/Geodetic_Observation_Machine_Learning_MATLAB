function c = cpolar(m)
%CPOLAR   Shades of blue, white, and red color map
%   CPOLAR(M) returns an M-by-3 matrix containing a "polar" colormap.
%   CPOLAR, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   NOTE: m will be forced to be odd to that center value is white
%   Use with CSYM to ensure center value is zero.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(cpolar)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT, CSYM.


if nargin < 1, m = size(get(gcf,'colormap'),1); end

if mod(m,2)==0, m=m+1; end

  CR=[linspace(0,1,(m-1)/2+1),ones(1,(m-1)/2)]';
  
  CB=flipud(CR);
  CG=[linspace(0,1,(m-1)/2+1)]';CG=[CG;flipud(CG(1:(m-1)/2))];
  c=[CR,CG,CB];
