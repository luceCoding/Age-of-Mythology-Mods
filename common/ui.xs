include "lib/rm_core.xs";

int c = cNumberPlayers;
const int VERTICAL_UI_PIXELS = 1080;
float[] playerScreenRatio = default;
float[] playerScreenIconSizeCompensationValue = default;
const string(int) EMPTY_COUNTER_TEXT = [](int p = 1) -> string { return ""; };

const float SHIFT_SPEED = 0.000001;
const float MAGIC_RATIO_FROM_CALCULATION = 17453.0;
const float DEFAULT_SCREEN_RATIO = 16.0 / 9.0;

const int BINARY_CONVERSION_DIGITS = 17;

bool[] toBinaryBits(int value = 0){
    bool[] binary = new bool(BINARY_CONVERSION_DIGITS, false);
    int toTest = value;
    for(int i = 0; i < BINARY_CONVERSION_DIGITS; i++){
        binary[i] = toTest % 2 == 1;
        toTest = toTest / 2;
    }
    return binary;
}

int fromBinaryBits(ref bool[] binary){
    int value = 0;
    int toAdd = 1;
    for(int i = 0; i < BINARY_CONVERSION_DIGITS; i++){
        if(binary[i]){
            value = value + toAdd;
        }
        toAdd = toAdd * 2;
    }
    return value;
}

void selectSingle(int unitId = -1){
    trUnitSelectClear();
    trUnitSelectByID(unitId);
}

string[] string2Array(string string0 = "", string string1 = ""){
    string[] arrayToMake = new string(2, "");
    arrayToMake[0] = string0;
    arrayToMake[1] = string1;
    return arrayToMake;
}

void cameraLookAt(vector dest = cOriginVector, float distance = 0.0, float heading = 0.0, float tilt = 0.0){
    float cameraH = cPi * heading / 180.0;
    float cameraT = cPi * tilt / 180.0;
    float cameraSinH = sin(cameraH);
    float cameraCosH = cos(cameraH);
    float cameraSinT = sin(cameraT);
    float cameraCosT = cos(cameraT);
    float cameraPosX = 0.0+dest.x-cameraCosH*cameraCosT*distance;
    float cameraPosY = cameraSinT*distance+dest.y;
    float cameraPosZ = 0.0+dest.z-cameraSinH*cameraCosT*distance;
    vector cameraCameraPos = vector(cameraPosX, cameraPosY, cameraPosZ);
    vector cameraCameraMx = vector(cameraCosH*cameraCosT, 0.0-cameraSinT, cameraSinH*cameraCosT);
    vector cameraCameraMy = vector(cameraCosH*cameraSinT, cameraCosT, cameraSinH*cameraSinT);
    vector cameraCameraMz = vector(cameraSinH, 0, 0.0-cameraCosH);
    trCameraCut(cameraCameraPos, cameraCameraMx, cameraCameraMy, cameraCameraMz);
}

class CameraTrack {
    int createIndex = 0;
    int trackIndex = -1;
    bool initialised = false;
    int count = 0;
    int[] timeArray = default;
    vector[] destArray = default;
    float[] distanceArray = default;
    float[] headingArray = default;
    float[] tiltArray = default;
    float[] fovArray = default;
    void initialise(){
        initialised = true;
        timeArray = new int(10, 0);
        destArray = new vector(10, cOriginVector);
        distanceArray = new float(10, 0.0);
        headingArray = new float(10, 0.0);
        tiltArray = new float(10, 0.0);
        fovArray = new float(10, 0.0);
    }
    void addWaypoint(int time = 0, vector dest = cOriginVector, float distance = 0.0, float heading = 0.0, float tilt = 0.0, float fov = 40.0){
        if(!initialised){
            initialise();
        }
        if(count == timeArray.size()){
            timeArray.resize(2 * timeArray.size(), 0);
            destArray.resize(2 * destArray.size(), cOriginVector);
            distanceArray.resize(2 * distanceArray.size(), 0.0);
            headingArray.resize(2 * headingArray.size(), 0.0);
            tiltArray.resize(2 * tiltArray.size(), 0.0);
            fovArray.resize(2 * fovArray.size(), 0.0);
        }
        timeArray[count] = time;
        destArray[count] = dest;
        distanceArray[count] = distance;
        headingArray[count] = heading;
        tiltArray[count] = tilt;
        fovArray[count] = fov;
        count++;
    }
    void create(vector dest = cOriginVector, float distance = 0.0, float heading = 0.0, float tilt = 0.0, float fov = 40.0){
        count = 0;
        addWaypoint(0, dest, distance, heading, tilt, fov);
    }
    void play(bool blend = false, int blendTime = 5000){
        if(!initialised){
            initialise();
        }
        float duration = timeArray[count - 1];
        trackIndex = trCameraTrackCreate("Track_"+createIndex, duration);
        for(int i = 0; i < count; i++){
            float cameraH = cPi * headingArray[i] / 180.0;
            float cameraT = cPi * tiltArray[i] / 180.0;
            float cameraSinH = sin(cameraH);
            float cameraCosH = cos(cameraH);
            float cameraSinT = sin(cameraT);
            float cameraCosT = cos(cameraT);
            vector dest = destArray[i];
            float cameraPosX = 0.0+dest.x-cameraCosH*cameraCosT*distanceArray[i];
            float cameraPosY = cameraSinT*distanceArray[i]+dest.y;
            float cameraPosZ = 0.0+dest.z-cameraSinH*cameraCosT*distanceArray[i];
            vector cameraCameraPos = vector(cameraPosX, cameraPosY, cameraPosZ);
            vector cameraCameraMx = vector(cameraCosH*cameraCosT, 0.0-cameraSinT, cameraSinH*cameraCosT);
            vector cameraCameraMy = vector(cameraCosH*cameraSinT, cameraCosT, cameraSinH*cameraSinT);
            vector cameraCameraMz = vector(cameraSinH, 0, 0.0-cameraCosH);
            int waypointIndex = trCameraTrackAddWaypoint(trackIndex, cameraCameraPos, cameraCameraMx, cameraCameraMy, cameraCameraMz, fovArray[i]);
            trCameraTrackWaypointSetTime(trackIndex, waypointIndex, timeArray[i]);
        }
        trCameraTrackLoad("Track_"+createIndex);
        trCameraTrackPlay(-1, -1, blend, blendTime);
        createIndex++;
    }
};

