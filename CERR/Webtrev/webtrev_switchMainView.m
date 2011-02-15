function webtrev_switchMainView(type)
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

stateS.lastAxis = 1; 

if strcmpi(type,'sag')
    pos = 2;
    hAxis = stateS.handle.CERRAxis(2);
elseif strcmpi(type, 'cor')
    pos = 3;
    hAxis = stateS.handle.CERRAxis(3);    
elseif strcmpi(type,'tra')
    pos = 2;
    hAxis = stateS.handle.CERRAxis(2);
end

axisLabelTmp1 = stateS.handle.CERRAxisLabel1(pos);
axisLabelTmp2 = stateS.handle.CERRAxisLabel2(pos);

stateS.handle.CERRAxis(pos) = stateS.handle.CERRAxis(stateS.lastAxis);
stateS.handle.CERRAxisLabel1(pos) = stateS.handle.CERRAxisLabel1(stateS.lastAxis);
stateS.handle.CERRAxisLabel2(pos) = stateS.handle.CERRAxisLabel2(stateS.lastAxis);

stateS.handle.CERRAxis(stateS.lastAxis) = hAxis;
stateS.handle.CERRAxisLabel1(stateS.lastAxis) = axisLabelTmp1;
stateS.handle.CERRAxisLabel2(stateS.lastAxis) = axisLabelTmp2;

stateS.currentAxis = stateS.lastAxis;

set(stateS.handle.CERRAxisLabel1(stateS.lastAxis), 'color', 'white');
set(stateS.handle.CERRAxisLabel1(stateS.currentAxis), 'color', 'red');

set(stateS.handle.CERRAxisLabel2(stateS.lastAxis), 'color', 'white');
set(stateS.handle.CERRAxisLabel2(stateS.currentAxis), 'color', 'red');

sliceCallBack('resize');