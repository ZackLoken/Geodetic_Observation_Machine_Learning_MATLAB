function c = csym(m)
%CSYM   Symmetric color axis about zero
%   CSYM(M) changes color axis limits to [-M,M].
%   CSYM, by itself, chooses M to be the largest absolute
%   value of the current color axis.
%
%   See also CPOLAR, CAXIS.

if nargin < 1, m = max(abs(clim)); end
clim([-m,m])