CameraTrack cameraTrack;

class Parameters {
    bool[] bools = default;
    int[] ints = default;
    float[] floats = default;
    string[] strings = default;
    vector[] vectors = default;
};

const Parameters EMPTY_PARAMETERS;

Parameters createParameters(){
    Parameters parameters;
    return parameters;
}

const string UI_SYSTEM_UNIT = "Crate";
const string UI_SYSTEM_UNIT2 = "CrateSmall";
const float UI_SYSTEM_SMALL_SCALE_MULTIPLIER = 1.355;
const float UI_SYSTEM_LOOK_DISTANCE = 57.0;
const float UI_SYSTEM_OFFSCREEN_Z = 1000.0;
string(int, ref Parameters) EMPTY_DYNAMIC_UI_CONTENT = [](int pToUse = 1, ref Parameters parametersToUse) -> string { return ""; };

int[] uiRelicTechArray = default;

class UiEntry {
    string unitType = "";
    bool clickable = false;
    bool hoverable = false;
    float x = 0.0;
    float y = 0.0;
    float width = 0.0;
    float height = 0.0;
    string(int, ref Parameters) getContent = EMPTY_DYNAMIC_UI_CONTENT;
    string(int, ref Parameters) getRolloverName = EMPTY_DYNAMIC_UI_CONTENT;
    string(int, ref Parameters) getRolloverDescription = EMPTY_DYNAMIC_UI_CONTENT;
    string content = "";
    string rolloverName = "";
    string rolloverDescription = "";
    bool showBackground = false;
    Parameters parameters;
    void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {};
    int[] clickableUnitArray = default;
    int id = -1;
    int rolloverId = -1;
    bool dynamic = false;

    void destroyUnits(int p = 1) {
        for (int i = 0; i < clickableUnitArray.size(); i++) {
            selectSingle(clickableUnitArray[i]);
            trUnitDestroy();
        }
        clickableUnitArray.resize(0, -1);
    }

    void destroyPrompt(int p = 1, int page = 0) {
        if (trCurrentPlayer() == p) {
            trWorldSpacePromptHide("UiSystem" + id + "Page" + page);
        }
    }

    void show(int p = 1, vector lookAt = cOriginVector, vector xAxisDirection = cOriginVector, vector yAxisDirection = cOriginVector, float lookAtHeading = 0.0, float lookAtTilt = 0.0, int page = 0, bool fakeShow = false, bool debug = false, bool disableClick = false, vector cameraPosition = cOriginVector) {
        if (dynamic) {
            content = getContent(p, parameters);
        }
        string adjustedContent = (showBackground && content != "") ? content : ("<icon=(1,10000)(0)>\n" + content);
        if (fakeShow) {
            if (trCurrentPlayer() == p && adjustedContent != "") {
                trWorldSpacePromptArea("UiSystem" + id + "Page" + page, lookAt + xAxisDirection * x + yAxisDirection * (y + UI_SYSTEM_OFFSCREEN_Z), adjustedContent, cOriginVector, showBackground);
            }
            return;
        }
        if (trCurrentPlayer() == p && adjustedContent != "") {
            vector promptLocation = lookAt + xAxisDirection * x + yAxisDirection * y;
            vector directionVector = xsVectorNormalize(promptLocation - cameraPosition);
            trWorldSpacePromptArea("UiSystem" + id + "Page" + page, cameraPosition + directionVector * 100000000.0, adjustedContent, cOriginVector, showBackground);
        }
        if (hoverable) {
            trTechHideEffects(uiRelicTechArray[rolloverId], p, true);
            if (dynamic) {
                rolloverName = getRolloverName(p, parameters);
            }
            trTechSetStringID(uiRelicTechArray[rolloverId], p, rolloverName + "<color=0,0,0>", cXSTechEffectDisplayName);
            if (dynamic) {
                rolloverDescription = getRolloverDescription(p, parameters);
            }
            trTechSetStringID(uiRelicTechArray[rolloverId], p, "</color>\n" + rolloverDescription, cXSTechEffectRollover);
        }
        if (clickable || hoverable) {
            vector pos = lookAt + xAxisDirection * x + yAxisDirection * (y + height / 2.0);
            int unit = trUnitCreateForced(unitType, pos.x, pos.y, pos.z, 0, p);
            selectSingle(unit);
            if (!debug) {
                trUnitChangeProtoUnit(unitType, false, true);
                trUnitSetShading(3, 1000.0);
            }
            if (hoverable) {
                trUnitSetScale(UI_SYSTEM_SMALL_SCALE_MULTIPLIER * height, 0.001, UI_SYSTEM_SMALL_SCALE_MULTIPLIER * width);
            } else {
                trUnitSetScale(height, 0.001, width);
            }
            trUnitRotateZ(lookAtTilt - 90, true);
            trUnitRotateY(-lookAtHeading - 180, true);
            if (!clickable || disableClick) {
                trUnitSetFlag(cUnitFlagIsUnbuilding, true);
            }
            trRelicForce(unit, hoverable ? kbTechGetName(uiRelicTechArray[rolloverId]) : "");
            clickableUnitArray.add(unit);
        }
    }

