function rawText = recognizePlateText(plateImg)
% recognizePlateText performs OCR on a cropped plate image.
%
% Input:
%   plateImg - cropped license plate image (RGB or grayscale)
%
% Output:
%   rawText - raw OCR result string, or "UNKNOWN" if failed

    rawText = "UNKNOWN";

    if isempty(plateImg)
        return;
    end

    try
        % Convert to grayscale if needed
        if size(plateImg, 3) == 3
            grayImg = rgb2gray(plateImg);
        else
            grayImg = plateImg;
        end

        % Resize to improve OCR accuracy
        grayImg = imresize(grayImg, 3);

        % Try multiple preprocessing approaches and pick best result
        candidates = {};

        % Approach 1: contrast enhancement
        img1 = imadjust(grayImg);
        result1 = strtrim(string(ocr(img1).Text));
        if strlength(result1) > 0
            candidates{end+1} = result1;
        end

        % Approach 2: adaptive histogram equalization
        img2 = adapthisteq(grayImg);
        result2 = strtrim(string(ocr(img2).Text));
        if strlength(result2) > 0
            candidates{end+1} = result2;
        end

        % Approach 3: Gaussian blur then threshold
        img3 = imgaussfilt(grayImg, 1);
        img3 = imbinarize(img3);
        result3 = strtrim(string(ocr(img3).Text));
        if strlength(result3) > 0
            candidates{end+1} = result3;
        end

        % Pick the longest result (most characters recognized)
        if ~isempty(candidates)
            bestResult = candidates{1};
            for i = 2:length(candidates)
                if strlength(candidates{i}) > strlength(bestResult)
                    bestResult = candidates{i};
                end
            end
            rawText = bestResult;
        end

    catch
        rawText = "UNKNOWN";
    end

end