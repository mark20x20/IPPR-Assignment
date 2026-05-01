function cleanedText = cleanRecognizedText(rawText)
cleanedText = "UNKNOWN";
if isempty(rawText)
    return;
end

textValue = upper(string(rawText));
textValue = regexprep(textValue, "\s+", "");
textValue = regexprep(textValue, "[^A-Z0-9]", "");

if strlength(textValue) > 0
    cleanedText = textValue;
end
end