    void refresh(int p = 1, vector lookAt = cOriginVector, vector xAxisDirection = cOriginVector, vector yAxisDirection = cOriginVector, float lookAtHeading = 0.0, float lookAtTilt = 0.0, bool debug = false, bool disableClick = false) {
        for (int i = 0; i < clickableUnitArray.size(); i++) {
            selectSingle(clickableUnitArray[i]);
            trUnitDestroy();
        }
        clickableUnitArray.resize(0, -1);
        if (clickable || hoverable) {
            vector pos = lookAt + xAxisDirection * x + yAxisDirection * (y + height / 2.0);
            int unit = trUnitCreateForced(unitType, pos.x, pos.y, pos.z, 0, p);
            selectSingle(unit);
            if (!debug) {
                trUnitChangeProtoUnit(unitType, false, true);
                trUnitSetShading(3, 1000.0);
            }
            if (hoverable) {
                trUnitSetScale(UI_SYSTEM_SMALL_SCALE_MULTIPLIER * height, 0.001, UI_SYSTEM_SMALL_SCALE_MULTIPLIER * width);
            } else {
                trUnitSetScale(height, 0.001, width);
            }
            trUnitRotateZ(lookAtTilt - 90, true);
            trUnitRotateY(-lookAtHeading - 180, true);
            if (!clickable || disableClick) {
                trUnitSetFlag(cUnitFlagIsUnbuilding, true);
            }
            trRelicForce(unit, hoverable ? kbTechGetName(uiRelicTechArray[rolloverId]) : "");
            clickableUnitArray.add(unit);
        }
    }

    bool dynamicUpdate(int p = 1, vector lookAt = cOriginVector, vector xAxisDirection = cOriginVector, vector yAxisDirection = cOriginVector, float lookAtHeading = 0.0, float lookAtTilt = 0.0, int page = 0, vector cameraPosition = cOriginVector) {
        if (dynamic == false) {
            return false;
        }
        string newContent = getContent(p, parameters);
        if (newContent != content) {
            content = newContent;
            string adjustedContent = (showBackground && content != "") ? content : ("<icon=(1,10000)(0)>\n" + content);
            if (trCurrentPlayer() == p) {
                if (adjustedContent != "") {
                    vector promptLocation = lookAt + xAxisDirection * x + yAxisDirection * y;
                    vector directionVector = xsVectorNormalize(promptLocation - cameraPosition);
                    trWorldSpacePromptArea("UiSystem" + id + "Page" + page, cameraPosition + directionVector * 100000000.0, adjustedContent, cOriginVector, showBackground);
                } else {
                    trWorldSpacePromptHide("UiSystem" + id + "Page" + page);
                }
            }
        }
        if (hoverable) {
            string newRolloverName = getRolloverName(p, parameters);
            if (newRolloverName != rolloverName) {
                rolloverName = newRolloverName;
                trTechSetStringID(uiRelicTechArray[rolloverId], p, rolloverName + "<color=0,0,0>", cXSTechEffectDisplayName);
            }
            string newRolloverDescription = getRolloverDescription(p, parameters);
            if (newRolloverDescription != rolloverDescription) {
                rolloverDescription = newRolloverDescription;
                trTechSetStringID(uiRelicTechArray[rolloverId], p, "</color>\n" + rolloverDescription, cXSTechEffectRollover);
            }
        }
        return true;
    }
};

UiEntry DUMMY_ENTRY;

class UiSystemPage {
    int page = 0;
    int realShow = -1;
    int delayDestroy = -1;
    UiEntry[] uiEntryArray = default;
    
    bool process(int p = 1, vector lookAt = cOriginVector, vector xAxisDirection = cOriginVector, vector yAxisDirection = cOriginVector, float lookAtHeading = 0.0, float lookAtTilt = 0.0, 
            bool debug = false, bool disableClick = false, vector cameraPosition = cOriginVector){
        bool isShowingToReturn = false;
        if(realShow >= 0 && xsGetTimeMS() > realShow){
            isShowingToReturn = true;
            realShow = -1;
            for(int i = 0; i < uiEntryArray.size(); i++){
                UiEntry entry = uiEntryArray[i];
                entry.show(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, page, false, debug, disableClick, cameraPosition);
            }
        }
        if(delayDestroy >= 0 && xsGetTimeMS() > delayDestroy){
            delayDestroy = -1;
            for(int i = 0; i < uiEntryArray.size(); i++){
                UiEntry entry = uiEntryArray[i];
                entry.destroyPrompt(p, page);
            }
            uiEntryArray.resize(0);
        }
        return isShowingToReturn;
    }
    
    void requestDestroy(int p = 1, bool fromExit = false){
        for(int i = 0; i < uiEntryArray.size(); i++){
            UiEntry entry = uiEntryArray[i];
            entry.destroyUnits(p);
            if(fromExit){
                entry.destroyPrompt(p, page);
            }
        }
        if(fromExit){
            realShow = -1;
        } else {
            delayDestroy = xsGetTimeMS();
        }
    }
    
    void dynamicUpdate(int p = 1, vector lookAt = cOriginVector, vector xAxisDirection = cOriginVector, vector yAxisDirection = cOriginVector, float lookAtHeading = 0.0, float lookAtTilt = 0.0, 
            vector cameraPosition = cOriginVector){
        for(int i = 0; i < uiEntryArray.size(); i++){
            UiEntry entry = uiEntryArray[i];
            if(entry.dynamicUpdate(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, page, cameraPosition)){
                uiEntryArray[i] = entry;
            }
        }
    }
};

class UiSystem {
    int p = 1;
    bool debug = false;
    vector lookAt = cOriginVector;
    vector lookAtForCamera = cOriginVector;
    vector cameraPosition = cOriginVector;
    float lookAtDistance = UI_SYSTEM_LOOK_DISTANCE;
    float lookAtHeading = 90.0;
    float lookAtTilt = 90.0;
    float lookAtFov = 1.0;
    vector xAxisDirection = vector(1.0, 0.0, 0.0);
    vector yAxisDirection = vector(0.0, 0.0, 1.0);
    bool uiActive = false;
    bool disableClick = false;
    int[] deletableFlagsToRevert = default;
    bool[] selectableFlagsToRevert = default;
    int rolloverCount = 0;
    UiSystemPage page0;
    UiSystemPage page1;
    UiSystemPage page2;
    int addPage = 0;
    int showingPage = 0;
    bool staticView = false;
    int checkDynamicFrequency = -1;
    int checkDynamicLastTime = -1;
    
