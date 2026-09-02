string replaceText(string text = "", string toReplace = "", string replacement = ""){
    int indexFound = xsStringFindFirst(text, toReplace, 0, true);
    if(indexFound < 0){
        return text;
    }
    string toReturn = xsStringSubstring(text, 0, indexFound - 1) + replacement;
    while(indexFound >= 0){
        int newIndexFound = xsStringFindFirst(text, toReplace, indexFound + xsStringLength(toReplace), true);
        if(newIndexFound >= 0){
            toReturn = toReturn + xsStringSubstring(text, indexFound + xsStringLength(toReplace), newIndexFound - 1) + replacement;
            indexFound = newIndexFound;
        } else {
            toReturn = toReturn + xsStringSubstring(text, indexFound + xsStringLength(toReplace), xsStringLength(text) - 1);
            indexFound = -1;
        }
    }
    return toReturn;
}

string toForwardSlash(string text = ""){
    return replaceText(text, xsStringSubstring("\ ", 0, 0), "/");
}