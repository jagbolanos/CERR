function initFlag = init_ML_DICOM
%"init_ML_DICOM"
%   Sets env variables necessary for operation of ML_DICOM.
%
%DK 09/20/06
%
%Usage:
%   init_ML_DICOM
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

initFlag = 1;

javaVersion = version('-java');
if isempty(num2str(javaVersion(8))) || num2str(javaVersion(8)) < 5
    warndlg('The current MATLAB Java VM is not compatible. Please see Export documentation on how to update Java VM to Java 1.5.0_06');
    initFlag = 0;
end

MATLABVer = version;

if str2num(MATLABVer(1,1:3))< 7.2 == 0
    path1 = which('dcm4che-core-2.0.5.jar');
    path2 = which('nlog4j-1.2.19.jar');
else
    oldpath = pwd;
    ML_dcm = what(fullfile('dcm4che-2.0.5','lib'));
    path1 = fullfile(ML_dcm.path,'dcm4che-core-2.0.5.jar');
    path2 = fullfile(ML_dcm.path,'nlog4j-1.2.19.jar');
    cd(oldpath);
end

if isempty(path1)| isempty(path2)
    warndlg('File "dcm4che-core-2.0.5.jar" is not added to MATLAB path. Add the folder "dcm4che-2.0.5" to MATLAB path and start again');
    initFlag = 0;
    return;
else
    javaaddpath(path1);
    javaaddpath(path2);
end