function webtrev_update_planC_to_DB(planPath, whichplan, user_id, creator_id, plannerName,processplan_id,fractionID,Rx,doseUnit)
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

global stateS

stateS.CERRFile = fullfile(planPath, [whichplan '.mat']);

planC = webtrev_Open_PlanC(stateS.CERRFile);

indexS = planC{end};

x = clock;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Update MySQL DB plans table

driver = 'com.mysql.jdbc.Driver';

databaseurl = 'jdbc:mysql://localhost/webtrev_development';

conn = database('webtrev_development','root','',driver,databaseurl);

% user_id = user_id;

% creator_id = creator_id;

tx_plan_id = whichplan;

try
    first_name = planC{indexS.scan}(1).scanInfo(1).DICOMHeaders.PatientName.GivenName;
catch
    nameIndx = strfind(planC{indexS.scan}.scanInfo(1).patientName,'^');
    first_name = planC{indexS.scan}.scanInfo(1).patientName(1:nameIndx-1);
    last_name = planC{indexS.scan}.scanInfo(1).patientName(nameIndx+1:end);
end

try
    last_name = planC{indexS.scan}(1).scanInfo(1).DICOMHeaders.PatientName.FamilyName;
catch
    
end

created_at = [date ' ' num2str(x(4)) ':' num2str(x(5)) ':' num2str(x(6))];

planner = plannerName;

try
    tx_plan_system = planC{indexS.scan}(1).scanInfo(1).DICOMHeaders.Manufacturer;
catch
    tx_plan_system = 'RTOG';
end

plan_status = 'unapproved';

send_review = 1;

colnames = {'user_id','creator_id','tx_plan_id','fractionID','Rx','doseUnit','first_name','last_name',...
    'created_at','planner','tx_plan_system','plan_status','send_review'};

plan = {user_id,creator_id,tx_plan_id,fractionID,Rx,doseUnit,first_name,last_name,...
    created_at,planner,tx_plan_system,plan_status,send_review};

fastinsert(conn, 'plans', colnames, plan)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

curs=exec(conn, 'select * from plans');

curs = fetch(curs);

plans = curs.Data;

plan_id = plans{end,1};

close(conn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garbage Collection
clear user_id creator_id tx_plan_id first_name last_name colnames plan planPath whichplan

clear created_at approved_at planner tx_plan_system plan_status send_review x plans curs

clear conn databaseurl driver indexS plannerName

%% Upload Review
webtrev_DB_review(planC, plan_id,Rx);

%% Calculate Report
webtrev_calc_DB_Report(planC, plan_id,processplan_id,Rx);