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

    textValue = upper(string(rawText));
    textValue = strtrim(textValue);

    % Remove all non-alphanumeric characters.
    textValue = regexprep(textValue, '[^A-Z0-9]', '');

    % Remove leading digits (plate should start with alphabetic prefix).
    textValue = regexprep(textValue, '^\d+', '');

    if strlength(textValue) == 0
        return;
    end

    token = regexp(char(textValue), '^([A-Z]+)([A-Z0-9]*)$', 'tokens', 'once');
    if isempty(token)
        cleanedText = textValue;
        return;
    end

    prefixPart = string(token{1});
    suffixPart = string(token{2});

    if strlength(suffixPart) > 0
        suffixPart = regexprep(suffixPart, 'O', '0');
        suffixPart = regexprep(suffixPart, '[IL]', '1');
        suffixPart = regexprep(suffixPart, 'S', '5');
        suffixPart = regexprep(suffixPart, 'B', '8');
    end

    textValue = prefixPart + suffixPart;

    if strlength(textValue) > 0
        cleanedText = textValue;
    end
end
