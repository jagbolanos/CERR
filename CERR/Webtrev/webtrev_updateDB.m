function webtrev_updateDB(command,dirtoprocess,spoolDir)
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

if ispc
    archive = strtok(fliplr(dirtoprocess), '\');
elseif isunix
    archive = strtok(fliplr(dirtoprocess), '/');
end

archive = fliplr(archive);

switch upper(command)

    case 'TOBEPROCESS'

        allFiles = dir(dirtoprocess);

        numFiles = length(allFiles);

        h = waitbar(0, 'Processing DCM Data'); set(h,'name',archive);

        nDose = 0; nStruct = 0; nPlan = 0;

        rtDose = {}; rtPlan = {}; rtStruct = {};

        for i = 1:numFiles

            if ~allFiles(i).isdir

                try
                    info = dicominfo(fullfile(dirtoprocess,allFiles(i).name));


                    if strcmpi(info.Modality,'RTPLAN')
                        % add RTPlan file name and UID link to check which
                        % dose it corresponds to.
                        nPlan = nPlan + 1;
                        rtPlan{1,nPlan} = info;

                    elseif strcmpi(info.Modality,'RTSTRUCT')
                        nStruct = nStruct + 1;

                        patientname_first = info.PatientName.GivenName;

                        patientname_last = info.PatientName.FamilyName;

                        ROIContourSequence=fieldnames(info.ROIContourSequence);

                        for i=1:size(ROIContourSequence,1) % for i=1:(number of VOIs) ...
                            voilabel=getfield(info.StructureSetROISequence,char(ROIContourSequence(i)),'ROIName');
                            VOI{i,1}=voilabel; % get VOI's name
                        end

                        rtStruct{1,nStruct} = info;
                        rtStruct{2,nStruct} = VOI;
                    elseif strcmpi(info.Modality,'RTDOSE')
                        nDose = nDose + 1;
                        rtDose{1,nDose} = info;
                    end

                    waitbar(i/numFiles)

                catch
                    warning([fullfile(dirtoprocess,allFiles(i).name) ' : Is not a DICOM']);
                    continue;
                end

            end
        end

        close(h);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%% Add Process Plan Information %%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        driver = 'com.mysql.jdbc.Driver';

        databaseurl = 'jdbc:mysql://localhost/webtrev_development';

        conn = database('webtrev_development','root','',driver,databaseurl);

        colNames = {'archive','patientname_first','patientname_last','datecreated'};

        x = clock;

        datecreated = [date ' ' num2str(x(4)) ':' num2str(x(5)) ':' num2str(x(6))];

        processPlan = {archive, patientname_first, patientname_last, datecreated};

        fastinsert(conn, 'processplans', colNames, processPlan)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%% Add Dose Inofrmation %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        curs=exec(conn, 'select id from processplans');

        colNames = {'processplan_id','dose_fraction','prescription','doseUnit','planfilename','dosefilename'};

        [dose_fraction,prescription,doseUnit,planfilename,dosefilename] = webtrev_getDosefraction(rtDose,rtPlan);


        curs = fetch(curs);

        id = curs.Data;

        processplan_id = id{end};

        allDose = {processplan_id,dose_fraction,prescription,doseUnit,planfilename,dosefilename};

        fastinsert(conn, 'alldoses',colNames, allDose);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%% Add Struct Inofrmation %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        allVOI = rtStruct{2};

        for i = 1:length(allVOI)
            fastinsert(conn,'allstructs',{'processplan_id','structurename'},{processplan_id, allVOI{i}})
        end

        close(conn);

        movefile(dirtoprocess,spoolDir);

        pause(30);
    case ''

end