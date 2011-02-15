function [dose_fraction,prescription,doseUnit,planfilename,dosefilename] = getDosefraction(rtDose,rtPlan)
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

for i=1:length(rtDose)
    infoD = rtDose{i};

    dosefilename = infoD.Filename;

    if ispc
        dosefilename = strtok(fliplr(dosefilename) ,'\');
    elseif isunix
        dosefilename = strtok(fliplr(dosefilename),'/');
    end

    dosefilename = fliplr(dosefilename);

    doseUnit = infoD.DoseUnits;

    if ~isempty(rtPlan)
        for k = 1:length(rtPlan)
            infoP = rtPlan{k};

            if strcmpi(infoP.SOPClassUID,infoD.ReferencedRTPlanSequence.Item_1.ReferencedSOPClassUID)

                fileName = infoP.Filename;

                if ispc
                    tok = strtok(fliplr(fileName) ,'\');
                elseif isunix
                    tok = strtok(fliplr(fileName),'/');
                end

                dose_fraction = infoP.RTPlanLabel;

                planfilename = fliplr(tok);

                if isfield(infoP, 'PrescriptionDescription')
                    prescription = infoP.PrescriptionDescription;

                else
                    prescription = 0;
                end

                break
            end
        end
    else
        dose_fraction = dosefilename;
        planfilename = ' ';
        prescription = 0;
    end
end