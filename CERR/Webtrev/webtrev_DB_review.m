function webtrev_DB_review(varargin)
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

global stateS planC;

CERRFile = stateS.CERRFile;

planC = varargin{1};

plan_id = varargin{2};

Rx = varargin{3};

indexS = planC{end};

%% Launch CERR and load planC
% Initialize CERR GUI
sliceCallBack('init');

stateS.CERRFile = CERRFile;

stateS.webtrev.isOn = 1;

% load the file in CERR
sliceCallBack('load',planC);

oldDir = pwd;


%% Connect to DB
driver = 'com.mysql.jdbc.Driver';

databaseurl = 'jdbc:mysql://localhost/webtrev_development';

conn = database('webtrev_development','root','',driver,databaseurl);

reviewDir = ['C:\Aptana_workspace\webtrev\public\plans\' num2str(plan_id) '\photos'];

mkdir(reviewDir);

cd(reviewDir);

[numCor, numSag, numTra] = size(planC{indexS.scan}(1).scanArray);
%% Capture Transverse and upload it to DB

colName = {'plan_id','position','coord','view_type'};

position = 0; skipSlc = 3;

[xCoord, yCoord, zCoord, xStart, yStart, zStart, xEndSlc, yEndSlc, zEndSlc] = webtrev_movetofirstslice;

zStart_target = zStart;

sliceCallBack('focus',stateS.handle.CERRAxis(1));

while zStart <= zEndSlc

    colName = colName(1:4);

    strIndx = 4;
    for i = 1:length(stateS.webtrev.StrOnSlc.trans)
        strIndx = strIndx + 1;
        colName{strIndx} = ['str' num2str(stateS.webtrev.StrOnSlc.trans(i))];
        strIndx = strIndx + 1;
        colName{strIndx} = ['str' num2str(stateS.webtrev.StrOnSlc.trans(i)) 'clr'];
    end

    position = position + 1;

    if position == 1
        review = {plan_id, position, roundoff(stateS.transverse.ZCoord,2),'tra'};

        strIndx = 4;
        for i = 1:length(stateS.webtrev.StrOnSlc.trans)
            strIndx = strIndx + 1;
            review{strIndx} = 1;
            strIndx = strIndx + 1;
            strClr = num2str(planC{indexS.structures}(stateS.webtrev.StrOnSlc.trans(i)).structureColor);
            review{strIndx} = [num2str(strClr(1)) ',' num2str(strClr(2)) ',' num2str(strClr(3))];
        end

        fastinsert(conn, 'reviews', colName, review)

        curs=exec(conn, 'select * from reviews');

        curs = fetch(curs);

        reviews = curs.Data;

        review_id = reviews{end,1};
    else
        review_id = review_id + 1;

        review = {plan_id, position, roundoff(stateS.transverse.ZCoord,2),'tra'};

        %         for i = 1:length(stateS.webtrev.StrOnSlc.trans)
        %             review{4+i} = 1;
        %         end

        strIndx = 4;
        for i = 1:length(stateS.webtrev.StrOnSlc.trans)
            strIndx = strIndx + 1;
            review{strIndx} = 1;
            strIndx = strIndx + 1;
            strClr = planC{indexS.structures}(stateS.webtrev.StrOnSlc.trans(i)).structureColor;
            review{strIndx} = [num2str(strClr(1)) ',' num2str(strClr(2)) ',' num2str(strClr(3))];
        end

        fastinsert(conn, 'reviews', colName, review)
    end

    largeFilename = [num2str(review_id) '.full'];

    thumbfilename = [num2str(review_id) '.thumb'];

    captureCERRViews(largeFilename,thumbfilename);

    for i = 1:skipSlc
        sliceCallBack('ChangeSlc','nextslice');
        zStart = zStart +1;
    end
end





goto('max',stateS.handle.CERRAxis(1));




%% Switch Main View to Sagittal
webtrev_switchMainView('sag');

webtrev_movetofirstslice(xCoord);

%% Capture Sagittal and upload it to DB
position = 0; skipSlc = 10;

sliceCallBack('focus',stateS.handle.CERRAxis(1));

while xStart <= xEndSlc
    %     colName = colName(1:4);
    %     for i = 1:length(stateS.webtrev.StrOnSlc.sag)
    %         colName{4+i} = ['str' num2str(stateS.webtrev.StrOnSlc.sag(i))];
    %     end

    strIndx = 4;
    for i = 1:length(stateS.webtrev.StrOnSlc.sag)
        strIndx = strIndx + 1;
        colName{strIndx} = ['str' num2str(stateS.webtrev.StrOnSlc.sag(i))];
        strIndx = strIndx + 1;
        colName{strIndx} = ['str' num2str(stateS.webtrev.StrOnSlc.sag(i)) 'clr'];
    end


    review_id = review_id + 1;

    position = position + 1;

    largeFilename = [num2str(review_id) '.full'];

    thumbfilename = [num2str(review_id) '.thumb'];

    captureCERRViews(largeFilename,thumbfilename);

    review = {plan_id, position, roundoff(stateS.sagittal.ZCoord,2),'sag'};

    % for i = 1:length(stateS.webtrev.StrOnSlc.sag)
    %     review{4+i} = 1;
    % end

    strIndx = 4;
    for i = 1:length(stateS.webtrev.StrOnSlc.sag)
        strIndx = strIndx + 1;
        review{strIndx} = 1;
        strIndx = strIndx + 1;
        strClr = planC{indexS.structures}(stateS.webtrev.StrOnSlc.sag(i)).structureColor;
        review{strIndx} = [num2str(strClr(1)) ',' num2str(strClr(2)) ',' num2str(strClr(3))];
    end

    fastinsert(conn, 'reviews', colName, review)

    for i = 1:skipSlc
        sliceCallBack('ChangeSlc','nextslice');
        xStart = xStart +1;
    end
end


goto('max',stateS.handle.CERRAxis(1));


%% Switch to Coronal in main view;
webtrev_switchMainView('cor');

webtrev_movetofirstslice(yCoord);
%% Capture Coronal and upload it to DB
position = 0; skipSlc = 10;

sliceCallBack('focus',stateS.handle.CERRAxis(1));

while yStart > yEndSlc

    colName = colName(1:4);
    strIndx = 4;
    for i = 1:length(stateS.webtrev.StrOnSlc.cor)
        strIndx = strIndx + 1;
        colName{strIndx} = ['str' num2str(stateS.webtrev.StrOnSlc.cor(i))];
        strIndx = strIndx + 1;
        colName{strIndx} = ['str' num2str(stateS.webtrev.StrOnSlc.cor(i)) 'clr'];
    end

    review_id = review_id + 1;

    position = position + 1;

    largeFilename = [num2str(review_id) '.full'];

    thumbfilename = [num2str(review_id) '.thumb'];

    captureCERRViews(largeFilename,thumbfilename);

    review = {plan_id, position, roundoff(stateS.coronal.ZCoord,2),'cor'};

    % for i = 1:length(stateS.webtrev.StrOnSlc.cor)
    %   review{4+i} = 1;
    % end

    strIndx = 4;
    for i = 1:length(stateS.webtrev.StrOnSlc.cor)
        strIndx = strIndx + 1;
        review{strIndx} = 1;
        strIndx = strIndx + 1;
        strClr = planC{indexS.structures}(stateS.webtrev.StrOnSlc.cor(i)).structureColor;
        review{strIndx} = [num2str(strClr(1)) ',' num2str(strClr(2)) ',' num2str(strClr(3))];
    end

    fastinsert(conn, 'reviews', colName, review)

    for i = 1:skipSlc
        sliceCallBack('ChangeSlc','prevslice');
        yStart = yStart - 1;
    end
end


goto('max',stateS.handle.CERRAxis(1));

close(conn)
%% Run DVH Capture
review_id = webtrev_runDVHCapture(plan_id, review_id);

%% Run Target Capture
webtrev_runTargetCapture(plan_id, review_id,zCoord,zStart_target,zEndSlc,Rx);

%%
pause(4);

cd(oldDir);

delete(gcf), close all, clear all, clc;