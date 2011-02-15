function review_id = webtrev_runDVHCapture(plan_id, review_id)
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

global planC

indexS = planC{end};

driver = 'com.mysql.jdbc.Driver';

databaseurl = 'jdbc:mysql://localhost/webtrev_development';

conn = database('webtrev_development','root','',driver,databaseurl);

%% Capture DVH and upload it to DB

colName_review = {'plan_id','position','view_type'};

colName_dvh = {'review_id','plan_id','istarget','structNum','structName','volume','mindose','meandose','maxdose','doseUnit'};

numStruct = length(planC{indexS.structures});

position = 0;

dvhNum = length(planC{indexS.DVH});

for i = 1:numStruct

    review_id = review_id + 1;

    position = position + 1;

    dvhNum = dvhNum + 1;

    planC{indexS.DVH}(dvhNum).structureName = planC{indexS.structures}(position).structureName;
    planC{indexS.DVH}(dvhNum).doseUnits = planC{indexS.dose}(1).doseUnits;
    planC{indexS.DVH}(dvhNum).fractionIDOfOrigin = planC{indexS.dose}(1).fractionGroupID;
    planC{indexS.DVH}(dvhNum).dateOfDVH = date;
    planC{indexS.DVH}(dvhNum).doseIndex = 1;
    planC{indexS.DVH}(dvhNum).dvhUID = createUID('dvh');
    planC{indexS.DVH}(dvhNum).assocStrUID = planC{indexS.structures}(position).strUID;
    planC{indexS.DVH}(dvhNum).assocDoseUID = planC{indexS.dose}(1).doseUID;
    planC{indexS.DVH}(dvhNum).DVHMatrix = [];

    surfV = zeros(1,dvhNum);

    volFlg = surfV;

    volFlg(end) = 1;

    doseStat = plotDVH(surfV, volFlg, surfV, surfV, 0, 1, 0, 'CUMU');

    if isempty(doseStat)
        review_id = review_id -1;
        continue
    end

    hPlot = findobj('tag', 'DVHPlot');

    largeFilename = [num2str(review_id) '.full.png'];

    thumbfilename = [num2str(review_id) '.thumb.png'];

    [large thumb] = LabBook('CAPTURE', hPlot);

    imwrite(large.cdata, largeFilename, 'png');

    % Downsample Thumb
    thumb.cdata = imresize(thumb.cdata,0.5,'nearest');

    imwrite(thumb.cdata, thumbfilename, 'png');

    review = {plan_id, position,'dvh'};

    fastinsert(conn, 'reviews', colName_review, review)

    targetFlg = istarget(planC{indexS.DVH}(position).structureName);

    doseUnits = planC{indexS.dose}(1).doseUnits;

    if strcmpi(doseUnits,'grays')
        doseUnits = 'Gy';
    elseif strcmpi(doseUnits,'cgy')
        doseUnits = 'cGy';
    elseif strcmpi(doseUnits,'cgys')
        doseUnits = 'cGy';
    elseif strcmpi(doseUnits,'gy')
        doseUnits = 'Gy';
    elseif strcmpi(doseUnits,'gys')
        doseUnits = 'Gy';
    elseif strcmpi(doseUnits,'grays')
        doseUnits = 'Gy';
    end

    dvh = {review_id, plan_id, targetFlg, i, planC{indexS.DVH}(position).structureName,roundoff(doseStat.volume,2),...
        roundoff(doseStat.min,2), roundoff(doseStat.mean,2), roundoff(doseStat.max,2),doseUnits};

    fastinsert(conn, 'dvhstats', colName_dvh, dvh)

    delete(hPlot);
end
close(conn);

function targetFlg = istarget(strName)

targetFlg = 0;

if any(findstr(upper(strName), 'GTV')) | any(findstr(upper(strName), 'PTV')) | any(findstr(upper(strName), 'CTV'))
    targetFlg = 1;
end
