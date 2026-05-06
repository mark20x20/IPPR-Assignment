function cleanedText = cleanRecognizedText(rawText)
% cleanRecognizedText cleans raw OCR output for state identification.
%
% Input:
%   rawText - raw string from OCR
%
% Output:
%   cleanedText - cleaned uppercase alphanumeric string starting with a letter

    cleanedText = "UNKNOWN";

    if isempty(rawText)
        return;
    end

    % Convert to uppercase string
    textValue = upper(string(rawText));

    % Remove all non-alphanumeric characters
    textValue = regexprep(textValue, '[^A-Z0-9]', '');

    % Remove leading digits (plate should start with a letter)
    textValue = regexprep(textValue, '^\d+', '');

    if strlength(textValue) > 0
        cleanedText = textValue;
    end

end