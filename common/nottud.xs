include "lib/rm_core.xs";

//Trigger code

string quote = "\\";

void() always = []() -> void {
    rmTriggerAddScriptLine("return true;");
};

void(int) alwaysIndexed = [](int p = 1) -> void {
    rmTriggerAddScriptLine("return true;");
};

void defineTrigger(string name = "", bool initiallyActive = true, bool looping = false, bool immediate = false, void() condition = always, void() effects = []() -> void {}){
    rmTriggerAddScriptLine("int "+name+"_lastTime = 0;");
    rmTriggerAddScriptLine("bool "+name+"_conditionToRun(int lastTime = 0) {");
        condition();
    rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("");
    rmTriggerAddScriptLine("rule _"+name);
    rmTriggerAddScriptLine("highFrequency");
    if(initiallyActive){
        rmTriggerAddScriptLine("active");
    }
    if(immediate){
        rmTriggerAddScriptLine("runImmediately");
    }
    rmTriggerAddScriptLine("{");
        rmTriggerAddScriptLine("if ("+name+"_conditionToRun("+name+"_lastTime)) {");
            effects();
            if(looping){
                rmTriggerAddScriptLine(""+name+"_lastTime = xsGetTimeMS();");
            } else {
                rmTriggerAddScriptLine("xsDisableSelf();");
            }
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("}");
}

void defineIndexedTrigger(string name = "", int p = 1, bool initiallyActive = true, bool looping = false, bool immediate = false, void(int) condition = alwaysIndexed, void(int) effects = [](int p = 1) -> void {}){
    string nameToUse = name + p;
    rmTriggerAddScriptLine("int "+nameToUse+"_lastTime = 0;");
    rmTriggerAddScriptLine("bool "+nameToUse+"_conditionToRun(int lastTime = 0) {");
        condition(p);
    rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("");
    rmTriggerAddScriptLine("rule _"+nameToUse);
    rmTriggerAddScriptLine("highFrequency");
    if(initiallyActive){
        rmTriggerAddScriptLine("active");
    }
    if(immediate){
        rmTriggerAddScriptLine("runImmediately");
    }
    rmTriggerAddScriptLine("{");
        rmTriggerAddScriptLine("if ("+nameToUse+"_conditionToRun("+nameToUse+"_lastTime)) {");
            effects(p);
            if(looping){
                rmTriggerAddScriptLine(""+nameToUse+"_lastTime = xsGetTimeMS();");
            } else {
                rmTriggerAddScriptLine("xsDisableSelf();");
            }
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("}");
}

string join(ref string[] stringArray, string joiner = "", string(string) transform = [](string value = "") -> string {return value;}){
    if(stringArray.size() <= 0){
        return "";
    }
    string wholeString = transform(stringArray[0]);
    for(int i = 1; i < stringArray.size(); i++){
        wholeString = wholeString + joiner + transform(stringArray[i]);
    }
    return wholeString;
}

string indexStringSequence(string prefix = "", string suffix = "", int count = 0){
    string wholeString = "";
    for(int i = 0; i < count; i++){
        wholeString = wholeString + prefix + i + suffix;
    }
    return wholeString;
}

string[] buildStringTypeArray(string type0 = "", string type1 = "", string type2 = "", string type3 = "", string type4 = "", string type5 = "", string type6 = "", string type7 = "",
        string type8 = "", string type9 = "", string type10 = "", string type11 = ""){
    string[] typeArray = new string(0, "");
    if(type0 != "")typeArray.add(type0);
    if(type1 != "")typeArray.add(type1);
    if(type2 != "")typeArray.add(type2);
    if(type3 != "")typeArray.add(type3);
    if(type4 != "")typeArray.add(type4);
    if(type5 != "")typeArray.add(type5);
    if(type6 != "")typeArray.add(type6);
    if(type7 != "")typeArray.add(type7);
    if(type8 != "")typeArray.add(type8);
    if(type9 != "")typeArray.add(type9);
    if(type10 != "")typeArray.add(type10);
    if(type11 != "")typeArray.add(type11);
    return typeArray;
}

string getTypeTitle(string type = ""){
    if(type == "bool") return "Bool";   
    if(type == "int") return "Int";   
    if(type == "float") return "Float";   
    if(type == "string") return "String";   
    if(type == "vector") return "Vector";   
    return type;
}

string getDefaultValue(string type = ""){
    if(type == "bool") return "false";   
    if(type == "int") return "0";   
    if(type == "float") return "0.0";   
    if(type == "string") return "\"\"";   
    if(type == "vector") return "cOriginVector";  
    return "";
}

string getParamQualifier(string type = ""){
    if(type == "bool") return type;   
    if(type == "int") return type;   
    if(type == "float") return type;   
    if(type == "string") return type;   
    if(type == "vector") return type;  
    return "ref " + type;
}

string getArrayDefaultValue(string type = ""){
    string defaultValue = getDefaultValue(type);
    if(defaultValue == ""){
        return "";
    }
    return ", " + defaultValue;
}

string getVariableDefaultValue(string type = ""){
    string defaultValue = getDefaultValue(type);
    if(defaultValue == ""){
        return "";
    }
    return " = " + defaultValue;
}

string getDefaultReturnStatement(string type = ""){
    string defaultValue = getDefaultValue(type);
    if(defaultValue == ""){
        return type + " _defaultClassInstance; return _defaultClassInstance;";
    }
    return "return " + defaultValue + ";";
}

string toLambdaTypeList(ref string[] types, bool afterMore = false){
    if(types.size() <= 0){
        return "";
    } 
    string wholeString = "";
    if(afterMore) wholeString = ", ";
    wholeString = wholeString + getParamQualifier(types[0]);
    for(int i = 1; i < types.size(); i++){
        wholeString = wholeString + ", " + getParamQualifier(types[i]);
    }
    return wholeString;
}

string toLambdaArgumentList(ref string[] types, bool afterMore = false){
    if(types.size() <= 0){
        return "";
    }
    string wholeString = "";
    if(afterMore) wholeString = ", ";
    wholeString = wholeString + getParamQualifier(types[0]) + " arg0" + getVariableDefaultValue(types[0]);
    for(int i = 1; i < types.size(); i++){
        wholeString = wholeString + ", " + getParamQualifier(types[i]) + " arg"+ i + getVariableDefaultValue(types[i]);
    }
    return wholeString;
}

void handleEveryBasicType(void(string) handler = [](string type = "") -> void {}){
    handler("bool");
    handler("int");
    handler("float");
    handler("string");
    handler("vector");
}

int forEachIndentation = 0;

