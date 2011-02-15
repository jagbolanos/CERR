function planC = loadStructure(rtstruct, planC, scanUID, study, ct_xmesh, ct_ymesh, ct_zmesh,tags)
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

rtstruct = rtstruct{1};

%rtstruct=rtstruct_filename;
% Get number of VOIs
ROIContourSequence=fieldnames(rtstruct.ROIContourSequence);

% Define cell array
VOI=cell(size(ROIContourSequence,1),2);

% Progress bar
h = waitbar(0,['Loading progress:']);
set(h,'Name','dicomrt_loadvoi: loading RTSTRUCT objects');

for i=1:size(ROIContourSequence,1) % for i=1:(number of VOIs) ...
    voilabel=getfield(rtstruct.StructureSetROISequence,char(ROIContourSequence(i)),'ROIName');
    VOI{i,1}=voilabel; % get VOI's name

    try
        ncont_temp=fieldnames(getfield(rtstruct.ROIContourSequence,char(ROIContourSequence(i)), ...
            'ContourSequence')); % get contour list per each VOI (temporary variable)
    catch
        warning(['ContourSequence not found for ROI: ', voilabel]);
        ncont_temp = [];
    end

    switch isempty(ncont_temp)
        case 0
            for j=1:size(ncont_temp,1) % for j=1:(number of contours) ...
                if j==1
                    VOI{i,2}=cell(size(ncont_temp,1),1);
                end
                try
                    NumberOfContourPoints=getfield(rtstruct.ROIContourSequence,char(ROIContourSequence(i)), ...
                        'ContourSequence', char(ncont_temp(j)),'NumberOfContourPoints');
                    ContourData=getfield(rtstruct.ROIContourSequence,char(ROIContourSequence(i)), ...
                        'ContourSequence',char(ncont_temp(j)),'ContourData');
                    x=dicomrt_mmdigit(ContourData(1:3:NumberOfContourPoints*3)*0.1,7);
                    y=dicomrt_mmdigit(ContourData(2:3:NumberOfContourPoints*3)*0.1,7);
                    z=dicomrt_mmdigit(ContourData(3:3:NumberOfContourPoints*3)*0.1,7);
                    VOI{i,2}{j,1}=cat(2,x,y,z); % this is the same as VOI{i,2}{j,1}=[x,y,z];
                end
            end
        case 1
            % set dummy values. This will be deleted later dugin the import
            NumberOfContourPoints=1;
            ContourData=[0,0,0];
            x=0;
            y=0;
            z=0;
            VOI{i,2}{1,1}=cat(2,x,y,z);
    end
    waitbar(i/size(ROIContourSequence,1),h);
    ncont_temp=[];
end
% VOI cell generation complete
% Store VOI in a cell array
cellVOI=cell(3,1);
cellVOI{1,1}=rtstruct;
cellVOI{2,1}=VOI;
cellVOI{3,1}=[];
% Close progress bar
close(h);

structureInitS = initializeCERR('structures');
%%
voitype=dicomrt_checkvoitype(cellVOI);

if isequal(voitype,'3D')
    cellVOI=dicomrt_3dto2dVOI(cellVOI);
end

if isempty(study{2,1})==0
    disp('(+) Fitting DICOM structures to CT scans to comply with RTOG format');
    cellVOI=dicomrt_fitvoi2ct(cellVOI,ct_zmesh,study);
    disp('(=) Fitting DICOM structures completed.');

    disp('(+) Validating DICOM structures');
    [cellVOI]=dicomrt_validatevoi(cellVOI,ct_xmesh,ct_ymesh,ct_zmesh);
    [newvoi]=dicomrt_closevoi(cellVOI);
    disp('(=) Validation DICOM structures completed.');

    % Conversion
    disp('(+) Converting DICOM structures');
    %         names = fieldnames(structureInitS);
    %         if length(structureInitS) == 0 & ~isempty(names)
    %             structureInitS(1).(names{1}) = deal([]);
    %         end
    [tmp_str,tags]=dicomrt_d2c_voi(structureInitS,indexS,newvoi,ct_xmesh,ct_ymesh,ct_zmesh,tags,scanUID);
    
    disp('(=) Conversion DICOM structures completed.');

else
    % Conversion
    disp('(+) Converting DICOM structures');
    %         names = fieldnames(structureInitS);
    %         if length(structureInitS) == 0 & ~isempty(names)
    %             structureInitS(1).(names{1}) = deal([]);
    %         end
    [tmp_str,tags]=dicomrt_d2c_voi(structureInitS,indexS,cellVOI,ct_xmesh,ct_ymesh,ct_zmesh,tags,tmp_scan.scanUID);
    disp('(=) Conversion DICOM structures completed.');
end

planC{indexS.structures} = tmp_str;

pack