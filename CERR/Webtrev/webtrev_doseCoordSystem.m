function [xmesh,ymesh,zmesh,tags,dimage] = doseCoordSystem(tags, PatientPosition,xmesh,ymesh,zmesh,dimage)
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

type = 'dose';
dimage                      = flipdim(dimage,3);

if PatientPosition==1                       % HFS
    tags.hio                    = 'IN';
    tags.pos                    = 'NOSE UP';
    if strcmpi('CT',type)~=1
        xmesh                       = xmesh;
        ymesh                       = -ymesh;
        zmesh                       = -zmesh;
        zmesh                       = flipdim(zmesh,1);
        %zmesh                       = zmesh-zmesh(1); % set origin to the first image transmitted
        tags.coord1OFFirstPoint     = xmesh(1);
        tags.coord2OFFirstPoint     = ymesh(1);
        temp_diff_x                 = diff(xmesh);
        temp_diff_y                 = diff(ymesh);
        tags.horizontalGridInterval = temp_diff_x(1);
        tags.verticalGridInterval   = temp_diff_y(1);
    else
        tags.originalCTxmesh        = xmesh;
        tags.originalCTymesh        = ymesh;
        tags.originalCTzmesh        = zmesh;
        xmesh                       = xmesh;
        ymesh                       = -ymesh;
        zmesh                       = -zmesh;
        zmesh                       = flipdim(zmesh,1);
        %zmesh                       = zmesh-zmesh(1); % set origin to the first image transmitted
        tags.xOffset                = xmesh(1) + sqrt(power((xmesh(1)-xmesh(end)),2))./2;
        tags.yOffset                = ymesh(1) - sqrt(power((ymesh(1)-ymesh(end)),2))./2;
        temp_diff_x                 = diff(xmesh);
        temp_diff_y                 = diff(ymesh);
        tags.grid1Units             = abs(temp_diff_x(1));
        tags.grid2Units             = abs(temp_diff_y(1));
    end
    tags.xcoordOfNormaliznPoint = '';
    tags.ycoordOfNormaliznPoint = '';
    tags.zcoordOfNormaliznPoint = '';
elseif PatientPosition==2                   % FFS

    tags.hio                    = 'OUT';
    tags.pos                    = 'NOSE UP';
    if strcmpi('CT',type)~=1
        %             xmesh                       = xmesh;
        xmesh                       = -xmesh;%DK
        ymesh                       = -ymesh;
        zmesh                       = -zmesh;
        zmesh                       = flipdim(zmesh,1);
        %zmesh                       = zmesh-zmesh(1); % set origin to the first image transmitted
        %             tags.coord1OFFirstPoint     = xmesh(1);
        tags.coord1OFFirstPoint     = -xmesh(1);%DK
        tags.coord2OFFirstPoint     = ymesh(1);
        temp_diff_x                 = diff(xmesh);
        temp_diff_y                 = diff(ymesh);
        tags.horizontalGridInterval = temp_diff_x(1);
        tags.verticalGridInterval   = temp_diff_y(1);
    else
        tags.originalCTxmesh        = xmesh;
        tags.originalCTymesh        = ymesh;
        tags.originalCTzmesh        = zmesh;
        xmesh                       = xmesh;
        ymesh                       = -ymesh;
        zmesh                       = -zmesh;
        zmesh                       = flipdim(zmesh,1);
        %zmesh                       = zmesh-zmesh(1); % set origin to the first image transmitted
        tags.xOffset                = xmesh(1) + sqrt(power((xmesh(1)-xmesh(end)),2))./2;
        tags.yOffset                = ymesh(1) - sqrt(power((ymesh(1)-ymesh(end)),2))./2;
        temp_diff_x                 = diff(xmesh);
        temp_diff_y                 = diff(ymesh);
        tags.grid1Units             = abs(temp_diff_x(1));
        tags.grid2Units             = abs(temp_diff_y(1));
    end
    tags.xcoordOfNormaliznPoint = '';
    tags.ycoordOfNormaliznPoint = '';
    tags.zcoordOfNormaliznPoint = '';
elseif PatientPosition==3                   % HFP

    tags.hio                    = 'IN';
    tags.pos                    = 'NOSE DOWN';
    if strcmpi('CT',type)~=1
        xmesh                       = -xmesh;
        ymesh                       = ymesh;
        zmesh                       = -zmesh;
        zmesh                       = flipdim(zmesh,1);
        %zmesh                       = zmesh-zmesh(1); % set origin to the first image transmitted
        tags.coord1OFFirstPoint     = xmesh(1);
        tags.coord2OFFirstPoint     = ymesh(1);
        temp_diff_x                 = diff(xmesh);
        temp_diff_y                 = diff(ymesh);
        tags.horizontalGridInterval = temp_diff_x(1);
        tags.verticalGridInterval   = temp_diff_y(1);
    else
        tags.originalCTxmesh        = xmesh;
        tags.originalCTymesh        = ymesh;
        tags.originalCTzmesh        = zmesh;
        xmesh                       = -xmesh;
        ymesh                       = ymesh;
        zmesh                       = -zmesh;
        zmesh                       = flipdim(zmesh,1);
        %zmesh                       = zmesh-zmesh(1); % set origin to the first image transmitted
        tags.xOffset                = xmesh(1) + sqrt(power((xmesh(1)-xmesh(end)),2))./2;
        tags.yOffset                = ymesh(1) - sqrt(power((ymesh(1)-ymesh(end)),2))./2;
        temp_diff_x                 = diff(xmesh);
        temp_diff_y                 = diff(ymesh);
        tags.grid1Units             = abs(temp_diff_x(1));
        tags.grid2Units             = abs(temp_diff_y(1));
    end
    tags.xcoordOfNormaliznPoint = '';
    tags.ycoordOfNormaliznPoint = '';
    tags.zcoordOfNormaliznPoint = '';
else                                        % FFP

    tags.hio                    = 'OUT';
    tags.pos                    = 'NOSE DOWN';
    if strcmpi('CT',type)~=1
        xmesh                       = -xmesh;
        ymesh                       = ymesh;
        zmesh                       = -zmesh;
        zmesh                       = flipdim(zmesh,1);
        %zmesh                       = zmesh-zmesh(1); % set origin to the first image transmitted
        tags.coord1OFFirstPoint     = xmesh(1);
        tags.coord2OFFirstPoint     = ymesh(1);
        temp_diff_x                 = diff(xmesh);
        temp_diff_y                 = diff(ymesh);
        tags.horizontalGridInterval = temp_diff_x(1);
        tags.verticalGridInterval   = temp_diff_y(1);
    else
        tags.originalCTxmesh        = xmesh;
        tags.originalCTymesh        = ymesh;
        tags.originalCTzmesh        = zmesh;
        xmesh                       = -xmesh;
        ymesh                       = ymesh;
        zmesh                       = -zmesh;
        zmesh                       = flipdim(zmesh,1);
        %zmesh                       = zmesh-zmesh(1); % set origin to the first image transmitted
        tags.xOffset                = xmesh(1) + sqrt(power((xmesh(1)-xmesh(end)),2))./2;
        tags.yOffset                = ymesh(1) - sqrt(power((ymesh(1)-ymesh(end)),2))./2;
        temp_diff_x                 = diff(xmesh);
        temp_diff_y                 = diff(ymesh);
        tags.grid1Units             = abs(temp_diff_x(1));
        tags.grid2Units             = abs(temp_diff_y(1));
    end
    tags.xcoordOfNormaliznPoint = '';
    tags.ycoordOfNormaliznPoint = '';
    tags.zcoordOfNormaliznPoint = '';
end