% LiFF_DemoSimple - Simple demonstration of LiFF Light Field Features
% 
% The demo loads a light field, converts it to grayscale, locates features, and visualizes them
% using colour to indicate the slope at which each feature is identified. 
%
% Change the input file in the "Tweakables" section at the top of the script.
% 
% See also LiFF_DemoColmapOut.m, LiFF_DemoFocalStack.m

% Part of LiFF Light Field Feature Toolbox v0.0.1
% Copyright (c) 2019 Donald G. Dansereau


% %---Tweakables---
InFolder1 = 'SampleScenes/238';
InFolder2 = 'SampleScenes/239';

% %---Load---
% fprintf('Loading light fields and converting to grayscale...\n');
LF1 = png_reader(InFolder1);
LF1 = LF1(2:end-2,2:end-2,:,:,:); % remove pixels on lenslet borders, 2 on the bot/right, 1 on top/left
LF1 = single(LF1);        % convert to float
LF1 = LF1 ./ max(LF1(:));  % normalize
LF1 = LiFF_RGB2Gray(LF1); % convert toLF grayscale

LF2 = png_reader(InFolder2);
LF2 = LF2(2:end-2,2:end-2,:,:,:); % remove pixels on lenslet borders, 2 on the bot/right, 1 on top/left
LF2 = single(LF2);        % convert to float
LF2 = LF2 ./ max(LF2(:));  % normalize
LF2 = LiFF_RGB2Gray(LF2); % convert to grayscale

I1 = squeeze(LF1(ceil(end/2),ceil(end/2),:,:));
I2 = squeeze(LF2(ceil(end/2),ceil(end/2),:,:));


%---Find features and descriptors---
fprintf('Extracting features...\n');
[f1,d1] = LiFF_ExtractFeatures( LF1 );
[f2,d2] = LiFF_ExtractFeatures( LF2 );

indexPairs = matchFeatures(d1',d2');

matchedPoints1 = f1(:, indexPairs(:,1));
matchedPoints2 = f2(:, indexPairs(:,2));

figure; showMatchedFeatures(I1,I2, matchedPoints1(1:2, :)', matchedPoints2(1:2, :)',  'montage');

[F,inliers] = estimateFundamentalMatrix(matchedPoints1(1:2, :)', matchedPoints2(1:2, :)','NumTrials',4000);

points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);
[features1,valid_points1] = extractFeatures(I1,points1);
[features2,valid_points2] = extractFeatures(I2,points2);
indexPairs = matchFeatures(features1,features2);
matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);
figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,  'montage');
