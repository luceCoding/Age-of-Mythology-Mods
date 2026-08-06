int CURRENT_DEBUG_LEVEL = 0; // Higher the level, the more detailed the debug is
// 0 - None
// 1 - Low
// 2 - Medium
// 3 - High

void log(int debugLevel = 0, string debug = ""){
    if (debugLevel >= CURRENT_DEBUG_LEVEL){
        trChatSendSpoofed(0, "DEBUG " + debugLevel + ": " + debug);
    }
}

void errorLog(string error = ""){
    trChatSendSpoofed(0, "ERROR: " + error);
}