void forEachStart(string dataType = "", string variable = "", string container = "", string indexVariable = ""){
    string indexVariableToUse = indexVariable == "" ? "_forEach"+forEachIndentation : indexVariable;
    rmTriggerAddScriptLine("for(int "+indexVariableToUse+" = 0; "+indexVariableToUse+" < "+container+".size(); "+indexVariableToUse+"++){");
    rmTriggerAddScriptLine(dataType+" "+variable+" = "+container+"["+indexVariableToUse+"];");
    forEachIndentation++;
}

void forEachEnd(){
    forEachIndentation--;
    rmTriggerAddScriptLine("}");
}

void defineDatabaseDefinition(string className = "", string[] typeArray = default){
    if(typeArray.size() > 0){
        rmTriggerAddScriptLine("class "+className+"Args {");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine(typeArray[i] + " arg" + i + getVariableDefaultValue(typeArray[i]) + ";");
            }
        rmTriggerAddScriptLine("};");
        rmTriggerAddScriptLine("");
    }
    
    rmTriggerAddScriptLine("class "+className+" {");
        rmTriggerAddScriptLine("bool initialised = false;");
        rmTriggerAddScriptLine("bool resizingProcess = false;");
        rmTriggerAddScriptLine("int count = 0;");
        rmTriggerAddScriptLine("int[] unitIdArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            rmTriggerAddScriptLine(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        if(typeArray.size() > 0){
            rmTriggerAddScriptLine(""+className+"Args args;");
        }
        rmTriggerAddScriptLine("void initialise(){");
            rmTriggerAddScriptLine("unitIdArray = new int(10, 0);");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            rmTriggerAddScriptLine("initialised = true;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        if(typeArray.size() > 0){
        rmTriggerAddScriptLine("void process(bool(int, ref "+className+"Args) handler = [](int unitId = 0, ref "+className+"Args argsDefault) -> bool {return false;}, ");
                rmTriggerAddScriptLine("void(int, ref "+className+"Args) handleDestroyed = [](int unitId = 0, ref "+className+"Args argsDefault) -> void {}){");
        } else {
        rmTriggerAddScriptLine("void process(bool(int) handler = [](int unitId = 0) -> bool {return false;}, ");
                rmTriggerAddScriptLine("void(int) handleDestroyed = [](int unitId = 0) -> void {}){");
        }
            rmTriggerAddScriptLine("if(!initialised){");
                rmTriggerAddScriptLine("initialise();");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("for(int index = count - 1; index >= 0; index--){");
                rmTriggerAddScriptLine("int unitId = unitIdArray[index];");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine("args.arg" + i + " = arg" + i + "Array[index];");
                }
                rmTriggerAddScriptLine("if(kbUnitGetProtoUnitID(unitId) < 0){");
                    rmTriggerAddScriptLine("count--;");
                    if(typeArray.size() > 0){
                        rmTriggerAddScriptLine("handleDestroyed(unitId, args);");
                    } else {
                        rmTriggerAddScriptLine("handleDestroyed(unitId);");
                    }
                    rmTriggerAddScriptLine("unitIdArray[index] = unitIdArray[count];");
                    for(int i = 0; i < typeArray.size(); i++){
                        rmTriggerAddScriptLine("arg" + i + "Array[index] = arg" + i + "Array[count];");
                    }
                    rmTriggerAddScriptLine("continue;");
                rmTriggerAddScriptLine("}");
                rmTriggerAddScriptLine("if(resizingProcess){");
                    rmTriggerAddScriptLine("continue;");
                rmTriggerAddScriptLine("}");
                rmTriggerAddScriptLine("trUnitSelectClear();");
                rmTriggerAddScriptLine("trUnitSelectByID(unitId);");
                if(typeArray.size() > 0){
                    rmTriggerAddScriptLine("if(handler(unitId, args)){");
                } else {
                    rmTriggerAddScriptLine("if(handler(unitId)){");
                }
                    rmTriggerAddScriptLine("count--;");
                    rmTriggerAddScriptLine("unitIdArray[index] = unitIdArray[count];");
                    for(int i = 0; i < typeArray.size(); i++){
                        rmTriggerAddScriptLine("arg" + i + "Array[index] = arg" + i + "Array[count];");
                    }
                rmTriggerAddScriptLine("} else {");
                    for(int i = 0; i < typeArray.size(); i++){
                        rmTriggerAddScriptLine("arg" + i + "Array[index] = args.arg" + i + ";");
                    }
                rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void add(int unitId = 0"+toLambdaArgumentList(typeArray, true)+"){");
            rmTriggerAddScriptLine("if(!initialised){");
                rmTriggerAddScriptLine("initialise();");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("if(count == unitIdArray.size()){");
                rmTriggerAddScriptLine("resizingProcess = true;");
                rmTriggerAddScriptLine("process();");
                rmTriggerAddScriptLine("resizingProcess = false;");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("if(count == unitIdArray.size()){");
                rmTriggerAddScriptLine("unitIdArray.resize(2 * unitIdArray.size(), 0);");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("unitIdArray[count] = unitId;");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[count] = arg" + i + ";");
            }
            rmTriggerAddScriptLine("count++;");
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("};");
}

string gTriggerName = "";

