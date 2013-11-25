module series1::Rank

import List;
import IO;
import util::Math;

data Rank = pp() | p() | n() | m() | mm();

public Rank rankSloc(int count){
    kloc = count/1000;
    if(kloc < 66){
        return pp();
    } else if(kloc >= 66 && kloc < 246){
        return p();
    } else if(kloc >= 246 && kloc < 665){
        return n();
    } else if(kloc >= 665 && kloc < 1310){
        return m();
    } else {
        return mm();
    }
}

public Rank rankDuplication(real prcnt){
	if(prcnt < 3.0){
		return pp();
	} else if(prcnt >= 3.0 && prcnt < 5.0){
		return p();
	} else if(prcnt >= 5.0 && prcnt < 10.0){
		return n();
	} else if(prcnt >= 10.0 && prcnt < 20.0){
		return m();
	} else {
		return mm();
	}
}

public Rank rankComplexity(lrel[int, str, loc] cclist, lrel[int, str, loc] unitsizeList){
	int linespp = 0;
	int linesp = 0;
	int linesm = 0;
	int linesn = 0;
	
	for(<cc,u,_> <- cclist){
		Rank rank;
		if(cc <= 10){
			rank = pp();
		} else if(cc > 10 && cc <= 20){
			rank = p();
		} else if(cc > 20 && cc <= 50){
			rank = m();
		} else {
			rank = n();
		}
		
		if(<size, u, _> <- unitsizeList){
			switch(rank){
				case pp(): linespp += size;
				case p(): linesp += size;
				case m(): linesm += size;
				case n(): linesn += size;
			}
		}
	}
	
	int total = linespp + linesp + linesm + linesn;
	return mapToRank(toReal(linesp) / total, toReal(linesm) / total, toReal(linesn) / total);
}

public Rank rankUnitSize(lrel[int, str, loc] unitsizeList){
	int linespp = 0;
	int linesp = 0;
	int linesm = 0;
	int linesn = 0;
	
	for(<size,_,_> <- unitsizeList){
		Rank rank;
		if(size <= 10){
			rank = pp();
		} else if(size > 10 && size <= 50){
			rank = p();
		} else if(size > 50 && size <= 100){
			rank = n();
		} else {
			rank = m();
		}
		
		switch(rank){
			case pp(): linespp += size;
			case p(): linesp += size;
			case m(): linesm += size;
			case n(): linesn += size;
		}
	}
	
	int total = linespp + linesp + linesm + linesn;			
	return mapToRank(toReal(linesp) / total, toReal(linesm) / total, toReal(linesn) / total);
}

private Rank mapToRank(real prcnt_moderate, real prcnt_high, real prcnt_vhigh){
	if(prcnt_moderate <= 0.25 && prcnt_high == 0.0 && prcnt_vhigh == 0.0){
		return pp();
	} else if(prcnt_moderate <= 0.30 && prcnt_high <= 0.05 && prcnt_vhigh == 0.0){
		return p();
	} else if(prcnt_moderate <= 0.40 && prcnt_high <= 0.10 && prcnt_vhigh == 0.0){
		return n();
	} else if(prcnt_moderate <= 0.50 && prcnt_high <= 0.15 && prcnt_vhigh <= 0.05){
		return m();
	}else {
		return mm();
	}
}