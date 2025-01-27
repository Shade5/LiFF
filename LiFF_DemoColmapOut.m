% LiFF_DemoColmapOut - Demonstration of LiFF Light Field Features for use with COLMAP
% 
% The demo is similar to LiFF_DemoSimple but with functionality for saving in COLMAP-compatible
% format, and a few improvements to deliver better performance with COLMAP on typical Lytro
% Illum-captured imagery:
% 
% - Uses higher-performance grayscale conversion that applies histogram equalization and ignores
%   empty subaperture images
% - Sets feature detection thresholds and parameters for better SfM performance
% - Converts features to COLMAP format and saves to disk
% 
% Change the input file, output file, and feature detection parameters in the "Tweakables" section
% at the top of the script.
% 
% See also LiFF_DemoSimple.m, LiFF_DemoFocalStack.m

% Part of LiFF Light Field Feature Toolbox v0.0.1
% Copyright (c) 2019 Donald G. Dansereau

clearvars

%---Tweakables---
InFile = 'SampleScenes/IMG_2298__Decoded.mat';
OutFile = 'SampleScenes/2298.txt';

load(InFile)

PeakThresh = 0.0066;
EdgeThresh = 10;
FirstOctave = -1;
Octaves = 4;
LevelsPerOctave = 3;

%---Load with alpha, to ignore invalid pixels---
fprintf('Loading light field and converting to grayscale...\n');
LF = LF(:, :, :, :, 1:3);
LF = LF(2:end-2,2:end-2,:,:,:);  % trim edge pixels, force odd view count
LF = single(LF); % convert to float
LF = LF ./ max(LF(:));
LF3 = LF;
LF = LiFF_RGB2Gray(LF); % convert to grayscale

%---Find features and descriptors---
fprintf('Extracting features...\n');
tic
[f,d] = LiFF_ExtractFeatures( LF, ...
	'FirstOctave', FirstOctave, 'Octaves', Octaves, 'Levels', LevelsPerOctave, ...
	'PeakThresh', PeakThresh, 'EdgeThresh', EdgeThresh );
toc

%---Display---
fprintf('Displaying features...\n');
figure(1);
clf
Thumb = squeeze(LF3(ceil(end/2),ceil(end/2),:,:,:));
imshow(Thumb);

MinSlope = min(f(5,:));
SlopeRange = max(1, max(f(5,:)) - MinSlope);
for( i=1:size(f,2) )
	CurFeat = f(:, i);
	Color = (CurFeat(5)-MinSlope)/SlopeRange;
	RGBColor = [1-Color, 1-2*abs(Color-0.5), Color];
	circle( [CurFeat(1), CurFeat(2)], CurFeat(3), [],RGBColor, 'linewidth', 2 );
end
title(sprintf('LiFF -- %d features', size(f,2)))

%---Convert and save for ColMap---
fprintf('Saving features to %s...\n', OutFile);
[f,d] = LiFF_ConvertLiFFToColmap(f,d);
LiFF_WriteFeatsToColmapFiles( OutFile, f,d );
imwrite(Thumb, OutFile(1:end - 4) + ".png");

fprintf('Done.\n');