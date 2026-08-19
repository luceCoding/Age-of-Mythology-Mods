void StringFisherYatesShuffle(ref string[] outStrings){
    for (int i = outStrings.size() - 1; i > 0; i--) {
        int swapIdx = xsRandInt(i + 1);
        string temp = outStrings[i];
        outStrings[i] = outStrings[swapIdx];
        outStrings[swapIdx] = temp;
    }
}

void IntFisherYatesShuffle(ref int[] outInts){
    for (int i = outInts.size() - 1; i > 0; i--) {
        int swapIdx = xsRandInt(i + 1);
        int temp = outInts[i];
        outInts[i] = outInts[swapIdx];
        outInts[swapIdx] = temp;
    }
}

void BoolFisherYatesShuffle(ref bool[] outBools){
    for (int i = outBools.size() - 1; i > 0; i--) {
        int swapIdx = xsRandInt(i + 1);
        bool temp = outBools[i];
        outBools[i] = outBools[swapIdx];
        outBools[swapIdx] = temp;
    }
}

void VectorFisherYatesShuffle(ref vector[] outVector){
    for (int i = outVector.size() - 1; i > 0; i--) {
        int swapIdx = xsRandInt(i + 1);
        vector temp = outVector[i];
        outVector[i] = outVector[swapIdx];
        outVector[swapIdx] = temp;
    }
}