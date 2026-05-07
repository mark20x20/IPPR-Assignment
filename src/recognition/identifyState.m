function stateName = identifyState(cleanedText)
% identifyState identifies the Malaysian state from a cleaned plate text.
%
% Input:
%   cleanedText - cleaned plate text string
%
% Output:
%   stateName - identified Malaysian state name, or "UNKNOWN"

    stateName = "UNKNOWN";

    if isempty(cleanedText)
        return;
    end

    textValue = upper(string(cleanedText));

    if strlength(textValue) < 1 || textValue == "UNKNOWN"
        return;
    end

    if strlength(textValue) >= 2
        twoPrefix = extractBetween(textValue, 1, 2);
        twoPrefix = string(twoPrefix);
        switch twoPrefix
            case "KV"
                stateName = "Selangor";
                return;
            case "TR"
                stateName = "Terengganu";
                return;
        end
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
        case "C"
            stateName = "Pahang";
        case "D"
            stateName = "Kelantan";
        case "F"
            stateName = "Putrajaya";
        case "G"
            stateName = "Pahang";
        case "H"
            stateName = "Kedah";
        case "L"
            stateName = "Labuan";
        case "Q"
            stateName = "Sarawak";
        case "R"
            stateName = "Perlis";
        case "S"
            stateName = "Selangor";
        case "V"
            stateName = "Selangor";
        case "X"
            stateName = "Sabah";
        case "Y"
            stateName = "Sabah";
        case "Z"
            stateName = "Kuala Lumpur";
        otherwise
            stateName = "UNKNOWN";
    end
end
