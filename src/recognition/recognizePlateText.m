function rawText = recognizePlateText(plateImg)
rawText = "UNKNOWN";
if isempty(plateImg)
    return;
end

try
    ocrResult = ocr(plateImg);
    candidate = string(ocrResult.Text);
    if strlength(strtrim(candidate)) > 0
        rawText = candidate;
    end
catch
    rawText = "UNKNOWN";
end
end