    void initialise(int pToUse = 1, bool debugToUse = false){
        p = pToUse;
        debug = debugToUse;
        page0.page = 0;
        page1.page = 1;
        page2.page = 2;
    }
    
    void setCameraPosition(vector dest = cOriginVector, float distance = 0.0, float heading = 0.0, float tilt = 0.0, float fov = 40.0){
        lookAtForCamera = dest;
        lookAtDistance = distance;
        lookAtHeading = heading;
        lookAtTilt = tilt;
        lookAtFov = fov;
        float cameraH = degToRad(heading);
        float cameraT = degToRad(tilt);
        float cameraSinH = sin(cameraH);
        float cameraCosH = cos(cameraH);
        float cameraSinT = sin(cameraT);
        float cameraCosT = cos(cameraT);
        float cameraPosX = 0.0+dest.x-cameraCosH*cameraCosT*distance;
        float cameraPosY = cameraSinT*distance+dest.y;
        float cameraPosZ = 0.0+dest.z-cameraSinH*cameraCosT*distance;
        cameraPosition = vector(cameraPosX, cameraPosY, cameraPosZ);
        float canvasDistance = (tan(degToRad(0.5)) * UI_SYSTEM_LOOK_DISTANCE) / tan(degToRad(0.5 * fov));
        float canvasDistanceFromLookPoint = -canvasDistance + distance;
        float canvasPosX = 0.0+dest.x-cameraCosH*cameraCosT*canvasDistanceFromLookPoint;
        float canvasPosY = cameraSinT*canvasDistanceFromLookPoint+dest.y;
        float canvasPosZ = 0.0+dest.z-cameraSinH*cameraCosT*canvasDistanceFromLookPoint;
        lookAt = vector(canvasPosX, canvasPosY, canvasPosZ);
        xAxisDirection = vector(cameraSinH, 0.0, -cameraCosH);
        yAxisDirection = vector(cameraSinT * cameraCosH, cameraCosT, cameraSinT * cameraSinH);
        if(uiActive && trCurrentPlayer() == p){
            cameraTrack.create(lookAtForCamera, lookAtDistance, lookAtHeading, lookAtTilt, lookAtFov);
            cameraTrack.addWaypoint(1000000000, lookAtForCamera, lookAtDistance, lookAtHeading, lookAtTilt, lookAtFov);
            cameraTrack.play();
        }
    }
    
    void enter(bool disableClickToUse = false, bool staticViewToUse = false, int checkDynamicFrequencyToUse = -1){
        staticView = staticViewToUse;
        checkDynamicFrequency = checkDynamicFrequencyToUse;
        checkDynamicLastTime = xsGetTimeMS();
        if(uiActive == false){
            uiActive = true;
            for(int i = 0; i < cNumberProtoUnits; i++){
                bool deletable = kbPlayerGetProtoStatFlag(p, i, cProtoUnitFlagDeleteable);
                if(deletable){
                    deletableFlagsToRevert.add(i);
                    trProtoUnitSetFlag(p, kbProtoUnitGetName(i), "Deleteable", false);
                }
            }
            if(trCurrentPlayer() == p){
                selectableFlagsToRevert.resize(cNumberProtoUnits * (cNumberPlayers + 1), false);
                int offset = 0;
                for(int q = 0; q <= cNumberPlayers; q++){
                    for(int i = 0; i < cNumberProtoUnits; i++){
                        bool selectable = kbPlayerGetProtoStatFlag(q, i, cProtoUnitFlagSelectable);
                        selectableFlagsToRevert[i + offset] = selectable;
                        if(selectable){
                            trProtoUnitSetFlag(q, kbProtoUnitGetName(i), "Selectable", false);
                        }
                    }
                    offset = offset + cNumberProtoUnits;
                }
            }
            trProtoUnitSetFlag(p, UI_SYSTEM_UNIT, "Deleteable", true);
            trProtoUnitSetFlag(p, UI_SYSTEM_UNIT2, "Deleteable", true);
            trProtoUnitSetFlag(p, UI_SYSTEM_UNIT, "Selectable", true);
            trProtoUnitSetFlag(p, UI_SYSTEM_UNIT2, "Selectable", true);
            int tempToSelect = trUnitCreateForced(UI_SYSTEM_UNIT, lookAt.x, lookAt.y, lookAt.z, 0, p);
            selectSingle(tempToSelect);
            if (trCurrentPlayer() == p){
                trUnitGameSelect(true);
            }
            trUnitDestroy();
            if(trCurrentPlayer() == p){
                cameraTrack.create(lookAtForCamera, lookAtDistance, lookAtHeading, lookAtTilt, lookAtFov);
                cameraTrack.addWaypoint(1000000000, lookAtForCamera, lookAtDistance, lookAtHeading, lookAtTilt, lookAtFov);
                cameraTrack.play();
            }
        }
        disableClick = disableClickToUse;
        if(showingPage == 0) {
            page0.requestDestroy(p, false);
        } else if(showingPage == 1) {
            page1.requestDestroy(p, false);
        } else {
            page2.requestDestroy(p, false);
        }
        rolloverCount = 0;
        if(addPage == 0){
            addPage = 1;
            page1.realShow = xsGetTimeMS();
        } else if(addPage == 1) {
            addPage = 2;
            page2.realShow = xsGetTimeMS();
        } else {
            addPage = 0;
            page0.realShow = xsGetTimeMS();
        }
    }
    
