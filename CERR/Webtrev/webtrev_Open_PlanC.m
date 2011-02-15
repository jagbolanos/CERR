function planC = webtrev_Open_PlanC(file)
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

[pathstr, name, ext, versn] = fileparts(file);

%untar if it is a .tar file
tarFile = 0;
if strcmpi(ext, '.tar')
    untar(file,pathstr)
    fileToUnzip = fullfile(pathstr, name);
    file = fileToUnzip;
    [pathstr, name, ext, versn] = fileparts(fullfile(pathstr, name));
    tarFile = 1;
end

if strcmpi(ext, '.bz2')
    zipFile = 1;
    CERRStatusString(['Decompressing ' name ext '...']);
    outstr = gnuCERRCompression(file, 'uncompress');
    loadfile = fullfile(pathstr, name);

    [pathstr, name, ext, versn] = fileparts(fullfile(pathstr, name));

else
    zipFile = 0;
    loadfile = file;
end

CERRStatusString(['Loading ' name ext '...']);

planC = load(loadfile,'planC');

if zipFile
    delete(loadfile);
end
if tarFile
    delete(fileToUnzip);
end

planC = planC.planC; %Conversion from struct created by load

stateS.CERRFile = file;

stateS.workspacePlan = 0;
