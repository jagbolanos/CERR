function [xCoord, yCoord, zCoord, xStart, yStart, zStart, XindHigh, YindHigh, ZindHigh] = webtrev_movetofirstslice(coord)
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

global planC stateS

indexS = planC{end};

hAxis = stateS.handle.CERRAxis(1);

view = getAxisInfo(hAxis,'view');

% check to see if coordinates and Variable are passed 
if ~exist('coord','var')

    strName = {planC{indexS.structures}.structureName};

    indx = strmatch('PTV', strName,'exact');

    if isempty(indx)
        indx = strmatch('ptv', strName,'exact');
    end

    if isempty(indx)
        indx = strmatch('PTV', strName);
    end

    if isempty(indx)
        indx = strmatch('ptv', strName);
    end

    if isempty(indx)
        error('no PTV')
    end

    for i = 1:length(indx)
        uniformStr = getUniformStr(indx(i), planC);

        %Get r,c,s of voxels inside uniformStr.
        [r,c,s] = find3d(uniformStr);

        clear uniformStr

        [xV, yV, zV] = getUniformScanXYZVals(planC{indexS.scan}(1));

        %Get the x,y,z coords of points in the structure, and transform.
        structXV = xV(c); clear c xV;
        structYV = yV(r); clear r yV;
        structZV = zV(s); clear s zV;

        transM = getTransM(planC{indexS.scan}(1), planC);

        [xT, yT, zT] = applyTransM(transM, structXV, structYV, structZV);

        clear structXV structYV structZV transM

        xCoordMax(i) = max(xT); 
        yCoordMax(i) = max(yT);
        zCoordMax(i) = max(zT);
        
        
        xCoord(i) = min(xT); clear xT;
        yCoord(i) = min(yT); clear yT;
        zCoord(i) = min(zT); clear zT;
        
        
    end
    
%     xCoord = max(xCoord);
%     yCoord = max(yCoord);
%     zCoord = max(zCoord);

    [xVals, yVals, zVals] = getScanXYZVals(planC{indexS.scan}(1));
        
    xStart = findnearest(xVals, min(xCoord)); 
    xCoord = xVals(xStart);
    yStart = findnearest(yVals, min(yCoord)); 
    yCoord = yVals(yStart);
    zStart = findnearest(zVals, min(zCoord)); 
    zCoord = zVals(zStart);
    
    
    XindHigh = findnearest(xVals, max(xCoordMax)); 
    clear xVals;
    YindHigh = findnearest(yVals, max(yCoordMax)); 
    clear yVals;
    ZindHigh = findnearest(zVals, max(zCoordMax)); 
    clear zVals;
        
else
    switch upper(view)

        case 'SAGITTAL'
            xCoord = coord;

        case 'CORONAL'
            yCoord = coord;

        case 'TRANSVERSE'
            zCoord = coord;
    end
end

% set the coordinates of Axis 
switch upper(view)

    case 'SAGITTAL'
        setAxisInfo(hAxis,'coord',xCoord);

    case 'CORONAL'
        setAxisInfo(hAxis,'coord',yCoord);

    case 'TRANSVERSE'
        setAxisInfo(hAxis,'coord',zCoord);
end

% Refresh CERR
CERRRefresh;