    void exit(bool normaliseCamera = false, float fov = 40.0){
        if(uiActive == true){
            uiActive = false;
            int tempToSelect = trUnitCreateForced(UI_SYSTEM_UNIT, lookAt.x, lookAt.y, lookAt.z, 0, p);
            selectSingle(tempToSelect);
            if (trCurrentPlayer() == p){
                trUnitGameSelect(true);
            }
            trUnitDestroy();
            for(int i = 0; i < deletableFlagsToRevert.size(); i++){
                trProtoUnitSetFlag(p, kbProtoUnitGetName(deletableFlagsToRevert[i]), "Deleteable", true);
            }
            deletableFlagsToRevert.clear();
            if(trCurrentPlayer() == p){
                int offset = 0;
                for(int q = 0; q <= cNumberPlayers; q++){
                    for(int i = 0; i < cNumberProtoUnits; i++){
                        bool selectable = selectableFlagsToRevert[i + offset];
                        if(selectable){
                            trProtoUnitSetFlag(q, kbProtoUnitGetName(i), "Selectable", true);
                        }
                    }
                    offset = offset + cNumberProtoUnits;
                }
                selectableFlagsToRevert.clear();
            }
            if(trCurrentPlayer() == p){
                if(normaliseCamera){
                    cameraTrack.create(lookAtForCamera, lookAtDistance, lookAtHeading, lookAtTilt, fov);
                    cameraTrack.addWaypoint(1, lookAtForCamera, lookAtDistance, lookAtHeading, lookAtTilt, fov);
                    cameraTrack.play(true, 0);
                }
            }
            page0.requestDestroy(p, true);
            page1.requestDestroy(p, true);
            page2.requestDestroy(p, true);
        }
    }
    
    void addDisplay(float x = 0.0, float y = 0.0, string content = "", bool showBackground = false){
        UiEntry entry;
        entry.unitType = UI_SYSTEM_UNIT;
        entry.clickable = false;
        entry.hoverable = false;
        entry.x = x;
        entry.y = y;
        entry.content = content;
        entry.showBackground = showBackground;
        if(addPage == 0){
            entry.id = page0.uiEntryArray.size();
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.size();
        } else {
            entry.id = page2.uiEntryArray.size();
        }
        entry.show(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, addPage, true, debug, disableClick, cameraPosition);
        if(addPage == 0){
            entry.id = page0.uiEntryArray.add(entry);
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.add(entry);
        } else {
            entry.id = page2.uiEntryArray.add(entry);
        }
    }
    
    void addDisplayWithHover(float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", string rolloverName = "", string rolloverDescription = "", bool showBackground = false){
        UiEntry entry;
        entry.unitType = UI_SYSTEM_UNIT2;
        entry.clickable = false;
        entry.hoverable = true;
        entry.x = x;
        entry.y = y;
        entry.width = width;
        entry.height = height;
        entry.content = content;
        entry.rolloverName = rolloverName;
        entry.rolloverDescription = rolloverDescription;
        entry.showBackground = showBackground;
        if(addPage == 0){
            entry.id = page0.uiEntryArray.size();
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.size();
        } else {
            entry.id = page2.uiEntryArray.size();
        }
        entry.rolloverId = rolloverCount;
        rolloverCount++;
        entry.show(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, addPage, true, debug, disableClick, cameraPosition);
        if(addPage == 0){
            entry.id = page0.uiEntryArray.add(entry);
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.add(entry);
        } else {
            entry.id = page2.uiEntryArray.add(entry);
        }
    }
    
    void addClickable(float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", ref Parameters parameters, 
            void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {}, bool showBackground = false){
        UiEntry entry;
        entry.unitType = UI_SYSTEM_UNIT;
        entry.clickable = true;
        entry.hoverable = false;
        entry.x = x;
        entry.y = y;
        entry.width = width;
        entry.height = height;
        entry.content = content;
        if(addPage == 0){
            entry.id = page0.uiEntryArray.size();
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.size();
        } else {
            entry.id = page2.uiEntryArray.size();
        }
        entry.parameters = parameters;
        entry.handler = handler;
        entry.showBackground = showBackground;
        entry.show(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, addPage, true, debug, disableClick, cameraPosition);
        if(addPage == 0){
            entry.id = page0.uiEntryArray.add(entry);
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.add(entry);
        } else {
            entry.id = page2.uiEntryArray.add(entry);
        }
    }
    
    void addClickableWithHover(float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", string rolloverName = "", string rolloverDescription = "", ref Parameters parameters, 
            void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {}, bool showBackground = false){
        UiEntry entry;
        entry.unitType = UI_SYSTEM_UNIT2;
        entry.clickable = true;
        entry.hoverable = true;
        entry.x = x;
        entry.y = y;
        entry.width = width;
        entry.height = height;
        entry.content = content;
        entry.rolloverName = rolloverName;
        entry.rolloverDescription = rolloverDescription;
        entry.parameters = parameters;
        entry.handler = handler;
        entry.showBackground = showBackground;
        if(addPage == 0){
            entry.id = page0.uiEntryArray.size();
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.size();
        } else {
            entry.id = page2.uiEntryArray.size();
        }
        entry.rolloverId = rolloverCount;
        rolloverCount++;
        entry.show(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, addPage, true, debug, disableClick, cameraPosition);
        if(addPage == 0){
            entry.id = page0.uiEntryArray.add(entry);
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.add(entry);
        } else {
            entry.id = page2.uiEntryArray.add(entry);
        }
    }
    
    void addDisplayDynamic(float x = 0.0, float y = 0.0, string(int, ref Parameters) getContent = EMPTY_DYNAMIC_UI_CONTENT, ref Parameters parameters, bool showBackground = false){
        UiEntry entry;
        entry.dynamic = true;
        entry.unitType = UI_SYSTEM_UNIT;
        entry.clickable = false;
        entry.hoverable = false;
        entry.x = x;
        entry.y = y;
        entry.getContent = getContent;
        entry.parameters = parameters;
        entry.showBackground = showBackground;
        if(addPage == 0){
            entry.id = page0.uiEntryArray.size();
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.size();
        } else {
            entry.id = page2.uiEntryArray.size();
        }
        entry.show(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, addPage, true, debug, disableClick, cameraPosition);
        if(addPage == 0){
            entry.id = page0.uiEntryArray.add(entry);
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.add(entry);
        } else {
            entry.id = page2.uiEntryArray.add(entry);
        }
    }
    
