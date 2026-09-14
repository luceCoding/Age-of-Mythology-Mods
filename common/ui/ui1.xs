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

float getLeftAnchorX(float leftPixelBuffer = 0.0, float widthOfElement = 0.0, int p = 0){
        return -0.5 * playerScreenRatio[p] + (leftPixelBuffer + widthOfElement) / 2.0 / VERTICAL_UI_PIXELS;
}

float getRightAnchorX(float rightPixelBuffer = 0.0, float widthOfElement = 0.0, int p = 0){
    return 0.5 * playerScreenRatio[p] - (rightPixelBuffer + widthOfElement) / 2.0 / VERTICAL_UI_PIXELS;
}