include "lib/rm_core.xs";

//Trigger code

string quote = "\\";

void code(string codeToRun = ""){
    rmTriggerAddScriptLine(codeToRun);
}

void() always = []() -> void {
    code("return true;");
};

void(int) alwaysIndexed = [](int p = 1) -> void {
    code("return true;");
};

void defineTrigger(string name = "", bool initiallyActive = true, bool looping = false, bool immediate = false, void() condition = always, void() effects = []() -> void {}){
    code("int "+name+"_lastTime = 0;");
    code("bool "+name+"_conditionToRun(int lastTime = 0) {");
        condition();
    code("}");
    code("");
    code("rule _"+name);
    code("highFrequency");
    if(initiallyActive){
        code("active");
    }
    if(immediate){
        code("runImmediately");
    }
    code("{");
        code("if ("+name+"_conditionToRun("+name+"_lastTime)) {");
            effects();
            if(looping){
                code(""+name+"_lastTime = xsGetTimeMS();");
            } else {
                code("xsDisableSelf();");
            }
        code("}");
    code("}");
}

void defineIndexedTrigger(string name = "", int p = 1, bool initiallyActive = true, bool looping = false, bool immediate = false, void(int) condition = alwaysIndexed, void(int) effects = [](int p = 1) -> void {}){
    string nameToUse = name + p;
    code("int "+nameToUse+"_lastTime = 0;");
    code("bool "+nameToUse+"_conditionToRun(int lastTime = 0) {");
        condition(p);
    code("}");
    code("");
    code("rule _"+nameToUse);
    code("highFrequency");
    if(initiallyActive){
        code("active");
    }
    if(immediate){
        code("runImmediately");
    }
    code("{");
        code("if ("+nameToUse+"_conditionToRun("+nameToUse+"_lastTime)) {");
            effects(p);
            if(looping){
                code(""+nameToUse+"_lastTime = xsGetTimeMS();");
            } else {
                code("xsDisableSelf();");
            }
        code("}");
    code("}");
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
    code("for(int "+indexVariableToUse+" = 0; "+indexVariableToUse+" < "+container+".size(); "+indexVariableToUse+"++){");
    code(dataType+" "+variable+" = "+container+"["+indexVariableToUse+"];");
    forEachIndentation++;
}

void forEachEnd(){
    forEachIndentation--;
    code("}");
}

