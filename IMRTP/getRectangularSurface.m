function [nrows, ncols, nslices] = getRectangularSurface(IM, planC)
indexS = planC{end};

%convert the field from xz plante to cols vs slices
cols = round(IM.beams.xFieldSize / planC{indexS.scan}.uniformScanInfo.grid1Units);
slices = round(IM.beams.zFieldSize / planC{indexS.scan}.uniformScanInfo.sliceThickness);

%adjust for calculations
if mod(cols,2) == 1
    cols = cols + 1;
end

if mod(slices,2) == 1
    slices = slices + 1;
end

%get the isocenter so we can place the field at it
[misocenter.r misocenter.c misocenter.s] = xyztom([IM.beams.isocenter.x],[IM.beams.isocenter.y],[IM.beams.isocenter.z],1,planC,'uniform');
misocenter.r = round(misocenter.r);
misocenter.c = round(misocenter.c);
misocenter.s = round(misocenter.s);

ncols = zeros(1,cols*slices);
i = 1;
for v=(misocenter.c-cols/2+1):(misocenter.c+cols/2)
    ncols(i:i+slices-1) = repmat(v,1,slices);
    i = i + slices;
end

%for each vector of cols associate with the corresponding slices
nslices = repmat((misocenter.s-slices/2+1):(misocenter.s+slices/2),1,cols);

%the row is fixed as it is a plane along cols vs. slices
nrows = repmat(misocenter.r,1,cols*slices);


end