function planC = loadDose(info_Image,planC,PatientPositionCODE,scanUID)
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


indexS = planC{end};

for i=1:length(info_Image)
    info_image = info_Image{i};

    dimage=dicomread(info_image);

    dimage = double(squeeze(dimage));

    % multiply by scaling factor
    dimage=dimage.*info_image.DoseGridScaling;

     zmesh = askZmesh(info_image,PatientPositionCODE);

    % Make zmesh a column vector
    zmesh=dicomrt_makevertical(zmesh);

    if PatientPositionCODE == 1 | PatientPositionCODE == 2
        min_x=info_image.ImagePositionPatient(1);
        pixel_spacing_x=info_image.PixelSpacing(1);

        min_y=info_image.ImagePositionPatient(2);
        pixel_spacing_y=info_image.PixelSpacing(2);

        [xmesh] = dicomrt_create1dmesh(min_x,pixel_spacing_x,info_image.Columns,0);
        [ymesh] = dicomrt_create1dmesh(min_y,pixel_spacing_y,info_image.Rows,0);

    else
        max_x=info_image.ImagePositionPatient(1);
        pixel_spacing_x=info_image.PixelSpacing(1);

        max_y=info_image.ImagePositionPatient(2);
        pixel_spacing_y=info_image.PixelSpacing(2);

        [xmesh] = dicomrt_create1dmesh(max_x,pixel_spacing_x,info_image.Columns,1);
        [ymesh] = dicomrt_create1dmesh(max_y,pixel_spacing_y,info_image.Rows,1);

    end

    zmesh=dicomrt_mmdigit(zmesh*0.1,7);
    ymesh=dicomrt_mmdigit(ymesh*0.1,7);
    xmesh=dicomrt_mmdigit(xmesh*0.1,7);

    type = 'Dose';

    tags = dicomrt_d2c_rtogtags;

    [xmesh,ymesh,zmesh,tags,dimage] = webtrev_doseCoordSystem(tags, PatientPositionCODE,xmesh,ymesh,zmesh,dimage);

    doseInitS = initializeCERR('dose');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Fill doseInitS

    doseInitS(1).imageType              = type;

    doseInitS(1).patientName            = [info_image.PatientName.FamilyName];

    try
        doseInitS(i).patientName     = [doseInitS(i).patientName,' ', ...
            info_image.PatientName.GivenName]; % may be not present in anonymized studies
    end

    
    doseInitS(1).doseType               = info_image.DoseType;
    
    doseInitS(1).doseUnits              = info_image.DoseUnits;
    
    doseInitS(1).doseScale              = 1;
    
    doseInitS(1).fractionGroupID        = num2str(i);
    
    doseInitS(1).orientationOfDose      = 'TRANSVERSE';    % LEAVE FOR NOW
       
    doseInitS(1).numberOfDimensions     = ndims(dimage);
    doseInitS(1).sizeOfDimension1       = size(dimage,2);
    doseInitS(1).sizeOfDimension2       = size(dimage,1);
    doseInitS(1).sizeOfDimension3       = size(dimage,3);
    
    doseInitS(1).coord1OFFirstPoint     = tags.coord1OFFirstPoint;
    
    doseInitS(1).coord2OFFirstPoint     = tags.coord2OFFirstPoint;
    
    doseInitS(1).transferProtocol       ='DICOM';

    doseInitS(1).DICOMHeaders           = info_image;

    % it would be possible to retrive this info from the RTDOSE images info
    % however for consistency we get xmesh ymesh and zmesh already calculated
    doseInitS(1).horizontalGridInterval = tags.horizontalGridInterval;
    
    doseInitS(1).verticalGridInterval   = tags.verticalGridInterval;
    % Optional
    try
        doseInitS(1).doseAtNormaliznPoint   = info_image.DoseReferenceSequence.Item_1.TargetPrescriptionDose;
    catch
        doseInitS(1).doseAtNormaliznPoint   ='';
    end
    doseInitS(1).doseArray              = dimage;

    doseInitS(1).zValues                = zmesh';
    
    doseInitS(1).doseUID                = createUID('DOSE');
    
    doseInitS(1).assocScanUID           = scanUID;
    % Writing CERR scan data
end

try
    planC{indexS.dose}= doseInitS;
catch
    
end

clear doseInitS xmesh ymesh zmesh tags dimage

function [zmesh]=askZmesh(info_image,PatientPositionCODE)

if info_image.GridFrameOffsetVector(1) == 0
    switch PatientPositionCODE
        case 1% HFS
            zmesh=info_image.ImagePositionPatient(3)+info_image.GridFrameOffsetVector;
        case 2% FFS
            zmesh=info_image.ImagePositionPatient(3)-info_image.GridFrameOffsetVector;
        case 3% HFP
            zmesh=info_image.ImagePositionPatient(3)+info_image.GridFrameOffsetVector;
        case 4% FFP
            zmesh=info_image.ImagePositionPatient(3)-info_image.GridFrameOffsetVector;
    end
else
    zmesh=info_image.GridFrameOffsetVector;
end

