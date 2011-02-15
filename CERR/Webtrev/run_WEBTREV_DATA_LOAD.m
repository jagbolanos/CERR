%% run_WEBTREV_DATA_LOAD
% Checks the Data Base for the process plan flag and processes the data by
% uploading DVH and Report Parameters and Images captures. Once the process
% is done MATLAB shoots an E-mail to the Dosimeterist
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

%% Check for flags to process
global stateS

driver = 'com.mysql.jdbc.Driver';

databaseurl = 'jdbc:mysql://localhost/webtrev_development';

conn = database('webtrev_development','root','',driver,databaseurl);

curs=exec(conn, 'select * from processplans');

curs = fetch(curs);

processplans = curs.Data;

inQueue = [processplans{:,11}];

curs=exec(conn, 'select * from alldoses');

curs = fetch(curs);

allDoses = curs.Data;

curs=exec(conn, 'select * from users');

curs = fetch(curs);

users = curs.Data;

nCnt = 0;

stateS.webtrev.isOn = 1;
%% Import DICOM Data to CERR
for i = 1:length(inQueue)
    nCnt = nCnt + 1;
    if inQueue(i)

        doseto_process = allDoses{processplans{nCnt,2},7};
%         try
            webtrev_dicomdirScan(processplans{nCnt,5},doseto_process);

            % Turn off inqueue flag
            colnames = {'inqueue'};

            exdata(1,1) = {0};

            update(conn, 'processplans', colnames, exdata, ...
                ['where id = ''' num2str(processplans{nCnt,1}) ''''])

            % Set processed flag
            colnames = {'processed'};

            exdata(1,1) = {1};

            update(conn, 'processplans', colnames, exdata, ...
                ['where id = ''' num2str(processplans{nCnt,1}) ''''])

%         catch
%             %%%% Update DB that there was and error
% 
%             continue;
%         end
    end
end

close(conn);

clear databaseurl conn curs
%% Launch CERR and Load Data

if ispc
cerrPlan_Path = 'C:\Test_WEBTREV\CERR_Plans';
elseif ismac
    cerrPlan_Path = '/Users/dkhullar/Documents/Test_WEBTREV/CERR_Plans';
elseif isunix
    cerrPlan_Path = '';
end

id_all = [users{:,1}];

nCnt = 0;

for i = 1:length(inQueue)
    nCnt = nCnt + 1;
    if inQueue(i)
        
        plannerID = find(id_all == processplans{nCnt,2});
        
        [fractionID Rx doseUnit]= webtrev_getFractionID(processplans{nCnt,4},allDoses);
        
        webtrev_update_planC_to_DB(cerrPlan_Path, processplans{nCnt,5}, processplans{nCnt,3},...
            processplans{nCnt,2}, users{plannerID,2},processplans{nCnt,1},fractionID,Rx,doseUnit);
    end
end

stateS.webtrev.isOn = 0;

% close(conn);
% 
% clear databaseurl conn curs allDoses
