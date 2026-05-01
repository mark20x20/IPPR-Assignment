function filteredImg = removeNoise(grayImg)
filteredImg = [];
if isempty(grayImg)
    return;
end

try
    filteredImg = medfilt2(grayImg, [3 3]);
catch
    filteredImg = grayImg;
end
end
