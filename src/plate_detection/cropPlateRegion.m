function plateImg = cropPlateRegion(originalImg, plateBBox)
plateImg = [];
if isempty(originalImg) || isempty(plateBBox) || numel(plateBBox) ~= 4
    return;
end

imgH = size(originalImg, 1);
imgW = size(originalImg, 2);
x = max(1, floor(plateBBox(1)));
y = max(1, floor(plateBBox(2)));
w = floor(plateBBox(3));
h = floor(plateBBox(4));

if w <= 0 || h <= 0 || x > imgW || y > imgH
    return;
end

w = min(w, imgW - x);
h = min(h, imgH - y);
if w <= 1 || h <= 1
    return;
end

try
    plateImg = imcrop(originalImg, [x, y, w, h]);
catch
    plateImg = [];
end
end
