function steVal = computeSteradian(probeRadius,probeDistToRadSource,varargin)
% function steVal = computeSteradian(probeRadius,probeDistToRadSource,varargin)
%-----------------------------------------------------------------------------------------
% COMPUTESTERADIAN - Computes the steradian value of the probe surface based on the probe
% radius and the distance of the probe from the radiation source. 
%
% INPUTS:
%   probeRadius          - radius of the radiation detector probe in a suitable unit.
%   probeDistToRadSource - probe distance in the same unit as that of probeRadius.
% OUTPUTS:
%   steVal - steradian value computed.
% EXAMPLE: 
%   0.0013 = computeSteradian(0.002,10) % Here, the inputs were given in mm.
%
% This function is called by:
% This function calls:
% MAT-files required:
%
% See also: 

% Author: Mani Subramaniyan
% Date created: 2009-08-05
% Last revision: 2009-08-05
% Created in Matlab version: 7.5.0.342 (R2007b)
%-----------------------------------------------------------------------------------------
% Algorithm: The algorithm is based on published formula ( see the document
% Photometry_Steradian_Calculation.pdf )

lightConeHalfAngle = atan(probeRadius/probeDistToRadSource);
steVal = 2 * pi * (1 - cos(lightConeHalfAngle));

