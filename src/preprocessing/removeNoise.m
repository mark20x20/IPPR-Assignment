function filteredImg = removeNoise(grayImg)
%REMOVENOISE Reduce small noise using median filtering.

filteredImg = [];

% Return empty output for empty input.
if isempty(grayImg)
    return;
end

% Small images are not filtered to preserve character details.
if min(size(grayImg, 1), size(grayImg, 2)) < 300
    filteredImg = grayImg;
else
    % Larger images use median filtering to reduce small noise.
    filteredImg = medfilt2(grayImg, [3 3]);
end
end
