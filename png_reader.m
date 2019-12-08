function LF = png_reader(folder)
    png_files = dir(fullfile(folder, '*.png'));
    sample_image = imread(fullfile(folder, png_files(1).name));
    [h, w, ~] = size(sample_image);
    LF = zeros(15, 15, h, w, 3);
    for i=1:15
        for j=1:15
            LF(i, j, :, :, :) =  imread(fullfile(folder, string(i) + '_' + string(j) + '.png'));
        end
    end
end