void createTypedScheduler(string name = "", string[] typeArray = default){
    
    string className = "Scheduler_" + name;
    
    rmTriggerAddScriptLine("class "+className+" {");
        rmTriggerAddScriptLine("bool initialised = false;");
        rmTriggerAddScriptLine("int count = 0;");
        rmTriggerAddScriptLine("int[] delayArray = default;");
        rmTriggerAddScriptLine("bool(int"+toLambdaTypeList(typeArray, true)+")[] toRunArray = default;");
        rmTriggerAddScriptLine("int[] lastTimeArray = default;");
        rmTriggerAddScriptLine("int[] iterationArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            rmTriggerAddScriptLine(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void initialise(){");
            rmTriggerAddScriptLine("initialised = true;");
            rmTriggerAddScriptLine("delayArray = new int(10, 0);");
            rmTriggerAddScriptLine("toRunArray = new bool(int"+toLambdaTypeList(typeArray, true)+")(10, [](int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;});");
            rmTriggerAddScriptLine("lastTimeArray = new int(10, 0);");
            rmTriggerAddScriptLine("iterationArray = new int(10, 0);");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void process(){");
            rmTriggerAddScriptLine("int time = xsGetTimeMS();");
            rmTriggerAddScriptLine("for(int index = count - 1; index >= 0; index--){");
                rmTriggerAddScriptLine("int delay = delayArray[index];");
                rmTriggerAddScriptLine("int lastTime = lastTimeArray[index];");
                rmTriggerAddScriptLine("if(time < lastTime + delay){");
                    rmTriggerAddScriptLine("continue;");
                rmTriggerAddScriptLine("}");
                rmTriggerAddScriptLine("lastTimeArray[index] = lastTime + delay;");
                rmTriggerAddScriptLine("int iteration = iterationArray[index];");
                rmTriggerAddScriptLine("iteration++;");
                rmTriggerAddScriptLine("iterationArray[index] = iteration;");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine(typeArray[i] + " arg" + i + " = arg" + i + "Array[index];");
                }
                rmTriggerAddScriptLine("bool(int"+toLambdaTypeList(typeArray, true)+") toRun = toRunArray[index];");
                rmTriggerAddScriptLine("if(toRun(iteration"+indexStringSequence(", arg", "", typeArray.size())+") == false){");
                    rmTriggerAddScriptLine("count--;");
                    rmTriggerAddScriptLine("delayArray[index] = delayArray[count];");
                    rmTriggerAddScriptLine("toRunArray[index] = toRunArray[count];");
                    rmTriggerAddScriptLine("lastTimeArray[index] = lastTimeArray[count];");
                    rmTriggerAddScriptLine("iterationArray[index] = iterationArray[count];");
                    for(int i = 0; i < typeArray.size(); i++){
                        rmTriggerAddScriptLine("arg" + i + "Array[index] = arg" + i + "Array[count];");
                    }
                rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void add(int delay = 0"+toLambdaArgumentList(typeArray, true)+", bool(int"+toLambdaTypeList(typeArray, true)+") toRun = [](int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;}){");
            rmTriggerAddScriptLine("if(!initialised){");
                rmTriggerAddScriptLine("initialise();");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("if(count == delayArray.size()){");
                rmTriggerAddScriptLine("delayArray.resize(2 * delayArray.size(), 0);");
                rmTriggerAddScriptLine("toRunArray.resize(2 * toRunArray.size(), [](int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;});");
                rmTriggerAddScriptLine("lastTimeArray.resize(2 * lastTimeArray.size(), 0);");
                rmTriggerAddScriptLine("iterationArray.resize(2 * iterationArray.size(), 0);");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("delayArray[count] = delay;");
            rmTriggerAddScriptLine("toRunArray[count] = toRun;");
            rmTriggerAddScriptLine("lastTimeArray[count] = xsGetTimeMS();");
            rmTriggerAddScriptLine("iterationArray[count] = 0;");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[count] = arg" + i + ";");
            }
            rmTriggerAddScriptLine("count++;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("void cancelAll(){");
            rmTriggerAddScriptLine("count = 0;");
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("};");
    
    rmTriggerAddScriptLine(className + " " + name + ";");
    
    gTriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        rmTriggerAddScriptLine(gTriggerName + ".process();");
    });
}

void createTypedUnitScheduler(string name = "", string[] typeArray = default){
    
    string className = "UnitScheduler_" + name;
    
    rmTriggerAddScriptLine("class "+className+" {");
        rmTriggerAddScriptLine("bool initialised = false;");
        rmTriggerAddScriptLine("int count = 0;");
        rmTriggerAddScriptLine("int[] unitArray = default;");
        rmTriggerAddScriptLine("int[] delayArray = default;");
        rmTriggerAddScriptLine("bool(int, int"+toLambdaTypeList(typeArray, true)+")[] toRunArray = default;");
        rmTriggerAddScriptLine("int[] lastTimeArray = default;");
        rmTriggerAddScriptLine("int[] iterationArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            rmTriggerAddScriptLine(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void initialise(){");
            rmTriggerAddScriptLine("initialised = true;");
            rmTriggerAddScriptLine("unitArray = new int(10, 0);");
            rmTriggerAddScriptLine("delayArray = new int(10, 0);");
            rmTriggerAddScriptLine("toRunArray = new bool(int, int"+toLambdaTypeList(typeArray, true)+")(10, [](int unitId = 0, int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;});");
            rmTriggerAddScriptLine("lastTimeArray = new int(10, 0);");
            rmTriggerAddScriptLine("iterationArray = new int(10, 0);");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void process(){");
            rmTriggerAddScriptLine("int time = xsGetTimeMS();");
            rmTriggerAddScriptLine("for(int index = count - 1; index >= 0; index--){");
                rmTriggerAddScriptLine("int delay = delayArray[index];");
                rmTriggerAddScriptLine("int lastTime = lastTimeArray[index];");
                rmTriggerAddScriptLine("if(time < lastTime + delay){");
                    rmTriggerAddScriptLine("continue;");
                rmTriggerAddScriptLine("}");
                rmTriggerAddScriptLine("lastTimeArray[index] = lastTime + delay;");
                rmTriggerAddScriptLine("int iteration = iterationArray[index];");
                rmTriggerAddScriptLine("iteration++;");
                rmTriggerAddScriptLine("iterationArray[index] = iteration;");
                rmTriggerAddScriptLine("int unitId = unitArray[index];");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine(typeArray[i] + " arg" + i + " = arg" + i + "Array[index];");
                }
                rmTriggerAddScriptLine("bool(int, int"+toLambdaTypeList(typeArray, true)+") toRun = toRunArray[index];");
                rmTriggerAddScriptLine("bool remove = kbUnitGetProtoUnitID(unitId) < 0;");
                rmTriggerAddScriptLine("if(remove == false){");
                    rmTriggerAddScriptLine("trUnitSelectClear();");
                    rmTriggerAddScriptLine("trUnitSelectByID(unitId);");
                    rmTriggerAddScriptLine("remove = toRun(unitId, iteration"+indexStringSequence(", arg", "", typeArray.size())+") == false;");
                rmTriggerAddScriptLine("}");
                rmTriggerAddScriptLine("if(remove){");
                    rmTriggerAddScriptLine("count--;");
                    rmTriggerAddScriptLine("unitArray[index] = unitArray[count];");
                    rmTriggerAddScriptLine("delayArray[index] = delayArray[count];");
                    rmTriggerAddScriptLine("toRunArray[index] = toRunArray[count];");
                    rmTriggerAddScriptLine("lastTimeArray[index] = lastTimeArray[count];");
                    rmTriggerAddScriptLine("iterationArray[index] = iterationArray[count];");
                    for(int i = 0; i < typeArray.size(); i++){
                        rmTriggerAddScriptLine("arg" + i + "Array[index] = arg" + i + "Array[count];");
                    }
                rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void add(int unitId = 0, int delay = 0"+toLambdaArgumentList(typeArray, true)+", bool(int, int"+toLambdaTypeList(typeArray, true)+") toRun = [](int unitId = 0, int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;}){");
            rmTriggerAddScriptLine("if(!initialised){");
                rmTriggerAddScriptLine("initialise();");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("if(count == delayArray.size()){");
                rmTriggerAddScriptLine("unitArray.resize(2 * unitArray.size(), 0);");
                rmTriggerAddScriptLine("delayArray.resize(2 * delayArray.size(), 0);");
                rmTriggerAddScriptLine("toRunArray.resize(2 * toRunArray.size(), [](int unitId = 0, int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;});");
                rmTriggerAddScriptLine("lastTimeArray.resize(2 * lastTimeArray.size(), 0);");
                rmTriggerAddScriptLine("iterationArray.resize(2 * iterationArray.size(), 0);");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("unitArray[count] = unitId;");
            rmTriggerAddScriptLine("delayArray[count] = delay;");
            rmTriggerAddScriptLine("toRunArray[count] = toRun;");
            rmTriggerAddScriptLine("lastTimeArray[count] = xsGetTimeMS();");
            rmTriggerAddScriptLine("iterationArray[count] = 0;");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[count] = arg" + i + ";");
            }
            rmTriggerAddScriptLine("count++;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("void cancelAll(){");
            rmTriggerAddScriptLine("count = 0;");
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("};");
    
    rmTriggerAddScriptLine(className + " " + name + ";");
    
    gTriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        rmTriggerAddScriptLine(gTriggerName + ".process();");
    });
}

