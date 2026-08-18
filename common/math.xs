float abs(float a = 0.0) {
    if (a >= 0.0) {
        return (a);
    }
    return (0.0 - a);
}

float pow(float n = 0.0, int x = 0) {
    if (x == 0) {
        return (1.0);
    }
    
    float r = n;
    int i = 1;
    int limit = x;
    
    if (x < 0) {
        limit = 0 - x;
    }
    
    while (i < limit) {
        r = r * n;
        i = i + 1;
    }
    
    if (x < 0) {
        return (1.0 / r);
    }
    
    return (r);
}

float sqrt(float s = 1.0) {
    if (0.0 > s) {
        s = 0.0 - s; //imaginary fallback
    }
    
    float h = 10.0;
    h = (h + s / h) / 2.0;
    h = (h + s / h) / 2.0;
    h = (h + s / h) / 2.0;
    h = (h + s / h) / 2.0;
    h = (h + s / h) / 2.0;
    h = (h + s / h) / 2.0;
    
    return ((h + s / h) / 2.0);
}

float max(float a = 0.0, float b = 0.0) {
    if (a > b) {
        return (a);
    }
    return (b);
}

float min(float a = 0.0, float b = 0.0) {
    if (a > b) {
        return (b);
    }
    return (a);
}

float normalizeDegrees(float deg = 0.0) {
    while (deg > 180.0) {
        deg = deg - 360.0;
    }
    while (deg < -180.0) {
        deg = deg + 360.0;
    }
    return(deg);
}

float sinDeg(float deg = 0.0) {
    float d = normalizeDegrees(deg);
    float rad = d * 0.0174532925; // Deg to Rad conversion constant (PI / 180)
    
    float r2 = rad * rad;
    float r3 = r2 * rad;
    float r5 = r3 * r2;
    float r7 = r5 * r2;
    float r9 = r7 * r2;

    return(rad - (r3 / 6.0) + (r5 / 120.0) - (r7 / 5040.0) + (r9 / 362880.0));
}

float cosDeg(float deg = 0.0) {
    float d = normalizeDegrees(deg);
    float rad = d * 0.0174532925; // Deg to Rad conversion constant (PI / 180)
    
    float r2 = rad * rad;
    float r4 = r2 * r2;
    float r6 = r4 * r2;
    float r8 = r6 * r2;

    return(1.0 - (r2 / 2.0) + (r4 / 24.0) - (r6 / 720.0) + (r8 / 40320.0));
}

// ==========================================
// PURE MATH ARCTANGENT IMPLEMENTATION
// ==========================================

// Helper: Custom Absolute Value
float customAbs(float val = 0.0) {
    if (val < 0.0) {
        return(0.0 - val);
    }
    return(val);
}

// Core polynomial approximation for atan(x) on range [0, 1] (returns Radians)
float customAtanBase(float x = 0.0) {
    float x2 = x * x;
    return(x * (0.999215 + x2 * (-0.321182 + x2 * (0.146273 - 0.038993 * x2))));
}

// Single-variable Arctangent (accepts x, returns -90.0 to 90.0 degrees)
float atanDeg(float x = 0.0) {
    float absX = customAbs(x);
    float rad = 0.0;
    
    if (absX <= 1.0) {
        rad = customAtanBase(absX);
    } else {
        // Identity: atan(x) = PI/2 - atan(1/x)
        rad = 1.5707963267 - customAtanBase(1.0 / absX);
    }

    if (x < 0.0) {
        rad = 0.0 - rad;
    }

    return(rad * 57.2957795); // Rad to Deg
}

// 2-Argument Arctangent (accepts y, x, returns -180.0 to 180.0 degrees)
float atan2Deg(float y = 0.0, float x = 0.0) {
    if (x == 0.0 && y == 0.0) {
        return(0.0);
    }

    float absY = customAbs(y);
    float absX = customAbs(x);
    float rad = 0.0;

    // First quadrant base angle calculation
    if (absY <= absX) {
        rad = customAtanBase(absY / absX);
    } else {
        rad = 1.5707963267 - customAtanBase(absX / absY);
    }

    // Convert to degrees
    float deg = rad * 57.2957795;

    // Quadrant adjustments
    if (x < 0.0) {
        deg = 180.0 - deg;
    }
    if (y < 0.0) {
        deg = 0.0 - deg;
    }

    return(deg);
}