void defineDatabaseDefinition(string className = "", string[] typeArray = default){
    if(typeArray.size() > 0){
        code("class "+className+"Args {");
            for(int i = 0; i < typeArray.size(); i++){
                code(typeArray[i] + " arg" + i + getVariableDefaultValue(typeArray[i]) + ";");
            }
        code("};");
        code("");
    }
    
    code("class "+className+" {");
        code("bool initialised = false;");
        code("bool resizingProcess = false;");
        code("int count = 0;");
        code("int[] unitIdArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            code(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        if(typeArray.size() > 0){
            code(""+className+"Args args;");
        }
        code("void initialise(){");
            code("unitIdArray = new int(10, 0);");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            code("initialised = true;");
        code("}");
        code("");
        if(typeArray.size() > 0){
        code("void process(bool(int, ref "+className+"Args) handler = [](int unitId = 0, ref "+className+"Args argsDefault) -> bool {return false;}, ");
                code("void(int, ref "+className+"Args) handleDestroyed = [](int unitId = 0, ref "+className+"Args argsDefault) -> void {}){");
        } else {
        code("void process(bool(int) handler = [](int unitId = 0) -> bool {return false;}, ");
                code("void(int) handleDestroyed = [](int unitId = 0) -> void {}){");
        }
            code("if(!initialised){");
                code("initialise();");
            code("}");
            code("for(int index = count - 1; index >= 0; index--){");
                code("int unitId = unitIdArray[index];");
                for(int i = 0; i < typeArray.size(); i++){
                    code("args.arg" + i + " = arg" + i + "Array[index];");
                }
                code("if(kbUnitGetProtoUnitID(unitId) < 0){");
                    code("count--;");
                    if(typeArray.size() > 0){
                        code("handleDestroyed(unitId, args);");
                    } else {
                        code("handleDestroyed(unitId);");
                    }
                    code("unitIdArray[index] = unitIdArray[count];");
                    for(int i = 0; i < typeArray.size(); i++){
                        code("arg" + i + "Array[index] = arg" + i + "Array[count];");
                    }
                    code("continue;");
                code("}");
                code("if(resizingProcess){");
                    code("continue;");
                code("}");
                code("trUnitSelectClear();");
                code("trUnitSelectByID(unitId);");
                if(typeArray.size() > 0){
                    code("if(handler(unitId, args)){");
                } else {
                    code("if(handler(unitId)){");
                }
                    code("count--;");
                    code("unitIdArray[index] = unitIdArray[count];");
                    for(int i = 0; i < typeArray.size(); i++){
                        code("arg" + i + "Array[index] = arg" + i + "Array[count];");
                    }
                code("} else {");
                    for(int i = 0; i < typeArray.size(); i++){
                        code("arg" + i + "Array[index] = args.arg" + i + ";");
                    }
                code("}");
            code("}");
        code("}");
        code("");
        code("void add(int unitId = 0"+toLambdaArgumentList(typeArray, true)+"){");
            code("if(!initialised){");
                code("initialise();");
            code("}");
            code("if(count == unitIdArray.size()){");
                code("resizingProcess = true;");
                code("process();");
                code("resizingProcess = false;");
            code("}");
            code("if(count == unitIdArray.size()){");
                code("unitIdArray.resize(2 * unitIdArray.size(), 0);");
                for(int i = 0; i < typeArray.size(); i++){
                    code("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            code("}");
            code("unitIdArray[count] = unitId;");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array[count] = arg" + i + ";");
            }
            code("count++;");
        code("}");
    code("};");
}

string gTriggerName = "";

void createTypedScheduler(string name = "", string[] typeArray = default){
    
    string className = "Scheduler_" + name;
    
    code("class "+className+" {");
        code("bool initialised = false;");
        code("int count = 0;");
        code("int[] delayArray = default;");
        code("bool(int"+toLambdaTypeList(typeArray, true)+")[] toRunArray = default;");
        code("int[] lastTimeArray = default;");
        code("int[] iterationArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            code(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        code("");
        code("void initialise(){");
            code("initialised = true;");
            code("delayArray = new int(10, 0);");
            code("toRunArray = new bool(int"+toLambdaTypeList(typeArray, true)+")(10, [](int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;});");
            code("lastTimeArray = new int(10, 0);");
            code("iterationArray = new int(10, 0);");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
        code("}");
        code("");
        code("void process(){");
            code("int time = xsGetTimeMS();");
            code("for(int index = count - 1; index >= 0; index--){");
                code("int delay = delayArray[index];");
                code("int lastTime = lastTimeArray[index];");
                code("if(time < lastTime + delay){");
                    code("continue;");
                code("}");
                code("lastTimeArray[index] = lastTime + delay;");
                code("int iteration = iterationArray[index];");
                code("iteration++;");
                code("iterationArray[index] = iteration;");
                for(int i = 0; i < typeArray.size(); i++){
                    code(typeArray[i] + " arg" + i + " = arg" + i + "Array[index];");
                }
                code("bool(int"+toLambdaTypeList(typeArray, true)+") toRun = toRunArray[index];");
                code("if(toRun(iteration"+indexStringSequence(", arg", "", typeArray.size())+") == false){");
                    code("count--;");
                    code("delayArray[index] = delayArray[count];");
                    code("toRunArray[index] = toRunArray[count];");
                    code("lastTimeArray[index] = lastTimeArray[count];");
                    code("iterationArray[index] = iterationArray[count];");
                    for(int i = 0; i < typeArray.size(); i++){
                        code("arg" + i + "Array[index] = arg" + i + "Array[count];");
                    }
                code("}");
            code("}");
        code("}");
        code("");
        code("void add(int delay = 0"+toLambdaArgumentList(typeArray, true)+", bool(int"+toLambdaTypeList(typeArray, true)+") toRun = [](int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;}){");
            code("if(!initialised){");
                code("initialise();");
            code("}");
            code("if(count == delayArray.size()){");
                code("delayArray.resize(2 * delayArray.size(), 0);");
                code("toRunArray.resize(2 * toRunArray.size(), [](int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;});");
                code("lastTimeArray.resize(2 * lastTimeArray.size(), 0);");
                code("iterationArray.resize(2 * iterationArray.size(), 0);");
                for(int i = 0; i < typeArray.size(); i++){
                    code("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            code("}");
            code("delayArray[count] = delay;");
            code("toRunArray[count] = toRun;");
            code("lastTimeArray[count] = xsGetTimeMS();");
            code("iterationArray[count] = 0;");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array[count] = arg" + i + ";");
            }
            code("count++;");
        code("}");
        code("void cancelAll(){");
            code("count = 0;");
        code("}");
    code("};");
    
    code(className + " " + name + ";");
    
    gTriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        code(gTriggerName + ".process();");
    });
}

