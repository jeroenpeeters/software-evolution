module series1::Rank

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

