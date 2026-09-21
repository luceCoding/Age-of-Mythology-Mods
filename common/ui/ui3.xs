bool uiSystemDebug = false;
vector[] uiSystemLookAtArray = default;
vector[] uiSystemLookAtForCameraArray = default;
vector[] uiSystemCameraPositionArray = default;
float[] uiSystemLookAtDistanceArray = default;
float[] uiSystemLookAtHeadingArray = default;
float[] uiSystemLookAtTiltArray = default;
float[] uiSystemLookAtFovArray = default;
vector[] uiSystemXAxisDirectionArray = default;
vector[] uiSystemYAxisDirectionArray = default;
bool[] uiSystemActiveArray = default;
bool[] uiSystemDisableClickArray = default;
bool[] uiSystemDeletableFlagsToRevertArray = default;
bool[] uiSystemSelectableFlagsToRevertArray = default;
int[] uiSystemAvailableIdArray = default;
int uiSystemNextId = 0;
int uiSystemCacheSize = 0;
vector[] uiSystemPositionCacheArray = default;
string[] uiSystemContentCacheArray = default;
int[] uiSystemIdCacheArray = default;
bool[] uiSystemCacheUsedArray = default;
vector[] uiSystemPositionWorkingCacheArray = default;
string[] uiSystemContentWorkingCacheArray = default;
int[] uiSystemIdWorkingCacheArray = default;
bool[] uiSystemIdWorkingCacheMissArray = default;
int[] uiSystemRelicTechArray = default;
int[] uiSystemClickedIndexArray = default;
int[] uiSystemThrottleClickArray = default;

void _uiSystemApplyCameraPosition(int p = 1)
{
    if (trCurrentPlayer() == p)
    {
        cameraTrack.create(uiSystemLookAtForCameraArray[p], uiSystemLookAtDistanceArray[p], uiSystemLookAtHeadingArray[p], uiSystemLookAtTiltArray[p], uiSystemLookAtFovArray[p]);
        cameraTrack.addWaypoint(1000000000, uiSystemLookAtForCameraArray[p], uiSystemLookAtDistanceArray[p], uiSystemLookAtHeadingArray[p], uiSystemLookAtTiltArray[p], uiSystemLookAtFovArray[p]);
        cameraTrack.play();
    }
}

void setUiSystemCameraPosition(int p = 1, vector dest = cOriginVector, float distance = 0.0, float heading = 0.0, float tilt = 0.0, float fov = 40.0)
{
    uiSystemLookAtForCameraArray[p] = dest;
    uiSystemLookAtDistanceArray[p] = distance;
    uiSystemLookAtHeadingArray[p] = heading;
    uiSystemLookAtTiltArray[p] = tilt;
    uiSystemLookAtFovArray[p] = fov;

    float cameraH = degToRad(heading);
    float cameraT = degToRad(tilt);
    float cameraSinH = sin(cameraH);
    float cameraCosH = cos(cameraH);
    float cameraSinT = sin(cameraT);
    float cameraCosT = cos(cameraT);

    float cameraPosX = 0.0 + dest.x - cameraCosH * cameraCosT * distance;
    float cameraPosY = cameraSinT * distance + dest.y;
    float cameraPosZ = 0.0 + dest.z - cameraSinH * cameraCosT * distance;
    uiSystemCameraPositionArray[p] = vector(cameraPosX, cameraPosY, cameraPosZ);

    float canvasDistance = (tan(degToRad(0.5)) * UI_SYSTEM_LOOK_DISTANCE) / tan(degToRad(0.5 * fov));
    float canvasDistanceFromLookPoint = -canvasDistance + distance;
    float canvasPosX = 0.0 + dest.x - cameraCosH * cameraCosT * canvasDistanceFromLookPoint;
    float canvasPosY = cameraSinT * canvasDistanceFromLookPoint + dest.y;
    float canvasPosZ = 0.0 + dest.z - cameraSinH * cameraCosT * canvasDistanceFromLookPoint;
    uiSystemLookAtArray[p] = vector(canvasPosX, canvasPosY, canvasPosZ);
    uiSystemXAxisDirectionArray[p] = vector(cameraSinH, 0.0, -cameraCosH);
    uiSystemYAxisDirectionArray[p] = vector(cameraSinT * cameraCosH, cameraCosT, cameraSinT * cameraSinH);

    if (uiSystemActiveArray[p])
    {
        _uiSystemApplyCameraPosition(p);
    }
}