void createTypedUnitScheduler(string name = "", string[] typeArray = default){
    
    string className = "UnitScheduler_" + name;
    
    code("class "+className+" {");
        code("bool initialised = false;");
        code("int count = 0;");
        code("int[] unitArray = default;");
        code("int[] delayArray = default;");
        code("bool(int, int"+toLambdaTypeList(typeArray, true)+")[] toRunArray = default;");
        code("int[] lastTimeArray = default;");
        code("int[] iterationArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            code(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        code("");
        code("void initialise(){");
            code("initialised = true;");
            code("unitArray = new int(10, 0);");
            code("delayArray = new int(10, 0);");
            code("toRunArray = new bool(int, int"+toLambdaTypeList(typeArray, true)+")(10, [](int unitId = 0, int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;});");
            code("lastTimeArray = new int(10, 0);");
            code("iterationArray = new int(10, 0);");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
        code("}");
        code("");
        code("void process(){");
            code("int time = xsGetTimeMS();");
            code("for(int index = count - 1; index >= 0; index--){");
                code("int delay = delayArray[index];");
                code("int lastTime = lastTimeArray[index];");
                code("if(time < lastTime + delay){");
                    code("continue;");
                code("}");
                code("lastTimeArray[index] = lastTime + delay;");
                code("int iteration = iterationArray[index];");
                code("iteration++;");
                code("iterationArray[index] = iteration;");
                code("int unitId = unitArray[index];");
                for(int i = 0; i < typeArray.size(); i++){
                    code(typeArray[i] + " arg" + i + " = arg" + i + "Array[index];");
                }
                code("bool(int, int"+toLambdaTypeList(typeArray, true)+") toRun = toRunArray[index];");
                code("bool remove = kbUnitGetProtoUnitID(unitId) < 0;");
                code("if(remove == false){");
                    code("trUnitSelectClear();");
                    code("trUnitSelectByID(unitId);");
                    code("remove = toRun(unitId, iteration"+indexStringSequence(", arg", "", typeArray.size())+") == false;");
                code("}");
                code("if(remove){");
                    code("count--;");
                    code("unitArray[index] = unitArray[count];");
                    code("delayArray[index] = delayArray[count];");
                    code("toRunArray[index] = toRunArray[count];");
                    code("lastTimeArray[index] = lastTimeArray[count];");
                    code("iterationArray[index] = iterationArray[count];");
                    for(int i = 0; i < typeArray.size(); i++){
                        code("arg" + i + "Array[index] = arg" + i + "Array[count];");
                    }
                code("}");
            code("}");
        code("}");
        code("");
        code("void add(int unitId = 0, int delay = 0"+toLambdaArgumentList(typeArray, true)+", bool(int, int"+toLambdaTypeList(typeArray, true)+") toRun = [](int unitId = 0, int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;}){");
            code("if(!initialised){");
                code("initialise();");
            code("}");
            code("if(count == delayArray.size()){");
                code("unitArray.resize(2 * unitArray.size(), 0);");
                code("delayArray.resize(2 * delayArray.size(), 0);");
                code("toRunArray.resize(2 * toRunArray.size(), [](int unitId = 0, int iteration = 1"+toLambdaArgumentList(typeArray, true)+") -> bool {return false;});");
                code("lastTimeArray.resize(2 * lastTimeArray.size(), 0);");
                code("iterationArray.resize(2 * iterationArray.size(), 0);");
                for(int i = 0; i < typeArray.size(); i++){
                    code("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            code("}");
            code("unitArray[count] = unitId;");
            code("delayArray[count] = delay;");
            code("toRunArray[count] = toRun;");
            code("lastTimeArray[count] = xsGetTimeMS();");
            code("iterationArray[count] = 0;");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array[count] = arg" + i + ";");
            }
            code("count++;");
        code("}");
        code("void cancelAll(){");
            code("count = 0;");
        code("}");
    code("};");
    
    code(className + " " + name + ";");
    
    gTriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        code(gTriggerName + ".process();");
    });
}

