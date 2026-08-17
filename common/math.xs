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