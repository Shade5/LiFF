load('SampleScenes/IMG_0242__Decoded.mat')
folder = 'SampleScenes/242';
for i=1:15
    for j=1:15
       imwrite(squeeze(LF(i, j, :, :, 1:3)), fullfile(folder, string(i) + '_' + string(j) + '.png'));
    end
end