string FLYING_PHYSICS = "trUnitReposition(pos.x, pos.y, pos.z, shouldStop == false, true);";
string SLIDING_PHYSICS = "trUnitReposition(pos.x, pos.y + getTerrainHeightAccurate(pos), pos.z, shouldStop == false, true);";

void createTypedPhysics(string name = "", string applyPosition = "", string[] typeArray = default){
    
    string className = "Physics_" + name;
    
    code("class "+className+" {");
        code("bool initialised = false;");
        code("int count = 0;");
        code("int lastTime = 0;");
        code("PhysicsState currentState;");
        code("int[] unitIdArray = default;");
        code("vector[] posArray = default;");
        code("vector[] velocityArray = default;");
        code("vector[] accelerationArray = default;");
        code("int[] timeArray = default;");
        code("bool(ref PhysicsState"+toLambdaTypeList(typeArray, true)+")[] stopArray = default;");
        code("void(int"+toLambdaTypeList(typeArray, true)+")[] handleStopArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            code(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        code("");
        code("void initialise(){");
            code("lastTime = xsGetTimeMS();");
            code("unitIdArray = new int(10, 0);");
            code("posArray = new vector(10, cOriginVector);");
            code("velocityArray = new vector(10, cOriginVector);");
            code("accelerationArray = new vector(10, cOriginVector);");
            code("timeArray = new int(10, 0);");
            code("stopArray = new bool(ref PhysicsState"+toLambdaTypeList(typeArray, true)+")(10, [](ref PhysicsState state"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
            code("handleStopArray = new void(int"+toLambdaTypeList(typeArray, true)+")(10, [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            code("initialised = true;");
        code("}");
        code("");
        code("void removeAtIndex(int index = 0){");
            code("count--;");
            code("unitIdArray[index] = unitIdArray[count];");
            code("posArray[index] = posArray[count];");
            code("velocityArray[index] = velocityArray[count];");
            code("accelerationArray[index] = accelerationArray[count];");
            code("timeArray[index] = timeArray[count];");
            code("stopArray[index] = stopArray[count];");
            code("handleStopArray[index] = handleStopArray[count];");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array[index] = arg" + i + "Array[count];");
            }
        code("}");
        code("");
        code("void process(){");
            code("if(!initialised){");
                code("initialise();");
            code("}");
            code("int deltaMs = xsGetTimeMS() - lastTime;");
            code("lastTime = xsGetTimeMS();");
            code("float delta = 0.001 * deltaMs;");
            code("float halfDeltaSq = 0.5 * delta * delta;");
            code("for(int index = count - 1; index >= 0; index--){");
                code("int unitId = unitIdArray[index];");
                code("if(kbUnitGetProtoUnitID(unitId) < 0){");
                    code("removeAtIndex(index);");
                    code("continue;");
                code("}");
                code("vector pos = posArray[index];");
                code("vector velocity = velocityArray[index];");
                code("vector acceleration = accelerationArray[index];");
                code("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = handleStopArray[index];");
                code("currentState.pos = vector(");
                        code("pos.x + velocity.x * delta + acceleration.x * halfDeltaSq,");
                        code("pos.y + velocity.y * delta + acceleration.y * halfDeltaSq,");
                        code("pos.z + velocity.z * delta + acceleration.z * halfDeltaSq);");
                code("currentState.velocity = vector(");
                        code("velocity.x + acceleration.x * delta,");
                        code("velocity.y + acceleration.y * delta,");
                        code("velocity.z + acceleration.z * delta);");
                code("timeArray[index] = timeArray[index] + deltaMs;");
                for(int i = 0; i < typeArray.size(); i++){
                    code(typeArray[i] + " arg" + i + " = arg" + i + "Array[index];");
                }
                code("trUnitSelectClear();");
                code("trUnitSelectByID(unitId);");
                code("bool(ref PhysicsState"+toLambdaTypeList(typeArray, true)+") stop = stopArray[index];");
                code("currentState.unitId = unitId;");
                code("currentState.acceleration = acceleration;");
                code("currentState.time = timeArray[index];");
                code("currentState.deltaTime = deltaMs;");
                code("bool shouldStop = stop(currentState"+indexStringSequence(", arg", "", typeArray.size())+");");
                code("posArray[index] = currentState.pos;");
                code("velocityArray[index] = currentState.velocity;");
                code("accelerationArray[index] = currentState.acceleration;");
                code("trUnitSelectClear();");
                code("trUnitSelectByID(unitId);");
                code(applyPosition);
                code("if(shouldStop){");
                    code("removeAtIndex(index);");
                    code("handleStop(unitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                code("}");
            code("}");
        code("}");
        code("");
        code("void add(int unitId = 0, vector pos = cOriginVector, vector velocity = cOriginVector, vector acceleration = cOriginVector ");
                code(toLambdaArgumentList(typeArray, true) + ",");
                code("bool(ref PhysicsState"+toLambdaTypeList(typeArray, true)+") stop = [](ref PhysicsState state"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;},");
                code("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{}){");
            code("if(!initialised){");
                code("initialise();");
            code("}");
            code("if(count == unitIdArray.size()){");
                code("for(int index = count - 1; index >= 0; index--){");
                    code("if(kbUnitGetProtoUnitID(unitId) < 0){");
                        code("removeAtIndex(unitIdArray[index]);");
                    code("}");
                code("}");
            code("}");
            code("if(count == unitIdArray.size()){");
                code("unitIdArray.resize(2 * unitIdArray.size(), 0);");
                code("posArray.resize(2 * posArray.size(), cOriginVector);");
                code("velocityArray.resize(2 * velocityArray.size(), cOriginVector);");
                code("accelerationArray.resize(2 * accelerationArray.size(), cOriginVector);");
                code("timeArray.resize(2 * timeArray.size(), 0);");
                code("stopArray.resize(2 * stopArray.size(), [](ref PhysicsState state"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
                code("handleStopArray.resize(2 * handleStopArray.size(), [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
                for(int i = 0; i < typeArray.size(); i++){
                    code("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            code("}");
            code("unitIdArray[count] = unitId;");
            code("posArray[count] = pos;");
            code("velocityArray[count] = velocity;");
            code("accelerationArray[count] = acceleration;");
            code("timeArray[count] = 0;");
            code("stopArray[count] = stop;");
            code("handleStopArray[count] = handleStop;");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array[count] = arg" + i + ";");
            }
            code("count++;");
        code("}");
    code("};");
    
    code(className + " " + name + ";");
    
    gTriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        code(gTriggerName + ".process();");
    });
}

void createTypedAttachBasic(string name = "", string[] typeArray = default){
    
    string className = "AttachBasic_" + name;
    
    code("class "+className+" {");
        code("bool initialised = false;");
        code("int count = 0;");
        code("int[] fromUnitIdArray = default;");
        code("int[] toUnitIdArray = default;");
        code("bool(int, int"+toLambdaTypeList(typeArray, true)+")[] stopArray = default;");
        code("void(int"+toLambdaTypeList(typeArray, true)+")[] handleStopArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            code(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        code("");
        code("void initialise(){");
            code("fromUnitIdArray = new int(10, 0);");
            code("toUnitIdArray = new int(10, 0);");
            code("stopArray = new bool(int, int"+toLambdaTypeList(typeArray, true)+")(10, [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
            code("handleStopArray = new void(int"+toLambdaTypeList(typeArray, true)+")(10, [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            code("initialised = true;");
        code("}");
        code("");
        code("void removeAtIndex(int index = 0){");
            code("count--;");
            code("fromUnitIdArray[index] = fromUnitIdArray[count];");
            code("toUnitIdArray[index] = toUnitIdArray[count];");
            code("stopArray[index] = stopArray[count];");
            code("handleStopArray[index] = handleStopArray[count];");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array[index] = arg" + i + "Array[count];");
            }
        code("}");
        code("");
        code("void process(){");
            code("if(!initialised){");
                code("initialise();");
            code("}");
            code("for(int index = count - 1; index >= 0; index--){");
                code("int fromUnitId = fromUnitIdArray[index];");
                code("int toUnitId = toUnitIdArray[index];");
                code("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = handleStopArray[index];");
                for(int i = 0; i < typeArray.size(); i++){
                    code(typeArray[i] + " arg" + i + " = arg" + i + "Array[index];");
                }
                code("if(kbUnitGetProtoUnitID(fromUnitId) < 0 || kbUnitGetProtoUnitID(toUnitId) < 0){");
                    code("if(kbUnitGetProtoUnitID(fromUnitId) >= 0){");
                        code("vector fromLoc = trUnitGetPosition(fromUnitId);");
                        code("trUnitSelectClear();");
                        code("trUnitSelectByID(fromUnitId);");
                        code("trUnitReposition(fromLoc.x, fromLoc.y, fromLoc.z, false, true);");
                        code("handleStop(fromUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                    code("}");
                    code("removeAtIndex(index);");
                    code("continue;");
                code("}");
                code("trUnitSelectClear();");
                code("trUnitSelectByID(toUnitId);");
                code("bool(int, int"+toLambdaTypeList(typeArray, true)+") stop = stopArray[index];");
                code("bool shouldStop = stop(fromUnitId, toUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                code("trUnitSelectClear();");
                code("trUnitSelectByID(fromUnitId);");
                code("trUnitRepositionToUnit(toUnitId, shouldStop == false, true);");
                code("trUnitSetHeading(trUnitGetHeading(toUnitId));");
                code("if(shouldStop){");
                    code("removeAtIndex(index);");
                    code("trUnitSelectClear();");
                    code("trUnitSelectByID(fromUnitId);");
                    code("handleStop(fromUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                code("}");
            code("}");
        code("}");
        code("");
        code("void add(int fromUnitId = 0, int toUnitId = 0");
                code(toLambdaArgumentList(typeArray, true) + ",");
                code("bool(int, int"+toLambdaTypeList(typeArray, true)+") stop = [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;}, ");
                code("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{}){");
            code("if(!initialised){");
                code("initialise();");
            code("}");
            code("if(count == fromUnitIdArray.size()){");
                code("fromUnitIdArray.resize(2 * fromUnitIdArray.size(), 0);");
                code("toUnitIdArray.resize(2 * toUnitIdArray.size(), 0);");
                code("stopArray.resize(2 * stopArray.size(), [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
                code("handleStopArray.resize(2 * handleStopArray.size(), [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
                for(int i = 0; i < typeArray.size(); i++){
                    code("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            code("}");
            code("fromUnitIdArray[count] = fromUnitId;");
            code("toUnitIdArray[count] = toUnitId;");
            code("stopArray[count] = stop;");
            code("handleStopArray[count] = handleStop;");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array[count] = arg" + i + ";");
            }
            code("count++;");
        code("}");
    code("};");
    
    code(className + " " + name + ";");
    
    gTriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        code(gTriggerName + ".process();");
    });
}

void createTypedAttach(string name = "", string[] typeArray = default){
    
    string className = "Attach_" + name;
    
    code("class "+className+" {");
        code("bool initialised = false;");
        code("int count = 0;");
        code("int[] fromUnitIdArray = default;");
        code("int[] toUnitIdArray = default;");
        code("float[] heightOffsetArray = default;");
        code("float[] distanceArray = default;");
        code("float[] angleArray = default;");
        code("float[] angleOffsetArray = default;");
        code("float[] rotOffsetArray = default;");
        code("bool(int, int"+toLambdaTypeList(typeArray, true)+")[] stopArray = default;");
        code("void(int"+toLambdaTypeList(typeArray, true)+")[] handleStopArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            code(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        code("");
        code("void initialise(){");
            code("fromUnitIdArray = new int(10, 0);");
            code("toUnitIdArray = new int(10, 0);");
            code("heightOffsetArray = new float(10, 0.0);");
            code("distanceArray = new float(10, 0.0);");
            code("angleArray = new float(10, 0.0);");
            code("angleOffsetArray = new float(10, 0.0);");
            code("rotOffsetArray = new float(10, 0.0);");
            code("stopArray = new bool(int, int"+toLambdaTypeList(typeArray, true)+")(10, [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
            code("handleStopArray = new void(int"+toLambdaTypeList(typeArray, true)+")(10, [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array = new " + typeArray[i] + "(10" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            code("initialised = true;");
        code("}");
        code("");
        code("void removeAtIndex(int index = 0){");
            code("count--;");
            code("fromUnitIdArray[index] = fromUnitIdArray[count];");
            code("toUnitIdArray[index] = toUnitIdArray[count];");
            code("heightOffsetArray[index] = heightOffsetArray[count];");
            code("distanceArray[index] = distanceArray[count];");
            code("angleArray[index] = angleArray[count];");
            code("angleOffsetArray[index] = angleOffsetArray[count];");
            code("rotOffsetArray[index] = rotOffsetArray[count];");
            code("stopArray[index] = stopArray[count];");
            code("handleStopArray[index] = handleStopArray[count];");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array[index] = arg" + i + "Array[count];");
            }
        code("}");
        code("");
        code("void process(){");
            code("if(!initialised){");
                code("initialise();");
            code("}");
            code("for(int index = count - 1; index >= 0; index--){");
                code("int fromUnitId = fromUnitIdArray[index];");
                code("int toUnitId = toUnitIdArray[index];");
                code("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = handleStopArray[index];");
                for(int i = 0; i < typeArray.size(); i++){
                    code(typeArray[i] + " arg" + i + " = arg" + i + "Array[index];");
                }
                code("if(kbUnitGetProtoUnitID(fromUnitId) < 0 || kbUnitGetProtoUnitID(toUnitId) < 0){");
                    code("if(kbUnitGetProtoUnitID(fromUnitId) >= 0){");
                        code("vector fromLoc = trUnitGetPosition(fromUnitId);");
                        code("trUnitSelectClear();");
                        code("trUnitSelectByID(fromUnitId);");
                        code("trUnitReposition(fromLoc.x, fromLoc.y, fromLoc.z, false, true);");
                        code("handleStop(fromUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                    code("}");
                    code("removeAtIndex(index);");
                    code("continue;");
                code("}");
                code("vector toLoc = trUnitGetPosition(toUnitId);");
                code("float toHeading = trUnitGetHeading(toUnitId) * cPi / 180.0;");
                code("trUnitSelectClear();");
                code("trUnitSelectByID(toUnitId);");
                code("bool(int, int"+toLambdaTypeList(typeArray, true)+") stop = stopArray[index];");
                code("bool shouldStop = stop(fromUnitId, toUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                code("trUnitSelectClear();");
                code("trUnitSelectByID(fromUnitId);");
                code("float heightOffset = heightOffsetArray[index];");
                code("float distance = distanceArray[index];");
                code("float angle = angleArray[index];");
                code("float angleOffset = angleOffsetArray[index];");
                code("float rotOffset = rotOffsetArray[index];");
                code("float toHeadingWithOffset = toHeading + angleOffset;");
                code("vector newLoc = vector(clamp(toLoc.x + distance * sin(toHeadingWithOffset), 0.0, toMetresX(1.0)), toLoc.y + heightOffset, clamp(toLoc.z + distance * cos(toHeadingWithOffset), 0.0, toMetresZ(1.0)));");
                code("trUnitReposition(newLoc.x, newLoc.y, newLoc.z, shouldStop == false, true);");
                code("trUnitSetHeading((toHeading + rotOffset) * 180.0 / cPi);");
                code("if(shouldStop){");
                    code("removeAtIndex(index);");
                    code("trUnitSelectClear();");
                    code("trUnitSelectByID(fromUnitId);");
                    code("handleStop(fromUnitId"+indexStringSequence(", arg", "", typeArray.size())+");");
                code("}");
            code("}");
        code("}");
        code("");
        code("void add(int fromUnitId = 0, int toUnitId = 0");
                code(toLambdaArgumentList(typeArray, true) + ",");
                code("bool(int, int"+toLambdaTypeList(typeArray, true)+") stop = [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;}, ");
                code("void(int"+toLambdaTypeList(typeArray, true)+") handleStop = [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{}){");
            code("if(!initialised){");
                code("initialise();");
            code("}");
            code("if(count == fromUnitIdArray.size()){");
                code("fromUnitIdArray.resize(2 * fromUnitIdArray.size(), 0);");
                code("toUnitIdArray.resize(2 * toUnitIdArray.size(), 0);");
                code("heightOffsetArray.resize(2 * heightOffsetArray.size(), 0.0);");
                code("distanceArray.resize(2 * distanceArray.size(), 0.0);");
                code("angleArray.resize(2 * angleArray.size(), 0.0);");
                code("angleOffsetArray.resize(2 * angleOffsetArray.size(), 0.0);");
                code("rotOffsetArray.resize(2 * rotOffsetArray.size(), 0.0);");
                code("stopArray.resize(2 * stopArray.size(), [](int fromUnitId = -1, int toUnitId = -1"+toLambdaArgumentList(typeArray, true)+") -> bool{return false;});");
                code("handleStopArray.resize(2 * handleStopArray.size(), [](int unitId = -1"+toLambdaArgumentList(typeArray, true)+") -> void{});");
                for(int i = 0; i < typeArray.size(); i++){
                    code("arg" + i + "Array.resize(2 * arg" + i + "Array.size()" + getArrayDefaultValue(typeArray[i]) + ");");
                }
            code("}");
            code("fromUnitIdArray[count] = fromUnitId;");
            code("toUnitIdArray[count] = toUnitId;");
            code("vector fromLoc = trUnitGetPosition(fromUnitId);");
            code("vector toLoc = trUnitGetPosition(toUnitId);");
            code("heightOffsetArray[count] = fromLoc.y - toLoc.y;");
            code("distanceArray[count] = xsVectorDistanceXZ(toLoc, fromLoc);");
            code("angleArray[count] = atan2(fromLoc.z - toLoc.z, fromLoc.x - toLoc.x);");
            code("angleOffsetArray[count] = trUnitGetHeading(toUnitId) * cPi / 180.0;");
            code("rotOffsetArray[count] = (trUnitGetHeading(fromUnitId) * cPi / 180.0) - angleOffsetArray[count];");
            code("stopArray[count] = stop;");
            code("handleStopArray[count] = handleStop;");
            for(int i = 0; i < typeArray.size(); i++){
                code("arg" + i + "Array[count] = arg" + i + ";");
            }
            code("count++;");
        code("}");
    code("};");
    
    code(className + " " + name + ";");
    
    gTriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        code(gTriggerName + ".process();");
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
    code("trUnitCreateForced(kbProtoUnitGetName("+protounitId+"), "+rmXFractionToMeters(v.x)+", "+(v.y)+", "+rmZFractionToMeters(v.z)+", "+(heading == cMaxInt ? xsRandInt(0, 359) : heading)+", "+p+", true);");
}

void placeObjectTrigger(int p = -1, int protounitId = -1, vector v = cOriginVector, float heading = cMaxFloat){
    code("trUnitCreateForced(kbProtoUnitGetName("+protounitId+"), "+(v.x)+", "+(v.y)+", "+(v.z)+", "+(heading == cMaxInt ? xsRandInt(0, 359) : heading)+", "+p+", true);");
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