    void addDisplayWithHoverDynamic(float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string(int, ref Parameters) getContent = EMPTY_DYNAMIC_UI_CONTENT, 
            string(int, ref Parameters) getRolloverName = EMPTY_DYNAMIC_UI_CONTENT, string(int, ref Parameters) getRolloverDescription = EMPTY_DYNAMIC_UI_CONTENT, ref Parameters parameters, bool showBackground = false){
        UiEntry entry;
        entry.dynamic = true;
        entry.unitType = UI_SYSTEM_UNIT2;
        entry.clickable = false;
        entry.hoverable = true;
        entry.x = x;
        entry.y = y;
        entry.width = width;
        entry.height = height;
        entry.getContent = getContent;
        entry.getRolloverName = getRolloverName;
        entry.getRolloverDescription = getRolloverDescription;
        entry.parameters = parameters;
        entry.showBackground = showBackground;
        if(addPage == 0){
            entry.id = page0.uiEntryArray.size();
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.size();
        } else {
            entry.id = page2.uiEntryArray.size();
        }
        entry.rolloverId = rolloverCount;
        rolloverCount++;
        entry.show(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, addPage, true, debug, disableClick, cameraPosition);
        if(addPage == 0){
            entry.id = page0.uiEntryArray.add(entry);
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.add(entry);
        } else {
            entry.id = page2.uiEntryArray.add(entry);
        }
    }
    
    void addClickableDynamic(float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string(int, ref Parameters) getContent = EMPTY_DYNAMIC_UI_CONTENT, ref Parameters parameters, 
            void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {}, bool showBackground = false){
        UiEntry entry;
        entry.dynamic = true;
        entry.unitType = UI_SYSTEM_UNIT;
        entry.clickable = true;
        entry.hoverable = false;
        entry.x = x;
        entry.y = y;
        entry.width = width;
        entry.height = height;
        entry.getContent = getContent;
        if(addPage == 0){
            entry.id = page0.uiEntryArray.size();
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.size();
        } else {
            entry.id = page2.uiEntryArray.size();
        }
        entry.parameters = parameters;
        entry.handler = handler;
        entry.showBackground = showBackground;
        entry.show(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, addPage, true, debug, disableClick, cameraPosition);
        if(addPage == 0){
            entry.id = page0.uiEntryArray.add(entry);
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.add(entry);
        } else {
            entry.id = page2.uiEntryArray.add(entry);
        }
    }
    
    void addClickableWithHoverDynamic(float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string(int, ref Parameters) getContent = EMPTY_DYNAMIC_UI_CONTENT, 
            string(int, ref Parameters) getRolloverName = EMPTY_DYNAMIC_UI_CONTENT, string(int, ref Parameters) getRolloverDescription = EMPTY_DYNAMIC_UI_CONTENT, ref Parameters parameters, 
            void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {}, bool showBackground = false){
        UiEntry entry;
        entry.dynamic = true;
        entry.unitType = UI_SYSTEM_UNIT2;
        entry.clickable = true;
        entry.hoverable = true;
        entry.x = x;
        entry.y = y;
        entry.width = width;
        entry.height = height;
        entry.getContent = getContent;
        entry.getRolloverName = getRolloverName;
        entry.getRolloverDescription = getRolloverDescription;
        entry.parameters = parameters;
        entry.handler = handler;
        entry.showBackground = showBackground;
        if(addPage == 0){
            entry.id = page0.uiEntryArray.size();
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.size();
        } else {
            entry.id = page2.uiEntryArray.size();
        }
        entry.rolloverId = rolloverCount;
        rolloverCount++;
        entry.show(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, addPage, true, debug, disableClick, cameraPosition);
        if(addPage == 0){
            entry.id = page0.uiEntryArray.add(entry);
        } else if(addPage == 1) {
            entry.id = page1.uiEntryArray.add(entry);
        } else {
            entry.id = page2.uiEntryArray.add(entry);
        }
    }
    
    UiEntry process(){
        if(page0.process(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, debug, disableClick, cameraPosition)){
            showingPage = 0;
        }
        if(page1.process(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, debug, disableClick, cameraPosition)){
            showingPage = 1;
        }
        if(page2.process(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, debug, disableClick, cameraPosition)){
            showingPage = 2;
        }
        if(uiActive){
            int clickedEntryIndex = -1;
            bool validClick = true;
            UiEntry[] uiEntryArray = showingPage == 0 ? page0.uiEntryArray : (showingPage == 1 ? page1.uiEntryArray : page2.uiEntryArray);
            for(int i = 0; i < uiEntryArray.size(); i++){
                UiEntry entry = uiEntryArray[i];
                int[] clickableUnitArray = entry.clickableUnitArray;
                for(int j = 0; j < clickableUnitArray.size(); j++){
                    selectSingle(clickableUnitArray[j]);
                    if(trUnitAlive() == false){
                        if(clickedEntryIndex == -1){
                            clickedEntryIndex = i;
                        } else if(clickedEntryIndex != i){
                            validClick = false;
                        }
                    }
                }
            }
            if(validClick == false){
                for(int i = 0; i < uiEntryArray.size(); i++){
                    UiEntry entry = uiEntryArray[i];
                    entry.refresh(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, debug, disableClick);
                    uiEntryArray[i] = entry;
                }
            } else if(clickedEntryIndex >= 0){
                if(staticView){
                    // Force update next frame
                    checkDynamicLastTime = xsGetTimeMS() - checkDynamicFrequency;
                    for(int i = 0; i < uiEntryArray.size(); i++){
                        UiEntry entry = uiEntryArray[i];
                        entry.refresh(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, debug, disableClick);
                        uiEntryArray[i] = entry;
                    }
                } else {
                    if(showingPage == 0) {
                        page0.requestDestroy(p, false);
                    } else if(showingPage == 1) {
                        page1.requestDestroy(p, false);
                    } else {
                        page2.requestDestroy(p, false);
                    }
                }
                rolloverCount = 0;
                UiEntry entry = uiEntryArray[clickedEntryIndex];
                return entry;
            }
            if(validClick == false || clickedEntryIndex < 0){
                int currentTime = xsGetTimeMS();
                if(checkDynamicFrequency >= 0 && currentTime >= checkDynamicLastTime + checkDynamicFrequency){
                    checkDynamicLastTime = currentTime;
                    if(showingPage == 0) {
                        page0.dynamicUpdate(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, cameraPosition);
                    } else if(showingPage == 1) {
                        page1.dynamicUpdate(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, cameraPosition);
                    } else {
                        page2.dynamicUpdate(p, lookAt, xAxisDirection, yAxisDirection, lookAtHeading, lookAtTilt, cameraPosition);
                    }
                }
            }
            if(trCurrentPlayer() == p && (trUnitTypeIsSelected(UI_SYSTEM_UNIT, true) || trUnitTypeIsSelected(UI_SYSTEM_UNIT2, true))){
                trExecuteConsoleCommand("uiDeleteSelectedUnit(true)");
            }
        }
        return DUMMY_ENTRY;
    }
};

