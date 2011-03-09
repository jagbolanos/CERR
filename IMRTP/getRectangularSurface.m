function IM = getRectangularSurface(IM, planC)
indexS = planC{end};

for i = 1 : length(IM.beams)
    %get the number of voxels across the x-plane
    nX = size(-IM.beams(i).xFieldSize/2:planC{indexS.scan}.uniformScanInfo.grid1Units:IM.beams(i).xFieldSize/2, 2);

    %get the number of voxels across the z-plane
    nZ = size(-IM.beams(i).zFieldSize/2:planC{indexS.scan}.uniformScanInfo.sliceThickness:IM.beams(i).zFieldSize/2, 2);

    %create an empty vector of the all the x coordinates for the points on the
    %plane
    xV = zeros(1,nX*nZ);
    j = 1;
    for v=-IM.beams(i).xFieldSize/2:planC{indexS.scan}.uniformScanInfo.grid1Units:IM.beams(i).xFieldSize/2
        xV(j:j+nZ-1) = repmat(v,1,nZ);
        j = j + nZ;
    end

    %for each vector of x coordinates associate the corresponding z coordinate
    zV = IM.beams(i).isocenter.z + repmat(-IM.beams(i).zFieldSize/2:planC{indexS.scan}.uniformScanInfo.sliceThickness:IM.beams(i).zFieldSize/2,1,nX);

    %the y plane is fixed
    %yV = repmat(0,1,nX*nZ);


    beamxV = IM.beams(i).isocenter.x + xV * cosd(-IM.beams(i).gantryAngle);
    beamyV = IM.beams(i).isocenter.y + xV * sind(-IM.beams(i).gantryAngle);
    
    %scatter(newxV, newyV);

    %transform the coordinates from xyz to rcs and then round
    [rowsV colsV slicesV] = xyztom(beamxV, beamyV, zV, 1, planC, 'uniform');
    IM.beams(i).edgeS.rows = round(rowsV);
    IM.beams(i).edgeS.cols = round(colsV);
    IM.beams(i).edgeS.slices = round(slicesV);
end

end