% trackPlans.m is a script that tracks the incomming DICOM data
% sets, updates the DataBase with Plan information to be processed and
% Notify the Dosimetery of plans to be processed. Once the information is
% captured the data directory is spooled to inque directory.
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

dcmReceiver = 'C:\Documents and Settings\dkhullar\Desktop\Desktop\Test_WEBTREV\DCM_receiver';
dcmSpool = 'C:\Documents and Settings\dkhullar\Desktop\Desktop\Test_WEBTREV\DCM_spool\';
allDCM = 'C:\Documents and Settings\dkhullar\Desktop\Desktop\Test_WEBTREV\All Data\';
dcmBad = 'C:\Documents and Settings\dkhullar\Desktop\Desktop\Test_WEBTREV\DCM_Bad\';


% Set Data Base return prefrance
setdbprefs('DataReturnFormat','cellarray');

while true
    % Check for new data dump
    newReceived = dir(dcmReceiver);

    dirflg = [newReceived.isdir];

    dirNum = find(dirflg);

    if length(dirNum)>2
%         pause(60)
        for i=1:length(dirNum)
            if ~strcmp(newReceived(dirNum(i)).name,'.') & ~strcmp(newReceived(dirNum(i)).name,'..')
%                 try
                    webtrev_updateDB('tobeProcess', fullfile(dcmReceiver, newReceived(dirNum(i)).name),dcmSpool);
                    
%                 catch
%                     movefile(fullfile(dcmReceiver, newReceived(dirNum(i)).name),dcmBad)
%                 end
            end
        end
    end
end

