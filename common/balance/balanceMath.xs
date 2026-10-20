float getSubLinearScale(int largerTeamSize = 1, int smallerTeamSize = 1, float k = 0.7) {
    if (smallerTeamSize <= 0 || largerTeamSize <= 0) {
        return(1.0);
    }
    
    if (smallerTeamSize >= largerTeamSize) {
        return(1.0);
    }
    
    float rawRatio = xsIntToFloat(largerTeamSize) / xsIntToFloat(smallerTeamSize);
    float scaledMultiplier = pow(rawRatio, k);
    
    float maxCap = 5.0;
    if (scaledMultiplier > maxCap) {
        scaledMultiplier = maxCap;
    }
    
    return(scaledMultiplier);
}

float getGenericTeamScale(int myTeamSize = 1, int opposingTeamSize = 1, float k = 0.7, float minFloor = 0.20, float maxCap = 5.00) {
    // 1. Guard clause against invalid input
    if (myTeamSize <= 0 || opposingTeamSize <= 0) {
        return 1.0;
    }

    // 2. Compute opposing-to-self ratio
    float ratio = xsIntToFloat(opposingTeamSize) / xsIntToFloat(myTeamSize);

    // 3. Sub-linear power law scaling
    float scale = pow(ratio, k);

    // 4. Clamps to prevent extreme out-of-bounds values
    if (scale < minFloor) scale = minFloor;
    if (scale > maxCap)   scale = maxCap;

    return scale;
}