function [planC PatientPositionCODE, study,xmesh,ymesh,zmesh,tags] = webtrev_loadct(ctlist,planC)
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

ctNum = length(ctlist);
zmesh = zeros(1,ctNum);
nct=0; CToffset=1000;

for i = 1:ctNum
    nct=nct+1;

    info_temp = ctlist{i};
    temp=dicomread(info_temp);


    zmesh(nct)=info_temp.ImagePositionPatient(3);

    if isfield(info_temp,'RescaleSlope')~=0 | isfield(info_temp,'RescaleIntercept')~=0
        temp=double(temp)*info_temp.RescaleSlope+info_temp.RescaleIntercept+CToffset;
    else
        warning('dicomrt_loadct: no DICOM Rescale data were found. Assuming RescaleSlope = 1, RescaleIntercept = 0 and CToffset = 1000');
        temp=double(temp);
    end

    case_study_info{nct}=info_temp;
    
    case_study(:,:,nct)=uint16(temp);
end

[zmesh,IX] = sort(zmesh);

case_study = case_study(:,:,IX);

clear ctlist;


% Make zmesh a column vector
zmesh=dicomrt_makevertical(zmesh);

[PatientPositionCODE]=dicomrt_getPatientPosition(info_temp);

if PatientPositionCODE == 1 | PatientPositionCODE == 2 
    min_x=info_temp.ImagePositionPatient(1);
    pixel_spacing_x=info_temp.PixelSpacing(1);
    
    min_y=info_temp.ImagePositionPatient(2);
    pixel_spacing_y=info_temp.PixelSpacing(2);
    
    [xmesh] = dicomrt_create1dmesh(min_x,pixel_spacing_x,size(temp,2),0);
    [ymesh] = dicomrt_create1dmesh(min_y,pixel_spacing_y,size(temp,1),0);

else
    max_x=info_temp.ImagePositionPatient(1);
    pixel_spacing_x=info_temp.PixelSpacing(1);
    
    max_y=info_temp.ImagePositionPatient(2);
    pixel_spacing_y=info_temp.PixelSpacing(2);
    
    [xmesh] = dicomrt_create1dmesh(max_x,pixel_spacing_x,size(temp,1),1);
    [ymesh] = dicomrt_create1dmesh(max_y,pixel_spacing_y,size(temp,2),1);

end

zmesh=dicomrt_mmdigit(zmesh*0.1,7);
ymesh=dicomrt_mmdigit(ymesh*0.1,7);
xmesh=dicomrt_mmdigit(xmesh*0.1,7);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indexS = planC{end};

scanInitS = initializeCERR('scan');

tags = dicomrt_d2c_rtogtags;

study{1,1}=case_study_info;
study{2,1}=case_study;
study{3,1}=[];

clear case_study case_study_info

[tmpS,tags] = dicomrt_d2c_scan(scanInitS,indexS,study,xmesh,ymesh,zmesh,tags);

tags.nimages = size(study{2,1},3);

planC{indexS.scan} = tmpS;

pack
