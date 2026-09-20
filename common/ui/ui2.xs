// Custom UI building

rmTriggerAddScriptLine("const string UI_SYSTEM_UNIT = \"Crate\";");
rmTriggerAddScriptLine("const string UI_SYSTEM_UNIT2 = \"CrateSmall\";");
rmTriggerAddScriptLine("const float UI_SYSTEM_SMALL_SCALE_MULTIPLIER = 1.355;");
rmTriggerAddScriptLine("const float UI_SYSTEM_LOOK_DISTANCE = 57.0;");
rmTriggerAddScriptLine("const float UI_SYSTEM_OFFSCREEN_Z = 1000.0;");
rmTriggerAddScriptLine("string(int, ref Parameters) EMPTY_DYNAMIC_UI_CONTENT = [](int pToUse = 1, ref Parameters parametersToUse) -> string { return \"\"; };");

rmTriggerAddScriptLine("class UiEntryParameterised {");
    rmTriggerAddScriptLine("Parameters parameters;");
    rmTriggerAddScriptLine("void(int, ref Parameters) handler = [](int p = 1, ref Parameters parametersToUse) -> void {};");
rmTriggerAddScriptLine("};");

rmTriggerAddScriptLine("class UiEntryStringParameterised {");
    rmTriggerAddScriptLine("Parameters parameters;");
    rmTriggerAddScriptLine("string(int, ref Parameters) getContent = EMPTY_DYNAMIC_UI_CONTENT;");
rmTriggerAddScriptLine("};");

createTypedPlayerSizingArray("int", "uiEntryOnTopOfArray");
createTypedPlayerSizingArray("float", "uiEntryXArray");
createTypedPlayerSizingArray("float", "uiEntryYArray");
createTypedPlayerSizingArray("float", "uiEntryWidthArray");
createTypedPlayerSizingArray("float", "uiEntryHeightArray");
createTypedPlayerSizingArray("string", "uiEntryContentArray");
createTypedPlayerSizingArray("string", "uiEntryRolloverNameArray");
createTypedPlayerSizingArray("string", "uiEntryRolloverDescriptionArray");
createTypedPlayerSizingArray("int", "uiEntryUnitArray");
createTypedPlayerSizingArray("int", "uiEntryUnitDataIndexArray");
createTypedPlayerSizingArray("int", "uiEntryRolloverDataIndexArray");
createTypedPlayerSizingArray("int", "uiEntryClickableDataIndexArray");
createTypedPlayerSizingArray("UiEntryParameterised", "uiEntryClickableHandlerArray");
createTypedPlayerSizingArray("int", "uiEntryUnitDataIndexInClickableArray");
createTypedPlayerSizingArray("int", "uiEntryOuterIndexInClickableArray");
createTypedPlayerSizingArray("int", "uiEntryDynamicDataIndexArray");
createTypedPlayerSizingArray("UiEntryStringParameterised", "uiEntryDynamicGetContentWrapperArray");
createTypedPlayerSizingArray("int", "uiEntryLastTimeArray");
createTypedPlayerSizingArray("int", "uiEntryFrequencyArray");
createTypedPlayerSizingArray("int", "uiEntryOuterIndexInDynamicArray");