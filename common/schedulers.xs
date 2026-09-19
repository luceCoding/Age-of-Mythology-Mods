// Implements a Hashed Wheel Timer

string g_TriggerName = "";

void createTypedScheduler(string name = "", string[] typeArray = default, int tickMS = 250, int wheelSize = 256){

    string className = "Scheduler_" + name;
    
    rmTriggerAddScriptLine("class " + className + " {");
        rmTriggerAddScriptLine("bool initialised = false;");
        rmTriggerAddScriptLine("int WHEEL_SIZE = " + wheelSize + ";");
        rmTriggerAddScriptLine("int TICK_MS = " + tickMS + ";");
        rmTriggerAddScriptLine("int currentTick = 0;");
        rmTriggerAddScriptLine("int lastTimeMS = 0;");
        
        // Slot heads array
        rmTriggerAddScriptLine("int[] slotHeadArray = default;");
        
        // Task node storage pool & free list
        rmTriggerAddScriptLine("int capacity = 0;");
        rmTriggerAddScriptLine("int freeHead = -1;");
        rmTriggerAddScriptLine("int[] nextInSlot = default;");
        rmTriggerAddScriptLine("int[] lapsArray = default;");
        rmTriggerAddScriptLine("int[] delayTicksArray = default;");
        rmTriggerAddScriptLine("int[] iterationArray = default;");
        rmTriggerAddScriptLine("bool(int" + toLambdaTypeList(typeArray, true) + ")[] toRunArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            rmTriggerAddScriptLine(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        rmTriggerAddScriptLine("");

        // Initialiser
        rmTriggerAddScriptLine("void initialise(){");
            rmTriggerAddScriptLine("initialised = true;");
            rmTriggerAddScriptLine("slotHeadArray = new int(WHEEL_SIZE, -1);");
            rmTriggerAddScriptLine("capacity = 16;");
            rmTriggerAddScriptLine("nextInSlot = new int(16, -1);");
            rmTriggerAddScriptLine("lapsArray = new int(16, 0);");
            rmTriggerAddScriptLine("delayTicksArray = new int(16, 0);");
            rmTriggerAddScriptLine("iterationArray = new int(16, 0);");
            rmTriggerAddScriptLine("toRunArray = new bool(int" + toLambdaTypeList(typeArray, true) + ")(16, [](int iteration = 1" + toLambdaArgumentList(typeArray, true) + ") -> bool {return false;});");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array = new " + typeArray[i] + "(16" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            // Link free list stack
            rmTriggerAddScriptLine("for(int i = 0; i < 15; i = i + 1){ nextInSlot[i] = i + 1; }");
            rmTriggerAddScriptLine("nextInSlot[15] = -1;");
            rmTriggerAddScriptLine("freeHead = 0;");
            rmTriggerAddScriptLine("lastTimeMS = xsGetTimeMS();");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");

        // Grow storage pool if capacity reached
        rmTriggerAddScriptLine("void growPool(){");
            rmTriggerAddScriptLine("int oldCap = capacity;");
            rmTriggerAddScriptLine("capacity = 2 * capacity;");
            rmTriggerAddScriptLine("nextInSlot.resize(capacity, -1);");
            rmTriggerAddScriptLine("lapsArray.resize(capacity, 0);");
            rmTriggerAddScriptLine("delayTicksArray.resize(capacity, 0);");
            rmTriggerAddScriptLine("iterationArray.resize(capacity, 0);");
            rmTriggerAddScriptLine("toRunArray.resize(capacity, [](int iteration = 1" + toLambdaArgumentList(typeArray, true) + ") -> bool {return false;});");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array.resize(capacity" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            rmTriggerAddScriptLine("for(int i = oldCap; i < capacity - 1; i = i + 1){ nextInSlot[i] = i + 1; }");
            rmTriggerAddScriptLine("nextInSlot[capacity - 1] = freeHead;");
            rmTriggerAddScriptLine("freeHead = oldCap;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");

        // O(1) Scheduling
        rmTriggerAddScriptLine("void add(int delayMS = 0" + toLambdaArgumentList(typeArray, true) + ", bool(int" + toLambdaTypeList(typeArray, true) + ") toRun = [](int iteration = 1" + toLambdaArgumentList(typeArray, true) + ") -> bool {return false;}){");
            rmTriggerAddScriptLine("if(!initialised){ initialise(); }");
            rmTriggerAddScriptLine("if(freeHead == -1){ growPool(); }");
            
            rmTriggerAddScriptLine("int idx = freeHead;");
            rmTriggerAddScriptLine("freeHead = nextInSlot[idx];");
            
            rmTriggerAddScriptLine("int delayTicks = delayMS / TICK_MS;");
            rmTriggerAddScriptLine("if(delayTicks < 1){ delayTicks = 1; }");
            rmTriggerAddScriptLine("int targetTick = currentTick + delayTicks;");
            rmTriggerAddScriptLine("int slot = targetTick % WHEEL_SIZE;");
            
            rmTriggerAddScriptLine("lapsArray[idx] = (delayTicks - 1) / WHEEL_SIZE;");
            rmTriggerAddScriptLine("delayTicksArray[idx] = delayTicks;");
            rmTriggerAddScriptLine("iterationArray[idx] = 0;");
            rmTriggerAddScriptLine("toRunArray[idx] = toRun;");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[idx] = arg" + i + ";");
            }
            
            rmTriggerAddScriptLine("nextInSlot[idx] = slotHeadArray[slot];");
            rmTriggerAddScriptLine("slotHeadArray[slot] = idx;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");

        // O(1) Tick Processing
        rmTriggerAddScriptLine("void process(){");
            rmTriggerAddScriptLine("if(!initialised){ return; }");
            rmTriggerAddScriptLine("int nowMS = xsGetTimeMS();");
            rmTriggerAddScriptLine("int elapsedTicks = (nowMS - lastTimeMS) / TICK_MS;");
            rmTriggerAddScriptLine("if(elapsedTicks <= 0){ return; }");
            
            rmTriggerAddScriptLine("for(int t = 0; t < elapsedTicks; t = t + 1){");
                rmTriggerAddScriptLine("currentTick = currentTick + 1;");
                rmTriggerAddScriptLine("lastTimeMS = lastTimeMS + TICK_MS;");
                rmTriggerAddScriptLine("int slot = currentTick % WHEEL_SIZE;");
                
                rmTriggerAddScriptLine("int prev = -1;");
                rmTriggerAddScriptLine("int curr = slotHeadArray[slot];");
                
                rmTriggerAddScriptLine("while(curr != -1){");
                    rmTriggerAddScriptLine("int nextTask = nextInSlot[curr];");
                    rmTriggerAddScriptLine("if(lapsArray[curr] > 0){");
                        rmTriggerAddScriptLine("lapsArray[curr] = lapsArray[curr] - 1;");
                        rmTriggerAddScriptLine("prev = curr;");
                    rmTriggerAddScriptLine("} else {");
                        rmTriggerAddScriptLine("if(prev == -1){ slotHeadArray[slot] = nextTask; }");
                        rmTriggerAddScriptLine("else { nextInSlot[prev] = nextTask; }");
                        
                        rmTriggerAddScriptLine("int iter = iterationArray[curr] + 1;");
                        rmTriggerAddScriptLine("iterationArray[curr] = iter;");
                        for(int i = 0; i < typeArray.size(); i++){
                            rmTriggerAddScriptLine(typeArray[i] + " arg" + i + " = arg" + i + "Array[curr];");
                        }
                        rmTriggerAddScriptLine("bool(int" + toLambdaTypeList(typeArray, true) + ") toRun = toRunArray[curr];");
                        
                        rmTriggerAddScriptLine("if(toRun(iter" + indexStringSequence(", arg", "", typeArray.size()) + ")){");
                            rmTriggerAddScriptLine("int dTicks = delayTicksArray[curr];");
                            rmTriggerAddScriptLine("int nTarget = currentTick + dTicks;");
                            rmTriggerAddScriptLine("int nSlot = nTarget % WHEEL_SIZE;");
                            rmTriggerAddScriptLine("lapsArray[curr] = (dTicks - 1) / WHEEL_SIZE;");
                            rmTriggerAddScriptLine("nextInSlot[curr] = slotHeadArray[nSlot];");
                            rmTriggerAddScriptLine("slotHeadArray[nSlot] = curr;");
                        rmTriggerAddScriptLine("} else {");
                            rmTriggerAddScriptLine("nextInSlot[curr] = freeHead;");
                            rmTriggerAddScriptLine("freeHead = curr;");
                        rmTriggerAddScriptLine("}");
                    rmTriggerAddScriptLine("}");
                    rmTriggerAddScriptLine("curr = nextTask;");
                rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");

        rmTriggerAddScriptLine("void cancelAll(){");
            rmTriggerAddScriptLine("if(!initialised){ return; }");
            rmTriggerAddScriptLine("for(int i = 0; i < WHEEL_SIZE; i = i + 1){ slotHeadArray[i] = -1; }");
            rmTriggerAddScriptLine("for(int i = 0; i < capacity - 1; i = i + 1){ nextInSlot[i] = i + 1; }");
            rmTriggerAddScriptLine("nextInSlot[capacity - 1] = -1;");
            rmTriggerAddScriptLine("freeHead = 0;");
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("};");
    
    rmTriggerAddScriptLine(className + " " + name + ";");
    
    g_TriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        rmTriggerAddScriptLine(g_TriggerName + ".process();");
    });
}

