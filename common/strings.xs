string replaceText(string text = "", string toReplace = "", string replacement = "") {
    int targetLen = xsStringLength(toReplace);
    if (targetLen == 0) { return text; }

    int indexFound = xsStringFindFirst(text, toReplace, 0, true);
    if (indexFound < 0) {
        return text;
    }

    string toReturn = "";
    if (indexFound > 0) {
        toReturn = xsStringSubstring(text, 0, indexFound - 1);
    }
    toReturn = toReturn + replacement;

    while (indexFound >= 0) {
        int nextStart = indexFound + targetLen;
        int newIndexFound = xsStringFindFirst(text, toReplace, nextStart, true);
        
        if (newIndexFound >= 0) {
            if (newIndexFound > nextStart) {
                toReturn = toReturn + xsStringSubstring(text, nextStart, newIndexFound - 1);
            }
            toReturn = toReturn + replacement;
            indexFound = newIndexFound;
        } else {
            int textLen = xsStringLength(text);
            if (nextStart < textLen) {
                toReturn = toReturn + xsStringSubstring(text, nextStart, textLen - 1);
            }
            indexFound = -1;
        }
    }
    return toReturn;
}

string toForwardSlash(string text = ""){
    return replaceText(text, xsStringSubstring("\ ", 0, 0), "/");
}