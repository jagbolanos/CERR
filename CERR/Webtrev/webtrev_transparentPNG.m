function webtrev_transparentPNG(name)
%
% Copyright 2010, Joseph O. Deasy, on behalf of the CERR development team.
% 
% This file is part of The Computational Environment for Radiotherapy Research (CERR).
% 
% CERR development has been led by:  Aditya Apte, Divya Khullar, James Alaly, and Joseph O. Deasy.
% 
% CERR has been financially supported by the US National Institutes of Health under multiple grants.
% 
% CERR is distributed under the terms of the Lesser GNU Public License. 
% 
%     This version of CERR is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
% CERR is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with CERR.  If not, see <http://www.gnu.org/licenses/>.

global stateS

% % % hAxis = stateS.handle.CERRAxis(1);
% % % A = getframe(hAxis);
% % % 
% % % [A alpha] = crop_background(A.cdata, [0 0 0]);
% % % 
% % % A = inpaint_background(A, alpha);
% % % % % % % Downscale the alphamatte
% % % % % % alpha = quarter_size(single(alpha), 0);
% % % % % % 
% % % % % % % Downscale
% % % % % % A = quarter_size(A, 255);
% % % 
% % % imwrite(A, name, 'Alpha', single(alpha));

hFig = stateS.handle.CERRSliceViewer;
hLMargin = findobj(hFig,'Tag', 'leftMargin');
lMarginPos = get(hLMargin,'position');
figPos = get(hFig,'position');

%Original resolution
% sliceCallBack('focus',stateS.handle.CERRAxis(4))

F = getframe(hFig,[lMarginPos(3) 65 figPos(3)-lMarginPos(3) figPos(4)-65]);

% FR = F.cdata(:,:,1); FG = F.cdata(:,:,2); FB = F.cdata(:,:,3);
% FR(FR==204) = 0; FG(FG==204) = 0; FB(FB==204) = 0;
% A(:,:,1)=FR; A(:,:,2)=FG; A(:,:,3)=FB;

A = F.cdata;

[A alpha] = crop_background(A, [0 0 0]);

% A = inpaint_background(A, alpha);

imwrite(A, name, 'Alpha', single(alpha));

% imwrite(F.cdata, name);

%% crop_background
function [A alpha] = crop_background(A, bcol)
% Map the foreground pixels
alpha = A(:,:,1) ~= bcol(1) | A(:,:,2) ~= bcol(2) | A(:,:,3) ~= bcol(3);
% Crop the background
N = any(alpha, 1);
M = any(alpha, 2);
M = find(M, 1):find(M, 1, 'last');
N = find(N, 1):find(N, 1, 'last');
A = A(M,N,:);
if nargout > 1
    % Crop the map
    alpha = alpha(M,N);
end
return

%% inpaint_background
function A = inpaint_background(A, alpha)
% Inpaint some of the background pixels with the colour of the nearest
% foreground neighbour
% Create neighbourhood
[Y X] = ndgrid(-4:4, -4:4);
X = Y .^ 2 + X .^ 2;
[X I] = sort(X(:));
X(I) = 2 .^ (numel(I):-1:1); % Use powers of 2
X = reshape(single(X), 9, 9);
X = X(end:-1:1,end:-1:1); % Flip for convolution
% Convolve with the mask & compute closest neighbour
M = conv2(single(alpha), X, 'same');
J = find(M ~= 0 & ~alpha);
[M M] = log2(M(J));
% Compute the index of the closest neighbour
[Y X] = ndgrid(-4:4, (-4:4)*size(alpha, 1));
X = X + Y;
X = X(I);
M = X(numel(X) + 2 - M) + J;
% Reshape for colour transfer
sz = size(A);
A = reshape(A, [sz(1)*sz(2) sz(3)]);
% Set background pixels to white (in case figure is greyscale)
A(~alpha,:) = 255;
% Change background colour to closest foreground colour
A(J,:) = A(M,:);
% Reshape back
A = reshape(A, sz);
return

%% quarter_size
function A = quarter_size(A, padval)
% Downsample an image by a factor of 4
try
    % Faster, but requires image processing toolbox
    A = imresize(A, 1/4, 'bilinear');
catch
    % No image processing toolbox - resize manually
    % Lowpass filter - use Gaussian (sigma: 1.7) as is separable, so faster
    filt = single([0.0148395 0.0498173 0.118323 0.198829 0.236384 0.198829 0.118323 0.0498173 0.0148395]);
    B = repmat(single(padval), [size(A, 1) size(A, 2)] + 8);
    for a = 1:size(A, 3)
        B(5:end-4,5:end-4) = A(:,:,a);
        A(:,:,a) = conv2(filt, filt', B, 'valid');
    end
    clear B
    % Subsample
    A = A(2:4:end,2:4:end,:);
end
return