void enterUiSystem(int p = 1, bool disableClick = false)
{
    uiSystemDisableClickArray[p] = disableClick;
    if (uiSystemActiveArray[p] == false)
    {
        uiSystemActiveArray[p] = true;
        int deleteableOffset = p * cNumberProtoUnits;
        for (int i = 0; i < cNumberProtoUnits; i++)
        {
            bool deleteable = kbPlayerGetProtoStatFlag(p, i, cProtoUnitFlagDeleteable);
            uiSystemDeletableFlagsToRevertArray[deleteableOffset + i] = deleteable;
            if (deleteable)
            {
                trProtoUnitSetFlag(p, kbProtoUnitGetName(i), "Deleteable", false);
            }
        }

        if (trCurrentPlayer() == p)
        {
            int offset = 0;
            for (int q = 0; q <= cNumberPlayers; q++)
            {
                for (int i = 0; i < cNumberProtoUnits; i++)
                {
                    bool selectable = kbPlayerGetProtoStatFlag(q, i, cProtoUnitFlagSelectable);
                    uiSystemSelectableFlagsToRevertArray[i + offset] = selectable;
                    if (selectable)
                    {
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

        vector lookAt = uiSystemLookAtArray[p];
        int tempToSelect = trUnitCreateForced(UI_SYSTEM_UNIT, lookAt.x, lookAt.y, lookAt.z, 0, p);
        selectSingle(tempToSelect);
        if (trCurrentPlayer() == p)
        {
            trUnitGameSelect(true);
        }
        trUnitDestroy();
        _uiSystemApplyCameraPosition(p);
    }

    int unitCount = uiEntryUnitArraySize(p);
    for (int i = 0; i < unitCount; i++)
    {
        selectSingle(uiEntryUnitArrayGet(p, i));
        trUnitDestroy();
    }

    uiEntryOnTopOfArrayClear(p);
    uiEntryXArrayClear(p);
    uiEntryYArrayClear(p);
    uiEntryWidthArrayClear(p);
    uiEntryHeightArrayClear(p);
    uiEntryContentArrayClear(p);
    uiEntryRolloverNameArrayClear(p);
    uiEntryRolloverDescriptionArrayClear(p);
    uiEntryUnitArrayClear(p);
    uiEntryUnitDataIndexArrayClear(p);
    uiEntryRolloverDataIndexArrayClear(p);
    uiEntryClickableDataIndexArrayClear(p);
    uiEntryClickableHandlerArrayClear(p);
    uiEntryUnitDataIndexInClickableArrayClear(p);
    uiEntryOuterIndexInClickableArrayClear(p);
    uiEntryDynamicDataIndexArrayClear(p);
    uiEntryDynamicGetContentWrapperArrayClear(p);
    uiEntryLastTimeArrayClear(p);
    uiEntryFrequencyArrayClear(p);
    uiEntryOuterIndexInDynamicArrayClear(p);
}

int _uiSystemGetAvailableId()
{
    int size = uiSystemAvailableIdArray.size();
    if (size > 0)
    {
        int id = uiSystemAvailableIdArray[size - 1];
        uiSystemAvailableIdArray.removeIndex(size - 1);
        return id;
    }

    int id = uiSystemNextId;
    uiSystemNextId++;
    return id;
}

void postEnterUiSystem(int p = 1, int swapOutTime = 1)
{
    Parameters parameters = createParameters();
    parameters.ints.add(p);

    if (p == trCurrentPlayer())
    {
        int count = uiEntryXArraySize(p);
        if (count > uiSystemPositionWorkingCacheArray.size())
        {
            uiSystemPositionWorkingCacheArray.resize(count, cOriginVector);
            uiSystemContentWorkingCacheArray.resize(count, "");
            uiSystemIdWorkingCacheArray.resize(count, -1);
            uiSystemIdWorkingCacheMissArray.resize(count, false);
        }

        for (int i = 0; i < count; i++)
        {
            vector promptLocation = uiSystemLookAtArray[p] + uiSystemXAxisDirectionArray[p] * uiEntryXArrayGet(p, i) + uiSystemYAxisDirectionArray[p] * uiEntryYArrayGet(p, i);
            vector directionVector = xsVectorNormalize(promptLocation - uiSystemCameraPositionArray[p]);
            vector finalLocation = uiSystemLookAtArray[p] + directionVector * 100000000.0;
            string content = uiEntryContentArrayGet(p, i);
            int id = -1;
            int onTopOfId = uiEntryOnTopOfArrayGet(p, i);

            if (onTopOfId < 0 || uiSystemIdWorkingCacheMissArray[onTopOfId] == false)
            {
                for (int j = 0; j < uiSystemCacheSize; j++)
                {
                    if (uiSystemCacheUsedArray[j] == false && uiSystemPositionCacheArray[j] == finalLocation && uiSystemContentCacheArray[j] == content)
                    {
                        uiSystemCacheUsedArray[j] = true;
                        id = uiSystemIdCacheArray[j];
                        break;
                    }
                }
            }

            if (id < 0)
            {
                id = _uiSystemGetAvailableId();
                if (content != "")
                {
                    trWorldSpacePromptArea("UiSystem" + id, finalLocation, "<icon=(1,10000)(0)>\n" + content, cOriginVector, false);
                }
                uiSystemIdWorkingCacheMissArray[i] = true;
            }
            else
            {
                uiSystemIdWorkingCacheMissArray[i] = false;
            }

            uiSystemPositionWorkingCacheArray[i] = finalLocation;
            uiSystemContentWorkingCacheArray[i] = content;
            uiSystemIdWorkingCacheArray[i] = id;
        }

        for (int i = uiSystemCacheSize - 1; i >= 0; i--)
        {
            if (uiSystemCacheUsedArray[i] == false)
            {
                if (swapOutTime > 0)
                {
                    parameters.ints.add(uiSystemIdCacheArray[i]);
                }
                else
                {
                    int id = uiSystemIdCacheArray[i];
                    trWorldSpacePromptHide("UiSystem" + id);
                    uiSystemAvailableIdArray.add(id);
                }
            }
        }

        if (count > uiSystemPositionCacheArray.size())
        {
            uiSystemPositionCacheArray.resize(count, cOriginVector);
            uiSystemContentCacheArray.resize(count, "");
            uiSystemIdCacheArray.resize(count, -1);
            uiSystemCacheUsedArray.resize(count, false);
        }

        uiSystemCacheSize = count;
        for (int i = 0; i < count; i++)
        {
            uiSystemPositionCacheArray[i] = uiSystemPositionWorkingCacheArray[i];
            uiSystemContentCacheArray[i] = uiSystemContentWorkingCacheArray[i];
            uiSystemIdCacheArray[i] = uiSystemIdWorkingCacheArray[i];
            uiSystemCacheUsedArray[i] = false;
        }
    }

    if (swapOutTime > 0)
    {
        highFreqSchedulerWithParameters.add(swapOutTime, parameters, [](int iteration = 1, ref Parameters parameters) -> bool
        {
            if (parameters.ints[0] == trCurrentPlayer())
            {
                int intParamCount = parameters.ints.size();
                for (int i = 1; i < intParamCount; i++)
                {
                    int id = parameters.ints[i];
                    trWorldSpacePromptHide("UiSystem" + id);
                    uiSystemAvailableIdArray.add(id);
                }
            }
            return false;
        });
    }
}

void exitUiSystem(int p = 1, bool normaliseCamera = false, float fov = 40.0)
{
    if (uiSystemActiveArray[p])
    {
        uiSystemActiveArray[p] = false;
        vector lookAt = uiSystemLookAtArray[p];
        int tempToSelect = trUnitCreateForced(UI_SYSTEM_UNIT, lookAt.x, lookAt.y, lookAt.z, 0, p);
        selectSingle(tempToSelect);
        if (trCurrentPlayer() == p)
        {
            trUnitGameSelect(true);
        }
        trUnitDestroy();

        int deleteableOffset = p * cNumberProtoUnits;
        for (int i = 0; i < cNumberProtoUnits; i++)
        {
            bool deleteable = uiSystemDeletableFlagsToRevertArray[deleteableOffset + i];
            if (deleteable)
            {
                trProtoUnitSetFlag(p, kbProtoUnitGetName(i), "Deleteable", true);
            }
        }

        if (trCurrentPlayer() == p)
        {
            int offset = 0;
            for (int q = 0; q <= cNumberPlayers; q++)
            {
                for (int i = 0; i < cNumberProtoUnits; i++)
                {
                    bool selectable = uiSystemSelectableFlagsToRevertArray[i + offset];
                    if (selectable)
                    {
                        trProtoUnitSetFlag(q, kbProtoUnitGetName(i), "Selectable", true);
                    }
                }
                offset = offset + cNumberProtoUnits;
            }
        }

        if (trCurrentPlayer() == p)
        {
            if (normaliseCamera)
            {
                cameraTrack.create(uiSystemLookAtForCameraArray[p], uiSystemLookAtDistanceArray[p], uiSystemLookAtHeadingArray[p], uiSystemLookAtTiltArray[p], uiSystemLookAtFovArray[p]);
                cameraTrack.addWaypoint(1, uiSystemLookAtForCameraArray[p], uiSystemLookAtDistanceArray[p], uiSystemLookAtHeadingArray[p], uiSystemLookAtTiltArray[p], uiSystemLookAtFovArray[p]);
                cameraTrack.play(true, 0);
            }

            for (int i = uiSystemCacheSize - 1; i >= 0; i--)
            {
                int id = uiSystemIdCacheArray[i];
                trWorldSpacePromptHide("UiSystem" + id);
                uiSystemAvailableIdArray.add(id);
            }
            uiSystemCacheSize = 0;
        }

        int unitCount = uiEntryUnitArraySize(p);
        for (int i = 0; i < unitCount; i++)
        {
            selectSingle(uiEntryUnitArrayGet(p, i));
            trUnitDestroy();
        }
    }
}

void _uiSystemRefreshUiUnit(int p = 1, int index = 0)
{
    int unitDataIndex = uiEntryUnitDataIndexArrayGet(p, index);
    int rolloverDataIndex = uiEntryRolloverDataIndexArrayGet(p, index);
    int clickableDataIndex = uiEntryClickableDataIndexArrayGet(p, index);
    selectSingle(uiEntryUnitArrayGet(p, unitDataIndex));
    trUnitDestroy();

    bool hoverable = rolloverDataIndex >= 0;
    string unitType = hoverable ? UI_SYSTEM_UNIT2 : UI_SYSTEM_UNIT;
    vector lookAt = uiSystemLookAtArray[p];
    float width = uiEntryWidthArrayGet(p, unitDataIndex);
    float height = uiEntryHeightArrayGet(p, unitDataIndex);
    vector pos = lookAt + uiSystemXAxisDirectionArray[p] * uiEntryXArrayGet(p, index) + uiSystemYAxisDirectionArray[p] * (uiEntryYArrayGet(p, index) + height / 2.0);
    int unit = trUnitCreateForced(unitType, pos.x, pos.y, pos.z, 0, p);
    selectSingle(unit);

    if (!uiSystemDebug)
    {
        trUnitChangeProtoUnit(unitType, false, true);
        trUnitSetShading(cShaderBurning, 1000.0);
    }

    if (hoverable)
    {
        trUnitSetScale(UI_SYSTEM_SMALL_SCALE_MULTIPLIER * height, 0.004, UI_SYSTEM_SMALL_SCALE_MULTIPLIER * width);
    }
    else
    {
        trUnitSetScale(height, 0.004, width);
    }

    trUnitRotateZ(uiSystemLookAtTiltArray[p] - 90, true);
    trUnitRotateY(-uiSystemLookAtHeadingArray[p] - 180, true);

    if (clickableDataIndex < 0 || uiSystemDisableClickArray[p])
    {
        trUnitSetFlag(cUnitFlagIsUnbuilding, true);
    }

    if (hoverable)
    {
        trRelicForce(unit, kbTechGetName(uiSystemRelicTechArray[rolloverDataIndex]));
    }

    uiEntryUnitArraySet(p, unitDataIndex, unit);
}

void _uiSystemRefreshUiTech(int p = 1, int index = 0)
{
    int rolloverDataIndex = uiEntryRolloverDataIndexArrayGet(p, index);
    int relicTech = uiSystemRelicTechArray[rolloverDataIndex];
    trTechHideEffects(relicTech, p, true);
    trTechSetStringID(relicTech, p, uiEntryRolloverNameArrayGet(p, rolloverDataIndex) + "<color=0,0,0>", cXSTechEffectDisplayName);
    trTechSetStringID(relicTech, p, "</color>\n" + uiEntryRolloverDescriptionArrayGet(p, rolloverDataIndex), cXSTechEffectRollover);
}

void _uiSystemAddDisplay(int p = 1, float x = 0.0, float y = 0.0, string content = "", int onTopOf = -1)
{
    uiEntryOnTopOfArrayAdd(p, onTopOf);
    uiEntryXArrayAdd(p, x);
    uiEntryYArrayAdd(p, y);
    uiEntryContentArrayAdd(p, content);
}

void _uiSystemAddUnit(int p = 1, float width = 0.0, float height = 0.0)
{
    uiEntryUnitDataIndexArrayAdd(p, uiEntryUnitArraySize(p));
    uiEntryWidthArrayAdd(p, width);
    uiEntryHeightArrayAdd(p, height);
    uiEntryUnitArrayAdd(p, -1);
}

void _uiSystemAddRollover(int p = 1, string rolloverName = "", string rolloverDescription = "")
{
    uiEntryRolloverDataIndexArrayAdd(p, uiEntryRolloverNameArraySize(p));
    uiEntryRolloverNameArrayAdd(p, rolloverName);
    uiEntryRolloverDescriptionArrayAdd(p, rolloverDescription);
}

void _uiSystemAddClickable(int p = 1, ref Parameters parameters, void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {})
{
    int outerIndex = uiEntryClickableDataIndexArrayAdd(p, uiEntryClickableHandlerArraySize(p));
    UiEntryParameterised wrapperHandler;
    wrapperHandler.parameters = parameters;
    wrapperHandler.handler = handler;
    uiEntryClickableHandlerArrayAdd(p, wrapperHandler);

    int unitDataIndex = uiEntryUnitDataIndexArrayGet(p, outerIndex);
    uiEntryUnitDataIndexInClickableArrayAdd(p, unitDataIndex);
    uiEntryOuterIndexInClickableArrayAdd(p, outerIndex);
}

void _uiSystemAddDynamic(int p = 1, int frequency = 0, string(int, ref Parameters) getContent = EMPTY_DYNAMIC_UI_CONTENT, ref Parameters parameters)
{
    int outerIndex = uiEntryDynamicDataIndexArrayAdd(p, uiEntryFrequencyArraySize(p));
    UiEntryStringParameterised getDisplayWrapper;
    getDisplayWrapper.parameters = parameters;
    getDisplayWrapper.getContent = getContent;
    uiEntryDynamicGetContentWrapperArrayAdd(p, getDisplayWrapper);
    uiEntryLastTimeArrayAdd(p, xsGetTimeMS());
    uiEntryFrequencyArrayAdd(p, frequency);
    uiEntryOuterIndexInDynamicArrayAdd(p, outerIndex);
}

int uiSystemAddDisplay(int p = 1, float x = 0.0, float y = 0.0, string content = "", int onTopOf = -1)
{
    int outerIndex = uiEntryXArraySize(p);
    _uiSystemAddDisplay(p, x, y, content, onTopOf);

    uiEntryUnitDataIndexArrayAdd(p, -1);
    uiEntryRolloverDataIndexArrayAdd(p, -1);
    uiEntryClickableDataIndexArrayAdd(p, -1);
    uiEntryDynamicDataIndexArrayAdd(p, -1);
    return outerIndex;
}

int uiSystemAddDisplayWithHover(int p = 1, float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", string rolloverName = "", string rolloverDescription = "", int onTopOf = -1)
{
    int outerIndex = uiEntryXArraySize(p);
    _uiSystemAddDisplay(p, x, y, content, onTopOf);

    _uiSystemAddUnit(p, width, height);
    _uiSystemAddRollover(p, rolloverName, rolloverDescription);
    uiEntryClickableDataIndexArrayAdd(p, -1);
    uiEntryDynamicDataIndexArrayAdd(p, -1);

    _uiSystemRefreshUiTech(p, outerIndex);
    _uiSystemRefreshUiUnit(p, outerIndex);
    return outerIndex;
}

int uiSystemAddClickable(int p = 1, float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "",
    ref Parameters parameters, void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {}, int onTopOf = -1)
{
    int outerIndex = uiEntryXArraySize(p);
    _uiSystemAddDisplay(p, x, y, content, onTopOf);

    _uiSystemAddUnit(p, width, height);
    uiEntryRolloverDataIndexArrayAdd(p, -1);
    _uiSystemAddClickable(p, parameters, handler);
    uiEntryDynamicDataIndexArrayAdd(p, -1);

    _uiSystemRefreshUiUnit(p, outerIndex);
    return outerIndex;
}

int uiSystemAddClickableWithHover(int p = 1, float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", string rolloverName = "", string rolloverDescription = "",
    ref Parameters parameters, void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {}, int onTopOf = -1)
{
    int outerIndex = uiEntryXArraySize(p);
    _uiSystemAddDisplay(p, x, y, content, onTopOf);

    _uiSystemAddUnit(p, width, height);
    _uiSystemAddRollover(p, rolloverName, rolloverDescription);
    _uiSystemAddClickable(p, parameters, handler);
    uiEntryDynamicDataIndexArrayAdd(p, -1);

    _uiSystemRefreshUiTech(p, outerIndex);
    _uiSystemRefreshUiUnit(p, outerIndex);
    return outerIndex;
}

int uiSystemAddDisplayDynamic(int p = 1, float x = 0.0, float y = 0.0, int frequency = 0, string(int, ref Parameters) getContent = EMPTY_DYNAMIC_UI_CONTENT, ref Parameters parameters, int onTopOf = -1)
{
    int outerIndex = uiEntryXArraySize(p);
    string content = (p == trCurrentPlayer()) ? getContent(p, parameters) : "";
    _uiSystemAddDisplay(p, x, y, content, onTopOf);

    uiEntryUnitDataIndexArrayAdd(p, -1);
    uiEntryRolloverDataIndexArrayAdd(p, -1);
    uiEntryClickableDataIndexArrayAdd(p, -1);
    _uiSystemAddDynamic(p, frequency, getContent, parameters);
    return outerIndex;
}

void _processUiSystems()
{
    int currentTime = xsGetTimeMS();
    int currentPlayer = trCurrentPlayer();

    for (int p = 1; p <= cNumberPlayers; p++)
    {
        uiSystemClickedIndexArray[p] = -1;

        if (!uiSystemActiveArray[p]) continue;

        // 1. DYNAMIC TEXT PROMPT UPDATES (Local Player Only)
        if (p == currentPlayer)
        {
            int dynamicCount = uiEntryLastTimeArraySize(p);
            for (int i = 0; i < dynamicCount; i++)
            {
                int frequency = uiEntryFrequencyArrayGet(p, i);
                int lastTime = uiEntryLastTimeArrayGet(p, i);

                if (currentTime - frequency >= lastTime)
                {
                    uiEntryLastTimeArraySet(p, i, currentTime);

                    UiEntryStringParameterised getContentWrapper = uiEntryDynamicGetContentWrapperArrayGet(p, i);
                    Parameters parameters = getContentWrapper.parameters;
                    string(int, ref Parameters) getContent = getContentWrapper.getContent;
                    string newContent = getContent(p, parameters);

                    int outerIndex = uiEntryOuterIndexInDynamicArrayGet(p, i);
                    if (newContent != uiEntryContentArrayGet(p, outerIndex))
                    {
                        uiEntryContentArraySet(p, outerIndex, newContent);
                        uiSystemContentCacheArray[outerIndex] = newContent;

                        if (newContent != "")
                        {
                            trWorldSpacePromptArea("UiSystem" + uiSystemIdCacheArray[outerIndex], 
                                uiSystemPositionWorkingCacheArray[outerIndex],
                                "<icon=(1,10000)(0)>\n" + newContent, 
                                cOriginVector, 
                                false);
                        }
                        else
                        {
                            trWorldSpacePromptHide("UiSystem" + uiSystemIdCacheArray[outerIndex]);
                        }
                    }
                }
            }
        }

        // 2. CLICK DETECTION VIA PROXY UNIT DEATH
        int count = uiEntryUnitDataIndexInClickableArraySize(p);
        if (count > 0)
        {
            if (count != kbUnitTypeCount(UI_SYSTEM_UNIT, p, cUnitStateABQ)) {
                int clickedEntryIndex = -1;
                bool validClick = true;

                for (int i = 0; i < count; i++)
                {
                    int unitDataIndex = uiEntryUnitDataIndexInClickableArrayGet(p, i);
                    int unitId = uiEntryUnitArrayGet(p, unitDataIndex);

                    if (unitId >= 0)
                    {
                        selectSingle(unitId);
                        if (trUnitAlive() == false)
                        {
                            uiSystemThrottleClickArray[p] = 0;
                            if (clickedEntryIndex == -1)
                            {
                                clickedEntryIndex = i;
                            }
                            else
                            {
                                validClick = false;
                            }
                            _uiSystemRefreshUiUnit(p, uiEntryOuterIndexInClickableArrayGet(p, i));
                        }
                    }
                }

                // 3. INLINE CLICK HANDLER DISPATCH
                if (validClick && clickedEntryIndex >= 0)
                {
                    uiSystemClickedIndexArray[p] = clickedEntryIndex;

                    UiEntryParameterised wrapperHandler = uiEntryClickableHandlerArrayGet(p, clickedEntryIndex);
                    Parameters parameters = wrapperHandler.parameters;
                    void(int, ref Parameters) handler = wrapperHandler.handler;
                    handler(p, parameters);
                }
            }
        }

        // 4. AUTO-DELETE CONSOLE COMMAND (Local Player Only)
        if (currentPlayer == p && (trUnitTypeIsSelected(UI_SYSTEM_UNIT, true) || trUnitTypeIsSelected(UI_SYSTEM_UNIT2, true)))
        {
            if (currentTime >= uiSystemThrottleClickArray[p])
            {
                uiSystemThrottleClickArray[p] = currentTime + 500;
                trExecuteConsoleCommand("uiDeleteSelectedUnit(true)");
            }
        }
    }
}

void initialiseUiSystems(bool debug = false)
{
    uiSystemDebug = debug;
    uiSystemLookAtArray.resize(cNumberPlayers + 1, cOriginVector);
    uiSystemLookAtForCameraArray.resize(cNumberPlayers + 1, cOriginVector);
    uiSystemCameraPositionArray.resize(cNumberPlayers + 1, cOriginVector);
    uiSystemLookAtDistanceArray.resize(cNumberPlayers + 1, UI_SYSTEM_LOOK_DISTANCE);
    uiSystemLookAtHeadingArray.resize(cNumberPlayers + 1, 90.0);
    uiSystemLookAtTiltArray.resize(cNumberPlayers + 1, 90.0);
    uiSystemLookAtFovArray.resize(cNumberPlayers + 1, 40.0);
    uiSystemXAxisDirectionArray.resize(cNumberPlayers + 1, vector(1.0, 0.0, 0.0));
    uiSystemYAxisDirectionArray.resize(cNumberPlayers + 1, vector(0.0, 0.0, 1.0));
    uiSystemActiveArray.resize(cNumberPlayers + 1, false);
    uiSystemDisableClickArray.resize(cNumberPlayers + 1, false);
    uiSystemDeletableFlagsToRevertArray.resize((cNumberPlayers + 1) * cNumberProtoUnits, false);
    uiSystemSelectableFlagsToRevertArray.resize((cNumberPlayers + 1) * cNumberProtoUnits, false);
    uiSystemClickedIndexArray.resize(cNumberPlayers + 1, -1);
    uiSystemThrottleClickArray.resize(cNumberPlayers + 1, 0);

    for (int p = 1; p <= cNumberPlayers; p++)
    {
        setUiSystemCameraPosition(p, vector(0.5 * kbGetMapXSize(), -10100.0, 0.5 * kbGetMapZSize()), 100.0, 45.0, 89.0, 40.0);
    }

    for (int i = 0; i < cNumberTechs; i++)
    {
        string tech = kbTechGetName(i);
        if (xsStringStartsWith(tech, "Relic", true) && xsStringEndsWith(tech, "Respawn", true) == false)
        {
            uiSystemRelicTechArray.add(i);
        }
    }

    string[] systemUnits = string2Array(UI_SYSTEM_UNIT, UI_SYSTEM_UNIT2);
    for (int p = 1; p <= cNumberPlayers; p++)
    {
        for (int _forEach0 = 0; _forEach0 < systemUnits.size(); _forEach0++)
        {
            string systemUnit = systemUnits[_forEach0];
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

            if (systemUnit == UI_SYSTEM_UNIT){
                trProtoUnitSetFlag(p, systemUnit, "NotKBTracked", false);
                trProtoUnitSetFlag(p, systemUnit, "KBTracked", true);
                trProtoUnitSetFlag(p, systemUnit, "StartOnNoUpdate", false);
            }

            if (p != trCurrentPlayer())
            {
                trProtoUnitSetFlag(p, systemUnit, "OnlyInEditor", true);
            }

            trModifyProtounitData(systemUnit, p, cXSProtoEffectBuildPoints, 100000, cXSRelativityAssign);
            trModifyProtounitData(systemUnit, p, cXSProtoEffectLOS, debug ? 5.0 : 0.0, cXSRelativityAssign);
        }

        trProtoUnitSetFlag(p, UI_SYSTEM_UNIT2, "Relic", true);
    }

    highFreqScheduler.add(25, [](int iteration = 0) -> bool
    {
        _processUiSystems();
        return true;
    });
}

// UI helper methods

string displayCompensatedIcon(int width = 1, int height = 1, string icon = "0")
{
    float compensationValue = playerScreenIconSizeCompensationValue[trCurrentPlayer()];
    int correctedWidth = round(compensationValue * width);
    int correctedHeight = round(compensationValue * height);
    return "<icon=(" + correctedWidth + "," + correctedHeight + ")(" + icon + ")>";
}

string minimapSafeSuffix(float posY = 0.0)
{
    return "\n" + displayCompensatedIcon(1, xsFloatToInt(round((posY + 0.5) * VERTICAL_UI_PIXELS)));
}

int minimapSafeDisplay(int p = 1, float x = 0.0, float y = 0.0, string content = "", int onTopOf = -1)
{
    return uiSystemAddDisplay(p, x, -0.5, content + minimapSafeSuffix(y), onTopOf);
}

int minimapSafeDisplayWithHover(int p = 1, float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", string rolloverName = "", string rolloverDescription = "", int onTopOf = -1)
{
    uiSystemAddDisplayWithHover(p, x, y, width, height, "", rolloverName, rolloverDescription);
    return minimapSafeDisplay(p, x, y, content, onTopOf);
}

int minimapSafeClickable(int p = 1, float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", ref Parameters parameters,
    void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {}, int onTopOf = -1)
{
    uiSystemAddClickable(p, x, y, width, height, "", parameters, handler);
    return minimapSafeDisplay(p, x, y, content, onTopOf);
}

int minimapSafeClickableWithHover(int p = 1, float x = 0.0, float y = 0.0, float width = 0.0, float height = 0.0, string content = "", string rolloverName = "", string rolloverDescription = "", ref Parameters parameters,
    void(int, ref Parameters) handler = [](int pToUse = 1, ref Parameters parametersToUse) -> void {}, int onTopOf = -1)
{
    uiSystemAddClickableWithHover(p, x, y, width, height, "", rolloverName, rolloverDescription, parameters, handler);
    return minimapSafeDisplay(p, x, y, content, onTopOf);
}
