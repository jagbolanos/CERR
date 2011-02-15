function webtrev_runTargetCapture(plan_id, review_id,zCoord,zStart_target,zEndSlc,rxDose)
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

sliceCallBack('focus',stateS.handle.CERRAxis(3))
runCERRCommand('go to max');

sliceCallBack('focus',stateS.handle.CERRAxis(2))
runCERRCommand('go to max');

sliceCallBack('focus',stateS.handle.CERRAxis(1))
runCERRCommand('go to max');

skipSlc = 3;

allStruct = getAllTarget(plan_id);

webtrev_switchMainView('tra')

driver = 'com.mysql.jdbc.Driver';

databaseurl = 'jdbc:mysql://localhost/webtrev_development';

conn = database('webtrev_development','root','',driver,databaseurl);

colName = {'plan_id','position','coord','view_type'};

sliceCallBack('ViewNoStructures')

if stateS.doseToggle    
    sliceCallBack('doseToggle')    
end

for i = 1: length(allStruct)
    webtrev_movetofirstslice(zCoord);

    strNum = allStruct{i};
    
    colName{5} = ['str' num2str(strNum)];

    position = 0;
    
    zStart = zStart_target;

    while zStart <= zEndSlc

        position = position + 1;

        review_id = review_id + 1;

        review = {plan_id, position, roundoff(stateS.transverse.ZCoord,2),'target',1};

        fastinsert(conn, 'reviews', colName, review)

        largeFilename = [num2str(review_id) '.full'];

        thumbfilename = [num2str(review_id) '.thumb'];

        runCERRCommand(['mask ',num2str(strNum),' ',num2str(1),' ',num2str(rxDose)])
        
        captureCERRViews(largeFilename,thumbfilename);

        for i = 1:skipSlc
            sliceCallBack('ChangeSlc','nextslice');
            zStart = zStart +1;
        end
    end
end
close(conn)

function allStruct = getAllTarget(plan_id)

driver = 'com.mysql.jdbc.Driver';

databaseurl = 'jdbc:mysql://localhost/webtrev_development';

conn = database('webtrev_development','root','',driver,databaseurl);

condition = ['SELECT * FROM dvhstats WHERE plan_id = ' num2str(plan_id) ' AND istarget = 1'];

curs=exec(conn, condition);

curs = fetch(curs);

allTarget = curs.Data;

allStruct = allTarget(:,5);

close(conn)

clear allTarget curs condition

clc