UiSystem[] uiSystemArray = default;

void initialiseUiSystem(bool debug = false){
    for(int i = 0; i < cNumberTechs; i++){
        string tech = kbTechGetName(i);
        if(xsStringStartsWith(tech, "Relic", true) && xsStringEndsWith(tech, "Respawn", true) == false){
            uiRelicTechArray.add(i);
        }
    }
    uiSystemArray.resize(cNumberPlayers + 1);
    string[] systemUnits = string2Array(UI_SYSTEM_UNIT, UI_SYSTEM_UNIT2);
    for(int p = 1; p <= cNumberPlayers; p++){
        UiSystem uiSystem = uiSystemArray[p];
        uiSystem.initialise(p, debug);
        uiSystem.setCameraPosition(vector(0.5 * kbGetMapXSize(), -10100.0, 0.5 * kbGetMapZSize()), 100.0, 45.0, 89.0, 40.0);
        uiSystemArray[p] = uiSystem;
        for(int i_systemUnits = 0; i_systemUnits < systemUnits.size(); i_systemUnits++){
            string systemUnit = systemUnits[i_systemUnits];
            trProtoUnitSetFlag(p, systemUnit, "Collideable", false);
            trProtoUnitSetFlag(p, systemUnit, "ForceDeleteable", true);
            trProtoUnitSetFlag(p, systemUnit, "Invulnerable", true);
            trProtoUnitSetFlag(p, systemUnit, "InvulnerableToAreaDamage", true);
            trProtoUnitSetFlag(p, systemUnit, "DontMarkExtraFog", true);
            trProtoUnitSetFlag(p, systemUnit, "VisibleUnderFog", true);
            trProtoUnitSetFlag(p, systemUnit, "ForceToNature", false);
            trProtoUnitSetFlag(p, systemUnit, "TieToGround", false);
            trProtoUnitSetFlag(p, systemUnit, "Selectable", true);
            trProtoUnitSetFlag(p, systemUnit, "Deleteable", true);
            trProtoUnitSetFlag(p, systemUnit, "FadeInOnBuild", !debug);
            trProtoUnitSetFlag(p, systemUnit, "HasLOS", true);
            trProtoUnitSetFlag(p, systemUnit, "ObscuredByUnits", true);
            trProtoUnitSetUnitType(p, systemUnit, "Building", true);
            if(p != trCurrentPlayer()){
                trProtoUnitSetFlag(p, systemUnit, "OnlyInEditor", true);
            }
            trModifyProtounitData(systemUnit, p, cXSProtoEffectBuildPoints, 100000, cXSRelativityAssign);
            trModifyProtounitData(systemUnit, p, cXSProtoEffectLOS, debug ? 5.0 : 0.0, cXSRelativityAssign);
        }
        trProtoUnitSetFlag(p, UI_SYSTEM_UNIT2, "Relic", true);
    }
}

string displayCompensatedIcon(int width = 1, int height = 1, string icon = "0"){
    float compensationValue = playerScreenIconSizeCompensationValue[trCurrentPlayer()];
    int correctedWidth = round(compensationValue * width);
    int correctedHeight = round(compensationValue * height);
    return "<icon=("+correctedWidth+","+correctedHeight+")("+icon+")>";
}

string minimapSafeSuffix(float posY = 0.0){
    return "\n" + displayCompensatedIcon(1, xsFloatToInt(round((posY + 0.5) * VERTICAL_UI_PIXELS)));
}

void minimapSafeDisplay(ref UiSystem system, float x = 0.0, float y = 0.0, string content = ""){
    system.addDisplay(x, -0.5, content + minimapSafeSuffix(y));
}

void minimapSafeDisplayWithHover(ref UiSystem system, float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", string rolloverName = "", string rolloverDescription = ""){
    minimapSafeDisplay(system, x, y, content);
    system.addDisplayWithHover(x, y, width, height, "", rolloverName, rolloverDescription);
}

void minimapSafeClickable(ref UiSystem system, float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", ref Parameters parameters, 
            void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {}){
    minimapSafeDisplay(system, x, y, content);
    system.addClickable(x, y, width, height, "", parameters, handler);
}

void minimapSafeClickableWithHover(ref UiSystem system, float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", string rolloverName = "", string rolloverDescription = "", ref Parameters parameters, 
            void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {}){
    minimapSafeDisplay(system, x, y, content);
    system.addClickableWithHover(x, y, width, height, "", rolloverName, rolloverDescription, parameters, handler);
}

