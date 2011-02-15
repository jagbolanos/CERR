function showAboutCERR
%The definitive copyright is contained here:
%This also contains the definitive version and last modified info.
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


[ver, date ] = CERRCurrentVersion;


hC = {'This is CERR (pronounced ''sir''): a Computational Environment for Radiotherapy Research.',...
         '',...
         ['This is version ' ver ', last modified on ' date '.'],...
         '',...
         'This software is copyright Washington University in St Louis.',...
          '',...
          'Developed by J.O.Deasy, with contributions from Konstantin Zakarian, Vanessa H. Clark, Angel Blanco, James Alaly, Andrew Hope and others.',...
          '',...
          'A free license is granted to use or modify, but only for non-commercial non-clinical uses.',...
          '',...
          'In particular, clinical decisions should not be made based on the use of CERR.', ...
          '',...
          'Use of CERR to design or test commercial products is not granted without an agreement with Washington University.',...
          '',...
          'Any user-modified software must retain the original copyright, and notice of changes, if redistributed.',...
          '',...
          'Any user-contributed software (not modifications of existing files) will retain the copyright terms of the contributor.',...
          '',...
           'No warranty or fitness is expressed or implied for any purpose whatsoever.  Use at your own risk.',...
          '',...
          'See user instructions in the ''cerr_user_information.html'' file in the documentation subdirectory.',...
          '',...
          'Please report any bugs, suggestions for improvements, or actual code improvements you would like to have included in CERR (with attribution) to Joe Deasy at jdeasy@radonc.wustl.edu OR Divya Khullar at dkhullar@radonc.wustl.edu OR to Aditya Apte at aapte@radonc.wustl.edu',...
          '',...
          'The latest version can be obtained from http://radium.wustl.edu/cerr.',...
          '',...
          'Thank you for using CERR.',...
          '',...
          '',...
          'DICOM-RT toolbox, authored by Emiliano Spezi, is GNU copyrighted.  Emiliano can be reached at emiliano.spezi@physics.org'};
h = helpdlg(hC,'About CERR');

try
    global stateS
    stateS.handle.aboutCERRFig = h;
end