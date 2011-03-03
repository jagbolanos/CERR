function [nrows, ncols, nslices] = getRectangularSurface(cols, slices)
%cols = 102; % in this particular case FieldSize / 0.0977 right now an even number is necessary
%slices = 40; %in this particular case FieldSize / 0.25 right now an even number is necessary
%edgeS.rows = repmat(256,1,squareFieldSizeCols*squareFieldSizeSlices);
%edgeS.cols = repmat((256-squareFieldSizeCols/2+1):(256+squareFieldSizeCols/2),1,squareFieldSizeSlices); % 512 / 2 => 256
%edgeS.slices = repmat((64-squareFieldSizeSlices/2+1):(64+squareFieldSizeSlices/2),1,squareFieldSizeCols) %1

ncols = zeros(1,cols*slices);
i = 1;
for v=(256-cols/2+1):(256+cols/2)
    ncols(i:i+slices-1) = repmat(v,1,slices);
    i = i + slices;
end

nslices = repmat((64-slices/2+1):(64+slices/2),1,cols);
nrows = repmat(256,1,cols*slices);
%scatter(ncols,nslices);

end