function maskM = getStructureMask(structNum, sliceNum, dim, planC)
%"getStructureMask"
%   Returns structure's mask on a specified slice number via uniformized
%   data.
%
%   structNum is the number of the requested structure
%   sliceNum is the slice NUMBER we want the structure on (not coordinate)
%   dim is the dimension (1,2,3 = x,y,z) that the slice should be taken
%   from.
%   planC is the plan (optional parameter: global is used if not passed)
%
%   WARNING: This function uses only uniformized data even if dim is 3 (for
%            zSlices).  In order to get the structure mask on a CT slice
%            via rasterSegments, use getRasterSegments and rasterToMask.
%
% JRA 11/14/03
%
%Usage:
%   function maskM = getStructureMask(structNum, sliceNum, dim, planC)
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

if ~exist('planC')
    global planC
end
indexS = planC{end};

[scanNum, relStructNum] = getStructureAssociatedScan(structNum, planC);

[indicesC, structBitsC, planC] = getUniformizedData(planC, scanNum);
[arraySize] = getUniformScanSize(planC{indexS.scan}(scanNum));

switch dim
	case 2
         rowDim = 3;    colDim = 2;     sliceDim = 1;
    case 1   
         rowDim = 3;    colDim = 1;     sliceDim = 2;
    case 3
         rowDim = 1;    colDim = 2;     sliceDim = 3;        
    otherwise
        warning('Valid Dimensions are 1,2,3 (x,y,z respectively.');
        return;
end

maskM = repmat(logical(0), [arraySize(rowDim) arraySize(colDim)]);
if relStructNum <= 52
    cellNum = 1;
else
    cellNum = ceil((relStructNum-52)/8)+1;
end
indicesM    = indicesC{cellNum};
structBitsM = structBitsC{cellNum};
sliceIndices = (indicesM(:,sliceDim) == sliceNum);
sliceXYZ = indicesM(sliceIndices,:);
if relStructNum <= 52
    sliceBits = logical(bitget(structBitsM(sliceIndices), relStructNum));
else
    sliceBits = logical(bitget(structBitsM(sliceIndices), relStructNum-52-8*(cellNum-2)));
end
structXYZ = sliceXYZ(sliceBits,:);

for i=1:size(structXYZ,1)
    maskM(structXYZ(i,rowDim), structXYZ(i,colDim)) = logical(1);
end
