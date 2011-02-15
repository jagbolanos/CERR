function webtrev_calcParam_updateDB(rowIn, planC, plan_id,Rx)
%
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

if isempty(rowIn)
    return
end
indexS = planC{end};

structNum = getStructNum(rowIn{4},planC,indexS);

%% Calculates dose parameters

% [dosesV, volsV, isError] = getDVH(structNum(1), 1, planC);
% [doseBinsV, volsHistV] = doseHist(dosesV, volsV, planC{indexS.CERROptions}.DVHBinWidth);
% if isError
% 
% end


[planC, doseBinsV, volsHistV] = getDVHMatrix(planC, structNum(1), 1);

meanD = sum(doseBinsV(:).* volsHistV(:))/sum(volsHistV);

meanD = roundoff(meanD, 2);

totalVol = roundoff(sum(volsHistV),2);

ind = max(find([volsHistV~=0]));

maxD = roundoff(doseBinsV(ind),2);

ind = min(find([volsHistV~=0]));

minD = roundoff(doseBinsV(ind),2);

%% Calculate Metrics

driver = 'com.mysql.jdbc.Driver';

databaseurl = 'jdbc:mysql://localhost/webtrev_development';

conn = database('webtrev_development','root','',driver,databaseurl);

switch upper(rowIn{6})
    case 'DX'
        DBtable = 'dxmetrics';
        curs=exec(conn, ['select * from dxmetrics WHERE inplanparam_id = ' num2str(rowIn{1})]);
    case 'VX'
        DBtable = 'vxmetrics';
        curs=exec(conn, ['select * from vxmetrics WHERE inplanparam_id = ' num2str(rowIn{1})]);
    case 'MAXDOSE'
        DBtable = 'maxdosemetrics';
        curs=exec(conn, ['select * from maxdosemetrics WHERE inplanparam_id = ' num2str(rowIn{1})]);
    case 'MEANDOSE'
        DBtable = 'meandosemetrics';
        curs=exec(conn, ['select * from meandosemetrics WHERE inplanparam_id = ' num2str(rowIn{1})]);
    case 'MINDOSE'
        DBtable = 'mindosemetrics';
        curs=exec(conn, ['select * from mindosemetrics WHERE inplanparam_id = ' num2str(rowIn{1})]);
end

curs = fetch(curs);

metric = curs.Data;

close(conn)

clear conn curs databaseurl driver

switch upper(rowIn{6})
    case 'DX'
        outMetric = calc_Dx(doseBinsV, volsHistV, str2num(metric{6}));
        passValue = str2num(metric{6});
        margin = str2num(metric{8});
    case 'VX'
        outMetric = calc_Vx(doseBinsV, volsHistV, str2num(metric{6}));
        passValue = str2num(metric{7});
        margin = str2num(metric{8});
    case 'MAXDOSE'
        outMetric = maxD;
        passValue = str2num(metric{6});
        margin = str2num(metric{7});
    case 'MEANDOSE'
        outMetric = meanD;
        passValue = str2num(metric{6});
        margin = str2num(metric{7});
    case 'MINDOSE'
        outMetric = minD;
        passValue = str2num(metric{6});
        margin = str2num(metric{7});
end

%% Check if Passing Criterion matches

if passValue-margin < outMetric < passValue+margin
    result = 'Pass';
else
    result = 'Not Match';
end

%% Update Database with result

% Connect to DB
driver = 'com.mysql.jdbc.Driver';
databaseurl = 'jdbc:mysql://localhost/webtrev_development';
conn = database('webtrev_development','root','',driver,databaseurl);

% Update DB table
colName = {'output', 'result'};
dataFill = {num2str(outMetric), result};

querry = ['where inplanparam_id = ' num2str(rowIn{1})];
update(conn, DBtable, colName, dataFill, querry);

% Update DB for inplanparameters
colName = {'plan_id','volume','volunit','mindose','meandose','maxdose','doseunit'};
inplanparams = {plan_id, num2str(totalVol), 'cc', num2str(minD), num2str(meanD), num2str(maxD), planC{indexS.dose}(1).doseUnits};

querry = ['where id = ' num2str(rowIn{1})];
update(conn, 'inplanparams', colName, inplanparams, querry);
% update(conn, 'Birthdays', colnames, exdata,'where First_Name = ''Jean''')

% fastinsert(conn, 'inplanparams', colName, inplanparams);

close (conn)
clear all
