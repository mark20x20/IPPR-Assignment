function stateName = identifyState(cleanedText)
stateName = "UNKNOWN";
if isempty(cleanedText)
    return;
end

textValue = upper(string(cleanedText));
if strlength(textValue) < 1 || textValue == "UNKNOWN"
    return;
end

prefix = extractBetween(textValue, 1, 1);
if isempty(prefix)
    return;
end
prefix = string(prefix);

switch prefix
    case "A"
        stateName = "Perak";
    case "B"
        stateName = "Selangor";
    case "J"
        stateName = "Johor";
    case "K"
        stateName = "Kedah";
    case "M"
        stateName = "Malacca";
    case "N"
        stateName = "Negeri Sembilan";
    case "P"
        stateName = "Penang";
    case "T"
        stateName = "Terengganu";
    case "W"
        stateName = "Kuala Lumpur";
    otherwise
        stateName = "UNKNOWN";
end
end