void createTypedUnitScheduler(string name = "", string[] typeArray = default, int tickMS = 50, int wheelSize = 256){
        
    string className = "UnitScheduler_" + name;
    
    rmTriggerAddScriptLine("class " + className + " {");
        rmTriggerAddScriptLine("bool initialised = false;");
        rmTriggerAddScriptLine("int WHEEL_SIZE = " + wheelSize + ";");
        rmTriggerAddScriptLine("int TICK_MS = " + tickMS + ";");
        rmTriggerAddScriptLine("int currentTick = 0;");
        rmTriggerAddScriptLine("int lastTimeMS = 0;");
        
        rmTriggerAddScriptLine("int[] slotHeadArray = default;");
        
        rmTriggerAddScriptLine("int capacity = 0;");
        rmTriggerAddScriptLine("int freeHead = -1;");
        rmTriggerAddScriptLine("int[] nextInSlot = default;");
        rmTriggerAddScriptLine("int[] lapsArray = default;");
        rmTriggerAddScriptLine("int[] delayTicksArray = default;");
        rmTriggerAddScriptLine("int[] iterationArray = default;");
        rmTriggerAddScriptLine("int[] unitArray = default;");
        rmTriggerAddScriptLine("bool(int, int" + toLambdaTypeList(typeArray, true) + ")[] toRunArray = default;");
        for(int i = 0; i < typeArray.size(); i++){
            rmTriggerAddScriptLine(typeArray[i] + "[] arg" + i + "Array = default;");
        }
        rmTriggerAddScriptLine("");

        rmTriggerAddScriptLine("void initialise(){");
            rmTriggerAddScriptLine("initialised = true;");
            rmTriggerAddScriptLine("slotHeadArray = new int(WHEEL_SIZE, -1);");
            rmTriggerAddScriptLine("capacity = 16;");
            rmTriggerAddScriptLine("nextInSlot = new int(16, -1);");
            rmTriggerAddScriptLine("lapsArray = new int(16, 0);");
            rmTriggerAddScriptLine("delayTicksArray = new int(16, 0);");
            rmTriggerAddScriptLine("iterationArray = new int(16, 0);");
            rmTriggerAddScriptLine("unitArray = new int(16, 0);");
            rmTriggerAddScriptLine("toRunArray = new bool(int, int" + toLambdaTypeList(typeArray, true) + ")(16, [](int unitId = 0, int iteration = 1" + toLambdaArgumentList(typeArray, true) + ") -> bool {return false;});");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array = new " + typeArray[i] + "(16" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            rmTriggerAddScriptLine("for(int i = 0; i < 15; i = i + 1){ nextInSlot[i] = i + 1; }");
            rmTriggerAddScriptLine("nextInSlot[15] = -1;");
            rmTriggerAddScriptLine("freeHead = 0;");
            rmTriggerAddScriptLine("lastTimeMS = xsGetTimeMS();");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");

        rmTriggerAddScriptLine("void growPool(){");
            rmTriggerAddScriptLine("int oldCap = capacity;");
            rmTriggerAddScriptLine("capacity = 2 * capacity;");
            rmTriggerAddScriptLine("nextInSlot.resize(capacity, -1);");
            rmTriggerAddScriptLine("lapsArray.resize(capacity, 0);");
            rmTriggerAddScriptLine("delayTicksArray.resize(capacity, 0);");
            rmTriggerAddScriptLine("iterationArray.resize(capacity, 0);");
            rmTriggerAddScriptLine("unitArray.resize(capacity, 0);");
            rmTriggerAddScriptLine("toRunArray.resize(capacity, [](int unitId = 0, int iteration = 1" + toLambdaArgumentList(typeArray, true) + ") -> bool {return false;});");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array.resize(capacity" + getArrayDefaultValue(typeArray[i]) + ");");
            }
            rmTriggerAddScriptLine("for(int i = oldCap; i < capacity - 1; i = i + 1){ nextInSlot[i] = i + 1; }");
            rmTriggerAddScriptLine("nextInSlot[capacity - 1] = freeHead;");
            rmTriggerAddScriptLine("freeHead = oldCap;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");

        rmTriggerAddScriptLine("void add(int unitId = 0, int delayMS = 0" + toLambdaArgumentList(typeArray, true) + ", bool(int, int" + toLambdaTypeList(typeArray, true) + ") toRun = [](int unitId = 0, int iteration = 1" + toLambdaArgumentList(typeArray, true) + ") -> bool {return false;}){");
            rmTriggerAddScriptLine("if(!initialised){ initialise(); }");
            rmTriggerAddScriptLine("if(freeHead == -1){ growPool(); }");
            
            rmTriggerAddScriptLine("int idx = freeHead;");
            rmTriggerAddScriptLine("freeHead = nextInSlot[idx];");
            
            rmTriggerAddScriptLine("int delayTicks = delayMS / TICK_MS;");
            rmTriggerAddScriptLine("if(delayTicks < 1){ delayTicks = 1; }");
            rmTriggerAddScriptLine("int targetTick = currentTick + delayTicks;");
            rmTriggerAddScriptLine("int slot = targetTick % WHEEL_SIZE;");
            
            rmTriggerAddScriptLine("unitArray[idx] = unitId;");
            rmTriggerAddScriptLine("lapsArray[idx] = (delayTicks - 1) / WHEEL_SIZE;");
            rmTriggerAddScriptLine("delayTicksArray[idx] = delayTicks;");
            rmTriggerAddScriptLine("iterationArray[idx] = 0;");
            rmTriggerAddScriptLine("toRunArray[idx] = toRun;");
            for(int i = 0; i < typeArray.size(); i++){
                rmTriggerAddScriptLine("arg" + i + "Array[idx] = arg" + i + ";");
            }
            
            rmTriggerAddScriptLine("nextInSlot[idx] = slotHeadArray[slot];");
            rmTriggerAddScriptLine("slotHeadArray[slot] = idx;");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");

        rmTriggerAddScriptLine("void process(){");
            rmTriggerAddScriptLine("if(!initialised){ return; }");
            rmTriggerAddScriptLine("int nowMS = xsGetTimeMS();");
            rmTriggerAddScriptLine("int elapsedTicks = (nowMS - lastTimeMS) / TICK_MS;");
            rmTriggerAddScriptLine("if(elapsedTicks <= 0){ return; }");
            
            rmTriggerAddScriptLine("for(int t = 0; t < elapsedTicks; t = t + 1){");
                rmTriggerAddScriptLine("currentTick = currentTick + 1;");
                rmTriggerAddScriptLine("lastTimeMS = lastTimeMS + TICK_MS;");
                rmTriggerAddScriptLine("int slot = currentTick % WHEEL_SIZE;");
                
                rmTriggerAddScriptLine("int prev = -1;");
                rmTriggerAddScriptLine("int curr = slotHeadArray[slot];");
                
                rmTriggerAddScriptLine("while(curr != -1){");
                    rmTriggerAddScriptLine("int nextTask = nextInSlot[curr];");
                    rmTriggerAddScriptLine("if(lapsArray[curr] > 0){");
                        rmTriggerAddScriptLine("lapsArray[curr] = lapsArray[curr] - 1;");
                        rmTriggerAddScriptLine("prev = curr;");
                    rmTriggerAddScriptLine("} else {");
                        rmTriggerAddScriptLine("if(prev == -1){ slotHeadArray[slot] = nextTask; }");
                        rmTriggerAddScriptLine("else { nextInSlot[prev] = nextTask; }");
                        
                        rmTriggerAddScriptLine("int unitId = unitArray[curr];");
                        rmTriggerAddScriptLine("if(kbUnitGetProtoUnitID(unitId) < 0){");
                            rmTriggerAddScriptLine("nextInSlot[curr] = freeHead;");
                            rmTriggerAddScriptLine("freeHead = curr;");
                        rmTriggerAddScriptLine("} else {");
                            rmTriggerAddScriptLine("trUnitSelectClear();");
                            rmTriggerAddScriptLine("trUnitSelectByID(unitId);");
                            rmTriggerAddScriptLine("int iter = iterationArray[curr] + 1;");
                            rmTriggerAddScriptLine("iterationArray[curr] = iter;");
                            for(int i = 0; i < typeArray.size(); i++){
                                rmTriggerAddScriptLine(typeArray[i] + " arg" + i + " = arg" + i + "Array[curr];");
                            }
                            rmTriggerAddScriptLine("bool(int, int" + toLambdaTypeList(typeArray, true) + ") toRun = toRunArray[curr];");
                            
                            rmTriggerAddScriptLine("if(toRun(unitId, iter" + indexStringSequence(", arg", "", typeArray.size()) + ")){");
                                rmTriggerAddScriptLine("int dTicks = delayTicksArray[curr];");
                                rmTriggerAddScriptLine("int nTarget = currentTick + dTicks;");
                                rmTriggerAddScriptLine("int nSlot = nTarget % WHEEL_SIZE;");
                                rmTriggerAddScriptLine("lapsArray[curr] = (dTicks - 1) / WHEEL_SIZE;");
                                rmTriggerAddScriptLine("nextInSlot[curr] = slotHeadArray[nSlot];");
                                rmTriggerAddScriptLine("slotHeadArray[nSlot] = curr;");
                            rmTriggerAddScriptLine("} else {");
                                rmTriggerAddScriptLine("nextInSlot[curr] = freeHead;");
                                rmTriggerAddScriptLine("freeHead = curr;");
                            rmTriggerAddScriptLine("}");
                        rmTriggerAddScriptLine("}");
                    rmTriggerAddScriptLine("}");
                    rmTriggerAddScriptLine("curr = nextTask;");
                rmTriggerAddScriptLine("}");
            rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("}");
        rmTriggerAddScriptLine("");

        rmTriggerAddScriptLine("void cancelAll(){");
            rmTriggerAddScriptLine("if(!initialised){ return; }");
            rmTriggerAddScriptLine("for(int i = 0; i < WHEEL_SIZE; i = i + 1){ slotHeadArray[i] = -1; }");
            rmTriggerAddScriptLine("for(int i = 0; i < capacity - 1; i = i + 1){ nextInSlot[i] = i + 1; }");
            rmTriggerAddScriptLine("nextInSlot[capacity - 1] = -1;");
            rmTriggerAddScriptLine("freeHead = 0;");
        rmTriggerAddScriptLine("}");
    rmTriggerAddScriptLine("};");
    
    rmTriggerAddScriptLine(className + " " + name + ";");
    
    g_TriggerName = name;
    defineTrigger(className + "Trigger", true, true, true, always, []() -> void {
        rmTriggerAddScriptLine(g_TriggerName + ".process();");
    });
}