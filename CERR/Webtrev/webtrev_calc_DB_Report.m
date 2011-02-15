function webtrev_calc_DB_Report(planC, plan_id, processplan_id,Rx)
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

%% Connect to DB
driver = 'com.mysql.jdbc.Driver';

databaseurl = 'jdbc:mysql://localhost/webtrev_development';

conn = database('webtrev_development','root','',driver,databaseurl);

curs=exec(conn, ['select * from inplanparams WHERE processplan_id = ' num2str(processplan_id)]);

curs = fetch(curs);

inplanparams = curs.Data;

close(conn)

clear conn curs databaseurl driver

paramCnt = size(inplanparams,1);

for i = 1:paramCnt
    
    rowIn = {inplanparams{i,:}};
    
    webtrev_calcParam_updateDB(rowIn, planC, plan_id,Rx);   
end