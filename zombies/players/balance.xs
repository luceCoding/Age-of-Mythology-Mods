void startPassiveIncome(){
    lowFreqScheduler.add(20000, [](int iterations = 1) -> bool {
        for (int p = 1; p <= cNumberPlayers-1; p++){
            if (g_finalTeams[p] == 1){
                trPlayerGrantResources(p, "Wood", woodEvery20Seconds);
                trPlayerGrantResources(p, "Gold", goldEvery20Seconds);
            }
            else {
                trPlayerGrantResources(p, "Wood", woodEvery20Seconds);
                trPlayerGrantResources(p, "Gold", goldEvery20Seconds);
                if ((iterations % 3) == 0){
                    trPlayerGrantResources(p, "Wood", g_dayNumber);
                    trPlayerGrantResources(p, "Gold", g_dayNumber);
                }
            }
        }
        return true;
    });    
}