string FLYING_PHYSICS = "trUnitReposition(pos.x, pos.y, pos.z, shouldStop == false, true);";
string SLIDING_PHYSICS = "trUnitReposition(pos.x, pos.y + getTerrainHeightAccurate(pos), pos.z, shouldStop == false, true);";

void createTypedPhysics(string name = "", string applyPosition = "", string[] typeArray = default){
    
    string className = "Physics_" + name;
    
    rmTriggerAddScriptLine("class "+className+" {");
        rmTriggerAddScriptLine("bool initialised = false;");
        rmTriggerAddScriptLine("int count = 0;");
        rmTriggerAddScriptLine("int lastTime = 0;");
        rmTriggerAddScriptLine("PhysicsState currentState;");
        rmTriggerAddScriptLine("int[] unitIdArray = default;");
        rmTriggerAddScriptLine("vector[] posArray = default;");
        rmTriggerAddScriptLine("vector[] velocityArray = default;");
        rmTriggerAddScriptLine("vector[] accelerationArray = default;");
        rmTriggerAddScriptLine("int[] timeArray = default;");
        rmTriggerAddScriptLine("bool(ref PhysicsState"+toLambdaTypeList(typeArray, true)+")[] stopArray = default;");
        rmTriggerAddScriptLine("void(int"+toLambdaTypeList(typeArray, true)+")[] handleStopArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            rmTriggerAddScriptLine(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void initialise(){");
            rmTriggerAddScriptLine("lastTime = xsGetTimeMS();");
            rmTriggerAddScriptLine("unitIdArray = new int(10, 0);");
            rmTriggerAddScriptLine("posArray = new vector(10, cOriginVector);");
            rmTriggerAddScriptLine("velocityArray = new vector(10, cOriginVector);");
            rmTriggerAddScriptLine("accelerationArray = new vector(10, cOriginVector);");
            rmTriggerAddScriptLine("timeArray = new int(10, 0);");
            rmTriggerAddScriptLine("stopArray = new bool(ref PhysicsState"+toLambdaTypeList(typeArray, true)+")(10, [](ref PhysicsState state"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
            rmTriggerAddScriptLine("handleStopArray = new void(int"+toLambdaTypeList(typeArray, true)+")(10, [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            rmTriggerAddScriptLine("initialised = true;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void removeAtIndex(int index = 0){");
            rmTriggerAddScriptLine("count--;");
            rmTriggerAddScriptLine("unitIdArray[index] = unitIdArray[count];");
            rmTriggerAddScriptLine("posArray[index] = posArray[count];");
            rmTriggerAddScriptLine("velocityArray[index] = velocityArray[count];");
            rmTriggerAddScriptLine("accelerationArray[index] = accelerationArray[count];");
            rmTriggerAddScriptLine("timeArray[index] = timeArray[count];");
            rmTriggerAddScriptLine("stopArray[index] = stopArray[count];");
            rmTriggerAddScriptLine("handleStopArray[index] = handleStopArray[count];");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[index] = arg" + i + "Array[count];");
            }
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void process(){");
            rmTriggerAddScriptLine("if(!initialised){");
                rmTriggerAddScriptLine("initialise();");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("int deltaMs = xsGetTimeMS() - lastTime;");
            rmTriggerAddScriptLine("lastTime = xsGetTimeMS();");
            rmTriggerAddScriptLine("float delta = 0.001 * deltaMs;");
            rmTriggerAddScriptLine("float halfDeltaSq = 0.5 * delta * delta;");
            rmTriggerAddScriptLine("for(int index = count - 1; index >= 0; index--){");
                rmTriggerAddScriptLine("int unitId = unitIdArray[index];");
                rmTriggerAddScriptLine("if(kbUnitGetProtoUnitID(unitId) < 0){");
                    rmTriggerAddScriptLine("removeAtIndex(index);");
                    rmTriggerAddScriptLine("continue;");
                rmTriggerAddScriptLine("}");
                rmTriggerAddScriptLine("vector pos = posArray[index];");
                rmTriggerAddScriptLine("vector velocity = velocityArray[index];");
                rmTriggerAddScriptLine("vector acceleration = accelerationArray[index];");
                rmTriggerAddScriptLine("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = handleStopArray[index];");
                rmTriggerAddScriptLine("currentState.pos = vector(");
                        rmTriggerAddScriptLine("pos.x + velocity.x * delta + acceleration.x * halfDeltaSq,");
                        rmTriggerAddScriptLine("pos.y + velocity.y * delta + acceleration.y * halfDeltaSq,");
                        rmTriggerAddScriptLine("pos.z + velocity.z * delta + acceleration.z * halfDeltaSq);");
                rmTriggerAddScriptLine("currentState.velocity = vector(");
                        rmTriggerAddScriptLine("velocity.x + acceleration.x * delta,");
                        rmTriggerAddScriptLine("velocity.y + acceleration.y * delta,");
                        rmTriggerAddScriptLine("velocity.z + acceleration.z * delta);");
                rmTriggerAddScriptLine("timeArray[index] = timeArray[index] + deltaMs;");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine(typeArray[i] + " arg" + i + " = arg" + i + "Array[index];");
                }
                rmTriggerAddScriptLine("trUnitSelectClear();");
                rmTriggerAddScriptLine("trUnitSelectByID(unitId);");
                rmTriggerAddScriptLine("bool(ref PhysicsState"+toLambdaTypeList(typeArray, true)+") stop = stopArray[index];");
                rmTriggerAddScriptLine("currentState.unitId = unitId;");
                rmTriggerAddScriptLine("currentState.acceleration = acceleration;");
                rmTriggerAddScriptLine("currentState.time = timeArray[index];");
                rmTriggerAddScriptLine("currentState.deltaTime = deltaMs;");
                rmTriggerAddScriptLine("bool shouldStop = stop(currentState"+indexStringSequence(", arg", "", typeArray.size())+");");
                rmTriggerAddScriptLine("posArray[index] = currentState.pos;");
                rmTriggerAddScriptLine("velocityArray[index] = currentState.velocity;");
                rmTriggerAddScriptLine("accelerationArray[index] = currentState.acceleration;");
                rmTriggerAddScriptLine("trUnitSelectClear();");
                rmTriggerAddScriptLine("trUnitSelectByID(unitId);");
                rmTriggerAddScriptLine(applyPosition);
                rmTriggerAddScriptLine("if(shouldStop){");
                    rmTriggerAddScriptLine("removeAtIndex(index);");
                    rmTriggerAddScriptLine("handleStop(unitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void add(int unitId = 0, vector pos = cOriginVector, vector velocity = cOriginVector, vector acceleration = cOriginVector ");
                rmTriggerAddScriptLine(toLambdaArgumentList(typeArray, true) + ",");
                rmTriggerAddScriptLine("bool(ref PhysicsState"+toLambdaTypeList(typeArray, true)+") stop = [](ref PhysicsState state"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;},");
                rmTriggerAddScriptLine("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{}){");
            rmTriggerAddScriptLine("if(!initialised){");
                rmTriggerAddScriptLine("initialise();");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("if(count == unitIdArray.size()){");
                rmTriggerAddScriptLine("for(int index = count - 1; index >= 0; index--){");
                    rmTriggerAddScriptLine("if(kbUnitGetProtoUnitID(unitId) < 0){");
                        rmTriggerAddScriptLine("removeAtIndex(unitIdArray[index]);");
                    rmTriggerAddScriptLine("}");
                rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("if(count == unitIdArray.size()){");
                rmTriggerAddScriptLine("unitIdArray.resize(2 * unitIdArray.size(), 0);");
                rmTriggerAddScriptLine("posArray.resize(2 * posArray.size(), cOriginVector);");
                rmTriggerAddScriptLine("velocityArray.resize(2 * velocityArray.size(), cOriginVector);");
                rmTriggerAddScriptLine("accelerationArray.resize(2 * accelerationArray.size(), cOriginVector);");
                rmTriggerAddScriptLine("timeArray.resize(2 * timeArray.size(), 0);");
                rmTriggerAddScriptLine("stopArray.resize(2 * stopArray.size(), [](ref PhysicsState state"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
                rmTriggerAddScriptLine("handleStopArray.resize(2 * handleStopArray.size(), [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("unitIdArray[count] = unitId;");
            rmTriggerAddScriptLine("posArray[count] = pos;");
            rmTriggerAddScriptLine("velocityArray[count] = velocity;");
            rmTriggerAddScriptLine("accelerationArray[count] = acceleration;");
            rmTriggerAddScriptLine("timeArray[count] = 0;");
            rmTriggerAddScriptLine("stopArray[count] = stop;");
            rmTriggerAddScriptLine("handleStopArray[count] = handleStop;");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[count] = arg" + i + ";");
            }
            rmTriggerAddScriptLine("count++;");
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("};");
    
    rmTriggerAddScriptLine(className + " " + name + ";");
    
    gTriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        rmTriggerAddScriptLine(gTriggerName + ".process();");
    });
}

void createTypedAttachBasic(string name = "", string[] typeArray = default){
    
    string className = "AttachBasic_" + name;
    
    rmTriggerAddScriptLine("class "+className+" {");
        rmTriggerAddScriptLine("bool initialised = false;");
        rmTriggerAddScriptLine("int count = 0;");
        rmTriggerAddScriptLine("int[] fromUnitIdArray = default;");
        rmTriggerAddScriptLine("int[] toUnitIdArray = default;");
        rmTriggerAddScriptLine("bool(int, int"+toLambdaTypeList(typeArray, true)+")[] stopArray = default;");
        rmTriggerAddScriptLine("void(int"+toLambdaTypeList(typeArray, true)+")[] handleStopArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            rmTriggerAddScriptLine(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void initialise(){");
            rmTriggerAddScriptLine("fromUnitIdArray = new int(10, 0);");
            rmTriggerAddScriptLine("toUnitIdArray = new int(10, 0);");
            rmTriggerAddScriptLine("stopArray = new bool(int, int"+toLambdaTypeList(typeArray, true)+")(10, [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
            rmTriggerAddScriptLine("handleStopArray = new void(int"+toLambdaTypeList(typeArray, true)+")(10, [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            rmTriggerAddScriptLine("initialised = true;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void removeAtIndex(int index = 0){");
            rmTriggerAddScriptLine("count--;");
            rmTriggerAddScriptLine("fromUnitIdArray[index] = fromUnitIdArray[count];");
            rmTriggerAddScriptLine("toUnitIdArray[index] = toUnitIdArray[count];");
            rmTriggerAddScriptLine("stopArray[index] = stopArray[count];");
            rmTriggerAddScriptLine("handleStopArray[index] = handleStopArray[count];");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[index] = arg" + i + "Array[count];");
            }
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void process(){");
            rmTriggerAddScriptLine("if(!initialised){");
                rmTriggerAddScriptLine("initialise();");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("for(int index = count - 1; index >= 0; index--){");
                rmTriggerAddScriptLine("int fromUnitId = fromUnitIdArray[index];");
                rmTriggerAddScriptLine("int toUnitId = toUnitIdArray[index];");
                rmTriggerAddScriptLine("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = handleStopArray[index];");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine(typeArray[i] + " arg" + i + " = arg" + i + "Array[index];");
                }
                rmTriggerAddScriptLine("if(kbUnitGetProtoUnitID(fromUnitId) < 0 || kbUnitGetProtoUnitID(toUnitId) < 0){");
                    rmTriggerAddScriptLine("if(kbUnitGetProtoUnitID(fromUnitId) >= 0){");
                        rmTriggerAddScriptLine("vector fromLoc = trUnitGetPosition(fromUnitId);");
                        rmTriggerAddScriptLine("trUnitSelectClear();");
                        rmTriggerAddScriptLine("trUnitSelectByID(fromUnitId);");
                        rmTriggerAddScriptLine("trUnitReposition(fromLoc.x, fromLoc.y, fromLoc.z, false, true);");
                        rmTriggerAddScriptLine("handleStop(fromUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                    rmTriggerAddScriptLine("}");
                    rmTriggerAddScriptLine("removeAtIndex(index);");
                    rmTriggerAddScriptLine("continue;");
                rmTriggerAddScriptLine("}");
                rmTriggerAddScriptLine("trUnitSelectClear();");
                rmTriggerAddScriptLine("trUnitSelectByID(toUnitId);");
                rmTriggerAddScriptLine("bool(int, int"+toLambdaTypeList(typeArray, true)+") stop = stopArray[index];");
                rmTriggerAddScriptLine("bool shouldStop = stop(fromUnitId, toUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                rmTriggerAddScriptLine("trUnitSelectClear();");
                rmTriggerAddScriptLine("trUnitSelectByID(fromUnitId);");
                rmTriggerAddScriptLine("trUnitRepositionToUnit(toUnitId, shouldStop == false, true);");
                rmTriggerAddScriptLine("trUnitSetHeading(trUnitGetHeading(toUnitId));");
                rmTriggerAddScriptLine("if(shouldStop){");
                    rmTriggerAddScriptLine("removeAtIndex(index);");
                    rmTriggerAddScriptLine("trUnitSelectClear();");
                    rmTriggerAddScriptLine("trUnitSelectByID(fromUnitId);");
                    rmTriggerAddScriptLine("handleStop(fromUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void add(int fromUnitId = 0, int toUnitId = 0");
                rmTriggerAddScriptLine(toLambdaArgumentList(typeArray, true) + ",");
                rmTriggerAddScriptLine("bool(int, int"+toLambdaTypeList(typeArray, true)+") stop = [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;}, ");
                rmTriggerAddScriptLine("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{}){");
            rmTriggerAddScriptLine("if(!initialised){");
                rmTriggerAddScriptLine("initialise();");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("if(count == fromUnitIdArray.size()){");
                rmTriggerAddScriptLine("fromUnitIdArray.resize(2 * fromUnitIdArray.size(), 0);");
                rmTriggerAddScriptLine("toUnitIdArray.resize(2 * toUnitIdArray.size(), 0);");
                rmTriggerAddScriptLine("stopArray.resize(2 * stopArray.size(), [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
                rmTriggerAddScriptLine("handleStopArray.resize(2 * handleStopArray.size(), [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("fromUnitIdArray[count] = fromUnitId;");
            rmTriggerAddScriptLine("toUnitIdArray[count] = toUnitId;");
            rmTriggerAddScriptLine("stopArray[count] = stop;");
            rmTriggerAddScriptLine("handleStopArray[count] = handleStop;");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[count] = arg" + i + ";");
            }
            rmTriggerAddScriptLine("count++;");
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("};");
    
    rmTriggerAddScriptLine(className + " " + name + ";");
    
    gTriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        rmTriggerAddScriptLine(gTriggerName + ".process();");
    });
}

void createTypedAttach(string name = "", string[] typeArray = default){
    
    string className = "Attach_" + name;
    
    rmTriggerAddScriptLine("class "+className+" {");
        rmTriggerAddScriptLine("bool initialised = false;");
        rmTriggerAddScriptLine("int count = 0;");
        rmTriggerAddScriptLine("int[] fromUnitIdArray = default;");
        rmTriggerAddScriptLine("int[] toUnitIdArray = default;");
        rmTriggerAddScriptLine("float[] heightOffsetArray = default;");
        rmTriggerAddScriptLine("float[] distanceArray = default;");
        rmTriggerAddScriptLine("float[] angleArray = default;");
        rmTriggerAddScriptLine("float[] angleOffsetArray = default;");
        rmTriggerAddScriptLine("float[] rotOffsetArray = default;");
        rmTriggerAddScriptLine("bool(int, int"+toLambdaTypeList(typeArray, true)+")[] stopArray = default;");
        rmTriggerAddScriptLine("void(int"+toLambdaTypeList(typeArray, true)+")[] handleStopArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            rmTriggerAddScriptLine(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void initialise(){");
            rmTriggerAddScriptLine("fromUnitIdArray = new int(10, 0);");
            rmTriggerAddScriptLine("toUnitIdArray = new int(10, 0);");
            rmTriggerAddScriptLine("heightOffsetArray = new float(10, 0.0);");
            rmTriggerAddScriptLine("distanceArray = new float(10, 0.0);");
            rmTriggerAddScriptLine("angleArray = new float(10, 0.0);");
            rmTriggerAddScriptLine("angleOffsetArray = new float(10, 0.0);");
            rmTriggerAddScriptLine("rotOffsetArray = new float(10, 0.0);");
            rmTriggerAddScriptLine("stopArray = new bool(int, int"+toLambdaTypeList(typeArray, true)+")(10, [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
            rmTriggerAddScriptLine("handleStopArray = new void(int"+toLambdaTypeList(typeArray, true)+")(10, [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            rmTriggerAddScriptLine("initialised = true;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void removeAtIndex(int index = 0){");
            rmTriggerAddScriptLine("count--;");
            rmTriggerAddScriptLine("fromUnitIdArray[index] = fromUnitIdArray[count];");
            rmTriggerAddScriptLine("toUnitIdArray[index] = toUnitIdArray[count];");
            rmTriggerAddScriptLine("heightOffsetArray[index] = heightOffsetArray[count];");
            rmTriggerAddScriptLine("distanceArray[index] = distanceArray[count];");
            rmTriggerAddScriptLine("angleArray[index] = angleArray[count];");
            rmTriggerAddScriptLine("angleOffsetArray[index] = angleOffsetArray[count];");
            rmTriggerAddScriptLine("rotOffsetArray[index] = rotOffsetArray[count];");
            rmTriggerAddScriptLine("stopArray[index] = stopArray[count];");
            rmTriggerAddScriptLine("handleStopArray[index] = handleStopArray[count];");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[index] = arg" + i + "Array[count];");
            }
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void process(){");
            rmTriggerAddScriptLine("if(!initialised){");
                rmTriggerAddScriptLine("initialise();");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("for(int index = count - 1; index >= 0; index--){");
                rmTriggerAddScriptLine("int fromUnitId = fromUnitIdArray[index];");
                rmTriggerAddScriptLine("int toUnitId = toUnitIdArray[index];");
                rmTriggerAddScriptLine("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = handleStopArray[index];");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine(typeArray[i] + " arg" + i + " = arg" + i + "Array[index];");
                }
                rmTriggerAddScriptLine("if(kbUnitGetProtoUnitID(fromUnitId) < 0 || kbUnitGetProtoUnitID(toUnitId) < 0){");
                    rmTriggerAddScriptLine("if(kbUnitGetProtoUnitID(fromUnitId) >= 0){");
                        rmTriggerAddScriptLine("vector fromLoc = trUnitGetPosition(fromUnitId);");
                        rmTriggerAddScriptLine("trUnitSelectClear();");
                        rmTriggerAddScriptLine("trUnitSelectByID(fromUnitId);");
                        rmTriggerAddScriptLine("trUnitReposition(fromLoc.x, fromLoc.y, fromLoc.z, false, true);");
                        rmTriggerAddScriptLine("handleStop(fromUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                    rmTriggerAddScriptLine("}");
                    rmTriggerAddScriptLine("removeAtIndex(index);");
                    rmTriggerAddScriptLine("continue;");
                rmTriggerAddScriptLine("}");
                rmTriggerAddScriptLine("vector toLoc = trUnitGetPosition(toUnitId);");
                rmTriggerAddScriptLine("float toHeading = trUnitGetHeading(toUnitId) * cPi / 180.0;");
                rmTriggerAddScriptLine("trUnitSelectClear();");
                rmTriggerAddScriptLine("trUnitSelectByID(toUnitId);");
                rmTriggerAddScriptLine("bool(int, int"+toLambdaTypeList(typeArray, true)+") stop = stopArray[index];");
                rmTriggerAddScriptLine("bool shouldStop = stop(fromUnitId, toUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                rmTriggerAddScriptLine("trUnitSelectClear();");
                rmTriggerAddScriptLine("trUnitSelectByID(fromUnitId);");
                rmTriggerAddScriptLine("float heightOffset = heightOffsetArray[index];");
                rmTriggerAddScriptLine("float distance = distanceArray[index];");
                rmTriggerAddScriptLine("float angle = angleArray[index];");
                rmTriggerAddScriptLine("float angleOffset = angleOffsetArray[index];");
                rmTriggerAddScriptLine("float rotOffset = rotOffsetArray[index];");
                rmTriggerAddScriptLine("float toHeadingWithOffset = toHeading + angleOffset;");
                rmTriggerAddScriptLine("vector newLoc = vector(clamp(toLoc.x + distance * sin(toHeadingWithOffset), 0.0, toMetresX(1.0)), toLoc.y + heightOffset, clamp(toLoc.z + distance * cos(toHeadingWithOffset), 0.0, toMetresZ(1.0)));");
                rmTriggerAddScriptLine("trUnitReposition(newLoc.x, newLoc.y, newLoc.z, shouldStop == false, true);");
                rmTriggerAddScriptLine("trUnitSetHeading((toHeading + rotOffset) * 180.0 / cPi);");
                rmTriggerAddScriptLine("if(shouldStop){");
                    rmTriggerAddScriptLine("removeAtIndex(index);");
                    rmTriggerAddScriptLine("trUnitSelectClear();");
                    rmTriggerAddScriptLine("trUnitSelectByID(fromUnitId);");
                    rmTriggerAddScriptLine("handleStop(fromUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");
        rmTriggerAddScriptLine("void add(int fromUnitId = 0, int toUnitId = 0");
                rmTriggerAddScriptLine(toLambdaArgumentList(typeArray, true) + ",");
                rmTriggerAddScriptLine("bool(int, int"+toLambdaTypeList(typeArray, true)+") stop = [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;}, ");
                rmTriggerAddScriptLine("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{}){");
            rmTriggerAddScriptLine("if(!initialised){");
                rmTriggerAddScriptLine("initialise();");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("if(count == fromUnitIdArray.size()){");
                rmTriggerAddScriptLine("fromUnitIdArray.resize(2 * fromUnitIdArray.size(), 0);");
                rmTriggerAddScriptLine("toUnitIdArray.resize(2 * toUnitIdArray.size(), 0);");
                rmTriggerAddScriptLine("heightOffsetArray.resize(2 * heightOffsetArray.size(), 0.0);");
                rmTriggerAddScriptLine("distanceArray.resize(2 * distanceArray.size(), 0.0);");
                rmTriggerAddScriptLine("angleArray.resize(2 * angleArray.size(), 0.0);");
                rmTriggerAddScriptLine("angleOffsetArray.resize(2 * angleOffsetArray.size(), 0.0);");
                rmTriggerAddScriptLine("rotOffsetArray.resize(2 * rotOffsetArray.size(), 0.0);");
                rmTriggerAddScriptLine("stopArray.resize(2 * stopArray.size(), [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
                rmTriggerAddScriptLine("handleStopArray.resize(2 * handleStopArray.size(), [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
                for(int i = 0; i < typeArray.size(); i++){
                    rmTriggerAddScriptLine("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("fromUnitIdArray[count] = fromUnitId;");
            rmTriggerAddScriptLine("toUnitIdArray[count] = toUnitId;");
            rmTriggerAddScriptLine("vector fromLoc = trUnitGetPosition(fromUnitId);");
            rmTriggerAddScriptLine("vector toLoc = trUnitGetPosition(toUnitId);");
            rmTriggerAddScriptLine("heightOffsetArray[count] = fromLoc.y - toLoc.y;");
            rmTriggerAddScriptLine("distanceArray[count] = xsVectorDistanceXZ(toLoc, fromLoc);");
            rmTriggerAddScriptLine("angleArray[count] = atan2(fromLoc.z - toLoc.z, fromLoc.x - toLoc.x);");
            rmTriggerAddScriptLine("angleOffsetArray[count] = trUnitGetHeading(toUnitId) * cPi / 180.0;");
            rmTriggerAddScriptLine("rotOffsetArray[count] = (trUnitGetHeading(fromUnitId) * cPi / 180.0) - angleOffsetArray[count];");
            rmTriggerAddScriptLine("stopArray[count] = stop;");
            rmTriggerAddScriptLine("handleStopArray[count] = handleStop;");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[count] = arg" + i + ";");
            }
            rmTriggerAddScriptLine("count++;");
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("};");
    
    rmTriggerAddScriptLine(className + " " + name + ";");
    
    gTriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        rmTriggerAddScriptLine(gTriggerName + ".process();");
    });
}

//Helper functions

float circleX(float centre = 0.0, float i = 0.0, float total = 0.0, float radius = 0.0, float disp = 0){
    return centre + radius * sin((cTwoPi * i) / total + (45.0 - disp) * 0.017453);
}

float circleZ(float centre = 0.0, float i = 0.0, float total = 0.0, float radius = 0.0, float disp = 0){
    return centre + radius * cos((cTwoPi * i) / total + (45.0 - disp) * 0.017453);
}

vector circleV(vector centre = cOriginVector, float i = 0.0, float total = 0.0, float radius = 0.0, float disp = 0){
    return vector(circleX(centre.x, i, total, radius, disp), centre.y, circleZ(centre.z, i, total, radius, disp));
}

// Vector 

vector xsVectorSetX(vector v = cOriginVector, float newValue = 0.0){
    return vector(newValue, v.y, v.z);
}
vector xsVectorSetY(vector v = cOriginVector, float newValue = 0.0){
    return vector(v.x, newValue, v.z);
}
vector xsVectorSetZ(vector v = cOriginVector, float newValue = 0.0){
    return vector(v.x, v.y, newValue);
}

// generate RM helper methods

vector vector2d(float x = 0.0, float z = 0.0){
    return vector(x, 0.0, z);
}

int randomIntWeighted(int minValue = 0, int maxValue = 1, int weight = 1){
    int value = maxValue;
    for(int i = 0; i < weight; i++){
        value = xsRandInt(minValue, value);
    }
    return value;
}

float randomFloatWeighted(float minValue = 0.0, float maxValue = 1.0, int weight = 1){
    float value = maxValue;
    for(int i = 0; i < weight; i++){
        value = xsRandFloat(minValue, value);
    }
    return value;
}

void placeObjectFractionTrigger(int p = -1, int protounitId = -1, vector v = cOriginVector, float heading = cMaxFloat){
    rmTriggerAddScriptLine("trUnitCreateForced(kbProtoUnitGetName("+protounitId+"), "+rmXFractionToMeters(v.x)+", "+(v.y)+", "+rmZFractionToMeters(v.z)+", "+(heading == cMaxInt ? xsRandInt(0, 359) : heading)+", "+p+", true);");
}

void placeObjectTrigger(int p = -1, int protounitId = -1, vector v = cOriginVector, float heading = cMaxFloat){
    rmTriggerAddScriptLine("trUnitCreateForced(kbProtoUnitGetName("+protounitId+"), "+(v.x)+", "+(v.y)+", "+(v.z)+", "+(heading == cMaxInt ? xsRandInt(0, 359) : heading)+", "+p+", true);");
}

string displayFloat(float value = 0.0, int maxDecimals = 6){
    float multiplyFactor = pow(10.0, maxDecimals);
    float valueRounded = round(value * multiplyFactor) / multiplyFactor + (0.5 / multiplyFactor);
    string valueAsString = xsFloatToString(valueRounded);
    if(maxDecimals < 6){
        valueAsString = xsStringSubstring(valueAsString, 0, xsStringLength(valueAsString) - (7 - maxDecimals));
    }
    for(int i = 0; i < maxDecimals; i++){
        if(xsStringSubstring(valueAsString, xsStringLength(valueAsString) - 1, xsStringLength(valueAsString) - 1) != "0"){
            return (valueAsString);
        } else {
            valueAsString = xsStringSubstring(valueAsString, 0, xsStringLength(valueAsString) - 2);
        }
    }
    return (xsStringSubstring(valueAsString, 0, xsStringLength(valueAsString) - 2));
}

void createTypedPlayerSizingArray(string type = "", string name = ""){
    rmTriggerAddScriptLine(""+type+"[] "+name+" = default;");
    rmTriggerAddScriptLine("int[] "+name+"CurrentSize = default;");
    rmTriggerAddScriptLine("int "+name+"MaxSize = 0;");
    
    rmTriggerAddScriptLine("int "+name+"Size(int p = 0){");
        rmTriggerAddScriptLine("if("+name+"CurrentSize.size() <= 0){");
            rmTriggerAddScriptLine("return 0;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("return "+name+"CurrentSize[p];");
    rmTriggerAddScriptLine("}");
    
    rmTriggerAddScriptLine("int "+name+"Add(int p = 0, "+type+" value"+getVariableDefaultValue(type)+"){");
        rmTriggerAddScriptLine("int size = "+name+"Size(p);");
        rmTriggerAddScriptLine("if(size >= "+name+"MaxSize){");
            rmTriggerAddScriptLine("int existingMaxSize = "+name+"MaxSize;");
            rmTriggerAddScriptLine("int newSize = (existingMaxSize == 0) ? 10 : ("+name+"MaxSize * 2);");
            rmTriggerAddScriptLine(""+name+".resize("+(cNumberPlayers+1)+" * newSize"+getArrayDefaultValue(type)+");");
            rmTriggerAddScriptLine("if(existingMaxSize == 0){");
                rmTriggerAddScriptLine(""+name+"CurrentSize.resize("+(cNumberPlayers+1)+", 0);");
            rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine(""+name+"MaxSize = newSize;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine(""+name+"[size * "+(cNumberPlayers+1)+" + p] = value;");
        rmTriggerAddScriptLine(""+name+"CurrentSize[p] = "+name+"CurrentSize[p] + 1;");
        rmTriggerAddScriptLine("return "+name+"CurrentSize[p] - 1;");
    rmTriggerAddScriptLine("}");
    
    rmTriggerAddScriptLine(""+type+" "+name+"Get(int p = 0, int index = 0){");
        rmTriggerAddScriptLine("return "+name+"[index * "+(cNumberPlayers+1)+" + p];");
    rmTriggerAddScriptLine("}");
    
    rmTriggerAddScriptLine("void "+name+"Set(int p = 0, int index = 0, "+type+" value"+getVariableDefaultValue(type)+"){");
        rmTriggerAddScriptLine("while("+name+"Size(p) <= index){");
            rmTriggerAddScriptLine(""+name+"Add(p);");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine(""+name+"[index * "+(cNumberPlayers+1)+" + p] = value;");
    rmTriggerAddScriptLine("}");
    
    rmTriggerAddScriptLine("void "+name+"Clear(int p = 0){");
        rmTriggerAddScriptLine("if("+name+"Size(p) > 0){");
            rmTriggerAddScriptLine(""+name+"CurrentSize[p] = 0;");
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("}");
}