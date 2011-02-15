function planC = webtrev_dicomdirScan(dirtoScan,dosefile)
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

dcmSpool = 'C:\Documents and Settings\dkhullar\Desktop\Desktop\Test_WEBTREV\DCM_spool';

path2scan = fullfile(dcmSpool,dirtoScan);

allFiles = dir(path2scan);

nrtplans=0;             % initialize number of different RTPLANS
nrtdoses=0;             % initialize number of different RTDOSES series
nrtcts=0;               % initialize number of different CT series
nrtstructs=0;           % initialize number of different RTSTRUCTURES
matchname = 1;

h = waitbar(0,'Scanning progress');
set(h,'Name',path2scan);

allLen = length(allFiles);

for i = 1:allLen

    if ~allFiles(i).isdir
        try
            temp=dicominfo(fullfile(path2scan,allFiles(i).name));

            if strcmpi(temp.Format,'DICOM')
                if strcmpi(temp.Modality,'RTPLAN')==1
                    nrtplans=nrtplans+1;
                    studylist{matchname,2}{nrtplans,1}=temp;

                elseif strcmpi(temp.Modality,'RTDOSE')==1

                    %                     [pathstr, name, ext] = fileparts(temp.Filename);

                    %                     if strcmpi([name '.' ext],dosefile)
                    nrtdoses=nrtdoses+1;

                    studylist{matchname,3}{nrtdoses,1}=temp;
                    %                     end

                elseif strcmpi(temp.Modality,'CT')==1
                    nrtcts=nrtcts+1;
                    studylist{matchname,4}{nrtcts,1}=temp;

                elseif strcmpi(temp.Modality,'RTSTRUCT')==1
                    nrtstructs=nrtstructs+1;
                    studylist{matchname,5}{nrtstructs,1}=temp;
                end
            end

        catch
            warning([allFiles(i).name ': is not a DICOM file']);
            continue;
        end
    end
    waitbar(i/allLen,h);
end

close(h);

studylist{matchname,1} = [temp.PatientName.FamilyName ' ' temp.PatientName.GivenName];

planC = initializeCERR;

indexS = planC{end};

[planC, PatientPositionCODE_CT, study,xmesh,ymesh,zmesh,tags] = webtrev_loadct(studylist{matchname,4},planC);

scanUID = planC{indexS.scan}(1).scanUID;

planC = webtrev_loadStructure(studylist{matchname,5}, planC, scanUID, study,xmesh,ymesh,zmesh,tags);

% Load options
optS=opts4Exe('CERROptions.m');

planC{indexS.CERROptions} = optS;

planC=dicomrt_d2c_setVoxelThicknesses(planC,indexS);

planC =  getRasterSegs(planC, optS);

% Get any dose surface points
planC =  getDSHPoints(planC,optS);

[planC PatientPositionCODE_Plan] = webtrev_loadRTPlan(studylist{matchname,2},planC);

if exist('PatientPositionCODE_Plan')
    PatientPositionCODE = PatientPositionCODE_Plan;
else
    PatientPositionCODE = PatientPositionCODE_CT;
end

planC = webtrev_loadDose(studylist{matchname,3},planC,PatientPositionCODE,scanUID);

clear study xmesh ymesh zmesh tags studylist

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(planC{indexS.structures})== 0
    flagVOI = 1;
else
    flagVOI = 0;
end

planC = dicomrt_d2c_uniformizescan(planC,planC{indexS.CERROptions},flagVOI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathToSave = 'C:\Documents and Settings\dkhullar\Desktop\Desktop\Test_WEBTREV\CERR_Plans';

planC_save_name = fullfile(pathToSave,dirtoScan);

save_planC(planC,[], 'passed', planC_save_name);

pause(3);

clear planC PatientPositionCODE_Plan optS scanUID
