function binaryPlateImg = binarizePlate(plateImg)
%BINARIZEPLATE Convert cropped plate image into binary image.
%
% Processing steps:
%   1. Convert to grayscale
%   2. Enhance contrast using adaptive histogram equalization
%   3. Reduce noise using median filtering
%   4. Try both bright and dark foreground adaptive thresholding
%   5. Select the binary result with a reasonable foreground ratio

binaryPlateImg = [];

if isempty(plateImg)
    return;
end

try
    if ndims(plateImg) == 3
        grayImg = rgb2gray(plateImg);
    else
        grayImg = plateImg;
    end

    grayImg = im2uint8(grayImg);
    grayImg = adapthisteq(grayImg);
    grayImg = medfilt2(grayImg, [3 3]);

    binaryBright = imbinarize(grayImg, "adaptive", ...
        "ForegroundPolarity", "bright", ...
        "Sensitivity", 0.45);

    binaryDark = imbinarize(grayImg, "adaptive", ...
        "ForegroundPolarity", "dark", ...
        "Sensitivity", 0.45);

    ratioBright = nnz(binaryBright) / numel(binaryBright);
    ratioDark = nnz(binaryDark) / numel(binaryDark);

    % Characters usually occupy a minority of the plate area.
    targetRatio = 0.25;

    if abs(ratioBright - targetRatio) <= abs(ratioDark - targetRatio)
        binaryPlateImg = binaryBright;
    else
        binaryPlateImg = binaryDark;
    end

    % If foreground is too large, invert the binary image.
    if nnz(binaryPlateImg) > numel(binaryPlateImg) * 0.60
        binaryPlateImg = ~binaryPlateImg;
    end

catch
    try
        if ndims(plateImg) == 3
            grayImg = rgb2gray(plateImg);
        else
            grayImg = plateImg;
        end

        level = graythresh(grayImg);
        binaryPlateImg = imbinarize(grayImg, level);

        if nnz(binaryPlateImg) > numel(binaryPlateImg) * 0.60
            binaryPlateImg = ~binaryPlateImg;
        end
    catch
        binaryPlateImg = [];
    end
end

end
