int CURRENT_DEBUG_LEVEL = -1; // Higher the level, the more detailed the debug is
// 0 - None
// 1 - Low
// 2 - Medium
// 3 - High

void log(int debugLevel = 0, string debug = ""){
    if (CURRENT_DEBUG_LEVEL >= debugLevel){
        trChatSend(1, "DEBUG: " + debug);
    }
}

void errorLog(string error = ""){
    trChatSend(1, "ERROR: " + error);
}