void setUiVisible(bool visible = true){
    if(visible){
        trExecuteConsoleCommand("gadgetReal(AGameMinimap)");
    } else {
        trExecuteConsoleCommand("gadgetUnreal(AGameMinimap)");
    }
    for(int i = 0; i <= 6; i++){
        trUIPanelVisibility(i, visible);
    }
}

string getIconPathFormat(string iconPath = "", int size = 128){
    return displayCompensatedIcon(size, size, iconPath);
}

void postRatioCalculation(){
    cameraTrack.create(vector(10, 4, 10), 50, 45, 45);
    cameraTrack.addWaypoint(1, vector(10, 4, 10), 50, 45, 45);
    cameraTrack.play(true, 0);
    setUiVisible(true);
    trSetObscuredUnits(true);
}

void performProportionCalculation(){
    setUiVisible(false);
    cameraTrack.create(vector(0.5 * kbGetMapXSize(), -999.0, 0.5 * kbGetMapZSize()), 1.0, 90.0, 90.0, 1.0);
    cameraTrack.addWaypoint(100000, vector(0.5 * kbGetMapXSize(), -999.0, 0.5 * kbGetMapZSize()), 1.0, 90.0, 90.0, 1.0);
    cameraTrack.play();
    scheduler.add(2000, [](int iterations = 1) -> bool {
        float startX = 0.5 * kbGetMapXSize();
        float posZ = 0.5 * kbGetMapZSize();
        IntUnitDeletionTracker tracker;
        for(int p = 1; p <= c; p++){
            trPlayerModifyLOS(p, true, 0);
        }
        trProtoUnitSetFlag(0, UI_SYSTEM_UNIT, "VisibleUnderFog", true);
        int objectToSee = trUnitCreateForced(UI_SYSTEM_UNIT, startX, -1000.0, posZ, 0, 0, true);
        selectSingle(objectToSee);
        trUnitSetScale(0.0, 0.0, 0.0);
        int lastVisible = 0;
        for(int i = 1; i <= 100000; i++){
            trUnitReposition(startX + SHIFT_SPEED * i, -1000.0, posZ, true, true);
            if(trUnitVisibleToPlayer()){
                lastVisible = i;
            }
        }
        trUnitDestroy();
        trProtoUnitSetFlag(0, UI_SYSTEM_UNIT, "VisibleUnderFog", false);
        for(int p = 1; p <= c; p++){
            trPlayerModifyLOS(p, false, 0);
        }
        for(int p = 1; p <= c; p++){
            int controlUnitId = trUnitCreateForced(UI_SYSTEM_UNIT, 0.5 * kbGetMapXSize(), 0.0, 0.5 * kbGetMapZSize(), 0, p);
            tracker.controlUnits.add(controlUnitId);
            for(int i = 0; i < BINARY_CONVERSION_DIGITS; i++){
                int unitId = trUnitCreateForced(UI_SYSTEM_UNIT, 0.5 * kbGetMapXSize(), 0.0, 0.5 * kbGetMapZSize(), 0, p);
                tracker.units.add(unitId);
            }
            trUnitSelectClear();
            if(p == trCurrentPlayer()){
                trUnitSelectByID(tracker.controlUnits[p - 1]);
                bool[] binary = toBinaryBits(lastVisible);
                for(int i = 0; i < BINARY_CONVERSION_DIGITS; i++){
                    if(binary[i]){
                        trUnitSelectByID(tracker.units[i + (p - 1) * BINARY_CONVERSION_DIGITS]);
                    }
                }
                trUnitGameSelect(true);
                trUnitSelectClear();
                trExecuteConsoleCommand("uiDeleteSelectedUnit(true)");
            }
        }
        schedulerWithIntUnitDeletionTracker.add(0, tracker, [](int iteration = 0, ref IntUnitDeletionTracker tracker) -> bool {
            int[] controlUnits = tracker.controlUnits;
            int[] units = tracker.units;
            for(int p = 1; p <= c; p++){
                selectSingle(controlUnits[p - 1]);
                if(trUnitAlive() && trPlayerIsDefeatedOrResigned(p) == false && kbPlayerIsHuman(p)){
                    return true;
                }
            }
            playerScreenRatio.resize((c+1), 0.0);
            playerScreenIconSizeCompensationValue.resize((c+1), 0.0);
            for(int p = 1; p <= c; p++){
                if(trPlayerIsDefeatedOrResigned(p) || kbPlayerIsHuman(p) == false){
                    playerScreenRatio[p] = DEFAULT_SCREEN_RATIO;
                    playerScreenIconSizeCompensationValue[p] = 1.0;
                } else {
                    bool[] binaryBits = new bool(BINARY_CONVERSION_DIGITS, false);
                    for(int i = 0; i < BINARY_CONVERSION_DIGITS; i++){
                        int unitId = units[i + (p - 1) * BINARY_CONVERSION_DIGITS];
                        selectSingle(unitId);
                        binaryBits[i] = trUnitAlive() == false;
                        trUnitDestroy();
                    }
                    int value = fromBinaryBits(binaryBits);
                    playerScreenRatio[p] = xsIntToFloat(value) / MAGIC_RATIO_FROM_CALCULATION;
                    playerScreenIconSizeCompensationValue[p] = max(1.0, DEFAULT_SCREEN_RATIO / playerScreenRatio[p]);
                }
            }
            postRatioCalculation();
            return false;
        });
        return false;
    });
}

float getLeftAnchorX(float leftPixelBuffer = 0.0, float widthOfElement = 0.0, int p = 0){
        return -0.5 * playerScreenRatio[p] + (leftPixelBuffer + widthOfElement) / 2.0 / VERTICAL_UI_PIXELS;
}

float getRightAnchorX(float rightPixelBuffer = 0.0, float widthOfElement = 0.0, int p = 0){
    return 0.5 * playerScreenRatio[p] - (rightPixelBuffer + widthOfElement) / 2.0 / VERTICAL_UI_PIXELS;
}